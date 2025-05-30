#!/bin/bash

# 按照操作系统安装守护进程

#创建软链接的函数
create_link() {
    #原始路径和目标路径
    local source="$1"
    local target="$2"

    #如果原始文件存在或为软链接则删除
    if [ -e "$target" ] || [ -L "$target" ]; then
        #删除文件命令
        local command="rm -rf \"$target\""
        echo -e "删除原始文件：$command"
        #执行命令并判断是否失败
        if ! sh -c "$command"; then
            echo -e "错误：删除原始文件失败：$(ls -l "$target")" >&2
            return 1
        fi
    fi
    #创建软链接命令
    local command="ln -s \"$source\" \"$target\""
    echo -e "创建软连接：$command"
    #执行命令并判断是否失败
    if ! sh -c "$command"; then
        echo -e "错误：创建软连接失败：$source -> $target" >&2
        return 1
    fi
    #创建成功后输出日志
    echo -e "创建软链接成功：$(ls -l "$target")"
    return 0
}

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
source="$(pwd)/dotfiles_daemon.$os.$arch"

# 判断文件是否存在
if [ ! -f "$source" ]; then
    echo "<找不到待执行程序：$source>"
    exit 1
fi

# 判断文件是否可执行
if [[ ! -x "$source" ]]; then
    # 尝试为文件添加可执行权限
    if ! chmod +x "$source"; then
        echo "<添加可执行权限失败：$source>"
        exit 1
    fi
fi

#创建可执行文件软连接
create_link "$source" "$HOME/.dotfiles_daemon"

# 按照不同操作系统执行不同指令
case "$os" in
darwin)
    #创建软连接
    create_link "$(pwd)/dotfiles_daemon.conf" "/opt/homebrew/etc/supervisor.d/dotfiles_daemon.conf"
    #刷新supervisor
    supervisorctl reload
    supervisorctl status
    ;;
linux)
    echo "后续需要自己创建软连接并使用supervisor启动守护进程"
    ;;
esac
