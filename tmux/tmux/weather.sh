#!/bin/bash

filename="${TMPDIR:-/tmp/}tmux-weather.tmp"               # 天气信息存放路径
url="https://wttr.in/Shenzhen?format=%l:%C+%t&lang=zh-cn" # 天气信息API接口

# 如果文件不存在或文件超过10分钟未修改就更新其中的内容
if [ ! -f "$filename" ] || [ "$(find "$filename" -mmin +10)" ]; then
    # 获取天气信息，输出结果到文件，使用&>覆盖输出并且携带错误输出，使得错误信息可以被回顾
    curl "$url" &>"$filename"
    # 命令的执行结果
    result=$?
    # 命令执行失败输出错误提示，使得无论如何都能展示出有效信息
    if [ ! $result -eq 0 ]; then
        echo "<获取天气信息失败>" >>"$filename"
    fi
fi

# 输出文件内容
cat "$filename"
