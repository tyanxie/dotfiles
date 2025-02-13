# dotfiles

个人配置管理仓库

## 相关软件

本仓库包含我个人使用的如下软件的相关配置：

- [btop](https://github.com/aristocratos/btop)
- [kitty](https://github.com/kovidgoyal/kitty)
- [neovim](https://github.com/neovim/neovim)
- [tmux](https://github.com/tmux/tmux)
- [wezterm](https://github.com/wez/wezterm)
- [yazi](https://github.com/sxyazi/yazi)
- [golangci-lint](https://github.com/golangci/golangci-lint)
- [ideavim](https://github.com/JetBrains/ideavim)
- [starship](https://github.com/starship/starship)

## 依赖安装

要想正常使用本仓库的内容，需要安装如下对应模块的相关软件：

- 全局软件
  - [fd](https://github.com/sharkdp/fd): 快速的文件查找器，用于替代 find 命令。
  - [ripgrep(rg)](https://github.com/BurntSushi/ripgrep): 快速的 grep 命令。
  - [fzf](https://github.com/junegunn/fzf): 强大的模糊查找工具。
  - [maple-font](https://github.com/subframe7536/maple-font): 推荐的等宽字体，支持中文等宽字体，可以安装 MapleMono-NF-CN-unhinted 版本。
  - [imagemagick](https://imagemagick.org/index.php): 用于在终端中展示图片的工具库。
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
