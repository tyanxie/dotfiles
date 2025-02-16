# dotfiles

个人配置管理仓库

- [相关软件](#相关软件)
  - [WezTerm](#wezterm)
- [依赖安装](#依赖安装)
- [使用方式](#使用方式)

## 相关软件

本仓库包含我个人使用的如下软件的相关配置：

- [btop](https://github.com/aristocratos/btop)
- [kitty](https://github.com/kovidgoyal/kitty)
- [neovim](https://github.com/neovim/neovim)
- [sketchybar](https://github.com/FelixKratz/SketchyBar)
- [tmux](https://github.com/tmux/tmux)
- [wezterm](https://github.com/wez/wezterm)
- [yazi](https://github.com/sxyazi/yazi)
- [golangci-lint](https://github.com/golangci/golangci-lint)
- [ideavim](https://github.com/JetBrains/ideavim)

### WezTerm

wezterm 的更新频率非常快，但是一直没有发布新的 release 版本，
截止 2025 年 02 月 14 日，最新的 release 版本还是 20240203，
但这段时间内已经修复过非常多的问题了，因此建议安装 nightly 版本进行使用，理论上可以获得更好的体验。

在 macOS 系统上使用 brew 包管理器，可以参考如下命令安装 nightly 版本，
更多安装方式可以参考[官方文档](https://wezterm.org/installation.html)：

```bash
# 安装 nightly 版本
brew install --cask wezterm@nightly

# 更新 nightly 版本（正常情况下 brew upgrade 不会自动更新 nightly 版本）
brew upgrade --cask wezterm@nightly --no-quarantine --greedy-latest
```

## 依赖安装

要想正常使用本仓库的内容，需要安装如下对应模块的相关软件：

- 全局软件
  - [fd](https://github.com/sharkdp/fd): 快速的文件查找器，用于替代 find 命令。
  - [ripgrep(rg)](https://github.com/BurntSushi/ripgrep): 快速的 grep 命令。
  - [fzf](https://github.com/junegunn/fzf): 强大的模糊查找工具。
  - [maple-font](https://github.com/subframe7536/maple-font): 推荐的等宽字体，支持中文等宽字体，可以安装 MapleMono-NF-CN-unhinted 版本。
  - [imagemagick](https://imagemagick.org/index.php): 开源的图像处理库。
  - [lazygit](https://github.com/jesseduffield/lazygit): 强大的终端git用户界面。
- tmux：参考 [tmux/README.md](tmux/README.md)
- IdeaVim
  - IdeaVim
  - IdeaVimExtension
  - Which-Key
  - AceJump

## 使用方式

本仓库提供 `setup.sh` 脚本，该脚本通过传入目标软件名称来快速安装该软件的配置。
例如要安装 neovim(nvim) 的配置，可以使用如下命令：

```bash
sh setup.sh nvim
```
