local M = {install_cfg = {"williamboman/mason.nvim"}}

function M.setup()

    local status_ok, mason = pcall(require, "mason")
    if not status_ok then return end
    mason.setup()
end

return M
