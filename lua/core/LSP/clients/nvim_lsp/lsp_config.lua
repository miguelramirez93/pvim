local plug_cfg = {
    install_cfg = {
        {"neovim/nvim-lspconfig", lazy = false},
        {"rafamadriz/friendly-snippets", lazy = false},
        {"williamboman/nvim-lsp-installer", lazy = false},
        {"tamago324/nlsp-settings.nvim", lazy = false},
        {"antoinemadec/FixCursorHold.nvim"}
    }
}

function plug_cfg.setup()
    local status_ok, nlspsettings = pcall(require, "nlspsettings")
    if not status_ok then return end

    nlspsettings.setup({
        config_home = vim.fn.stdpath('config') .. '/nlsp-settings',
        local_settings_dir = ".nlsp-settings",
        local_settings_root_markers_fallback = {'.git'},
        append_default_schemas = true,
        loader = 'json'
    })
end

return plug_cfg
