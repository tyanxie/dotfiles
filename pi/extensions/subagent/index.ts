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
			const details = result.details as SubagentDetails | undefined;
			if (!details || details.results.length === 0) {
				const text = result.content[0];
				return new Text(
					text?.type === "text" ? (text.text ?? "") : "(no output)",
					0, 0,
				);
			}

			const expanded = options?.expanded ?? false;
			const MAX_TRUNCATE_CHARS = 80;
			let hasTruncation = false;
			const truncate = (text: string): string => {
				// 压缩空白为单行预览
				const normalized = text.replace(/\s+/g, " ").trim();
				if (normalized.length <= MAX_TRUNCATE_CHARS) return normalized;
				hasTruncation = true;
				let end = MAX_TRUNCATE_CHARS;
				// 往回找最近的空格（单词边界），中文文本无空格则直接截断
				const lastSpace = normalized.lastIndexOf(" ", end);
				if (lastSpace > end * 0.5) end = lastSpace;
				// 去掉末尾标点和空白
				let result = normalized.slice(0, end);
				result = result.replace(/[\s,.:;!?\-\u2014\uff0c\u3002\uff1a\uff1b\uff01\uff1f\u3001]+$/, "");
				return result + "...";
			};

			/** 紧凑渲染：每个 section 标题和内容在同一行 */
			const renderCompact = (r: SingleResult, indent = "  "): string[] => {
				const partial = r.exitCode === -1;
				const lines: string[] = [];

				if (r.model) {
					lines.push(indent + theme.fg("mdHeading", "[Model]") + " " + theme.fg("dim", r.model));
				}
				if (r.promptContent) {
					lines.push(indent + theme.fg("mdHeading", "[Prompt]") + " " + theme.fg("dim", truncate(r.promptContent)));
				}
				lines.push(indent + theme.fg("mdHeading", "[Task]") + " " + theme.fg("dim", truncate(r.task)));

				// Status
				let statusIcon: string;
				let statusText: string;
				if (partial) {
					statusIcon = theme.fg("warning", "\u2192");
					statusText = "running";
				} else {
					const isError = r.exitCode !== 0 || r.stopReason === "error" || r.stopReason === "aborted";
					if (isError) {
						statusIcon = theme.fg("error", "\u2717");
						statusText = r.stopReason || "failed";
					} else {
						statusIcon = theme.fg("success", "\u2713");
						statusText = "completed";
					}
				}
				const usageStr = r.usage.turns > 0 ? " (" + formatUsageStats(r.usage) + ")" : "";
				lines.push(indent + theme.fg("mdHeading", "[Status]") + " " + statusIcon + " " + statusText + theme.fg("dim", usageStr));

				// Output — 只在有内容时展示
				const finalOutput = getFinalOutput(r.messages);
				const toolCalls = getDisplayItems(r.messages).filter((item) => item.type === "toolCall");
				if (finalOutput || toolCalls.length > 0) {
					const outputPreview = finalOutput ? truncate(finalOutput) : "(tool calls only)";
					lines.push(indent + theme.fg("mdHeading", "[Output]") + " " + outputPreview);
				}

				if (!partial && (r.exitCode !== 0 || r.stopReason === "error") && r.errorMessage) {
					lines.push(indent + theme.fg("error", `Error: ${r.errorMessage}`));
				}

				return lines;
			};

			/** 完整渲染：每个 section 标题独占一行，内容在下方 */
			const renderFull = (r: SingleResult, indent = "  "): string[] => {
				const partial = r.exitCode === -1;
				const lines: string[] = [];

				if (r.model) {
					lines.push(indent + theme.fg("mdHeading", "[Model]"));
					lines.push(indent + theme.fg("dim", r.model));
					lines.push("");
				}

				if (r.promptContent) {
					lines.push(indent + theme.fg("mdHeading", "[Prompt]"));
					for (const l of r.promptContent.split("\n")) {
						lines.push(indent + theme.fg("dim", l));
					}
					lines.push("");
				}

				lines.push(indent + theme.fg("mdHeading", "[Task]"));
				for (const l of r.task.split("\n")) {
					lines.push(indent + theme.fg("dim", l));
				}
				lines.push("");

				// Status
				let statusIcon: string;
				let statusText: string;
				if (partial) {
					statusIcon = theme.fg("warning", "\u2192");
					statusText = "running";
				} else {
					const isError = r.exitCode !== 0 || r.stopReason === "error" || r.stopReason === "aborted";
					if (isError) {
						statusIcon = theme.fg("error", "\u2717");
						statusText = r.stopReason || "failed";
					} else {
						statusIcon = theme.fg("success", "\u2713");
						statusText = "completed";
					}
				}
				const usageStr = r.usage.turns > 0 ? " (" + formatUsageStats(r.usage) + ")" : "";
				lines.push(indent + theme.fg("mdHeading", "[Status]"));
				lines.push(indent + statusIcon + " " + statusText + theme.fg("dim", usageStr));

				// Output
				const displayItems = getDisplayItems(r.messages);
				const finalOutput = getFinalOutput(r.messages);
				const toolCalls = displayItems.filter((item) => item.type === "toolCall");
				const hasOutput = finalOutput || toolCalls.length > 0;

				if (hasOutput) {
					lines.push("");
					lines.push(indent + theme.fg("mdHeading", "[Output]"));
					for (const item of displayItems) {
						if (item.type === "toolCall" && item.name && item.args) {
							lines.push(
								indent + theme.fg("muted", "\u2192 ") +
									formatToolCall(item.name, item.args,
										(c: string, t: string) => theme.fg(c as ThemeColor, t)),
							);
						}
					}
					if (finalOutput) {
						for (const l of finalOutput.split("\n")) {
							lines.push(indent + l);
						}
					}
				}

				if (!partial && (r.exitCode !== 0 || r.stopReason === "error") && r.errorMessage) {
					lines.push("");
					lines.push(indent + theme.fg("error", `Error: ${r.errorMessage}`));
				}

				return lines;
			};

			/** 根据 expanded 选择渲染模式 */
			const renderResult = (r: SingleResult, indent = "  "): string[] => {
				return expanded ? renderFull(r, indent) : renderCompact(r, indent);
			};

			// --- Single 模式 ---
			if (details.mode === "single" && details.results.length === 1) {
				const lines = ["", ...renderResult(details.results[0])];
				if (hasTruncation) {
					lines.push("");
					lines.push("  " + theme.fg("dim", "(Ctrl+O to expand)"));
				}
				return new Text(lines.join("\n"), 0, 0);
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
					lines.push("");
					lines.push(`  ${theme.fg("muted", `[${i + 1}]`)}`);
					const itemLines = renderResult(r, "  ");
					lines.push(...itemLines);
				}

				if (running === 0) {
					const totalStr = formatUsageStats(aggregateUsage(details.results));
					if (totalStr) {
						lines.push("");
						lines.push("  " + theme.fg("dim", "Total: " + totalStr));
					}
				}

				if (hasTruncation) {
					lines.push("");
					lines.push("  " + theme.fg("dim", "(Ctrl+O to expand)"));
				}

				return new Text(lines.join("\n"), 0, 0);
			}

			// --- Chain 模式 ---
			if (details.mode === "chain") {
				const successCount = details.results.filter((r) => r.exitCode === 0).length;
				const total = details.results.length;

				const lines: string[] = [];
				lines.push(
					theme.fg("toolTitle", theme.bold("chain")) +
						"  " + theme.fg("accent", `${successCount}/${total} steps`),
				);

				for (const r of details.results) {
					lines.push("");
					lines.push(`  ${theme.fg("muted", `Step ${r.step}:`)}`);
					const itemLines = renderResult(r, "  ");
					lines.push(...itemLines);
				}

				const totalStr = formatUsageStats(aggregateUsage(details.results));
				if (totalStr) {
					lines.push("");
					lines.push("  " + theme.fg("dim", "Total: " + totalStr));
				}

				if (hasTruncation) {
					lines.push("");
					lines.push("  " + theme.fg("dim", "(Ctrl+O to expand)"));
				}

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
