// Package stat 系统当前状态信息命令
package stat

import (
	"errors"
	"fmt"
	"math"
	"strings"
	"time"

	"github.com/shirou/gopsutil/v4/cpu"
	"github.com/shirou/gopsutil/v4/mem"
	"github.com/shirou/gopsutil/v4/net"
	"github.com/urfave/cli/v2"
)

var interval int // 统计的秒级时间间隔

// command 命令实例
var command = &cli.Command{
	Name:    "stat",
	Aliases: []string{"s"},
	Usage:   "Get the current system status information",
	Action:  action,
	Flags: []cli.Flag{
		&cli.IntFlag{
			Name:        "interval",
			Aliases:     []string{"t"},
			Usage:       "The second-level interval for statistics",
			Value:       1,
			Destination: &interval,
			DefaultText: "1",
		},
	},
}

// Command 获取命令实现
func Command() *cli.Command {
	return command
}

// action 执行函数
func action(_ *cli.Context) error {
	// 参数校验
	if interval <= 0 {
		return errors.New("interval must greeter than 0")
	}

	// 获取当前总上传/下载字节数
	beginSent, beginRecv, err := getNetIOStat()
	if err != nil {
		return fmt.Errorf("get begin net io stat failed: %w", err)
	}

	// 获取cpu整体利用率，此时会等待一段时间收集cpu信息
	cpuPercent, err := cpu.Percent(time.Duration(interval)*time.Second, false)
	if err != nil {
		return fmt.Errorf("get cpu percent failed: %w", err)
	}

	// 等待一段时间后在获取一次总上传/下载字节数
	endSent, endRecv, err := getNetIOStat()
	if err != nil {
		return fmt.Errorf("get end net io stat failed: %w", err)
	}

	// 获取内存状态
	memStat, err := mem.VirtualMemory()
	if err != nil {
		return fmt.Errorf("get virtual memory stat failed: %w", err)
	}

	// 一行输出最终信息
	fmt.Printf(" %.2f%%  %.2f%%  %s/s  %s/s",
		cpuPercent[0],
		memStat.UsedPercent,
		humanateBytes(endSent-beginSent/uint64(interval)),
		humanateBytes(endRecv-beginRecv/uint64(interval)),
	)
	return nil
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

// humanateBytes 基于Byte单位生成易读的带宽单位，计算标准：1KB=1000B
// from: https://github.com/dustin/go-humanize/blob/961771c7ab9992c55cd100b0562246e970925856/bytes.go#L68
func humanateBytes(s uint64) string {
	// 小数字直接返回
	if s < 10 {
		return fmt.Sprintf("%dB", s)
	}
	// 计算基数
	e := math.Floor(math.Log(float64(s)) / math.Log(1000))
	// 获取单位
	sizes := []string{"B", "KB", "MB", "GB", "TB", "PB", "EB"}
	suffix := sizes[int(e)]
	// 计算在单位下的数值
	val := math.Floor(float64(s)/math.Pow(1000, e)*10+0.5) / 10
	// 格式化方式
	f := "%.0f%s"
	if val < 10 {
		f = "%.2f%s"
	}
	// 返回结果
	return fmt.Sprintf(f, val, suffix)
}
