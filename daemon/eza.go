package main

import (
	"log/slog"
	"runtime"
)

var ezaConfigDirectory = "" // eza配置目录

// initEzaConfig 初始化eza配置
func initEzaConfig() {
	// 按照操作系统区分
	switch runtime.GOOS {
	case GOOSDarwin:
		ezaConfigDirectory = home + "/Library/Application Support/eza"
	case GOOSLinux:
		ezaConfigDirectory = home + "/.config/eza"
	default:
		slog.Error("unsupported eza config os", "GOOS", runtime.GOOS)
		return
	}
}

// processEza 处理eza主题
func processEza(appearance Appearance) {
	if ezaConfigDirectory == "" {
		slog.Error("unsupported eza config os", "GOOS", runtime.GOOS)
		return
	}
	// 获取需要加载的主题配置文件路径
	filename := ezaConfigDirectory + "/themes/catppuccin-latte.yml"
	if appearance == AppearanceDark {
		filename = ezaConfigDirectory + "/themes/catppuccin-mocha.yml"
	}
	// 软连接路径
	linkName := ezaConfigDirectory + "/theme.yml"
	// 重新建立软连接
	err := relink(filename, linkName)
	if err != nil {
		slog.Error("relink eza theme file failed", "filename", filename, "linkName", linkName, "err", err)
		return
	}
	slog.Info("process eza theme complete", "filename", filename, "linkName", linkName)
}
