local plug_cfg = {
    install_cfg = {{"SmiteshP/nvim-navic", requires = "neovim/nvim-lspconfig"}}
}

function plug_cfg.setup()
    local navic_ok, navic = pcall(require, "nvim-navic")

    if not navic_ok then return end

    navic.setup({separator = " -> "})

    vim.o.winbar = "  %{%v:lua.require'nvim-navic'.get_location()%}"
end

return plug_cfg
