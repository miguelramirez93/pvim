local M = {install_cfg = {{"ray-x/lsp_signature.nvim"}}, disabled = true}

function M.setup()
    local status_ok, lsp_signature = pcall(require, "lsp_signature")
    if not status_ok then return end
    lsp_signature.setup()
end

return M
