local plugs_service = require "core.plugins.service"
local conf_service = require "core.config.service"
local colorschemes = require "core.UI.colorschemes"

local M = {
    plugs = {
        auto_sync = true,
        client = require "core.plugins.clients.lazy",
        load_folder_path = '/lua/plugins'
    },
    UI = {
        colorscheme = "kanagawa",
        widgets = {
            home = require "core.UI.home",
            explorer = require "core.UI.explorer",
            searcher = require "core.UI.searcher",
            status_line = require "core.UI.status_line",
            tab_line = require "core.UI.tap_line",
            shortcuts = require "core.UI.shortcuts"
        },
        indentation = require "core.UI.indentation"
    },
    LSP = {
        client = require "core.LSP.clients.nvim_lsp.client",
        disabled = false
    },
    builtins = {
        autopairs = require "core.builtins.autopairs",
        word_under_cursor = require "core.builtins.word_under_cursor",
        git = {
            gutter = require "core.builtins.gitsigns",
            client = require "core.builtins.fugitive"
        }
    },
    user_conf_folder_path = '/lua/config'
}

function M.setup()

    plugs_service.plugins_client = M.plugs.client
    plugs_service.auto_sync = M.plugs.auto_sync
    plugs_service.user_plgs_folder_path = M.plugs.load_folder_path

    if not M.LSP.disabled and M.LSP.client.dep_plugs then
        plugs_service.batch_add(M.LSP.client.dep_plugs)
    end

    plugs_service.load_all()
    plugs_service.setup_core_plugins()
    plugs_service.setup_user_plugins()

    if not M.LSP.disabled then M.LSP.client.setup() end

    conf_service.user_conf_folder_path = M.user_conf_folder_path
    conf_service.load_custom_cfg()

    colorschemes.select(M.UI.colorscheme)
end

function M.LSP.add_source(src) M.LSP.client.add_source(src) end

function M.LSP.add_server_cfg(cfg) M.LSP.client.add_server_cfg(cfg) end

function M.LSP.sources() return M.LSP.client.builtin_sources() end

return M
