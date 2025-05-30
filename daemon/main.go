// Package main 进程入口
package main

import (
	"log/slog"
	"os"
	"path/filepath"
	"runtime"
	"strconv"
	"sync"

	sshconfig "github.com/kevinburke/ssh_config"
)

// Appearance 外观模式
type Appearance int32

// parseAppearance 反序列化Appearance
func parseAppearance(s string) (Appearance, error) {
	appearance, err := strconv.ParseInt(s, 10, 32)
	if err != nil {
		return AppearanceUnknown, err
	}
	return Appearance(appearance), nil
}

// 外观模式枚举
const (
	AppearanceUnknown Appearance = iota
	AppearanceLight
	AppearanceDark
)

// RunMode 运行模式
type RunMode int32

// 运行模式
const (
	RunModeUnknown = iota // 未知模式
	RunModeLocal          // 本地运行
	RunModeRemote         // 远程运行
)

const defaultPort = 33843 // 默认监听和请求的端口

var (
	runMode           RunMode             // 运行模式
	currentAppearance = AppearanceUnknown // 记录当前使用的外观模式
	mutex             sync.Mutex          // 处理加锁
	home              string              // 用户家目录
	remoteHostnames   []string            // ssh配置中远程机器地址列表
)

func main() {
	// 初始化用户家目录
	initUserHomeDir()
	// 初始化ssh配置
	initSSHConfig()

	// 简单按照操作系统进行区分，darwin为本机，linux为远程机
	switch runtime.GOOS {
	case "darwin":
		initSyncLocal()
	case "linux":
		initSyncRemote()
	default:
		slog.Error("unsupported os", "GOOS", runtime.GOOS)
		return
	}
}

// initUserHomeDir 初始化用户家目录
func initUserHomeDir() {
	var err error
	home, err = os.UserHomeDir()
	if err != nil {
		slog.Error("get user home directory failed", "err", err)
		return
	}
	slog.Info("user home directory", "dir", home, "path", os.Getenv("PATH"))
}

// initSSHConfig 初始化ssh配置
func initSSHConfig() {
	// 获取ssh配置路径
	configPath := filepath.Join(home, ".ssh", "config")
	// 打开文件解析ssh配置
	file, err := os.Open(configPath)
	if err != nil {
		slog.Error("open ssh config file failed", "path", configPath, "err", err)
		return
	}
	defer file.Close()
	// 解析配置
	config, err := sshconfig.Decode(file)
	if err != nil {
		slog.Error("decode ssh config failed", "path", configPath, "err", err)
		return
	}
	// 读取配置，获取目标地址列表
	for _, host := range config.Hosts {
		for _, pattern := range host.Patterns {
			hostname := sshconfig.Get(pattern.String(), "HostName")
			if hostname != "" {
				remoteHostnames = append(remoteHostnames, hostname)
			}
		}
	}
	slog.Info("get ssh remote hostnames complete", "hostnames", remoteHostnames)
}

// process 通用处理函数
func process(appearance Appearance) {
	// 尝试加锁
	if !mutex.TryLock() {
		slog.Info("try lock failed, maybe is processing now")
		return
	}
	defer mutex.Unlock()

	// 如果实际外观与当前外观一致，则无需继续处理
	if appearance == currentAppearance {
		return
	}

	// 按照运行模式的不同做的额外操作
	switch runMode {
	case RunModeLocal:
		// 将外观同步给远程机器
		for _, hostname := range remoteHostnames {
			go sendToRemote(appearance, hostname)
		}
	case RunModeRemote:
		// 将外观写入文件
		filename := filepath.Join(home, ".dotfiles-daemon-appearance")
		data := strconv.FormatInt(int64(appearance), 10)
		err := os.WriteFile(filename, []byte(data), 0666)
		if err != nil {
			slog.Error("write appearance to file failed", "appearance", appearance, "filename", filename, "err", err)
		}
	}

	// 执行处理
	processTmux(appearance)
	processYazi(appearance)
	processLazygit(appearance)

	// 修改实际外观
	slog.Info("change appearance complete", "before", currentAppearance, "now", appearance)
	currentAppearance = appearance
}
