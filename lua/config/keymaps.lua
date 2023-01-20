local keymaps = require("shared.keymaps")

keymaps.map("n", "<C-t>", ":tabnew<CR>")
keymaps.map("n", "<C-s>", ":w<CR>")


keymaps.map("v", "<", "<gv")
keymaps.map("v", ">", ">gv")


keymaps.map("n", "<C-p>", ":Telescope find_files<CR>")
keymaps.map("n", "<C-f>", ":Telescope live_grep<CR>")

-- Nvimtree
keymaps.map("n", "<C-b>", ":NvimTreeToggle<CR>")
