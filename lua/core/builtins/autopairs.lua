local plug_cfg = {
    install_cfg = {{"windwp/nvim-autopairs"}},
    disable_filetype = {"TelescopePrompt", "spectre_panel"}
}

function plug_cfg.setup()
    local status_ok, npairs = pcall(require, "nvim-autopairs")
    if not status_ok then return end

    npairs.setup {disable_filetype = plug_cfg.disable_filetype}

    local cmp_autopairs = require "nvim-autopairs.completion.cmp"
    local cmp_status_ok, cmp = pcall(require, "cmp")
    if not cmp_status_ok then return end
    cmp.event:on("confirm_done",
                 cmp_autopairs.on_confirm_done {map_char = {tex = ""}})
end

return plug_cfg
