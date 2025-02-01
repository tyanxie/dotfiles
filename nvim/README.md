# Neovim

个人 [Neovim](https://github.com/neovim/neovim) 配置。

- [依赖环境](#依赖环境)
- [快捷键](#快捷键)
- [问题记录](#问题记录)
  - [Go](#go)

## 依赖环境

使用本仓库的 Neovim 配置需要至少配置好如下的开发环境，以确保依赖能够正常安装。

- c/c++：推荐使用 [LLVM](https://llvm.org/)。
- [Go](https://go.dev/)
- [Lua](https://www.lua.org/)
- [Node.js](https://nodejs.org) 与 [npm](https://www.npmjs.com/)
- [Rust](https://www.rust-lang.org/)：国内推荐按照 [RsProxy](https://rsproxy.cn/) 的流程进行安装。

## 快捷键

本仓库 Neovim 配置涉及的常用快捷键可以参考：[KEYMAPS.md](KEYMAPS.md)。

## 问题记录

> 本章节记录一些让我无法将 Neovim 作为主要工作流的问题。

### Go

> Go语言遇到的两个问题是我只能暂时放弃将 Neovim 作为主要工作流的核心原因。

1. 在加载大型项目时，gopls 的 code completion 无法提示出一个完全从未使用过的模块，
   想要提示出来必须是一个使用过或间接引用过的模块才可以正常提示，个人认为这是一个 bug，
   正在等待 gopls 官方的回复：[issue](https://github.com/golang/go/issues/71462)，无论如何这是一个非常影响使用体验的问题。

2. 实际项目中常常会出现多个相同名称的不同 module，并且有可能需要被引入到同一个文件中，例如不同情况下使用不同的 log 进行输出，
   但是 gopls 的 code action 只会展示一个 import 选项，也就是所谓的最优选项，不会展示其它的选项，这在实际项目开发中会比较折腾，
   尝尝需要手动在 import 块中录入内容才可以，此外 gopls 也不支持代码提示的时候提示出其他包，例如引入了一个 log 包，那么就永远
   只会提示这个 log 包下的内容，而不是像 GoLand 可以提示出其它包中的内容以供选择。
