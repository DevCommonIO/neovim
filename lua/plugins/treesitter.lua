return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        highlight = { enable = true },
        indent = { enable = true },
        ensure_installed = {
          "lua", "tsx", "typescript", "javascript", "html", "css", "json", "markdown", "bash", "python"
        },
        auto_install = true,
      })
    end,
  }