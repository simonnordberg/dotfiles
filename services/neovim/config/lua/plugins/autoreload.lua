return {
  {
    "autoreload",
    virtual = true,
    config = function()
      vim.o.autoread = true
      vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
        command = "checktime",
      })
    end,
  },
}
