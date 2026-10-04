return {
  {
    "nvim-flutter/flutter-tools.nvim",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "saghen/blink.cmp",
    },
    keys = {
      { "<leader>Fe", "<cmd>FlutterEmulators<cr>", desc = "Emulators" },
      { "<leader>Fd", "<cmd>FlutterDevices<cr>", desc = "Devices" },
      { "<leader>Fr", "<cmd>FlutterRun<cr>", desc = "Run" },
      { "<leader>Fh", "<cmd>FlutterReload<cr>", desc = "Hot Reload" },
      { "<leader>FR", "<cmd>FlutterRestart<cr>", desc = "Hot Restart" },
      { "<leader>Fq", "<cmd>FlutterQuit<cr>", desc = "Quit App" },
      { "<leader>Fo", "<cmd>FlutterOutlineToggle<cr>", desc = "Outline" },
      { "<leader>Fl", "<cmd>FlutterLogToggle<cr>", desc = "Log" },
      { "<leader>Ft", "<cmd>FlutterDevTools<cr>", desc = "DevTools" },
      { "<leader>Fg", "<cmd>FlutterPubGet<cr>", desc = "Pub Get" },
      { "<leader>Fx", "<cmd>FlutterLspRestart<cr>", desc = "Restart LSP" },
      { "<leader>Fa", "<cmd>FlutterReanalyze<cr>", desc = "Reanalyze" },
    },
    config = function()
      require("flutter-tools").setup({
        fvm = true,
        ui = { border = "rounded" },
        decorations = {
          statusline = { app_version = true, device = true },
        },
        debugger = {
          enabled = false,
          run_via_dap = false,
        },
        widget_guides = { enabled = true },
        closing_tags = {
          highlight = "Comment",
          prefix = "// ",
          enabled = true,
        },
        dev_log = {
          enabled = true,
          open_cmd = "tabnew", -- keeps the log in new buffer
        },
        lsp = {
          color = { enabled = true, virtual_text = true },
          capabilities = require("blink.cmp").get_lsp_capabilities(),
          settings = {
            showTodos = true,
            completeFunctionCalls = true,
            renameFilesWithClasses = "prompt",
            enableSnippets = true,
            updateImportsOnRename = true,
          },
        },
      })
    end,
  },

  -- group name in which-key
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>F", group = "Flutter" },
      },
    },
  },

  -- show Flutter app version + device in the statusline
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      table.insert(opts.sections.lualine_x, 1, function()
        local d = vim.g.flutter_tools_decorations or {}
        local parts = {}
        if d.app_version and d.app_version ~= "" then
          table.insert(parts, d.app_version)
        end
        if d.device and d.device ~= "" then
          table.insert(parts, d.device)
        end
        return table.concat(parts, " ")
      end)
    end,
  },
}

--- With DAP on, <leader>Fr starts your app under the debugger. Use <leader>db for breakpoints, and <F5>, <F10> and <F11> to continue and step.
