/**
 * Powerflow 扩展
 *
 * 在每次 agent 开始时注入 SKILL.md 核心指引部分（CORE_GUIDE_END 标记之前的内容）
 * skills 目录通过 package.json 的 pi.skills 字段声明式注册
 */

import { readFile } from "node:fs/promises";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

/** 扩展根目录 */
const EXT_DIR = dirname(fileURLToPath(import.meta.url));

/** SKILL.md 文件路径 */
const SKILL_MD_PATH = join(EXT_DIR, "skills", "powerflow", "SKILL.md");

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

  // 在 session start 时预加载核心指引
  pi.on("session_start", async (_event, ctx) => {
    try {
      const content = await readFile(SKILL_MD_PATH, "utf-8");
      coreGuide = extractCoreGuide(content);
      if (!coreGuide) {
        ctx.ui.notify(
          `[powerflow] "${CORE_GUIDE_END_MARKER}" marker not found in SKILL.md, core guide injection skipped`,
          "warning",
        );
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
