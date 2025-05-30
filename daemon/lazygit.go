package main

import (
	"log/slog"
	"os/exec"
	"strings"
)

// processLazygit 处理lazygit主题
func processLazygit(appearance Appearance) {
	// 获取lazygit配置目录
	cmd := exec.Command("lazygit", "--print-config-dir")
	output, err := cmd.Output()
	if err != nil {
		slog.Error("get lazygit config directory failed", "cmd", cmd, "err", err)
		return
	}
	// 移除输出末尾的换行符
	dir := strings.TrimSpace(string(output))
	// 获取需要加载的主题配置文件路径
	filename := dir + "/config-catppuccin-latte-blue.yml"
	if appearance == AppearanceDark {
		filename = dir + "/config-catppuccin-mocha-blue.yml"
	}
	// 软连接路径
	linkName := dir + "/config.yml"
	// 重新建立软链接
	err = relink(filename, linkName)
	if err != nil {
		slog.Error("relink lazygit config failed", "filename", filename, "linkName", linkName, "err", err)
		return
	}
	slog.Info("process lazygit config complete", "filename", filename, "linkName", linkName)
}
