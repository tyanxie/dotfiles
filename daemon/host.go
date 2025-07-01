package main

import (
	"bufio"
	"bytes"
	"log/slog"
	"os/exec"
	"strings"
)

// SSHHost ssh配置中的主机信息
type SSHHost struct {
	Hostname string // 主机地址
	Port     string // ssh端口
}

// NewSSHHost 创建ssh配置主机信息
func NewSSHHost(hostname, port string) *SSHHost {
	return &SSHHost{
		Hostname: hostname,
		Port:     port,
	}
}

// IsConnect 判断当前是否连接到指定主机
func (s *SSHHost) String() string {
	return s.Hostname + ":" + s.Port
}

// IsConnect 判断当前是否连接到指定主机
func (s *SSHHost) IsConnect() bool {
	// 执行命令获取与当前主机建立的链接
	cmd := exec.Command("lsof", "-i", "@"+s.Hostname) //nolint
	output, err := cmd.CombinedOutput()
	if err != nil {
		slog.Error("lsof check connect host failed", "err", err, "cmd", cmd.String())
		return false
	}
	// 目标地址
	address := s.Hostname + ":" + s.Port
	// 遍历结果每一行并判断是否存在目标地址
	scanner := bufio.NewScanner(bytes.NewReader(output))
	for scanner.Scan() {
		// 获取当前行
		line := scanner.Text()
		// 判断是否包含目标地址
		if !strings.Contains(line, address) {
			continue
		}
		// 判断链接是否正常
		if !strings.Contains(line, "(ESTABLISHED)") {
			continue
		}
		// 包含目标地址并且链接正常，认为正常链接到指定主机
		slog.Info("lsof check ssh to host complete", "lsof", line)
		return true
	}
	// 所有行都未命中，认为没有链接
	return false
}
