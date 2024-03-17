return {
  {
    "ojroques/nvim-osc52",
    init = function()
      vim.keymap.set("n", "<leader>c", require("osc52").copy_operator, { expr = true })
      vim.keymap.set("n", "<leader>cc", "<leader>c_", { remap = true, desc = "Copy to system clipboard" })
      vim.keymap.set("v", "<leader>c", require("osc52").copy_visual)
    end,
  },
}
