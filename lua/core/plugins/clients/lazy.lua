local function bootstrap()
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
    end
    vim.opt.rtp:prepend(lazypath)
end

function plugins_cfg_to_lazy_plugs(plugins_cfg)
    local lazy_plugs = {}
    for _, plug_cfg in pairs(plugins_cfg) do
        table.insert(lazy_plugs, plug_cfg.install_cfg)
    end
    return lazy_plugs
end


local M = {}

function M.setup(plugins_cfg)
    bootstrap()
    local lazy_installed, lazy = pcall(require, "lazy")
    if not lazy_installed then return end

    lazy.setup(plugins_cfg_to_lazy_plugs(plugins_cfg))
end

return M