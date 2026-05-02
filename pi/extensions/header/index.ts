/**
 * 自定义启动 header 扩展。
 *
 * 在 session_start 时替换默认 header，展示个性化 ASCII art 和版本信息，
 * 风格参考 neovim snacks.dashboard 配置。
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { VERSION } from "@mariozechner/pi-coding-agent";
import { visibleWidth, truncateToWidth } from "@mariozechner/pi-tui";

/** ANSI Shadow 字体的 "T-PI" ASCII art */
const HEADER_ART = [
  "████████╗   ██████╗ ██╗",
  "╚══██╔══╝   ██╔══██╗██║",
  "   ██║█████╗██████╔╝██║",
  "   ██║╚════╝██╔═══╝ ██║",
  "   ██║      ██║     ██║",
  "   ╚═╝      ╚═╝     ╚═╝",
];

export default function (pi: ExtensionAPI) {
  pi.on("session_start", async (_event, ctx) => {
    if (!ctx.hasUI) return;

    ctx.ui.setHeader((_tui, theme) => {
      return {
        render(width: number): string[] {
          const lines: string[] = [];

          // ASCII art 居中显示
          const artWidth = visibleWidth(HEADER_ART[0] ?? "");
          for (const artLine of HEADER_ART) {
            const pad = Math.max(0, Math.floor((width - artWidth) / 2));
            lines.push(" ".repeat(pad) + theme.fg("accent", artLine));
          }

          // 版本信息居中
          const versionText = "pi v" + VERSION;
          const versionPad = Math.max(
            0,
            Math.floor((width - visibleWidth(versionText)) / 2),
          );
          lines.push("");
          lines.push(" ".repeat(versionPad) + theme.fg("dim", versionText));

          return lines.map((l) => truncateToWidth(l, width));
        },
        invalidate() {},
      };
    });
  });

  // 提供命令恢复默认 header
  pi.registerCommand("builtin-header", {
    description: "Restore built-in header",
    handler: async (_args, ctx) => {
      ctx.ui.setHeader(undefined);
      ctx.ui.notify("Built-in header restored", "info");
    },
  });
}
