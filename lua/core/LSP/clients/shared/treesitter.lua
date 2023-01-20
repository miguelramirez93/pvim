local M = {
    install_cfg = {{"nvim-treesitter/nvim-treesitter", run = ":TSUpdate"}}
}

local enabled_languajes = {}

function M.enable_languaje(lang) table.insert(enabled_languajes, lang) end

function M.load()
    local status_ok, configs = pcall(require, "nvim-treesitter.configs")
    if not status_ok then return end

    local ensure_installed = nil

    if #enabled_languajes ~= 0 then ensure_installed = enabled_languajes end

    configs.setup {
        -- one of "all", "maintained" (parsers with maintainers), or a list of languages
        ensure_installed = ensure_installed or "all",
        sync_install = false, -- install languages synchronously (only applied to `ensure_installed`)
        ignore_install = {""}, -- List of parsers to ignore installing
        autopairs = {enable = true},
        highlight = {
            enable = true, -- false will disable the whole extension
            disable = {""}, -- list of language that will be disabled
            additional_vim_regex_highlighting = false
        },
        indent = {enable = true, disable = {"yaml"}},
        context_commentstring = {enable = true, enable_autocmd = false}
    }
end

return M
