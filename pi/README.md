# Pi Config

[pi-coding-agent](https://github.com/badlogic/pi-mono) 的个人配置包，包含自定义扩展和主题。

## 目录结构

```
pi/
├── extensions/                 # 扩展
│   ├── subagent/               # 通用 subagent 委派工具
│   │   ├── core.ts             # spawn + JSON 解析（不依赖 pi API）
│   │   └── index.ts
│   ├── superpowers/            # Superpowers 工作流 skills + session 注入
│   │   ├── index.ts
│   │   └── skills/             # 14 个 superpowers skills
│   ├── footer/                  # 自定义 footer（进度条+模型信息）
│   │   └── index.ts
│   ├── theme/                  # 同步系统外观模式到 pi 主题
│   │   └── index.ts
│   ├── task/                   # 通用任务追踪工具
│   │   ├── core.ts             # 纯逻辑（不依赖 pi API）
│   │   └── index.ts
│   └── tool-confirm/           # 工具调用确认对话框
│       └── index.ts
└── themes/                     # 主题
    ├── catppuccin-latte.json   # Catppuccin Latte (亮色)
    └── catppuccin-mocha.json   # Catppuccin Mocha (暗色)
```

## 扩展

### footer

自定义 footer，使用 `setFooter` API 替换默认 footer 为单行紧凑布局：

- 左侧：工作目录 + Git 分支（accent/muted 配色）
- 中间：上下文进度条（10 格，按用量 0~60%/60~90%/90~100% 显示绿/黄/红，并显示上下文窗口大小）
- 右侧：模型信息（provider + model + thinking level），右对齐

各段在数据不可用时自动隐藏。

### theme

通过 [dotfiles-daemon](../daemon) 同步系统外观模式。daemon 检测系统外观（macOS / Linux）并将结果（1=light, 2=dark）写入 `~/.dotfiles-daemon-appearance`，扩展通过 `fs.watch` 监听该文件变化，自动在 Catppuccin Latte 和 Mocha 之间切换主题。

### tool-confirm

在 `bash`、`edit`、`write` 工具执行前弹出确认对话框，用户选择 Allow 才执行，否则拦截。使用 `/tool-confirm` 命令可在运行中动态开关。

### task

通用任务追踪工具，注册 `task` 自定义 tool 供 LLM 调用。支持 `init`、`update`、`status`、`clear` 四种操作。

- TUI widget 常驻显示完整任务列表和进度
- 状态存储在 session 的 tool result details 中，通过分支历史重建（支持 undo/redo）
- 自定义渲染：调用摘要和结果展示均带主题颜色

### subagent

通用 subagent 委派工具，通过 spawn 独立 pi 子进程执行任务。支持三种模式：

- **Single** — 单任务委派
- **Parallel** — 多任务并行执行（最多 8 个，4 并发）
- **Chain** — 串行链式执行，`{previous}` 占位符传递上一步输出

prompt 来源：内联文本（`prompt`）或文件路径（`promptFile`），二者互斥。model 默认继承主 session，可通过 `provider/id` 格式指定。不创建临时文件，prompt 内容通过 `--append-system-prompt` 传递给子进程。

### superpowers

基于 [Superpowers](https://github.com/obra/superpowers) 的工作流 skills 集成，包含 14 个 skills：

- **流程类**：brainstorming、writing-plans、executing-plans、verification-before-completion
- **开发类**：test-driven-development、systematic-debugging、subagent-driven-development
- **协作类**：requesting-code-review、receiving-code-review、dispatching-parallel-agents
- **工具类**：using-git-worktrees、finishing-a-development-branch、writing-skills
- **元技能**：using-superpowers（session 启动时注入 system prompt）

通过 `resources_discover` 事件注册 skills 目录。

## 主题

基于 [Catppuccin](https://github.com/catppuccin/catppuccin) 色板生成的两个主题：

- **catppuccin-latte** — 亮色，适合白天使用
- **catppuccin-mocha** — 暗色，适合夜间使用

## 安装

本包为个人 dotfiles 的一部分，仅支持本地安装：

```bash
pi install /path/to/dotfiles/pi
```

## 开发

```bash
# 安装类型依赖（仅用于编辑器 LSP 类型检查，pi 运行时不依赖）
pnpm install

# 修改扩展或主题后，在 pi 中执行 /reload 即可热重载
```
