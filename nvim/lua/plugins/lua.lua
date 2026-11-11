return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        lua_ls = {
          settings = {
            Lua = {
              runtime = {
                version = "LuaJIT",
              },
              diagnostics = {
                globals = { "love" },
                disable = {
                  "duplicate-set-field",
                },
              },
              workspace = {
                checkThirdParty = false,
                library = {
                  vim.fn.expand("~/.local/share/lua-love/love2d/library"),
                },
              },
              completion = {
                callSnippet = "Replace",
              },
              hint = {
                enable = true,
              },
            },
          },
        },
      },
    },
  },
}
