# AGENTS.md

本项目是 pi-coding-agent 的个人配置包。

## 项目结构

- `extensions/` — pi 扩展，每个扩展一个子目录，入口为 `index.ts`
- `extensions/superpowers/skills/` — superpowers skills，通过 `resources_discover` 事件注册
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
- 不使用 emoji / 颜文字，图标统一使用 Nerd Font 字形
- Nerd Font 字形与后续文字之间使用两个空格（图标 + 空格 + 文字），保证视觉间距
- Nerd Font 字符属于 Unicode PUA 区域，`edit` 工具无法正确写入，必须通过 `bash` 调用 Python 写入
- 修改后在 pi 中执行 `/reload` 即可热重载

## 自定义工具开发规范

- 通过 `pi.registerTool()` 注册自定义 tool，使用 TypeBox 定义参数 schema
- 纯逻辑抽取到独立文件（如 `core.ts`），不依赖 pi API，方便测试
- `pi.registerTool()` 的类型定义与 `@sinclair/typebox` 的 `Type.Optional(StringEnum(...))` 存在类型不兼容，可用 `Type.Union(Type.Literal(...))` 替代
- tool 状态通过 `details` 字段存储在 session 中，通过 `reconstructFromBranch()` 从 session 历史重建
- 支持 `renderCall` / `renderResult` 自定义 TUI 渲染
- 支持 `ctx.ui.setWidget()` 注册常驻 widget

## subagent 扩展开发规范

- `subagent` 扩展通过 `spawn` 独立 `pi` 子进程实现任务委派
- 不创建临时文件，`--append-system-prompt` 同时支持文件路径和原始文本
- model 默认继承主 session（`ctx.model.provider/ctx.model.id`），可通过参数覆盖
- prompt 来源支持 `prompt`（内联）和 `promptFile`（文件路径），二者互斥
- 三种模式：single（单任务）、parallel（并行）、chain（串行链式，`{previous}` 占位符传递输出）

## Git 提交规范

- 格式：`type(scope): 描述`（Conventional Commits）
- scope 使用点号分隔子模块层级，如 `neovim.lsp`、`pi.themes`、`tmux.helper`
- 破坏性变更在冒号前加 `!`，如 `feat(neovim)!: 支持 Nvim 0.12.0`
- 描述使用中文，单行，结尾不加句号

## 主题开发规范

- 基于 Catppuccin 色板，使用 `vars` 定义调色板颜色，`colors` 中引用
- 必须定义全部 51 个 color token
- 支持 hex（`#rrggbb`）、256 色索引（0-255）、变量引用、空字符串（终端默认色）
