return {
  "saghen/blink.cmp",
  opts = {
    keymap = {
      preset = "default",
      ["<Tab>"] = { "accept", "snippet_forward", "fallback" },
      ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
      ["<CR>"] = {}, -- disable Enter from accepting completion
    },
  },
}
