return {
  {
    "tmillr/sos.nvim",
    init = function()
      require("sos").setup({
        timeout = 20000,
        autowrite = true,
        save_on_cmd = "some",
        save_on_bufleave = true,
        save_on_focuslost = true,
      })
    end,
  },
}
