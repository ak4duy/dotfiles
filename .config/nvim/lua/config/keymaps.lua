-- normal mode mappings
vim.keymap.set("n", "j", "gk")
vim.keymap.set("n", "k", "gj")
vim.keymap.set("n", "<A-j>", "<cmd>m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("n", "<A-k>", "<cmd>m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "j", "k", { buffer = true })
vim.keymap.set("n", "k", "j", { buffer = true })

-- visual mode mappings
vim.keymap.set("v", "j", "gk")
vim.keymap.set("v", "k", "gj")
vim.keymap.set("v", "<A-j>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
vim.keymap.set("v", "<A-k>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })

-- insert mode mapping
vim.keymap.set("i", "<A-j>", "<Esc><cmd>m .-2<CR>==gi", { desc = "Move line up (insert)" })
vim.keymap.set("i", "<A-k>", "<Esc><cmd>m .+1<CR>==gi", { desc = "Move line down (insert)" })

-- zed custom mappings
vim.api.nvim_set_keymap("n", "vie", "ggVG", { noremap = true, silent = true })
vim.keymap.set("n", "<C-e>", function()
  Snacks.explorer()
end, { desc = "Toggle Explorer" })

-- transparent background
-- vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
-- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
-- vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none" })
-- vim.api.nvim_set_hl(0, "Pmenu", { bg = "none" })
