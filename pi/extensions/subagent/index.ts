/**
 * Subagent Extension
 *
 * 通用 subagent 工具，通过 spawn 独立 pi 子进程委派任务。
 * 支持三种模式：单任务、并行、链式。
 * prompt 来源灵活：内联文本或文件路径。
 */

import type {
	ExtensionAPI,
	ExtensionContext,
	Theme,
	ThemeColor,
} from "@mariozechner/pi-coding-agent";
import { getMarkdownTheme } from "@mariozechner/pi-coding-agent";
import { Container, Markdown, Spacer, Text } from "@mariozechner/pi-tui";
import { Type } from "@sinclair/typebox";
import {
	type TaskInput,
	type SingleResult,
	type SubagentDetails,
	type OnUpdateCallback,
	type DisplayItem,
	MAX_PARALLEL_TASKS,
	MAX_CONCURRENCY,
	COLLAPSED_ITEM_COUNT,
	runSingleTask,
	getFinalOutput,
	getDisplayItems,
	formatUsageStats,
	formatToolCall,
	aggregateUsage,
	shortenPath,
	mapWithConcurrencyLimit,
	emptyUsage,
} from "./core.js";

// --- Schema ---

const SingleTaskSchema = Type.Object({
	prompt: Type.Optional(
		Type.String({ description: "Inline system prompt text" }),
	),
	promptFile: Type.Optional(
		Type.String({ description: "Path to system prompt file" }),
	),
	task: Type.String({ description: "Task to delegate" }),
	model: Type.Optional(
		Type.String({
			description: "Model (provider/id), defaults to current session model",
		}),
	),
});

const SubagentParams = Type.Object({
	// Single 模式
	prompt: Type.Optional(
		Type.String({ description: "Inline system prompt text" }),
	),
	promptFile: Type.Optional(
		Type.String({ description: "Path to system prompt file" }),
	),
	task: Type.Optional(Type.String({ description: "Task to delegate" })),
	model: Type.Optional(
		Type.String({
			description: "Model (provider/id), defaults to current session model",
		}),
	),

	// Parallel 模式
	tasks: Type.Optional(
		Type.Array(SingleTaskSchema, {
			description: "Array of tasks for parallel execution",
		}),
	),

	// Chain 模式
	chain: Type.Optional(
		Type.Array(SingleTaskSchema, {
			description:
				"Array of tasks for sequential execution, {previous} placeholder for prior output",
		}),
	),
});

interface SubagentInput {
	prompt?: string;
	promptFile?: string;
	task?: string;
	model?: string;
	tasks?: TaskInput[];
	chain?: TaskInput[];
}

// --- 渲染辅助 ---

function renderDisplayItems(
	items: DisplayItem[],
	theme: Theme,
	limit?: number,
): string {
	const toShow = limit ? items.slice(-limit) : items;
	const skipped = limit && items.length > limit ? items.length - limit : 0;
	let text = "";
	if (skipped > 0) text += theme.fg("muted", `... ${skipped} earlier items\n`);
	for (const item of toShow) {
		if (item.type === "text") {
			const preview = item.text?.split("\n").slice(0, 3).join("\n") || "";
			text += `${theme.fg("toolOutput" as ThemeColor, preview)}\n`;
		} else if (item.name && item.args) {
			text += `${theme.fg("muted", "\u2192 ") + formatToolCall(item.name, item.args, (c, t) => theme.fg(c as ThemeColor, t))}\n`;
		}
	}
	return text.trimEnd();
}

/** 获取当前 session 的模型标识 */
function getSessionModel(ctx: ExtensionContext): string | undefined {
	const m = ctx.model;
	if (!m) return undefined;
	return `${m.provider}/${m.id}`;
}

/** 构建可用模型列表文本 */
function buildModelList(pi: ExtensionAPI): string {
	try {
		// 通过 session_start 事件获取的 ctx 拿 modelRegistry
		// 这里在注册时还没有 ctx，所以延迟到 promptGuidelines 回调不行
		// 先用空值，在 session_start 时更新
		return "";
	} catch {
		return "";
	}
}

