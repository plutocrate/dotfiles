-- lua/plugins/blink.lua
return {
  "saghen/blink.cmp",
  opts = {
    keymap = {
      preset = "default",
      ["<Tab>"] = { "accept", "fallback" },
      ["<S-Tab>"] = { "select_prev", "fallback" }, -- Shift+Tab to go up
      ["<CR>"] = {}, -- disable Enter from accepting completion
    },
  },
}
