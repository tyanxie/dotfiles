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
│   ├── sync-appearance/        # 同步 macOS 外观模式到 pi 主题
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

### sync-appearance

通过 [dotfiles-daemon](../daemon) 同步 macOS 外观模式。daemon 将当前外观（1=light, 2=dark）写入 `~/.dotfiles-daemon-appearance`，扩展通过 `fs.watch` 监听该文件变化，自动在 Catppuccin Latte 和 Mocha 之间切换主题。

### tool-confirm

在 `bash`、`edit`、`write` 工具执行前弹出确认对话框，用户选择 Allow 才执行，否则拦截。使用 `/tool-confirm` 命令可在运行中动态开关。

### task

通用任务追踪工具，注册 `task` 自定义 tool 供 LLM 调用。支持 `init`、`update`、`status`、`clear` 四种操作。

- TUI widget 常驻显示完整任务列表和进度
- 状态存储在 session 的 tool result details 中，支持分支重建
- 自定义渲染：调用摘要和结果展示均带主题颜色

### subagent

通用 subagent 委派工具，通过 spawn 独立 pi 子进程执行任务。支持三种模式：

- **Single** — 单任务委派
- **Parallel** — 多任务并行执行（最多 8 个，4 并发）
- **Chain** — 串行链式执行，`{previous}` 占位符传递上一步输出

prompt 来源灵活：内联文本（`prompt`）或文件路径（`promptFile`）。model 默认继承主 session，可通过 `provider/id` 格式指定。

### superpowers

基于 [Superpowers](https://github.com/obra/superpowers) 的工作流 skills 集成，包含 14 个 skills（brainstorming、TDD、debugging、code review 等）。通过 `resources_discover` 事件注册 skills 目录，session 启动时注入 `using-superpowers` 核心指引到 system prompt。

## 主题

基于 [Catppuccin](https://github.com/catppuccin/catppuccin) 色板生成的两个主题：

- **catppuccin-latte** — 亮色，适合白天使用
- **catppuccin-mocha** — 暗色，适合夜间使用

## 安装

```bash
# 本地安装（dotfiles 已 clone 的情况下）
pi install /path/to/dotfiles/pi

# 远程安装
pi install git:github.com/tyanxie/dotfiles
```

## 开发

```bash
# 安装 LSP 类型依赖
cd pi && pnpm install

# 修改扩展或主题后，在 pi 中执行 /reload 即可热重载
```
