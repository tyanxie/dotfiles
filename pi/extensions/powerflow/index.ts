/**
 * Powerflow 扩展
 *
 * 1. 通过 resources_discover 注册扩展内置的 skills 目录
 * 2. 在每次 agent 开始时注入 SKILL.md 核心指引部分（CORE_GUIDE_END 标记之前的内容）
 */

import { readFile } from "node:fs/promises";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

/** 扩展根目录 */
const EXT_DIR = dirname(fileURLToPath(import.meta.url));

/** 内置 skills 目录 */
const SKILLS_DIR = join(EXT_DIR, "skills");

/** SKILL.md 文件路径 */
const SKILL_MD_PATH = join(SKILLS_DIR, "powerflow", "SKILL.md");

/** 核心指引分隔标记 */
const CORE_GUIDE_END_MARKER = "<!-- CORE_GUIDE_END -->";

/**
 * 从 SKILL.md 中提取核心指引部分
 * 提取 frontmatter 之后、CORE_GUIDE_END 标记之前的内容
 */
function extractCoreGuide(content: string): string | null {
	// 跳过 frontmatter
	let body = content;
	if (body.startsWith("---")) {
		const endIdx = body.indexOf("---", 3);
		if (endIdx !== -1) {
			body = body.slice(endIdx + 3).trimStart();
		}
	}

	// 查找分隔标记
	const markerIdx = body.indexOf(CORE_GUIDE_END_MARKER);
	if (markerIdx === -1) {
		return null;
	}

	return body.slice(0, markerIdx).trimEnd();
}

export default function (pi: ExtensionAPI) {
	let coreGuide: string | null = null;

	// 注册内置 skills 目录
	pi.on("resources_discover", async (_event, _ctx) => {
		return {
			skillPaths: [SKILLS_DIR],
		};
	});

	// 在 session start 时预加载核心指引
	pi.on("session_start", async (_event, _ctx) => {
		try {
			const content = await readFile(SKILL_MD_PATH, "utf-8");
			coreGuide = extractCoreGuide(content);
			if (!coreGuide) {
				console.error(
					`[powerflow] 警告: SKILL.md 中未找到 "${CORE_GUIDE_END_MARKER}" 标记，将注入全文`,
				);
				// fallback: 注入全文（跳过 frontmatter）
				let fallback = content;
				if (fallback.startsWith("---")) {
					const endIdx = fallback.indexOf("---", 3);
					if (endIdx !== -1) {
						fallback = fallback.slice(endIdx + 3).trimStart();
					}
				}
				coreGuide = fallback;
			}
		} catch {
			coreGuide = null;
		}
	});

	// 在每次 agent 开始前注入核心指引到 system prompt
	pi.on("before_agent_start", async (event, _ctx) => {
		if (!coreGuide) return;

		const injection = [
			"<POWERFLOW>",
			"你拥有 powerflow 工作流能力。以下是核心指引，用于快速判断是否启用工作流：",
			"",
			coreGuide,
			"",
			"如需启用完整工作流，请 read 本 skill 的 SKILL.md 获取详细指引。",
			"</POWERFLOW>",
		].join("\n");

		return {
			systemPrompt: event.systemPrompt + "\n\n" + injection,
		};
	});
}
