return {
  "jake-stewart/multicursor.nvim",
  branch = "1.0",
  config = function()
    -- 获取multicursor库
    local mc = require("multicursor-nvim")

    -- 初始化模块
    mc.setup()

    -- 添加快捷键
    local set = vim.keymap.set

    -- 在当前位置添加光标并向上
    set({ "n", "x" }, "<up>", function()
      mc.lineAddCursor(-1)
    end, { desc = "Add cursor above the main cursor" })
    -- 在当前位置添加光标并向下
    set({ "n", "x" }, "<down>", function()
      mc.lineAddCursor(1)
    end, { desc = "Add cursor below the main cursor" })
    -- 跳过当前位置并向上
    set({ "n", "x" }, "<leader><up>", function()
      mc.lineSkipCursor(-1)
    end, { desc = "Skip cursor above the main cursor" })
    -- 跳过当前位置并向下
    set({ "n", "x" }, "<leader><down>", function()
      mc.lineSkipCursor(1)
    end, { desc = "Skip cursor below the main cursor" })

    -- 使用Ctrl和鼠标左键添加和删除光标
    set("n", "<c-leftmouse>", mc.handleMouse)
    set("n", "<c-leftdrag>", mc.handleMouseDrag)

    -- 自定义光标高亮
    local hl = vim.api.nvim_set_hl
    hl(0, "MultiCursorCursor", { link = "Cursor" })
    hl(0, "MultiCursorVisual", { link = "Visual" })
    hl(0, "MultiCursorSign", { link = "SignColumn" })
    hl(0, "MultiCursorMatchPreview", { link = "Search" })
    hl(0, "MultiCursorDisabledCursor", { link = "Visual" })
    hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
    hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
  end,
}
