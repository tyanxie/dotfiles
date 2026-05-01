/**
 * 自定义 footer 扩展。
 *
 * 使用 setFooter API 完全替换默认 footer，单行展示：
 * 工作目录 + Git 分支 | 上下文进度条 | 模型信息（右对齐）
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@mariozechner/pi-tui";

/** 格式化 token 数量（参考原生 footer 的 formatTokens 逻辑） */
function formatContextWindow(count: number): string {
  if (count < 1000) return count.toString();
  if (count < 10000) return `${(count / 1000).toFixed(1)}k`;
  if (count < 1000000) return `${Math.round(count / 1000)}k`;
  if (count < 10000000) return `${(count / 1000000).toFixed(1)}M`;
  return `${Math.round(count / 1000000)}M`;
}

export default function (pi: ExtensionAPI) {
  pi.on("session_start", async (_event, ctx) => {
    ctx.ui.setFooter((tui, theme, footerData) => {
      const unsub = footerData.onBranchChange(() => tui.requestRender());

      return {
        dispose: unsub,
        // pi 框架要求实现此方法，当前无需额外逻辑
        invalidate() {},
        render(width: number): string[] {
          // === 左侧：工作目录 + Git 分支 ===
          let pwd = process.cwd();
          const home = process.env.HOME || process.env.USERPROFILE;
          if (home && pwd.startsWith(home)) {
            pwd = `~${pwd.slice(home.length)}`;
          }

          const branch = footerData.getGitBranch();
          const pwdStr = theme.fg("accent", pwd);
          const branchStr = branch ? theme.fg("muted", ` (${branch})`) : "";
          const left = pwdStr + branchStr;

          // === 中间：进度条 + 百分比 ===
          const usage = ctx.getContextUsage();
          let progressStr = "";

          if (usage && usage.percent != null) {
            const percent = usage.percent;
            const filled = Math.min(10, Math.max(0, Math.round(percent / 10)));
            const empty = 10 - filled;

            let colorToken: "success" | "warning" | "error";
            if (percent >= 90) {
              colorToken = "error";
            } else if (percent >= 60) {
              colorToken = "warning";
            } else {
              colorToken = "success";
            }

            // 格式化上下文窗口大小
            const contextWindow =
              usage.contextWindow ?? ctx.model?.contextWindow ?? 0;
            const cwText =
              contextWindow > 0 ? "/" + formatContextWindow(contextWindow) : "";

            const bar =
              theme.fg(colorToken, "\u2588".repeat(filled)) +
              theme.fg("dim", "\u2591".repeat(empty));
            const pctText = theme.fg(
              colorToken,
              ` ${Math.round(percent)}%${cwText}`,
            );
            progressStr = "  " + bar + pctText;
          }

          // === 右侧：模型信息 ===
          let rightStr = "";

          if (ctx.model) {
            const provider = ctx.model.provider;
            const modelId = ctx.model.id;
            const thinkingLevel = pi.getThinkingLevel();

            let modelInfo = `(${provider}) ${modelId}`;
            if (ctx.model.reasoning && thinkingLevel !== "off") {
              modelInfo += ` \u2022 ${thinkingLevel}`;
            }

            rightStr = theme.fg("dim", modelInfo);
          }

          // === 组装单行输出 ===
          const leftPart = left + progressStr;
          const leftWidth = visibleWidth(leftPart);
          const rightWidth = visibleWidth(rightStr);

          let line: string;
          if (rightStr && leftWidth + 2 + rightWidth <= width) {
            // 右侧放得下，用空格填充右对齐
            const padding = " ".repeat(width - leftWidth - rightWidth);
            line = leftPart + padding + rightStr;
          } else if (rightStr) {
            // 宽度不够，截断右侧
            const available = width - leftWidth - 2;
            if (available > 0) {
              const truncatedRight = truncateToWidth(rightStr, available);
              const truncatedWidth = visibleWidth(truncatedRight);
              const padding = " ".repeat(
                Math.max(0, width - leftWidth - truncatedWidth),
              );
              line = leftPart + padding + truncatedRight;
            } else {
              line = truncateToWidth(leftPart, width);
            }
          } else {
            line = truncateToWidth(leftPart, width);
          }

          return [truncateToWidth(line, width)];
        },
      };
    });
  });
}
