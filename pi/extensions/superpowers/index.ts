/**
 * Superpowers extension
 *
 * 1. 通过 resources_discover 注册扩展内置的 skills 目录
 * 2. 在每次 agent 开始时注入 superpowers-using-superpowers skill 的核心指引，
 *    对齐原版 superpowers 插件的 SessionStart hook 行为
 */

import { readFile } from "node:fs/promises";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

/** 扩展根目录 */
const EXT_DIR = dirname(fileURLToPath(import.meta.url));

/** 内置 skills 目录 */
const SKILLS_DIR = join(EXT_DIR, "skills");

/** using-superpowers skill 文件路径 */
const USING_SUPERPOWERS_PATH = join(
	SKILLS_DIR,
	"superpowers-using-superpowers",
	"SKILL.md",
);

export default function (pi: ExtensionAPI) {
	let skillContent: string | null = null;

	// 注册内置 skills 目录
	pi.on("resources_discover", async (_event, _ctx) => {
		return {
			skillPaths: [SKILLS_DIR],
		};
	});

	// 在 session start 时预加载 skill 内容
	pi.on("session_start", async (_event, _ctx) => {
		try {
			skillContent = await readFile(USING_SUPERPOWERS_PATH, "utf-8");
		} catch {
			skillContent = null;
		}
	});

	// 在每次 agent 开始前注入到 system prompt
	pi.on("before_agent_start", async (event, _ctx) => {
		if (!skillContent) return;

		const injection = [
			"<EXTREMELY_IMPORTANT>",
			"You have superpowers.",
			"",
			"Below is the full content of your 'superpowers-using-superpowers' skill — your introduction to using skills.",
			"For all other skills, use `/skill:name` or `read` to load the full SKILL.md.",
			"",
			skillContent,
			"</EXTREMELY_IMPORTANT>",
		].join("\n");

		return {
			systemPrompt: event.systemPrompt + "\n\n" + injection,
		};
	});
}
