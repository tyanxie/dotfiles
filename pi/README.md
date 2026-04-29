# Pi Config

[pi-coding-agent](https://github.com/badlogic/pi-mono) 的个人配置包，包含自定义扩展和主题。

## 目录结构

```
pi/
├── extensions/                 # 扩展
│   ├── sync-appearance/        # 同步 macOS 外观模式到 pi 主题
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
