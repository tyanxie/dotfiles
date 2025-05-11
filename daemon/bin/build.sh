#!/bin/bash

# 构建脚本，编译守护进程

# 编译时的ldflags参数
# `-s`禁用符号表，`-w`禁用DWARF调试信息，减少包体积
ldflags="-s -w"

# 编译命令
build_base_command="go build -ldflags=\"$ldflags\" -v"

# 编译执行函数
build() {
    # 系统
    local os="$1"
    # 架构
    local arch="$2"
    # 构造编译命令
    command="CGO_ENABLED=0 GOOS=$os GOARCH=$arch $build_base_command -o dotfiles_daemon.$os.$arch .."
    # 打印命令用于提示
    echo "$command"
    # 执行编译命令
    sh -c "$command"
}

# 编译darwin arm64版本
build darwin arm64

# 编译linux amd64版本
build linux amd64

# 重启supervisor对应服务
supervisorctl restart dotfiles_daemon
supervisorctl status dotfiles_daemon
