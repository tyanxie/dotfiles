# tmux

个人 [tmux](https://github.com/tmux/tmux) 配置。

- [依赖安装](#依赖安装)
- [内置工具介绍](#内置工具介绍)
  - [tmux_buffer_monitor](#tmux_buffer_monitor)
  - [sensible.tmux](#sensibletmux)
  - [weather.sh](#weathersh)

## 依赖安装

- [tmux-mem-cpu-load](https://github.com/thewtex/tmux-mem-cpu-load): 显示cpu、内存使用量的工具。

## 内置工具介绍

本仓库内置一些工具包，一般位于 [tmux](tmux) 目录下。

### tmux_buffer_monitor

tmux 缓冲区监控脚本，用于在远程服务器上复制内容的时候可以通过 OSC52 协议将复制的内容发送到本地机器的剪切板中，
注意要使用该脚本首先需要终端模拟器的支持 OSC52 协议。

安装方式：脚本提供了 [supervisor](https://github.com/Supervisor/supervisor) 配置文件进行运行，
只需要将 `tmux_buffer_monitor.conf` 文件拷贝或软连接到 `supervisor` 配置路径，
并通过 `supervisorctl update` 等命令启动即可。

日志观察：可以在 `/tmp/tmux_buffer_monitor.log` 文件中查看脚本的运行日志。

实现原理：

1. 监控 tmux 缓冲区列表（`tmux list-buffers`），如果有更新会进行处理。
2. 每次处理的时候通过 who 等命令获取到当前活跃的所有的 ssh 链接的 pts 句柄。
3. 以 OSC52 协议格式向上述获得的 pts 句柄发送内容。
4. 此时只要用户使用的终端模拟器支持 OSC52 协议（如 wezterm），则内容可以正常出现在系统剪切板。

### tmux_helper

使用 [go](https://go.dev/) 语言编写的 tmux 帮助程序。

特性：

1. 获取一段时间内的 CPU 使用率、内存使用率、网络上传/下载速率。

### sensible.tmux

来源于 [tmux-sensible](https://github.com/tmux-plugins/tmux-sensible) 的 tmux 基本配置。

### weather.sh

通过请求 [wttr.in](https://github.com/chubin/wttr.in) 获取当前天气信息，通过调用该脚本将天气信息展示在状态栏中。

由于状态栏每 2 秒就会更新一次，如果直接每次都请求 `wttr.in` 会导致过于频繁的请求，
因此该脚本的具体逻辑是将获取到的天气信息存储到文件中，并且每次都读取这个文件来获取。
如此，只有在文件超过一定时间内未更新（通过 `find` 命令实现）或者文件不存在的时候，才会触发发起请求。