export default function (pi: ExtensionAPI) {
	let modelListText = "";

	// 在 session start 时获取可用模型列表
	pi.on("session_start", async (_event, ctx) => {
		try {
			const models = ctx.modelRegistry.getAvailable();
			const lines = models.map(
				(m) => `  - ${m.provider}/${m.id}`,
			);
			modelListText = lines.join("\n");
		} catch {
			modelListText = "";
		}
	});

	pi.registerTool({
		name: "subagent",
		label: "Subagent",
		description: [
			"Delegate tasks to subagents with isolated context.",
			"Modes: single (task), parallel (tasks array), chain (sequential with {previous} placeholder).",
			"Prompt source: inline text (prompt) or file path (promptFile), mutually exclusive.",
			"Model defaults to current session model if not specified.",
		].join(" "),
		promptSnippet:
			"Delegate tasks to subagents with isolated context (single/parallel/chain modes)",
		promptGuidelines: [
			"subagent spawns an isolated pi subprocess. Use prompt for inline system prompt or promptFile for a file path. "
			+ "Defaults to current session model. Pass model with provider/id format to override. "
			+ "Use subagent for tasks that benefit from isolated context: implementation, code review, parallel investigation.",
		],
		parameters: SubagentParams,

		async execute(_toolCallId, params, signal, onUpdate, ctx) {
			const p = params as unknown as SubagentInput;
			const defaultModel = getSessionModel(ctx);
			const cwd = ctx.cwd;

			const hasChain = (p.chain?.length ?? 0) > 0;
			const hasTasks = (p.tasks?.length ?? 0) > 0;
			const hasSingle = Boolean(p.task);
			const modeCount =
				Number(hasChain) + Number(hasTasks) + Number(hasSingle);

			const makeDetails =
				(mode: "single" | "parallel" | "chain") =>
				(results: SingleResult[]): SubagentDetails => ({
					mode,
					results,
				});

			if (modeCount !== 1) {
				const modelsInfo = modelListText
					? `\n\nAvailable models:\n${modelListText}`
					: "";
				return {
					content: [
						{
							type: "text",
							text: `Invalid parameters. Provide exactly one of: task (single), tasks (parallel), or chain.${modelsInfo}`,
						},
					],
					details: makeDetails("single")([]),
				};
			}

			// --- Chain 模式 ---
			if (p.chain && p.chain.length > 0) {
				const results: SingleResult[] = [];
				let previousOutput = "";

				for (let i = 0; i < p.chain.length; i++) {
					const step = p.chain[i];
					const taskWithContext = step.task.replace(
						/\{previous\}/g,
						previousOutput,
					);

					const chainUpdate: OnUpdateCallback | undefined = onUpdate
						? (partial) => {
								const currentResult = partial.details?.results[0];
								if (currentResult) {
									onUpdate({
										content: partial.content as any,
										details: makeDetails("chain")([
											...results,
											currentResult,
										]),
									});
								}
							}
						: undefined;

					const result = await runSingleTask(
						cwd,
						{ ...step, task: taskWithContext },
						defaultModel,
						i + 1,
						signal,
						chainUpdate,
						makeDetails("chain"),
					);
					results.push(result);

					const isError =
						result.exitCode !== 0 ||
						result.stopReason === "error" ||
						result.stopReason === "aborted";
					if (isError) {
						const errorMsg =
							result.errorMessage ||
							result.stderr ||
							getFinalOutput(result.messages) ||
							"(no output)";
						return {
							content: [
								{
									type: "text",
									text: `Chain stopped at step ${i + 1}: ${errorMsg}`,
								},
							],
							details: makeDetails("chain")(results),
							isError: true,
						};
					}
					previousOutput = getFinalOutput(result.messages);
				}
				return {
					content: [
						{
							type: "text",
							text:
								getFinalOutput(
									results[results.length - 1].messages,
								) || "(no output)",
						},
					],
					details: makeDetails("chain")(results),
				};
			}

			// --- Parallel 模式 ---
			if (p.tasks && p.tasks.length > 0) {
				if (p.tasks.length > MAX_PARALLEL_TASKS) {
					return {
						content: [
							{
								type: "text",
								text: `Too many parallel tasks (${p.tasks.length}). Max is ${MAX_PARALLEL_TASKS}.`,
							},
						],
						details: makeDetails("parallel")([]),
					};
				}

				const allResults: SingleResult[] = new Array(p.tasks.length);
				for (let i = 0; i < p.tasks.length; i++) {
					allResults[i] = {
						promptSource: p.tasks[i].promptFile
							? shortenPath(p.tasks[i].promptFile!)
							: p.tasks[i].prompt
								? "(inline)"
								: "(none)",
						task: p.tasks[i].task,
						exitCode: -1,
						messages: [],
						stderr: "",
						usage: emptyUsage(),
					};
				}

				const emitParallelUpdate = () => {
					if (onUpdate) {
						const running = allResults.filter(
							(r) => r.exitCode === -1,
						).length;
						const done = allResults.filter(
							(r) => r.exitCode !== -1,
						).length;
						onUpdate({
							content: [
								{
									type: "text",
									text: `Parallel: ${done}/${allResults.length} done, ${running} running...`,
								},
							],
							details: makeDetails("parallel")([...allResults]),
						});
					}
				};

				const results = await mapWithConcurrencyLimit(
					p.tasks,
					MAX_CONCURRENCY,
					async (t, index) => {
						const result = await runSingleTask(
							cwd,
							t,
							defaultModel,
							undefined,
							signal,
							(partial) => {
								if (partial.details?.results[0]) {
									allResults[index] = partial.details.results[0];
									emitParallelUpdate();
								}
							},
							makeDetails("parallel"),
						);
						allResults[index] = result;
						emitParallelUpdate();
						return result;
					},
				);

				const successCount = results.filter(
					(r) => r.exitCode === 0,
				).length;
				const summaries = results.map((r) => {
					const output = getFinalOutput(r.messages);
					const preview =
						output.slice(0, 100) +
						(output.length > 100 ? "..." : "");
					return `[${r.promptSource}] ${r.exitCode === 0 ? "completed" : "failed"}: ${preview || "(no output)"}`;
				});
				return {
					content: [
						{
							type: "text",
							text: `Parallel: ${successCount}/${results.length} succeeded\n\n${summaries.join("\n\n")}`,
						},
					],
					details: makeDetails("parallel")(results),
				};
			}

			// --- Single 模式 ---
			if (p.task) {
				const result = await runSingleTask(
					cwd,
					{
						prompt: p.prompt,
						promptFile: p.promptFile,
						task: p.task,
						model: p.model,
					},
					defaultModel,
					undefined,
					signal,
					onUpdate
						? (partial) => {
								onUpdate({
									content: partial.content as any,
									details: makeDetails("single")(
										partial.details?.results ?? [],
									),
								});
							}
						: undefined,
					makeDetails("single"),
				);

				const isError =
					result.exitCode !== 0 ||
					result.stopReason === "error" ||
					result.stopReason === "aborted";
				if (isError) {
					const errorMsg =
						result.errorMessage ||
						result.stderr ||
						getFinalOutput(result.messages) ||
						"(no output)";
					return {
						content: [
							{
								type: "text",
								text: `Subagent ${result.stopReason || "failed"}: ${errorMsg}`,
							},
						],
						details: makeDetails("single")([result]),
						isError: true,
					};
				}
				return {
					content: [
						{
							type: "text",
							text:
								getFinalOutput(result.messages) ||
								"(no output)",
						},
					],
					details: makeDetails("single")([result]),
				};
			}

			return {
				content: [
					{
						type: "text",
						text: "Invalid parameters. Provide task, tasks, or chain.",
					},
				],
				details: makeDetails("single")([]),
			};
		},



		// --- TUI 渲染：调用摘要 ---
		renderCall(args: Record<string, unknown>, theme) {
			const a = args as unknown as SubagentInput;

			if (a.chain && a.chain.length > 0) {
				return new Text(
					theme.fg("toolTitle", theme.bold("subagent ")) +
						theme.fg("accent", `chain (${a.chain.length} steps)`),
					0, 0,
				);
			}
			if (a.tasks && a.tasks.length > 0) {
				return new Text(
					theme.fg("toolTitle", theme.bold("subagent ")) +
						theme.fg("accent", `parallel (${a.tasks.length} tasks)`),
					0, 0,
				);
			}
			return new Text(
				theme.fg("toolTitle", theme.bold("subagent")),
				0, 0,
			);
		},

		// --- TUI 渲染：结果展示 ---
		renderResult(
			result: { content: Array<{ type: string; text?: string }>; details?: unknown },
			options: { expanded?: boolean; isPartial?: boolean },
			theme: Theme,
		) {
			const isPartial = options?.isPartial ?? false;
			const details = result.details as SubagentDetails | undefined;
			if (!details || details.results.length === 0) {
				const text = result.content[0];
				return new Text(
					text?.type === "text" ? (text.text ?? "") : "(no output)",
					0, 0,
				);
			}

			const expanded = options?.expanded ?? false;
			const MAX_COLLAPSED_LINES = 2;
			const MAX_OUTPUT_ITEMS = 5;

			const truncate = (text: string, maxLines: number): string => {
				const lines = text.split("\n");
				if (lines.length <= maxLines) return text;
				return lines.slice(0, maxLines).join("\n") + "\n...";
			};

			/** 渲染单个 result 的详情块 */
			const renderSingleBlock = (r: SingleResult, partial: boolean): string => {
				const lines: string[] = [];

				// 标题后空行
				lines.push("");

				// Model 块
				if (r.model) {
					lines.push("  " + theme.fg("mdHeading", "[Model]"));
					lines.push("  " + theme.fg("dim", r.model));
					lines.push("");
				}

				// Prompt 块
				if (r.promptContent) {
					lines.push("  " + theme.fg("mdHeading", "[Prompt]"));
					const promptDisplay = expanded
						? r.promptContent
						: truncate(r.promptContent, MAX_COLLAPSED_LINES);
					for (const l of promptDisplay.split("\n")) {
						lines.push("  " + theme.fg("dim", l));
					}
					lines.push("");
				}

				// Task 块
				lines.push("  " + theme.fg("mdHeading", "[Task]"));
				const taskDisplay = expanded
					? r.task
					: truncate(r.task, MAX_COLLAPSED_LINES);
				for (const l of taskDisplay.split("\n")) {
					lines.push("  " + theme.fg("dim", l));
				}
				lines.push("");

				// Status 块
				let statusIcon: string;
				let statusText: string;
				if (partial) {
					statusIcon = theme.fg("warning", "\u2192");
					statusText = "running";
				} else {
					const isError =
						r.exitCode !== 0 ||
						r.stopReason === "error" ||
						r.stopReason === "aborted";
					if (isError) {
						statusIcon = theme.fg("error", "\u2717");
						statusText = r.stopReason || "failed";
					} else {
						statusIcon = theme.fg("success", "\u2713");
						statusText = "completed";
					}
				}
				const usageStr = r.usage.turns > 0
					? " (" + formatUsageStats(r.usage) + ")"
					: "";
				lines.push("  " + theme.fg("mdHeading", "[Status]"));
				lines.push(
					"  " + statusIcon + " " + statusText + theme.fg("dim", usageStr),
				);

				// Output 块 — 只在有内容时展示
				const displayItems = getDisplayItems(r.messages);
				const finalOutput = getFinalOutput(r.messages);
				const toolCalls = displayItems.filter((item) => item.type === "toolCall");
				const hasOutput = finalOutput || toolCalls.length > 0;

				if (hasOutput) {
					lines.push("");
					lines.push("  " + theme.fg("mdHeading", "[Output]"));
					if (expanded) {
						for (const item of displayItems) {
							if (item.type === "toolCall" && item.name && item.args) {
								lines.push(
									"  " + theme.fg("muted", "\u2192 ") +
										formatToolCall(item.name, item.args,
											(c: string, t: string) => theme.fg(c as ThemeColor, t)),
								);
							}
						}
						if (finalOutput) {
							for (const l of finalOutput.split("\n")) {
								lines.push("  " + l);
							}
						}
					} else {
						const toShow = toolCalls.slice(-MAX_OUTPUT_ITEMS);
						const skipped = toolCalls.length - toShow.length;
						if (skipped > 0) {
							lines.push("  " + theme.fg("muted", `... ${skipped} earlier items`));
						}
						for (const item of toShow) {
							if (item.name && item.args) {
								lines.push(
									"  " + theme.fg("muted", "\u2192 ") +
										formatToolCall(item.name, item.args,
											(c: string, t: string) => theme.fg(c as ThemeColor, t)),
								);
							}
						}
						if (finalOutput) {
							const preview = truncate(finalOutput, MAX_COLLAPSED_LINES);
							for (const l of preview.split("\n")) {
								lines.push("  " + theme.fg("dim", l));
							}
						}
					}
				}

				if (!partial && (r.exitCode !== 0 || r.stopReason === "error") && r.errorMessage) {
					lines.push("");
					lines.push("  " + theme.fg("error", `Error: ${r.errorMessage}`));
				}

				return lines.join("\n");
			};

			// --- Single 模式 ---
			if (details.mode === "single" && details.results.length === 1) {
				return new Text(renderSingleBlock(details.results[0], isPartial), 0, 0);
			}

			// --- Parallel 模式 ---
			if (details.mode === "parallel") {
				const running = details.results.filter((r) => r.exitCode === -1).length;
				const successCount = details.results.filter((r) => r.exitCode === 0).length;
				const status = running > 0
					? `${details.results.length - running}/${details.results.length} done, ${running} running`
					: `${successCount}/${details.results.length} completed`;

				const lines: string[] = [];
				lines.push(
					theme.fg("toolTitle", theme.bold("parallel")) +
						"  " + theme.fg("accent", status),
				);

				for (let i = 0; i < details.results.length; i++) {
					const r = details.results[i];
					const isRunning = r.exitCode === -1;
					const isError = r.exitCode > 0 || r.stopReason === "error" || r.stopReason === "aborted";
					const icon = isRunning
						? theme.fg("warning", "\u2192")
						: isError
							? theme.fg("error", "\u2717")
							: theme.fg("success", "\u2713");
					const modelStr = r.model ? "  " + theme.fg("dim", r.model) : "";

					lines.push("");
					lines.push(
						`  ${theme.fg("muted", `[${i + 1}]`)} ${icon} ${isRunning ? "running" : isError ? "failed" : "completed"}${modelStr}`,
					);
					const taskPreview = truncate(r.task, 1);
					lines.push(`      ${theme.fg("mdHeading", "[Task]")} ${theme.fg("dim", taskPreview)}`);
					const output = getFinalOutput(r.messages);
					const outputPreview = output
						? truncate(output, 1)
						: isRunning ? "(running...)" : "(no output)";
					lines.push(`      ${theme.fg("mdHeading", "[Output]")} ${theme.fg("dim", outputPreview)}`);
				}

				if (running === 0) {
					lines.push("");
					lines.push("  " + theme.fg("dim", "Total: " + formatUsageStats(aggregateUsage(details.results))));
				}

				return new Text(lines.join("\n"), 0, 0);
			}

			// --- Chain 模式 ---
			if (details.mode === "chain") {
				const successCount = details.results.filter((r) => r.exitCode === 0).length;
				const total = details.results.length;
				const modelStr = details.results[0]?.model
					? "  " + theme.fg("dim", details.results[0].model)
					: "";

				const lines: string[] = [];
				lines.push(
					theme.fg("toolTitle", theme.bold("chain")) +
						"  " + theme.fg("accent", `${successCount}/${total} steps`) + modelStr,
				);

				for (const r of details.results) {
					const isRunning = r.exitCode === -1;
					const isError = r.exitCode > 0 || r.stopReason === "error" || r.stopReason === "aborted";
					const icon = isRunning
						? theme.fg("warning", "\u2192")
						: isError
							? theme.fg("error", "\u2717")
							: r.exitCode === 0
								? theme.fg("success", "\u2713")
								: theme.fg("dim", "\u25CB");

					lines.push("");
					lines.push(
						`  ${theme.fg("muted", `Step ${r.step}:`)} ${icon} ${isRunning ? "running" : isError ? "failed" : r.exitCode === 0 ? "completed" : "pending"}`,
					);
					if (r.promptContent) {
						const promptPreview = truncate(r.promptContent, 1);
						lines.push(`      ${theme.fg("mdHeading", "[Prompt]")} ${theme.fg("dim", promptPreview)}`);
					}
					const taskPreview = truncate(r.task.replace(/\{previous\}/g, "").trim(), 1);
					lines.push(`      ${theme.fg("mdHeading", "[Task]")} ${theme.fg("dim", taskPreview)}`);
					const output = getFinalOutput(r.messages);
					const outputPreview = output
						? truncate(output, 1)
						: isRunning ? "(running...)" : "(no output)";
					lines.push(`      ${theme.fg("mdHeading", "[Output]")} ${theme.fg("dim", outputPreview)}`);
				}

				lines.push("");
				lines.push("  " + theme.fg("dim", "Total: " + formatUsageStats(aggregateUsage(details.results))));

				return new Text(lines.join("\n"), 0, 0);
			}

			const fallbackText = result.content[0];
			return new Text(
				fallbackText?.type === "text" ? (fallbackText.text ?? "") : "(no output)",
				0, 0,
			);
		},
	});
}
