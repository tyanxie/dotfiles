#!/bin/bash

filename="${TMPDIR:-/tmp}tmux-weather.tmp"                   # 天气信息存放路径
url="https://wttr.in/Shenzhen?format=%l:%C+%t&lang=zh-cn" # 天气信息API接口

# 如果文件不存在或文件超过10分钟未修改就更新其中的内容
if [ ! -f "$filename" ] || [ "$(find "$filename" -mmin +10)" ]; then
    # 获取天气信息
    weather=$(curl "$url")
    # 命令的执行结果
    result=$?
    # 如果执行成功则将结果输出文件，否则输出错误信息到文件
    if [ $result -eq 0 ]; then
        echo "$weather" >"$filename"
    else
        echo "<获取天气信息失败>" >"$filename"
    fi
fi

# 输出文件内容
cat "$filename"
