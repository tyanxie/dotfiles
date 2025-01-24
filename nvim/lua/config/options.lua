-- 设置leader键
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Snacks动画，设置为false可以全局关闭snacks动画
vim.g.snacks_animate = true

-- 保存时禁止自动格式化
vim.g.autoformat = false

-- 同步系统剪切板
vim.opt.clipboard = "unnamedplus"
-- ssh链接时使用OSC52传输剪切板数据
if os.getenv("SSH_CLIENT") ~= nil or os.getenv("SSH_TTY") ~= nil then
    -- wezterm不支持读取系统剪切板，因此需要自己实现一个paste函数取代原有的paste函数，否则会导致粘贴时卡住
    -- https://github.com/neovim/neovim/discussions/28010#discussioncomment-10187140
    local function paste()
        return {
            vim.split(vim.fn.getreg(""), "\n"),
            vim.fn.getregtype(""),
        }
    end

    -- 使用OSC52支持ssh复制内容到本机剪切板
    -- 注意使用的终端仿真器需要支持OSC52
    vim.g.clipboard = {
        name = "OSC 52",
        copy = {
            ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
            ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
        },
        paste = {
            ["+"] = paste,
            ["*"] = paste,
        },
    }
end

-- 配置补全选项
-- menu 显示补全菜单
-- menuone 即使只有一个补全候选项也显示菜单
-- noselect 不自动选择补全项，而是等待用户选择
vim.opt.completeopt = "menu,menuone,noselect"

-- 具有conceal属性的文本的处理类型，conceal属性的文本是可以被隐藏的，例如markdown中的加粗标识*
-- 0：不隐藏任何字符（默认值）
-- 1：隐藏具有 conceal 属性的字符，但在光标移动到该字符上时显示
-- 2：隐藏具有 conceal 属性的字符，即使在光标移动到该字符上时也不显示
-- 3：隐藏具有 conceal 属性的字符，并且不占用任何空间。这意味着隐藏的字符不会留出空白
-- vim.opt.conceallevel = 2

-- 退出前确认是否需要保存
vim.opt.confirm = true

-- 高亮显示当前行
vim.opt.cursorline = true

-- TAB宽度
vim.opt.tabstop = 4
-- 使用空格代替TAB
vim.opt.expandtab = true
-- 插入模式下按下TAB插入的空格数量
vim.opt.softtabstop = 4
-- 缩进宽度
vim.opt.shiftwidth = 4
-- 缩进时将缩进量取整
vim.opt.shiftround = true
-- 自动插入缩进
vim.opt.smartindent = true

-- 折叠代码
vim.opt.fillchars = {
    foldopen = "",
    foldclose = "",
    fold = " ",
    foldsep = " ",
    diff = "╱",
    eob = " ",
}
-- 设置为99使得打开时不自动缩进
vim.opt.foldlevel = 99
-- 使用表达式进行缩进，配置foldexpr选项使用
vim.opt.foldmethod = "expr"
-- 使用treessiter进行缩进
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
-- 缩进时不显示任何文本
vim.opt.foldtext = ""
-- 始终显示符号列，即行号和文本之间的列
vim.opt.signcolumn = "yes"
-- 使用snack接管状态栏列（行号、诊断标记等），这也是实现缩进展示图标的能力
vim.opt.statuscolumn = [[%!v:lua.require'snacks.statuscolumn'.get()]]

-- 格式化表达式
vim.opt.formatexpr = "v:lua.require'conform'.formatexpr()"
-- 格式化选项，不配置c/r/o选项，实现在注释行换行时不会自动增加注释符号
vim.opt.formatoptions = "jqlnt"

-- grep输出格式
vim.opt.grepformat = "%f:%l:%c:%m"
-- grep使用rg命令
vim.opt.grepprg = "rg --vimgrep"
-- 搜索时忽略大小写
vim.opt.ignorecase = true
-- 使用大写字母时不忽略大小写
vim.opt.smartcase = true

-- command模式下实时预览
vim.opt.inccommand = "nosplit"

-- 跳转（如<C-O>、<C-I>命令）选项
-- stack: 允许在跳转列表中记录重复的位置。默认情况下，如果你跳转到一个已经存在于跳转列表中的位置，它不会被再次记录。启用 stack 选项后，即使位置重复，也会记录
-- view: 记录视图状态（如窗口布局、光标位置等），使得跳转后可以恢复之前的状态
vim.opt.jumpoptions = "view"

-- 使用全局状态栏
-- 0：从不显示状态栏。
-- 1：仅在有多个窗口时显示状态栏。
-- 2：总是显示状态栏，即使只有一个窗口。
-- 3：全局状态栏模式。状态栏显示在整个 Neovim 窗口的底部，而不是每个窗口的底部。
vim.o.laststatus = 3

-- 显示一些不可见的字符，比如行尾的空格
vim.opt.list = true

-- 启用鼠标
vim.opt.mouse = "a"

-- 弹出菜单透明度
vim.opt.pumblend = 10
-- 弹出菜单最大条数
vim.opt.pumheight = 10

-- 显示行号和相对行号
vim.opt.number = true
vim.opt.relativenumber = true

-- 禁用默认标尺，即状态栏的行号和列号，交给lualine显示
vim.opt.ruler = false
-- 不显示当前模式，交给lualine显示
vim.opt.showmode = false

-- 上下滚动至少展示的行数
vim.opt.scrolloff = 16
-- 左右滚动至少展示的列数
vim.opt.sidescrolloff = 8

-- 会话保存选项
vim.opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }

-- 信息显示控制
-- a：在普通模式下不显示“ATTENTION”提示
-- c：压缩完成菜单消息，不显示“匹配 x 个”
-- F：不要给 :file 命令显示“文件名已修改”消息
-- i：在插入模式下不显示插入模式消息
-- l：不显示 :lsp 命令的完成消息
-- m：不显示 --更多-- 提示
-- n：当文件被写入时，不显示 [New File] 信息
-- o：覆盖文件时不显示“是否覆盖？”提示
-- r：当文件名短到可以放在一行时，不显示 [readonly] 信息
-- s：不显示搜索匹配的消息
-- t：不显示“已交换文件”消息
-- T：当 :filetype 命令启用时不显示消息
-- W：不显示“写入文件”消息
-- x：不显示“文件已修改”消息
-- A：不显示“附加”消息
-- I：不显示插入模式下的“正在插入”提示
-- S：不显示拼写检查消息
vim.opt.shortmess:append({ W = true, I = true, c = true, C = true })

-- 拼写检查
vim.opt.spelllang = { "en" }

-- 新的窗口出现在右侧
vim.opt.splitright = true
-- 新的窗口出现在下侧
vim.opt.splitbelow = true
-- 保持窗口位置
vim.opt.splitkeep = "screen"

-- 启用真彩支持
vim.opt.termguicolors = true

-- 序列按键的超时时间
vim.opt.timeoutlen = 300

-- 记录undo信息
vim.opt.undofile = true
vim.opt.undolevels = 10000

-- 更新交换文件和触发CursorHold事件的时间
vim.opt.updatetime = 200

-- visual模式下允许光标移动到没有文本的位置
vim.opt.virtualedit = "block"

-- 命令行补全模式
vim.opt.wildmode = "longest:full,full"

-- 窗口最小宽度
vim.opt.winminwidth = 5

-- 关闭自动换行
vim.opt.wrap = false

-- 在第120列展示高亮竖线
vim.opt.colorcolumn = "120"
