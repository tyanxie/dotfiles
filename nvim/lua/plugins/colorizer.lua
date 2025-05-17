-- 用于预览如16进制表示的颜色的荧光笔插件
return {
  "norcalli/nvim-colorizer.lua",
  event = "VeryLazy",
  opts = {
    -- 指定文件类型展示颜色
    "css",
    "html",
    vue = {
      css = true,
    },
  },
}
