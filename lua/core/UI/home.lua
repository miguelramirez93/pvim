local pHeader = {
    "⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⣀⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀",
    "⠀⠀⠀⠀⠀⣤⠖⠚⠉⠉⠀⠀⠈⠉⠙⠒⠦⣄⡀⠀⠀⠀",
    "⠀⠀⣀⡴⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⣄⠀⠀",
    "⠀⣰⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⡀⠀",
    "⠀⡏⠀⠀⠀⢠⠖⠛⠦⣄⠀⠀⠘⢦⣀⡄⠀⠀⠀⠀⣇⠀",
    "⢸⠃⠀⠀⠀⣯⠀⠀⠀⣼⠂⠀⠀⠀⣽⠷⣄⠀⠀⠀⢹⡀",
    "⢸⠀⠀⠀⠀⠘⠲⠦⠖⠃⠀⠀⠀⠀⠀⠀⠈⠁⠀⠀⢈⡇",
    "⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣧",
    "⠸⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡗",
    "⠀⣇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⡇",
    "⠀⢹⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⡇",
    "⠀⢸⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠁",
    "⠀⠸⣇⠀⠀⠀⠀⢀⠀⠀⠀⠀⠀⠀⣀⠀⠀⠀⠀⠀⣾⠁",
    "⠀⠀⠈⠓⠦⢤⠴⠛⠧⣤⣀⣀⣠⡴⠙⢦⣀⣀⣀⣴⠃⠀",
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠁⠀⠀⠀"
}

local pFooter = "miguelramirez93"

local M = {
    disabled = false,
    install_cfg = {{"goolord/alpha-nvim"}},
    header = pHeader,
    footer = pFooter,
    buttons_cfg = {
        {"f", "  Find file", ":Telescope find_files <CR>"},
        {"e", "  New file", ":ene <BAR> startinsert <CR>"},
        {"p", "  Find project", ":Telescope projects <CR>"},
        {"r", "  Recently used files",":Telescope oldfiles <CR>"},
        {"t", "  Find text", ":Telescope live_grep <CR>"},
        {"c", "  Configuration",":e ~/.config/nvim/init.lua <CR>"},
        {"q", "  Quit Neovim", ":qa<CR>"},
    }
}

function M.setup()

    local status_ok, alpha = pcall(require, "alpha")
    if not status_ok then return end

    local dashboard = require("alpha.themes.dashboard")

    dashboard.section.header.val = M.header

    dashboard.section.buttons.val = M.buttons_cfg_to_alpha_buttons(dashboard)

    dashboard.section.footer.val = M.footer

    dashboard.section.footer.opts.hl = "Type"
    dashboard.section.header.opts.hl = "Include"
    dashboard.section.buttons.opts.hl = "Keyword"

    dashboard.opts.opts.noautocmd = true
    alpha.setup(dashboard.opts)
end

function M.buttons_cfg_to_alpha_buttons(dashboard)
    local buttons = {}

    for _, button_cfg in ipairs(M.buttons_cfg) do
        table.insert(buttons, dashboard.button(button_cfg[1], button_cfg[2],button_cfg[3]))
    end

    return buttons
end

return M