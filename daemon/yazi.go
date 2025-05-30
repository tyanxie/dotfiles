package main

import "log/slog"

// processYazi 处理yazi主题
func processYazi(appearance Appearance) {
	// 获取需要加载的主题配置文件路径
	filename := home + "/.config/yazi/catppuccin_latte.toml"
	if appearance == AppearanceDark {
		filename = home + "/.config/yazi/catppuccin_mocha.toml"
	}
	// 软连接路径
	linkName := home + "/.config/yazi/theme.toml"
	// 重新建立软连接
	err := relink(filename, linkName)
	if err != nil {
		slog.Error("relink yazi theme file failed", "filename", filename, "linkName", linkName, "err", err)
		return
	}
	slog.Info("process yazi theme complete", "filename", filename, "linkName", linkName)
}
