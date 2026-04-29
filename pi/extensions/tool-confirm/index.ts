/**
 * 在 bash、edit、write 工具执行前弹出自定义确认对话框。
 * 展示工具名称和关键参数摘要，用户选择"确认"才执行，否则拦截。
 *
 * 对话框布局对齐 pi 内置的 ExtensionSelectorComponent 风格：
 * 边框 → 标题 → 摘要 → 选项列表 → 帮助提示 → 边框
 *
 * 使用 /tool-confirm 命令可在运行中动态开关确认功能。
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { Container, Spacer, Text } from "@mariozechner/pi-tui";

/** 需要确认的工具集合 */
const TOOLS_NEED_CONFIRM = new Set(["bash", "edit", "write"]);

/**
 * 动态边框组件，根据宽度绘制一条横线。
 * 对齐 pi 内置 DynamicBorder（未从 pi-tui 导出，因此内联实现）。
 */
class Border {
	private colorFn: (s: string) => string;

	constructor(colorFn: (s: string) => string) {
		this.colorFn = colorFn;
	}

	invalidate() {}

	render(width: number): string[] {
		return [this.colorFn("─".repeat(Math.max(1, width)))];
	}
}

export default function (pi: ExtensionAPI) {
	/** 是否启用确认对话框 */
	let enabled = true;

	// 注册 /tool-confirm 命令，用于动态开关
	pi.registerCommand("tool-confirm", {
		description: "Toggle tool confirmation on/off",
		handler: async (_args, ctx) => {
			enabled = !enabled;
			ctx.ui.notify(`🔔 Tool confirm: ${enabled ? "ON" : "OFF"}`, "info");
		},
	});

	pi.on("tool_call", async (event, ctx) => {
		if (!enabled) return;
		if (!TOOLS_NEED_CONFIRM.has(event.toolName)) return;

		// 弹出自定义确认对话框
		const confirmed = await ctx.ui.custom<boolean>((tui, theme, _kb, done) => {
			const container = new Container();

			// 选项数据及状态
			const options = ["Allow", "Block"];
			let selectedIndex = 0;

			// 选项列表容器（需要在键盘事件中更新）
			const listContainer = new Container();

			/** 根据当前选中状态刷新选项列表 */
			function updateList() {
				listContainer.clear();
				for (let i = 0; i < options.length; i++) {
					const isSelected = i === selectedIndex;
					const text = isSelected
						? theme.fg("accent", "→ ") + theme.fg("accent", options[i])
						: "  " + theme.fg("text", options[i]);
					listContainer.addChild(new Text(text, 1, 0));
				}
			}

			// === 组装布局（对齐内置 ExtensionSelectorComponent） ===

			// 上边框
			container.addChild(new Border((s) => theme.fg("border", s)));
			container.addChild(new Spacer(1));

			// 标题：工具名称 + 提示
			container.addChild(new Text(
				theme.fg("accent", theme.bold(event.toolName)) + theme.fg("muted", " — Allow this tool call?"),
				1, 0,
			));
			container.addChild(new Spacer(1));

			// 选项列表
			updateList();
			container.addChild(listContainer);
			container.addChild(new Spacer(1));

			// 底部帮助提示
			container.addChild(new Text(
				theme.fg("dim", "↑↓ navigate • enter select • esc cancel"),
				1, 0,
			));
			container.addChild(new Spacer(1));

			// 下边框
			container.addChild(new Border((s) => theme.fg("border", s)));

			return {
				render: (w) => container.render(w),
				invalidate: () => container.invalidate(),
				handleInput: (data) => {
					if (data === "\x1b[A" || data === "k") {
						// 上移
						selectedIndex = Math.max(0, selectedIndex - 1);
						updateList();
					} else if (data === "\x1b[B" || data === "j") {
						// 下移
						selectedIndex = Math.min(options.length - 1, selectedIndex + 1);
						updateList();
					} else if (data === "\r" || data === "\n") {
						// 确认选择
						done(selectedIndex === 0);
					} else if (data === "\x1b") {
						// Esc 取消
						done(false);
					}
					tui.requestRender();
				},
			};
		});

		// 未确认则拦截
		if (!confirmed) {
			return { block: true, reason: "Blocked by user" };
		}
	});
}
