-- Dart/Flutter: dartls sends `print(object)` as plain text, not a snippet,
-- so blink's snippet_forward has nothing to jump to. This fallback makes Tab
-- select the argument under/after the cursor so typing replaces it.
local function dart_next_arg()
  if vim.bo.filetype ~= "dart" then
    return false
  end

  local line = vim.api.nvim_get_current_line()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local before, rest = line:sub(1, col), line:sub(col + 1)

  local function select_word()
    vim.api.nvim_feedkeys(vim.keycode("<C-o>viw<C-g>"), "n", false)
  end

  -- cursor right before a word, just after "(" or ","  -> select that word
  if rest:match("^[%w_]+") and before:match("[%(,]%s*$") then
    select_word()
    return true
  end

  -- cursor at the end of an argument -> hop to the next argument and select it
  local skip = rest:match("^[%w_%.]*,%s*()")
  if skip then
    vim.api.nvim_win_set_cursor(0, { row, col + skip - 1 })
    select_word()
    return true
  end

  return false
end

return {
  "saghen/blink.cmp",
  opts = {
    keymap = {
      preset = "default",
      ["<Tab>"] = { "accept", "snippet_forward", dart_next_arg, "fallback" },
      ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
      ["<CR>"] = {}, -- disable Enter from accepting completion
    },
  },
}
