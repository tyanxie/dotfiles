package main

import (
	"log/slog"
	"os/exec"
)

// processTmux 处理tmux主题
func processTmux(appearance Appearance) {
	// 获取需要加载的主题配置文件路径
	filename := home + "/.config/tmux/themes/catppuccin-latte.conf"
	if appearance == AppearanceDark {
		filename = home + "/.config/tmux/themes/catppuccin-mocha.conf"
	}
	// 创建主题配置文件命令
	cmd := exec.Command("tmux", "source-file", filename) // nolint
	// 执行命令
	output, err := cmd.CombinedOutput()
	if err != nil {
		slog.Error("exec command failed", "err", err, "cmd", cmd, "output", output)
		return
	}
	slog.Info("process tmux theme complete", "cmd", cmd)
}
