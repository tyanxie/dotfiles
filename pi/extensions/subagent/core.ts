/**
 * Subagent 核心逻辑
 *
 * 通过 spawn 独立 pi 子进程执行委派任务。
 * 不依赖 pi 扩展 API，方便测试。
 */

import { spawn } from "node:child_process";
import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";

// --- 常量 ---

export const MAX_PARALLEL_TASKS = 8;
export const MAX_CONCURRENCY = 4;
export const COLLAPSED_ITEM_COUNT = 10;

// --- 类型定义 ---

export interface UsageStats {
	input: number;
	output: number;
	cacheRead: number;
	cacheWrite: number;
	cost: number;
	contextTokens: number;
	turns: number;
}

export interface SingleResult {
	/** prompt 来源描述（文件路径或 "(inline)"） */
	promptSource: string;
	/** prompt 实际内容（用于渲染展示） */
	promptContent?: string;
	task: string;
	exitCode: number;
	messages: MessageLike[];
	stderr: string;
	usage: UsageStats;
	model?: string;
	stopReason?: string;
	errorMessage?: string;
	step?: number;
}

export interface SubagentDetails {
	mode: "single" | "parallel" | "chain";
	results: SingleResult[];
}

/** 精简的消息类型，只保留渲染需要的字段 */
export interface MessageLike {
	role: string;
	content: Array<{
		type: string;
		text?: string;
		name?: string;
		arguments?: Record<string, unknown>;
	}>;
	model?: string;
	usage?: {
		input?: number;
		output?: number;
		cacheRead?: number;
		cacheWrite?: number;
		cost?: { total?: number };
		totalTokens?: number;
	};
	stopReason?: string;
	errorMessage?: string;
}

export interface TaskInput {
	prompt?: string;
	promptFile?: string;
	task: string;
	model?: string;
}

export type OnUpdateCallback = (partial: {
	content: Array<{ type: string; text: string }>;
	details: SubagentDetails;
}) => void;

// --- 工具函数 ---

export function emptyUsage(): UsageStats {
	return {
		input: 0,
		output: 0,
		cacheRead: 0,
		cacheWrite: 0,
		cost: 0,
		contextTokens: 0,
		turns: 0,
	};
}

export function getFinalOutput(messages: MessageLike[]): string {
	for (let i = messages.length - 1; i >= 0; i--) {
		const msg = messages[i];
		if (msg.role === "assistant") {
			for (const part of msg.content) {
				if (part.type === "text" && part.text) return part.text;
			}
		}
	}
	return "";
}

export function formatTokens(count: number): string {
	if (count < 1000) return count.toString();
	if (count < 10000) return `${(count / 1000).toFixed(1)}k`;
	if (count < 1000000) return `${Math.round(count / 1000)}k`;
	return `${(count / 1000000).toFixed(1)}M`;
}

export function formatUsageStats(
	usage: UsageStats,
	model?: string,
): string {
	const parts: string[] = [];
	if (usage.turns)
		parts.push(`${usage.turns} turn${usage.turns > 1 ? "s" : ""}`);
	if (usage.input) parts.push(`\u2191${formatTokens(usage.input)}`);
	if (usage.output) parts.push(`\u2193${formatTokens(usage.output)}`);
	if (usage.cacheRead) parts.push(`R${formatTokens(usage.cacheRead)}`);
	if (usage.cacheWrite) parts.push(`W${formatTokens(usage.cacheWrite)}`);
	if (usage.cost) parts.push(`$${usage.cost.toFixed(4)}`);
	if (usage.contextTokens && usage.contextTokens > 0) {
		parts.push(`ctx:${formatTokens(usage.contextTokens)}`);
	}
	if (model) parts.push(model);
	return parts.join(" ");
}

export function aggregateUsage(results: SingleResult[]): UsageStats {
	const total = emptyUsage();
	for (const r of results) {
		total.input += r.usage.input;
		total.output += r.usage.output;
		total.cacheRead += r.usage.cacheRead;
		total.cacheWrite += r.usage.cacheWrite;
		total.cost += r.usage.cost;
		total.turns += r.usage.turns;
	}
	return total;
}

export function shortenPath(p: string): string {
	const home = os.homedir();
	return p.startsWith(home) ? `~${p.slice(home.length)}` : p;
}

