/**
 * 通过 dotfiles-daemon 同步系统外观模式到 pi 主题。
 *
 * daemon 检测系统外观模式（macOS / Linux）并将结果
 * （1=light, 2=dark）写入 ~/.dotfiles-daemon-appearance，
 * 本扩展监听该文件变化，自动在 Catppuccin Latte 和 Mocha 之间切换。
 *
 * 若文件不存在（如 WSL 或未安装 daemon 的环境），则默认使用暗色主题。
 */

import { watch, existsSync, type FSWatcher } from "node:fs";
import { readFile } from "node:fs/promises";
import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";

const APPEARANCE_FILE = `${process.env.HOME}/.dotfiles-daemon-appearance`;
const THEME_LIGHT = "catppuccin-latte";
const THEME_DARK = "catppuccin-mocha";

/** 根据外观模式值返回对应主题名 */
function appearanceToTheme(content: string): string {
	return content.trim() === "2" ? THEME_DARK : THEME_LIGHT;
}

export default function (pi: ExtensionAPI) {
	let watcher: FSWatcher | null = null;
	let currentTheme: string | null = null;

	/** 读取外观文件并切换主题 */
	async function syncTheme(ctx: ExtensionContext) {
		try {
			const content = await readFile(APPEARANCE_FILE, "utf8");
			const theme = appearanceToTheme(content);
			if (theme === currentTheme) return;
			const result = ctx.ui.setTheme(theme);
			if (result.success) {
				currentTheme = theme;
				ctx.ui.notify(`  Theme switched to: ${theme}`, "info");
			} else {
				ctx.ui.notify(`  Failed to switch theme: ${result.error}`, "error");
			}
		} catch (err) {
			ctx.ui.notify(`  Failed to read appearance file: ${err}`, "error");
		}
	}

	pi.on("session_start", async (_event, ctx) => {
		// 文件不存在时直接使用默认暗色主题
		if (!existsSync(APPEARANCE_FILE)) {
			const result = ctx.ui.setTheme(THEME_DARK);
			if (result.success) {
				currentTheme = THEME_DARK;
			}
			ctx.ui.notify(`  Appearance file (${APPEARANCE_FILE}) not found, using default theme: ${THEME_DARK}`, "info");
			return;
		}

		// 启动时立即同步一次
		await syncTheme(ctx);

		// 监听文件变化
		ctx.ui.notify(`  Watching ${APPEARANCE_FILE} for theme sync`, "info");
		try {
			watcher = watch(APPEARANCE_FILE, () => {
				syncTheme(ctx);
			});
		} catch (err) {
			ctx.ui.notify(`  Failed to watch appearance file: ${err}`, "error");
		}
	});

	pi.on("session_shutdown", () => {
		if (watcher) {
			watcher.close();
			watcher = null;
		}
	});
}
