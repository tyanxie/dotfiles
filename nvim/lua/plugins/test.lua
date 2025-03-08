return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "fredrikaverpil/neotest-golang", -- go语言测试支持
      "nvim-neotest/nvim-nio",
    },
    opts = {
      -- Can be a list of adapters like what neotest expects,
      -- or a list of adapter names,
      -- or a table of adapter names, mapped to adapter configs.
      -- The adapter will then be automatically loaded with the config.
      adapters = {
        ["neotest-golang"] = {
          -- Here we can set options for neotest-golang, e.g.
          -- go_test_args = { "-v", "-race", "-count=1", "-timeout=60s" },
          dap_go_enabled = true, -- requires leoluz/nvim-dap-go
        },
      },
      status = { virtual_text = true },
      output = { open_on_run = true },
      quickfix = {
        open = function()
          require("trouble").open({ mode = "quickfix", focus = false })
        end,
      },
    },
    config = function(_, opts)
      opts.consumers = opts.consumers or {}
      opts.consumers.trouble = function(client)
        client.listeners.results = function(adapter_id, results, partial)
          if partial then
            return
          end
          local tree = assert(client:get_position(nil, { adapter = adapter_id }))

          local failed = 0
          for pos_id, result in pairs(results) do
            if result.status == "failed" and tree:get_key(pos_id) then
              failed = failed + 1
            end
          end
          vim.schedule(function()
            local trouble = require("trouble")
            if trouble.is_open() then
              trouble.refresh()
              if failed == 0 then
                trouble.close()
              end
            end
          end)
          return {}
        end
      end

      if opts.adapters then
        local adapters = {}
        for name, config in pairs(opts.adapters or {}) do
          if type(name) == "number" then
            if type(config) == "string" then
              config = require(config)
            end
            adapters[#adapters + 1] = config
          elseif config ~= false then
            local adapter = require(name)
            if type(config) == "table" and not vim.tbl_isempty(config) then
              local meta = getmetatable(adapter)
              if adapter.setup then
                adapter.setup(config)
              elseif adapter.adapter then
                adapter.adapter(config)
                adapter = adapter.adapter
              elseif meta and meta.__call then
                adapter = adapter(config)
              else
                error("Adapter " .. name .. " does not support setup")
              end
            end
            adapters[#adapters + 1] = adapter
          end
        end
        opts.adapters = adapters
      end

      require("neotest").setup(opts)
    end,

    keys = {
      { "<leader>ct", "", desc = "+test" },
      {
        "<leader>ctt",
        function()
          require("neotest").run.run(vim.fn.expand("%"))
        end,
        desc = "Run File (Neotest)",
      },
      {
        "<leader>ctT",
        function()
          require("neotest").run.run(vim.uv.cwd())
        end,
        desc = "Run All Test Files (Neotest)",
      },
      {
        "<leader>ctr",
        function()
          require("neotest").run.run()
        end,
        desc = "Run Nearest (Neotest)",
      },
      {
        "<leader>ctl",
        function()
          require("neotest").run.run_last()
        end,
        desc = "Run Last (Neotest)",
      },
      {
        "<leader>cts",
        function()
          require("neotest").summary.toggle()
        end,
        desc = "Toggle Summary (Neotest)",
      },
      {
        "<leader>cto",
        function()
          require("neotest").output.open({ enter = true, auto_close = true })
        end,
        desc = "Show Output (Neotest)",
      },
      {
        "<leader>ctO",
        function()
          require("neotest").output_panel.toggle()
        end,
        desc = "Toggle Output Panel (Neotest)",
      },
      {
        "<leader>ctS",
        function()
          require("neotest").run.stop()
        end,
        desc = "Stop (Neotest)",
      },
      {
        "<leader>ctw",
        function()
          require("neotest").watch.toggle(vim.fn.expand("%"))
        end,
        desc = "Toggle Watch (Neotest)",
      },
    },
  },
}
