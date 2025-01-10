#!/bin/bash

#原始路径和目标路径
source="$(pwd)/ideavimrc"
target="$HOME/.ideavimrc"

#创建软链接的函数
create_link() {
    #删除原始目标文件
    rm -rf "$target"
    #创建软链接
    ln -s "$source" "$target"
    #如果创建失败则输出日志并退出脚本
    if [ $? -ne 0 ]; then
        echo "错误：创建 .ideavimrc 软连接失败：$source -> $target"
        exit 1
    fi
    #创建成功后输出日志并退出脚本
    echo "创建 .ideavimrc 软链接成功"
    ls -l "$target"
    exit 0
}

#判断文件是否不存在
if [ ! -e "$target" ]; then
    #文件不存在则直接创建链接
    create_link
else
    #文件存在则询问用户是否删除文件
    echo -n ".ideavimrc 已经存在，是否删除并重新创建？（y/n）:"
    #等待用户输入
    read -r input
    #如果用户输入是y或Y，则删除原始配置并重新创建
    if [[ "$input" =~ ^[Yy]$ ]]; then
        create_link
    fi
fi
