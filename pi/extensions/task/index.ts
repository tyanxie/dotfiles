/**
 * Task Tracker Extension
 *
 * 通用任务追踪工具，注册 task 供 LLM 调用。
 * 状态存储在 tool result details 中，支持 session 分支重建。
 * 在 TUI widget 中展示任务列表和进度。
 *
 * 操作:
 *   init   — 初始化任务列表
 *   update — 更新单个任务状态
 *   status — 查看当前进度
 *   clear  — 清除任务列表
 */

import type {
	ExtensionAPI,
	ExtensionContext,
	Theme,
} from "@mariozechner/pi-coding-agent";
import { Text } from "@mariozechner/pi-tui";
import { Type } from "@sinclair/typebox";
import {
	type Task,
	type TaskStatus,
	type BranchEntry,
	type TaskTrackerDetails,
	handleInit,
	handleUpdate,
	handleStatus,
	handleClear,
	formatWidgetData,
	reconstructFromBranch,
} from "./core.js";

const TaskTrackerParams = Type.Object({
	action: Type.Union(
		[
			Type.Literal("init"),
			Type.Literal("update"),
			Type.Literal("status"),
			Type.Literal("clear"),
		],
		{ description: "Action to perform" },
	),
	tasks: Type.Optional(
		Type.Array(Type.String(), {
			description: "Task names (for init)",
		}),
	),
	index: Type.Optional(
		Type.Integer({
			minimum: 0,
			description: "Task index, 0-based (for update)",
		}),
	),
	status: Type.Optional(
		Type.Union(
			[
				Type.Literal("pending"),
				Type.Literal("in_progress"),
				Type.Literal("complete"),
			],
			{ description: "New status (for update)" },
		),
	),
});

interface TaskTrackerInput {
	action: "init" | "update" | "status" | "clear";
	tasks?: string[];
	index?: number;
	status?: TaskStatus;
}

/** 渲染 widget 文本（带主题颜色，展示完整任务列表） */
function renderWidgetText(tasks: Task[], theme: Theme): string {
	if (tasks.length === 0) return "";

	const complete = tasks.filter((t) => t.status === "complete").length;
	const lines: string[] = [];
	lines.push(
		theme.fg("muted", `Tasks (${complete}/${tasks.length})`),
	);
	for (let i = 0; i < tasks.length; i++) {
		const t = tasks[i];
		const icon =
			t.status === "complete"
				? theme.fg("success", "\u2713")
				: t.status === "in_progress"
					? theme.fg("warning", "\u2192")
					: theme.fg("dim", "\u25CB");
		lines.push(`  ${icon} ${t.name}`);
	}
	return lines.join("\n");
}

