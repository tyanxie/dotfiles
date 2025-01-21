-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- 设置高亮竖线的颜色
vim.cmd([[highlight ColorColumn ctermbg=NONE guibg=#323438]])

-- 移除formatoptions选项中的c/r/o选项，实现在注释行换行时不会自动增加注释符号
vim.opt.formatoptions:remove("c")
vim.opt.formatoptions:remove("r")
vim.opt.formatoptions:remove("o")
