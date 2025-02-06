// Package main 程序主入口
package main

import (
	"errors"
	"flag"
	"fmt"
	"strings"
	"time"

	"github.com/shirou/gopsutil/v4/cpu"
	"github.com/shirou/gopsutil/v4/mem"
	"github.com/shirou/gopsutil/v4/net"
)

// 要统计的时间间隔
var interval int

func main() {
	// 解析参数
	flag.IntVar(&interval, "interval", 1,
		"Fetch data interval in seconds, same as tmux status refresh interval. Default: 1")
	flag.Parse()

	// 参数校验
	if interval <= 0 {
		panic(errors.New("interval must greeter than 0"))
	}

	// 获取当前总上传/下载字节数
	beginSent, beginRecv, err := getNetIOStat()
	if err != nil {
		panic(fmt.Errorf("get begin net io stat failed: %w", err))
	}

	// 获取cpu整体利用率，此时会等待一段时间收集cpu信息
	cpuPercent, err := cpu.Percent(time.Duration(interval)*time.Second, false)
	if err != nil {
		panic(fmt.Errorf("get cpu percent failed: %w", err))
	}

	// 等待一段时间后在获取一次总上传/下载字节数
	endSent, endRecv, err := getNetIOStat()
	if err != nil {
		panic(fmt.Errorf("get end net io stat failed: %w", err))
	}

	// 获取内存状态
	memStat, err := mem.VirtualMemory()
	if err != nil {
		panic(fmt.Errorf("get virtual memory stat failed: %w", err))
	}

	// 一行输出最终信息
	fmt.Printf(" %.2f%%  %.2f%%  %dB/s  %dB/s",
		cpuPercent[0],
		memStat.UsedPercent,
		endSent-beginSent/uint64(interval),
		endRecv-beginRecv/uint64(interval),
	)
}

// getNetIOStat 获取当前的网络io信息，移除回环等地址
// @return sent 当前时间点发送的总字节数
// @return recv 当前时间点接收的总字节数
func getNetIOStat() (sent, recv uint64, err error) {
	// 获取所有网卡的信息
	allIOCounters, err := net.IOCounters(true)
	if err != nil {
		return 0, 0, err
	}
	// 遍历所有网卡信息记录发送和接收的总字节数
	for _, stat := range allIOCounters {
		// 如果是回环地址，则忽略，使用前缀lo判断，兼容mac系统上的lo0
		if strings.HasPrefix(stat.Name, "lo") {
			continue
		}
		sent += stat.BytesSent
		recv += stat.BytesRecv
	}
	return sent, recv, nil
}
