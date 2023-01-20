local M = {install_cfg = {{"nvim-telescope/telescope.nvim"}}}

function M.setup()
    local status_ok, telescope = pcall(require, "telescope")
    if not status_ok then return end
    telescope.setup()
end

return M
