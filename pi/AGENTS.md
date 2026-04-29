# AGENTS.md

本项目是 pi-coding-agent 的个人配置包。

## 项目结构

- `extensions/` — pi 扩展，每个扩展一个子目录，入口为 `index.ts`
- `themes/` — pi 主题，JSON 格式
- `package.json` — pi package 声明 + LSP 类型依赖
- `tsconfig.json` — TypeScript 配置（仅用于编辑器类型检查，pi 运行时不依赖）

## 技术要点

- 扩展使用 TypeScript 编写，通过 jiti 加载，无需编译
- 类型从 `@mariozechner/pi-coding-agent` 和 `@mariozechner/pi-tui` 导入
- 主题 JSON 需定义全部 51 个 color token，格式参考 pi 文档 themes.md
- `node_modules/` 和 `pnpm-lock.yaml` 仅用于编辑器 LSP，不参与 pi 运行时

## 扩展开发规范

- 每个扩展独立一个目录，入口为 `index.ts`
- 导出默认函数 `export default function (pi: ExtensionAPI) { ... }`
- 注释使用中文，日志和用户提示使用英文
- 使用 `pi.on()` 订阅事件，`pi.registerCommand()` 注册命令
- UI 组件从 `@mariozechner/pi-tui` 导入（`Container`、`Text`、`SelectList`、`Spacer` 等）
- `DynamicBorder` 未从 pi-tui 导出，需内联实现（参考 tool-confirm）
- 修改后在 pi 中执行 `/reload` 即可热重载

## 主题开发规范

- 基于 Catppuccin 色板，使用 `vars` 定义调色板颜色，`colors` 中引用
- 必须定义全部 51 个 color token
- 支持 hex（`#rrggbb`）、256 色索引（0-255）、变量引用、空字符串（终端默认色）
