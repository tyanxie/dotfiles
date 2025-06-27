#!/bin/bash

# 用于监控tmux-buffer是否有变化，如果有则通过OSC52发送数据

# 获取最新一个buffer的名称
get_last_buffer_name() {
    tmux list-buffers -F "#{buffer_name}" | head -n 1
}

# 已启动时最新的buffer名称作为初始值
last_buffer_name="$(get_last_buffer_name)"

echo "start monitor tmux buffer, current buffer: $last_buffer_name"

# 监控 tmux buffer
while true; do
    # 获取当前最新的buffer名称
    current_buffer_name=$(get_last_buffer_name)

    # 如果当前buffer名称和上次buffer名称不一样，则说明有新内容需要处理
    if [[ "$current_buffer_name" != "$last_buffer_name" ]]; then
        echo "find new buffer: $current_buffer_name"
        # 立刻更新最新处理的buffer名称
        last_buffer_name="$current_buffer_name"
        # 获取最新buffer中的内容
        content=$(tmux show-buffer -b "$current_buffer_name")

        # 获取活跃的ssh链接列表如果存在则进行处理
        ssh_sessions=$(who | grep 'pts')
        if [ -n "$ssh_sessions" ]; then
            # 向所有当前活跃的ssh链接中发送通过OSC52发送内容
            echo "$ssh_sessions" | awk '{print $2}' | while read -r terminal; do
                terminal="/dev/$terminal"
                printf "\033]52;c;$(echo -n "$content" | base64)\a" >>$terminal
                printf "send buffer [%s] content to ssh session [%s]\n" "$current_buffer_name" "$terminal"
            done
        fi
    fi

    # 间隔200ms进行处理，复制内容尽量快速
    sleep 0.2
done
