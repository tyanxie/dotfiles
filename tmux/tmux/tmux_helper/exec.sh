#!/bin/bash

# 按照操作系统执行tmux_helper的工具

# 使用uname -s获取操作系统，同时通过tr命令将所有字符转为小写
os=$(uname -s | tr '[:upper:]' '[:lower:]')

# 使用uname -m获取系统架构
arch=$(uname -m)
# arch取值兼容
case "$arch" in
x86_64)
    arch="amd64"
    ;;
esac

# 使用os和arch拼接文件路径
filename="$HOME/.config/tmux/tmux_helper/tmux_helper.$os.$arch"

# 判断文件是否存在
if [ ! -f "$filename" ]; then
    echo "<找不到待执行程序：$filename>"
    exit 1
fi

# 判断文件是否可执行
if [[ ! -x "$filename" ]]; then
    # 尝试为文件添加可执行权限
    if ! chmod +x "$filename"; then
        echo "<添加可执行权限失败：$filename>"
        exit 1
    fi
fi

# 执行并透传所有参数
$filename "$@"
