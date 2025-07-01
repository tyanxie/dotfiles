package main

import (
	"fmt"
	"log/slog"
	"net/http"
)

// initSyncRemote 远程机初始化同步
func initSyncRemote() {
	// 运行模式
	runMode = RunModeRemote
	// 创建多路复用器，监听数据
	mux := http.NewServeMux()
	mux.HandleFunc("/", func(_ http.ResponseWriter, r *http.Request) {
		// 从url中获取外观信息
		appearanceStr := r.URL.Query().Get("appearance")
		// 解析外观值
		appearance, err := parseAppearance(appearanceStr)
		if err != nil {
			slog.Error("parse appearance failed", "s", appearanceStr, "err", err)
			return
		}
		// 异步处理
		go process(appearance)
	})
	// 监听端口
	addr := fmt.Sprintf(":%d", defaultPort)
	if err := http.ListenAndServe(addr, mux); err != nil { //nolint
		slog.Error("ListenAndServe failed", "addr", addr, "err", err)
	}
}
