package main

import (
	"fmt"
	"os"
)

// relink 删除原始文件并将目标文件软链接
func relink(filename, linkName string) error {
	// 尝试删除原有的软连接
	err := os.Remove(linkName)
	if err != nil {
		return fmt.Errorf("remove link failed: %w", err)
	}
	// 创建软连接
	err = os.Symlink(filename, linkName)
	if err != nil {
		return fmt.Errorf("create symlink failed: %w", err)
	}
	return nil
}
