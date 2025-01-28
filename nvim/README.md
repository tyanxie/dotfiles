# Neovim

个人 [Neovim](https://github.com/neovim/neovim) 配置。

## 问题记录

> 本章节记录一些让我实在无法用下去的问题。

1. gopls的code completion无法提示出一个完全从未使用过的模块，
想要提示出来必须是一个使用过或间接引用过的模块才可以正常提示，个人认为这是一个bug，
正在等待gopls官方的回复：[issue](https://github.com/golang/go/issues/71462)，无论如何这是一个非常影响使用体验的问题，
这也是我只能暂时放弃将Neovim作为主要工作流的核心原因。

## Protocol Buffers (Protobuf)

当前配置使用 [protols](https://github.com/coder3101/protols) 作为
[Protobuf](https://protobuf.dev/) 协议的 LSP 服务器，

安装 protols 需要 [rust](https://www.rust-lang.org/) 开发环境，
国内可以使用 [rsproxy](https://rsproxy.cn) 安装并配置 rust 开发环境。

配置好 rust 开发环境后，即可直接打开 Protobuf 文件进行使用，本项目使用的 Mason 会自动安装 protols 依赖。

## 3rd/image.nvim

[3rd/image.nvim](https://github.com/3rd/image.nvima) 是一个强大的能够在 Neovim 中实现预览图片的插件。
但是安装该插件会比较复杂，本小节简单记录可能会遇见的问题以及解决问题的思路。

### LuaRocks

该插件使用 [LuaRocks](https://luarocks.org/) 进行安装，因此在使用该插件之前必须安装好 Lua 的开发环境以及配置好 LuaRocks。

如果当前机器上并没有 LuaRocks，那么 lazy.nvim 会自动使用 [hererocks](https://github.com/mpeterv/hererocks) 安装 
LuaRocks 环境到本机的 `~/.local/share/lazy-rock` 目录下。

通过 hererocks 自动安装 LuaRocks 可能会出现失败，这种情况下要么手动安装配置 LuaRocks 到系统上然后重启 Neovim，
要么就需要分析安装的错误信息，并且尝试解决相关问题。
例如某次失败中我们分析出是因为系统上缺少了一个C库：`readline`，在手动安装该库后，hererocks 便将 LuaRocks 成功安装了。

### ImageMagick

该插件依赖 [ImageMagick](https://imagemagick.org/) 工具包，因此系统上需要安装该软件，下面简单列举部分系统的安装方式：

```bash
# Debian/Ubuntu:
sudo apt-get install imagemagick libmagickwand-dev

# CentOS/RHEL:
sudo yum install ImageMagick ImageMagick-devel

# Fedora
sudo dnf install ImageMagick ImageMagick-devel

# macOS (Homebrew):
brew install imagemagick
```
