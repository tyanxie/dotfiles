# Neovim

个人 [Neovim](https://github.com/neovim/neovim) 配置。

## 问题记录

> 本章节记录一些让我实在无法用下去的问题。

### Go

> Go语言遇到的两个问题是我只能暂时放弃将 Neovim 作为主要工作流的核心原因。

1. gopls 的 code completion 无法提示出一个完全从未使用过的模块，
想要提示出来必须是一个使用过或间接引用过的模块才可以正常提示，个人认为这是一个 bug，
正在等待 gopls 官方的回复：[issue](https://github.com/golang/go/issues/71462)，无论如何这是一个非常影响使用体验的问题。

2. 实际项目中常常会出现多个相同名称的不同 module，并且有可能需要被引入到同一个文件中，例如不同情况下使用不同的 log 进行输出，
但是 gopls 的 code action 只会展示一个 import 选项，也就是所谓的最优选项，不会展示其它的选项，这在实际项目开发中会比较折腾，
尝尝需要手动在 import 块中录入内容才可以，此外 gopls 也不支持代码提示的时候提示出其他包，例如引入了一个 log 包，那么就永远
只会提示这个 log 包下的内容，而不是像 GoLand 可以提示出其它包中的内容以供选择。

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
