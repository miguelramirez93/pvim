local pvim = require("pvim")
-- 
local req = require("shared.requirement")

local plug_cfg = {
    install_cfg = {
        {'ray-x/go.nvim', run = ':GoUpdateBinaries'}, {'ray-x/guihua.lua'} -- recommanded if need floating window support
    }
}

function plug_cfg.setup()
    local status_ok, util = pcall(require, "lspconfig/util")
    local root_dir = nil
    if status_ok then
        root_dir = util.root_pattern("go.work", "go.mod", ".git")
    end

    pvim.LSP.add_server_cfg({
        name = "gopls",
        lang = "go",
        opts = {
            cmd = {'gopls', 'serve'},
            filetypes = {"go", "gomod"},
            root_dir = root_dir,
            settings = {
                gopls = {analyses = {unusedparams = true}, staticcheck = true}
            }
        }
    })

    local sources = pvim.LSP.sources()
    if sources then pvim.LSP.add_source(sources.code_actions.refactoring) end

    if req.installed("go") then
        -- Run gofmt + goimport on save
        vim.api.nvim_exec(
            [[ autocmd BufWritePre *.go :silent! lua require('go.format').goimport() ]],
            false)
        require('go').setup()
    end
end

return plug_cfg