export function formatToolCall(
	toolName: string,
	args: Record<string, unknown>,
	themeFg: (color: string, text: string) => string,
): string {
	switch (toolName) {
		case "bash": {
			const command = (args.command as string) || "...";
			const preview =
				command.length > 60 ? `${command.slice(0, 60)}...` : command;
			return themeFg("muted", "$ ") + themeFg("toolOutput", preview);
		}
		case "read": {
			const rawPath = (args.file_path || args.path || "...") as string;
			const filePath = shortenPath(rawPath);
			const offset = args.offset as number | undefined;
			const limit = args.limit as number | undefined;
			let text = themeFg("accent", filePath);
			if (offset !== undefined || limit !== undefined) {
				const startLine = offset ?? 1;
				const endLine =
					limit !== undefined ? startLine + limit - 1 : "";
				text += themeFg(
					"warning",
					`:${startLine}${endLine ? `-${endLine}` : ""}`,
				);
			}
			return themeFg("muted", "read ") + text;
		}
		case "write": {
			const rawPath = (args.file_path || args.path || "...") as string;
			const filePath = shortenPath(rawPath);
			const content = (args.content || "") as string;
			const lines = content.split("\n").length;
			let text =
				themeFg("muted", "write ") + themeFg("accent", filePath);
			if (lines > 1) text += themeFg("dim", ` (${lines} lines)`);
			return text;
		}
		case "edit": {
			const rawPath = (args.file_path || args.path || "...") as string;
			return (
				themeFg("muted", "edit ") +
				themeFg("accent", shortenPath(rawPath))
			);
		}
		default: {
			const argsStr = JSON.stringify(args);
			const preview =
				argsStr.length > 50 ? `${argsStr.slice(0, 50)}...` : argsStr;
			return themeFg("accent", toolName) + themeFg("dim", ` ${preview}`);
		}
	}
}

export interface DisplayItem {
	type: "text" | "toolCall";
	text?: string;
	name?: string;
	args?: Record<string, unknown>;
}

export function getDisplayItems(messages: MessageLike[]): DisplayItem[] {
	const items: DisplayItem[] = [];
	for (const msg of messages) {
		if (msg.role === "assistant") {
			for (const part of msg.content) {
				if (part.type === "text")
					items.push({ type: "text", text: part.text });
				else if (part.type === "toolCall")
					items.push({
						type: "toolCall",
						name: part.name,
						args: part.arguments,
					});
			}
		}
	}
	return items;
}

// --- 并发控制 ---

export async function mapWithConcurrencyLimit<TIn, TOut>(
	items: TIn[],
	concurrency: number,
	fn: (item: TIn, index: number) => Promise<TOut>,
): Promise<TOut[]> {
	if (items.length === 0) return [];
	const limit = Math.max(1, Math.min(concurrency, items.length));
	const results: TOut[] = new Array(items.length);
	let nextIndex = 0;
	const workers = new Array(limit).fill(null).map(async () => {
		while (true) {
			const current = nextIndex++;
			if (current >= items.length) return;
			results[current] = await fn(items[current], current);
		}
	});
	await Promise.all(workers);
	return results;
}

// --- pi 子进程启动 ---

/** 确定 pi 可执行文件调用方式 */
export function getPiInvocation(
	args: string[],
): { command: string; args: string[] } {
	const currentScript = process.argv[1];
	const isBunVirtualScript = currentScript?.startsWith("/$bunfs/root/");
	if (currentScript && !isBunVirtualScript && fs.existsSync(currentScript)) {
		return { command: process.execPath, args: [currentScript, ...args] };
	}
	const execName = path.basename(process.execPath).toLowerCase();
	const isGenericRuntime = /^(node|bun)(\.exe)?$/.test(execName);
	if (!isGenericRuntime) {
		return { command: process.execPath, args };
	}
	return { command: "pi", args };
}

// --- 核心执行函数 ---

