local tmux = require("tmux")

vim.keymap.set("n", "<leader>ts", tmux.switch, { desc = "切换tmux会话" })
vim.keymap.set("n", "<leader>tn", tmux.new, { desc = "创建tmux会话" })
