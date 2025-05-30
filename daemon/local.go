package main

import (
	"bytes"
	"context"
	"fmt"
	"log/slog"
	"net/http"
	"os/exec"
	"time"
)

// initSyncLocal 本机初始化同步
func initSyncLocal() {
	// 运行模式
	runMode = RunModeLocal
	// 定时处理
	ticker := time.NewTicker(350 * time.Millisecond)
	defer ticker.Stop()
	// 循环处理
	for {
		// 获取当前外观
		appearance := getLocalAppearance()
		// 执行处理
		process(appearance)
		// 等待下次执行
		<-ticker.C
	}
}

// getLocalAppearance 获取外观
func getLocalAppearance() Appearance {
	// macos系统通过读取AppleInterfaceStyle获取
	output, err := exec.Command("defaults", "read", "-g", "AppleInterfaceStyle").CombinedOutput()
	// 结果中包含Dark则说明是深色模式
	if err == nil && bytes.Contains(output, []byte("Dark")) {
		return AppearanceDark
	}
	// 默认使用浅色模式
	return AppearanceLight
}

// sendToRemote 发送外观信息到远程地址
func sendToRemote(appearance Appearance, hostname string) {
	// 拼接地址
	url := fmt.Sprintf("http://%s:%d/?appearance=%d", hostname, defaultPort, appearance)
	// 构造context，200ms超时
	ctx, cancel := context.WithTimeout(context.Background(), 200*time.Millisecond)
	defer cancel()
	// 构造请求
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
	if err != nil {
		slog.Error("create remote request failed", "url", url, "err", err)
		return
	}
	// 发送请求
	rsp, err := http.DefaultClient.Do(req)
	if err != nil {
		slog.Error("send remote request failed", "req", req, "err", err)
		return
	}
	defer rsp.Body.Close()
	// 判断错误码
	if rsp.StatusCode != http.StatusOK {
		slog.Error("remote response status code not ok", "statsCode", rsp.StatusCode, "status", rsp.Status)
		return
	}
}
