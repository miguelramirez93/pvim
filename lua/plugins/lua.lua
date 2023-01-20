local pvim = require("pvim")
local logger = require("shared.logger")

local plug_cfg = {}

function plug_cfg.setup()
    pvim.LSP.add_server_cfg({
        name = "sumneko_lua",
        lang = "lua",
        opts = {
            settings = {
                Lua = {
                    diagnostics = {globals = {"vim"}},
                    workspace = {
                        library = {
                            [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                            [vim.fn.stdpath("config") .. "/lua"] = true
                        }
                    }
                }
            }
        }
    })
    local sources = pvim.LSP.sources()
    if sources then
        pvim.LSP.add_source(sources.code_actions.refactoring)
        pvim.LSP.add_source(sources.diagnostics.luacheck)
        pvim.LSP.add_source(sources.formatting.lua_format)
    end
end

return plug_cfg
