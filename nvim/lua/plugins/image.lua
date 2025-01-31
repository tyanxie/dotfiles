return {
    "3rd/image.nvim",
    event = "VeryLazy",
    -- 非Linux系统才启用，Linux系统上配置难度高并且性能差，暂时不在Linux上启用
    enabled = require("util").not_linux(),
    opts = {},
}
