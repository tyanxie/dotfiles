-- 向目标内容周围添加surround符号
-- 常见用法：
-- ysiw) - 向当前单词周围添加小括号 - y(ield)s(urround)i(n)w(word)
-- ds) - 删除最近的小括号 - d(elete)s(urround)
--
-- 备忘
-- 1. 一般来说用左符号（例如：(、[）新增时会自带空格，而用右符号（例如：)、]）时则不会
--      这主要是由于默认的surround配置中在左符号中自带了空格：
--      https://github.com/kylechui/nvim-surround/blob/ae298105122c87bbe0a36b1ad20b06d417c0433e/lua/nvim-surround/config.lua#L18
return {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    opts = {
        keys = {
            "y",
        },
    },
}
