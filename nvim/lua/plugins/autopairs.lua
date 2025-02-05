-- 自动补全字符对，例如输入左括号自动补全右括号
-- 和mini.pairs相比更加智能，例如在单词之上输入左括号，不会自动补全右括号，使用起来更方便。
return {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
}
