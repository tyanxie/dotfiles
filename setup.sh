#!/bin/bash

#创建软链接的函数
create_link() {
    #名称
    local name="$1"
    #原始路径和目标路径
    local source="$2"
    local target="$3"

    #如果原始文件存在或为软链接则删除
    if [ -e "$target" ] || [ -L "$target" ]; then
        #删除文件命令
        local command="rm -rf \"$target\""
        echo -e "[$name] 删除原始文件：$command"
        #执行命令并判断是否失败
        if ! sh -c "$command"; then
            echo -e "[$name] 错误：删除原始文件失败：$(ls -l "$target")" >&2
            return 1
        fi
    fi
    #创建软链接命令
    local command="ln -s \"$source\" \"$target\""
    echo -e "[$name] 创建软连接：$command"
    #执行命令并判断是否失败
    if ! sh -c "$command"; then
        echo -e "[$name] 错误：创建软连接失败：$source -> $target" >&2
        return 1
    fi
    #创建成功后输出日志
    echo -e "[$name] 创建软链接成功：$(ls -l "$target")"
    return 0
}

#初始化函数，负责判断对应配置文件路径是否存在，如果存在则提示是否需要删除，并作出相应动作
setup() {
    #名称
    local name="$1"
    #原始路径和目标路径
    local source="$2"
    local target="$3"

    #判断文件是否不存在且不为软链接
    if [ ! -e "$target" ] && [ ! -L "$target" ]; then
        #文件不存在则直接创建链接
        create_link "$name" "$source" "$target"
        return $?
    else
        #文件存在则询问用户是否删除文件
        echo -n "[$name] 文件已经存在（\"$target\"），是否删除并重新创建？（y/n）："
        #等待用户输入
        read -r input
        #如果用户输入是y或Y，则删除原始配置并重新创建
        if [[ "$input" =~ ^[Yy]$ ]]; then
            create_link "$name" "$source" "$target"
            return $?
        else
            echo "[$name] 跳过处理"
            return 0
        fi
    fi
}

#初始化lazygit配置
setup_lazygit() {
    #名称
    local name="$1"

    #本地路径
    local source_dir
    source_dir="$(pwd)/lazygit"

    #目标路径
    local target_dir
    if ! target_dir="$(lazygit --print-config-dir)"; then
        echo "获取 lazygit 配置目录失败"
        return 0
    fi

    #创建目标路径目录
    mkdir -p "$target_dir"

    #链接配置文件
    setup "$name" "$source_dir/config-catppuccin-latte-blue.yml" "$target_dir/config.yml"
    setup "$name" "$source_dir/config-catppuccin-latte-blue.yml" "$target_dir/config-catppuccin-latte-blue.yml"
    setup "$name" "$source_dir/config-catppuccin-mocha-blue.yml" "$target_dir/config-catppuccin-mocha-blue.yml"
    return $?
}

#初始化yazi配置
setup_yazi() {
    #名称
    local name="$1"
    #本地路径
    local source_dir
    source_dir="$(pwd)/yazi"
    #目标路径
    local target_dir="$HOME/.config/yazi"

    #如果目标目录存在或为软连接，则询问用户是否要删除
    if [ -e "$target_dir" ] || [ -L "$target_dir" ]; then
        echo -n "[$name] 文件已经存在（\"$target_dir\"），是否删除并重新创建？（y/n）："
        #等待用户输入
        read -r input
        #如果用户输入是y或Y，则删除原始路径并重新创建
        if [[ "$input" =~ ^[Yy]$ ]]; then
            rm -rf "$target_dir"
        else
            echo "[$name] 跳过处理"
            return 0
        fi
    fi

    #创建目标路径
    mkdir "$target_dir"

    #创建必要的软连接
    create_link "$name" "$source_dir/yazi.toml" "$target_dir/yazi.toml"
    create_link "$name" "$source_dir/keymap.toml" "$target_dir/keymap.toml"
    create_link "$name" "$source_dir/catppuccin_latte.toml" "$target_dir/theme.toml"
    create_link "$name" "$source_dir/catppuccin_latte.tmTheme" "$target_dir/catppuccin_latte.tmTheme"
    create_link "$name" "$source_dir/catppuccin_latte.toml" "$target_dir/catppuccin_latte.toml"
    create_link "$name" "$source_dir/catppuccin_mocha.tmTheme" "$target_dir/catppuccin_mocha.tmTheme"
    create_link "$name" "$source_dir/catppuccin_mocha.toml" "$target_dir/catppuccin_mocha.toml"
}

#如果一个参数都没有，需要报错
if [ "$#" -eq "0" ]; then
    echo "至少需要一个参数" >&2
    exit 1
fi

#遍历所有参数并进行处理
for arg in "$@"; do
    case $arg in
    btop)
        setup "$arg" "$(pwd)/btop" "$HOME/.config/btop"
        ;;
    kitty)
        setup "$arg" "$(pwd)/kitty" "$HOME/.config/kitty"
        ;;
    lazygit)
        setup_lazygit "$arg"
        ;;
    neovim | nvim)
        setup "$arg" "$(pwd)/nvim" "$HOME/.config/nvim"
        ;;
    sbar | sketchybar)
        setup "$arg" "$(pwd)/sketchybar" "$HOME/.config/sketchybar"
        ;;
    tmux)
        setup "$arg" "$(pwd)/tmux/tmux.conf" "$HOME/.tmux.conf"
        setup "$arg" "$(pwd)/tmux/tmux" "$HOME/.config/tmux"
        ;;
    wezterm)
        setup "$arg" "$(pwd)/wezterm" "$HOME/.config/wezterm"
        ;;
    yazi)
        setup_yazi "$arg"
        ;;
    golangci)
        setup "$arg" "$(pwd)/golangci.yml" "$HOME/.golangci.yml"
        ;;
    ideavimrc)
        setup "$arg" "$(pwd)/ideavimrc" "$HOME/.ideavimrc"
        ;;
    *)
        echo "不支持的参数：$arg" >&2
        ;;
    esac

    #处理完成一个参数后换行分隔
    echo ""
done

#输出执行完成结果
echo "执行完毕"
