return {
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters = {
        ["markdownlint-cli2"] = {
          prepend_args = {
            "--disable",
            "MD013",
            "--",
          },
        },
      },
    },
  },
}
