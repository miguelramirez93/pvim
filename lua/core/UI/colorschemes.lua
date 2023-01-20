local M = {
    install_cfg = {
        {"lunarvim/darkplus.nvim"}, {"Everblush/everblush.nvim"},
        {'navarasu/onedark.nvim'}, {"folke/tokyonight.nvim"},
        {'B4mbus/oxocarbon-lua.nvim'}, {'shaunsingh/moonlight.nvim'},
        {'bluz71/vim-moonfly-colors', branch = 'cterm-compat'},
        {'rebelot/kanagawa.nvim'}
    }
}
function M.select(name)
    local set_theme_cmd = [[
let g:onedark_config = {
    \ 'style': 'darker',
\}

let g:material_style = "darker"

try
  colorscheme $selected
catch /^Vim\%((\a\+)\)\=:E185/
  colorscheme default
  set background=dark
endtry
]]

    set_theme_cmd = set_theme_cmd:gsub("$selected", name)

    vim.cmd(set_theme_cmd)
end

return M