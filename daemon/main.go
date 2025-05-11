// Package main 进程入口
package main

import (
	"bytes"
	"log/slog"
	"os"
	"os/exec"
	"sync"
	"time"
)

// Appearance 外观模式
type Appearance int32

// 外观模式枚举
const (
	AppearanceUnknown Appearance = iota
	AppearanceLight
	AppearanceDark
)

var (
	currentAppearance = AppearanceUnknown // 记录当前使用的外观模式
	mutex             sync.Mutex          // 处理加锁
	home              string              // 用户家目录
)

func main() {
	// 获取用户家目录
	var err error
	home, err = os.UserHomeDir()
	if err != nil {
		slog.Error("get user home directory failed", "err", err)
	} else {
		slog.Info("user home directory", "dir", home, "path", os.Getenv("PATH"))
	}

	// 定时处理
	ticker := time.NewTicker(350 * time.Millisecond)
	defer ticker.Stop()
	// 循环处理
	for {
		// 执行处理
		process()
		// 等待下次执行
		<-ticker.C
	}
}

// process 执行处理
func process() {
	// 尝试加锁
	if !mutex.TryLock() {
		slog.Info("try lock failed, maybe is processing now")
		return
	}
	defer mutex.Unlock()

	// 获取当前实际外观
	appearance := getAppearance()
	// 如果实际外观与当前外观一致，则无需继续处理
	if appearance == currentAppearance {
		return
	}

	// 执行处理
	processTmux(appearance)

	// 修改实际外观
	slog.Info("change appearance complete", "before", currentAppearance, "now", appearance)
	currentAppearance = appearance
}

// getAppearance 获取外观
func getAppearance() Appearance {
	// macos系统通过读取AppleInterfaceStyle获取
	output, err := exec.Command("defaults", "read", "-g", "AppleInterfaceStyle").CombinedOutput()
	// 结果中包含Dark则说明是深色模式
	if err == nil && bytes.Contains(output, []byte("Dark")) {
		return AppearanceDark
	}
	// 默认使用浅色模式
	return AppearanceLight
}

// processTmux 处理tmux主题
func processTmux(appearance Appearance) {
	// 获取需要加载的主题配置文件路径
	filename := home + "/.config/tmux/themes/catppuccin-latte.conf"
	if appearance == AppearanceDark {
		filename = home + "/.config/tmux/themes/catppuccin-mocha.conf"
	}
	// 创建主题配置文件命令
	cmd := exec.Command("tmux", "source-file", filename)
	// 执行命令
	output, err := cmd.CombinedOutput()
	if err != nil {
		slog.Error("exec command failed", "err", err, "cmd", cmd, "output", output)
		return
	}
	slog.Info("process tmux theme complete", "cmd", cmd)
}