export default function (pi: ExtensionAPI) {
	let tasks: Task[] = [];

	/** 从 session branch 重建状态 */
	const reconstructState = (ctx: ExtensionContext) => {
		tasks = reconstructFromBranch(
			ctx.sessionManager.getBranch() as BranchEntry[],
		);
	};

	/** 更新 TUI widget */
	const updateWidget = (ctx: ExtensionContext) => {
		if (!ctx.hasUI) return;
		if (tasks.length === 0) {
			ctx.ui.setWidget("task", undefined);
		} else {
			ctx.ui.setWidget("task", (_tui, theme) => {
				return new Text(renderWidgetText(tasks, theme), 0, 0);
			});
		}
	};

	// 在 session 事件时重建状态和 widget
	pi.on("session_start", async (_event, ctx) => {
		reconstructState(ctx);
		updateWidget(ctx);
	});
	pi.on("session_tree", async (_event, ctx) => {
		reconstructState(ctx);
		updateWidget(ctx);
	});

	pi.registerTool({
		name: "task",
		label: "Task Tracker",
		description:
			"Track task/plan progress. Actions: init (set task list), update (change task status), status (show current state), clear (remove task list).",
		promptSnippet:
			"Track task progress with init/update/status/clear actions",
		promptGuidelines: [
			"Use task to track implementation plan progress: init with task names, update status as you work, clear when done.",
		],
		parameters: TaskTrackerParams,

		async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
			const p = params as unknown as TaskTrackerInput;
			let result;

			switch (p.action) {
				case "init": {
					result = handleInit(p.tasks);
					if (!result.error) {
						tasks = result.tasks;
						updateWidget(ctx);
					} else {
						// 出错时保留现有任务
						result = { ...result, tasks: [...tasks] };
					}
					break;
				}
				case "update": {
					result = handleUpdate(tasks, p.index, p.status);
					tasks = result.tasks;
					updateWidget(ctx);
					break;
				}
				case "status": {
					result = handleStatus(tasks);
					break;
				}
				case "clear": {
					result = handleClear(tasks);
					tasks = result.tasks;
					updateWidget(ctx);
					break;
				}
				default:
					return {
						content: [
							{ type: "text", text: `Unknown action: ${p.action}` },
						],
						details: {
							action: "status",
							tasks: [...tasks],
							error: "unknown action",
						} as TaskTrackerDetails,
					};
			}

			const details: TaskTrackerDetails = {
				action: p.action,
				tasks: result.tasks,
				...(result.error ? { error: result.error } : {}),
			};

			return {
				content: [{ type: "text", text: result.text }],
				details,
			};
		},

		// 自定义渲染：工具调用摘要
		renderCall(args: Record<string, unknown>, theme) {
			const a = args as unknown as TaskTrackerInput;
			let text = theme.fg("toolTitle", theme.bold("task "));
			text += theme.fg("muted", a.action);
			if (a.action === "update" && a.index !== undefined) {
				text += ` ${theme.fg("accent", `[${a.index}]`)}`;
				if (a.status) text += ` \u2192 ${theme.fg("dim", a.status)}`;
			}
			if (a.action === "init" && a.tasks) {
				text += ` ${theme.fg("dim", `(${a.tasks.length} tasks)`)}`;
			}
			return new Text(text, 0, 0);
		},

		// 自定义渲染：工具结果展示（含完整任务列表）
		renderResult(result: { content: Array<{ type: string; text?: string }>; details?: unknown }, _options: unknown, theme: Theme) {
			const details = result.details as TaskTrackerDetails | undefined;
			if (!details) {
				const text = result.content[0];
				return new Text(text?.type === "text" ? text.text : "", 0, 0);
			}

			if (details.error) {
				return new Text(theme.fg("error", `Error: ${details.error}`), 0, 0);
			}

			const taskList = details.tasks;
			switch (details.action) {
				case "init": {
					const lines: string[] = [];
					lines.push(
						theme.fg("success", "\u2713 ") +
							theme.fg(
								"muted",
								`Plan initialized with ${taskList.length} tasks`,
							),
					);
					lines.push("");
					for (let i = 0; i < taskList.length; i++) {
						lines.push(
							`  ${theme.fg("dim", "\u25CB")} ${theme.fg("muted", `[${i}]`)} ${taskList[i].name}`,
						);
					}
					return new Text(lines.join("\n"), 0, 0);
				}
				case "update": {
					const complete = taskList.filter(
						(t) => t.status === "complete",
					).length;
					return new Text(
						theme.fg("success", "\u2713 ") +
							theme.fg(
								"muted",
								`Updated (${complete}/${taskList.length} complete)`,
							),
						0,
						0,
					);
				}
				case "status": {
					if (taskList.length === 0) {
						return new Text(theme.fg("dim", "No task list active"), 0, 0);
					}
					const complete = taskList.filter(
						(t) => t.status === "complete",
					).length;
					const lines: string[] = [];
					lines.push(
						theme.fg("muted", `${complete}/${taskList.length} complete`),
					);
					for (const t of taskList) {
						const icon =
							t.status === "complete"
								? theme.fg("success", "\u2713")
								: t.status === "in_progress"
									? theme.fg("warning", "\u2192")
									: theme.fg("dim", "\u25CB");
						lines.push(`  ${icon} ${theme.fg("muted", t.name)}`);
					}
					return new Text(lines.join("\n"), 0, 0);
				}
				case "clear":
					return new Text(
						theme.fg("success", "\u2713 ") +
							theme.fg("muted", "Task list cleared"),
						0,
						0,
					);
				default:
					return new Text(theme.fg("dim", "Done"), 0, 0);
			}
		},
	});
}
