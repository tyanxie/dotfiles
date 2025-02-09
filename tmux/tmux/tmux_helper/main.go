// Package main 程序主入口
package main

import (
	"fmt"
	"os"

	"github.com/tyanxie/dotfiles/tmux/tmux/tmux_helper/cmd"
)

func main() {
	if err := cmd.New().Run(os.Args); err != nil {
		fmt.Printf("<执行错误：%v>\n", err)
	}
}
