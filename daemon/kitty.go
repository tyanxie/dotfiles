package main

import (
	"errors"
	"fmt"
	"io/fs"
	"log/slog"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

const (
	kittySocketPrefix = "mykitty"                                       // kitty的socket文件前缀
	kittenCommandName = "/Applications/kitty.app/Contents/MacOS/kitten" // kitten命令
)

// processKitty 处理kitty主题
func processKitty(appearance Appearance) {
	// 获取需要加载的主题配置文件路径
	filename := home + "/.config/kitty/catppuccin_latte.conf"
	if appearance == AppearanceDark {
		filename = home + "/.config/kitty/catppuccin_mocha.conf"
	}
	// 软连接路径
	linkName := home + "/.config/kitty/theme.conf"
	// 重新建立软连接
	err := relink(filename, linkName)
	if err != nil {
		slog.Error("relink kitty theme file failed", "filename", filename, "linkName", linkName, "err", err)
		return
	}
	// 查找kitty的socket文件路径
	socketPath, err := findKittySocketPath()
	if err != nil {
		slog.Error("find kitty socket path failed", "err", err)
		return
	}
	// 发送重载kitty配置命令
	cmd := exec.Command(kittenCommandName, "@", "--to", fmt.Sprintf("unix:%s", socketPath), "load-config") // nolint
	// 执行命令
	output, err := cmd.CombinedOutput()
	if err != nil {
		slog.Error("exec command failed", "err", err, "cmd", cmd, "output", output)
		return
	}
	slog.Info("process kitty theme complete", "filename", filename, "cmd", cmd)
}

// findKittySocketPath 查找kitty的socket文件路径
func findKittySocketPath() (string, error) {
	// 获取系统临时目录
	tempDir := os.TempDir()
	// 打开目录
	dirEntries, err := os.ReadDir(tempDir)
	if err != nil {
		return "", fmt.Errorf("read temp directory failed, tempDir:%s, err:%w", tempDir, err)
	}
	// 遍历查找socket文件
	for _, entry := range dirEntries {
		if entry.IsDir() || entry.Type() != fs.ModeSocket {
			continue
		}
		// 文件名称
		filename := entry.Name()
		if strings.HasPrefix(entry.Name(), kittySocketPrefix) {
			// 返回拼接后的文件完整路径
			return filepath.Join(tempDir, filename), nil
		}
	}
	// 走到这里代表没有找到
	return "", errors.New("kitty socket not found")
}