export async function runSingleTask(
	cwd: string,
	input: TaskInput,
	defaultModel: string | undefined,
	step: number | undefined,
	signal: AbortSignal | undefined,
	onUpdate: OnUpdateCallback | undefined,
	makeDetails: (results: SingleResult[]) => SubagentDetails,
): Promise<SingleResult> {
	// 校验 prompt 和 promptFile 互斥
	if (input.prompt && input.promptFile) {
		return {
			promptSource: "(error)",
			task: input.task,
			exitCode: 1,
			messages: [],
			stderr: "prompt and promptFile are mutually exclusive",
			usage: emptyUsage(),
			step,
		};
	}

	const model = input.model ?? defaultModel;
	const promptSource = input.promptFile
		? shortenPath(input.promptFile)
		: input.prompt
			? "(inline)"
			: "(none)";

	// 读取 prompt 内容用于渲染展示
	let promptContent: string | undefined;
	if (input.promptFile) {
		try {
			promptContent = fs.readFileSync(input.promptFile, "utf-8");
		} catch {
			promptContent = undefined;
		}
	} else if (input.prompt) {
		promptContent = input.prompt;
	}

	const currentResult: SingleResult = {
		promptSource,
		promptContent,
		task: input.task,
		exitCode: -1,
		messages: [],
		stderr: "",
		usage: emptyUsage(),
		model,
		step,
	};

	const emitUpdate = () => {
		if (onUpdate) {
			onUpdate({
				content: [
					{
						type: "text",
						text:
							getFinalOutput(currentResult.messages) ||
							"(running...)",
					},
				],
				details: makeDetails([currentResult]),
			});
		}
	};

	// 构建 spawn 参数
	const args: string[] = ["--mode", "json", "-p", "--no-session"];
	if (model) args.push("--model", model);
	if (input.promptFile) {
		args.push("--append-system-prompt", input.promptFile);
	} else if (input.prompt) {
		args.push("--append-system-prompt", input.prompt);
	}
	args.push(`Task: ${input.task}`);

	let wasAborted = false;

	const exitCode = await new Promise<number>((resolve) => {
		const invocation = getPiInvocation(args);
		const proc = spawn(invocation.command, invocation.args, {
			cwd,
			shell: false,
			stdio: ["ignore", "pipe", "pipe"],
		});
		let buffer = "";

		const processLine = (line: string) => {
			if (!line.trim()) return;
			let event: Record<string, unknown>;
			try {
				event = JSON.parse(line);
			} catch {
				return;
			}

			if (
				event.type === "message_end" &&
				event.message
			) {
				const msg = event.message as MessageLike;
				currentResult.messages.push(msg);

				if (msg.role === "assistant") {
					currentResult.usage.turns++;
					const usage = msg.usage;
					if (usage) {
						currentResult.usage.input += usage.input || 0;
						currentResult.usage.output += usage.output || 0;
						currentResult.usage.cacheRead +=
							usage.cacheRead || 0;
						currentResult.usage.cacheWrite +=
							usage.cacheWrite || 0;
						currentResult.usage.cost +=
							usage.cost?.total || 0;
						currentResult.usage.contextTokens =
							usage.totalTokens || 0;
					}
					if (!currentResult.model && msg.model)
						currentResult.model = msg.model;
					if (msg.stopReason)
						currentResult.stopReason = msg.stopReason;
					if (msg.errorMessage)
						currentResult.errorMessage = msg.errorMessage;
				}
				emitUpdate();
			}

			if (
				event.type === "tool_result_end" &&
				event.message
			) {
				currentResult.messages.push(
					event.message as MessageLike,
				);
				emitUpdate();
			}
		};

		proc.stdout!.on("data", (data: Buffer) => {
			buffer += data.toString();
			const lines = buffer.split("\n");
			buffer = lines.pop() || "";
			for (const line of lines) processLine(line);
		});

		proc.stderr!.on("data", (data: Buffer) => {
			currentResult.stderr += data.toString();
		});

		proc.on("close", (code: number | null) => {
			if (buffer.trim()) processLine(buffer);
			resolve(code ?? 0);
		});

		proc.on("error", () => {
			resolve(1);
		});

		if (signal) {
			const killProc = () => {
				wasAborted = true;
				proc.kill("SIGTERM");
				setTimeout(() => {
					if (!proc.killed) proc.kill("SIGKILL");
				}, 5000);
			};
			if (signal.aborted) killProc();
			else signal.addEventListener("abort", killProc, { once: true });
		}
	});

	currentResult.exitCode = exitCode;
	if (wasAborted) {
		currentResult.exitCode = 1;
		currentResult.stopReason = "aborted";
	}
	return currentResult;
}
