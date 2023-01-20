local plug_cfg = {
    install_cfg = {
        {
            "ThePrimeagen/refactoring.nvim",
            requires = {
                {"nvim-lua/plenary.nvim"}, {"nvim-treesitter/nvim-treesitter"}
            }
        }
    }
}

function plug_cfg.setup()
    local status_ok, refactoring = pcall(require, "refactoring")
    if not status_ok then return end

    refactoring.setup()
end

return plug_cfg
