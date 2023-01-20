local pvim = require("pvim")

local plug_cfg = {}

function plug_cfg.setup()
    pvim.LSP.add_server_cfg({name = "jdtls", lang = "java"})
end

return plug_cfg
