local keymaps = require "shared.keymaps"

local M = {
    disabled = false,
    install_cfg = {{"kyazdani42/nvim-tree.lua"}},
    auto_reload_on_write = true,
    sort_by = "name",
    adaptive_size = true,
    width = 30,
    side = "left",
    keybinding = {
        {key = {"l", "<CR>", "o"}, action = "edit"},
        {key = "h", action = "close_node"}, {key = "v", action = "vsplit"}
    },
    git = {enable = true, ignore = true, timeout = 400},
    exclude = {
        filetype = {
            "notify", "packer", "qf", "diff", "fugitive", "fugitiveblame",
            "lazy"
        },
        buftype = {"nofile", "terminal", "help"}
    },
    indent_markers = true,
    update_focused_file = true,
    quit_on_open = true,
    diagnostics = {
        enable = true,
        icons = {hint = "", info = "", warning = "", error = ""}
    }
}

function M.setup()
    local status_ok, nvim_tree = pcall(require, "nvim-tree")
    if not status_ok then return end

    local config_status_ok, nvim_tree_config =
        pcall(require, "nvim-tree.config")
    if not config_status_ok then return end

    local tree_cb = nvim_tree_config.nvim_tree_callback

    keymaps.map("n", "<C-b>", ":NvimTreeToggle<CR>")

    nvim_tree.setup { -- BEGIN_DEFAULT_OPTS
        auto_reload_on_write = M.auto_reload_on_write,
        sort_by = M.sort_by,
        view = {
            adaptive_size = M.adaptive_size,
            width = M.width,
            side = M.side,
            mappings = {
                custom_only = false,
                list = M.keybindings_to_nvimtree_key_mapping(tree_cb)
            }
        },
        renderer = {
            indent_markers = {
                enable = M.indent_markers,
                icons = {corner = "└ ", edge = "│ ", none = "  "}
            }
        },
        git = M.git,
        hijack_directories = {enable = true, auto_open = true},
        update_focused_file = {
            enable = M.update_focused_file,
            update_cwd = false,
            ignore_list = {}
        },
        actions = {
            open_file = {
                quit_on_open = M.quit_on_open,
                resize_window = false,
                window_picker = {
                    enable = false,
                    chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
                    exclude = M.exclude
                }
            }
        },
        diagnostics = M.diagnostics
    } -- END_DEFAULT_OPTS
end

function M.keybindings_to_nvimtree_key_mapping(tree_cb)
    local keybindings = {}

    for _, keybinding in ipairs(M.keybinding) do
        table.insert(keybindings,
                     {key = keybinding.key, cb = tree_cb(keybinding.action)})
    end

    return keybindings
end

return M
