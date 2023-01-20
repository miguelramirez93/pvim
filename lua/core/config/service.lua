local modules = require "shared.modules"

local M = {
    user_conf_folder_path = '/lua/config'
}

function M.load_custom_cfg()
    modules.require_from_folder(M.user_conf_folder_path)
end

return M