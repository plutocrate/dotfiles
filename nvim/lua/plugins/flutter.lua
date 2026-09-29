return {
  {
    "nvim-flutter/flutter-tools.nvim",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim",
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
    },
    config = function()
      require("flutter-tools").setup({
        fvm = true,
        ui = { border = "rounded" },
        decorations = {
          statusline = { app_version = true, device = true },
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
}
