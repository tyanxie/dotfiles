# Pi

个人 [pi](https://pi.dev/) 包。

## 目录结构

```
pi/
├── extensions/                 # 扩展
│   ├── subagent/               # 通用 subagent 委派工具
│   │   ├── core.ts             # spawn + JSON 解析（不依赖 pi API）
│   │   └── index.ts
│   ├── web/                   # 网络内容获取（全局可用）
│   │   ├── core.ts             # 纯逻辑（Jina Reader + Tavily Search）
│   │   └── index.ts
│   ├── header/                 # 自定义启动 header（ASCII art + 快捷提示）
│   │   └── index.ts
│   ├── footer/                  # 自定义 footer（进度条+模型信息）
│   │   └── index.ts
│   ├── theme/                  # 同步系统外观模式到 pi 主题
│   │   └── index.ts
│   ├── task/                   # 通用任务追踪工具
│   │   ├── core.ts             # 纯逻辑（不依赖 pi API）
│   │   └── index.ts
│   ├── format/                 # 自动格式化（edit/write 后触发）
│   │   └── index.ts
│   └── rtk/                    # RTK token 优化（bash 命令改写）
│       └── index.ts
└── themes/                     # 主题
    ├── catppuccin-latte.json   # Catppuccin Latte (亮色)
    └── catppuccin-mocha.json   # Catppuccin Mocha (暗色)
```

## 扩展

### header

自定义启动 header，使用 `setHeader` API 替换默认 header，展示个性化面板：

- ASCII art：ANSI Shadow 字体的 "T-PI" 居中显示，配色跟随主题 accent
- 版本号：`pi vX.X.X` 居中

使用 `/builtin-header` 命令可恢复默认 header。

### footer

自定义 footer，使用 `setFooter` API 替换默认 footer 为单行紧凑布局：

- 左侧：工作目录 + Git 分支（accent/muted 配色）
- 中间：上下文进度条（10 格，按用量 0~60%/60~90%/90~100% 显示绿/黄/红，并显示上下文窗口大小）
- 右侧：模型信息（provider + model + thinking level），右对齐

各段在数据不可用时自动隐藏。

### theme

通过 [dotfiles-daemon](../daemon) 同步系统外观模式。daemon 检测系统外观（macOS / Linux）并将结果（1=light, 2=dark）写入 `~/.dotfiles-daemon-appearance`，扩展通过 `fs.watch` 监听该文件变化，自动在 Catppuccin Latte 和 Mocha 之间切换主题。

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

### format

自动格式化扩展，监听 `tool_result` 事件，当 `edit`/`write` 工具成功修改文件后，根据文件扩展名调用对应 formatter：

- `.go` → goimports
- `.js` `.jsx` `.ts` `.tsx` `.vue` `.html` `.css` `.scss` `.less` `.json` `.md` `.yaml` `.yml` → prettier

Formatter 通过系统 PATH 查找，不可用时首次警告后静默跳过。

### web

网络内容获取扩展，全局可用。通过 `web` 自定义 tool 提供网页拉取和搜索能力。

- **双引擎架构**：Fetch 使用 Jina Reader API（免费、无需 key），Search 使用 Tavily API（需要 `TAVILY_API_KEY`）
- **单 tool 双 action**：`action: "fetch"` 拉取 URL 转 Markdown，`action: "search"` 搜索网络内容
- **渐进式解锁**：fetch 开箱即用，search 在调用时检查 key，未配置则报错引导
- **配置引导**：`/setup-web` 命令展示 Tavily 注册流程
- **自定义渲染**：renderCall 展示 action + 目标，renderResult 展示 [Input] + [Output]

### rtk

[RTK (Rust Token Killer)](https://github.com/rtk-ai/rtk) token 优化扩展，全局可用。拦截 bash 命令并改写为 rtk 等价命令，通过智能过滤/压缩命令输出减少 60-90% 的 token 消耗。

- **透明改写**：监听 `tool_call` 事件，对 bash 命令调用 `rtk rewrite` 查询等价写法，原地改写命令
- **安全放行**：无法安全改写的复杂命令（管道、子命令替换、重定向等）原样放行
- **fail-open**：rtk 未安装、版本过旧、rewrite 超时/出错时均静默放行，不阻塞任何操作
- **用户提示**：每次改写通过 `notify` 展示原始命令到改写命令的映射
- **依赖**：需要 [rtk >= 0.23.0](https://github.com/rtk-ai/rtk#installation) 安装在 PATH 中

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
bun install

# 修改扩展或主题后，在 pi 中执行 /reload 即可热重载
```
