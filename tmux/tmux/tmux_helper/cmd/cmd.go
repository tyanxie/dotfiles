// Package cmd 命令执行入口
package cmd

import (
	"github.com/tyanxie/dotfiles/tmux/tmux/tmux_helper/cmd/stat"
	"github.com/tyanxie/dotfiles/tmux/tmux/tmux_helper/cmd/weather"
	"github.com/urfave/cli/v2"
)

// New 创建新的命令实例
func New() *cli.App {
	// 初始化应用信息
	app := cli.NewApp()
	// 应用名称
	app.Name = "tmux_helper"
	// 应用使用介绍
	app.Usage = "tmux helper tools"
	// 隐藏版本信息
	app.HideVersion = true
	// 引入子命令
	app.Commands = append(app.Commands, stat.Command(), weather.Command())
	// 返回应用
	return app
}
