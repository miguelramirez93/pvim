local plugs_service = require "core.plugins.service"
local plugs_packer_client = require "core.plugins.clients.packer"
local plugs_lazy_client = require "core.plugins.clients.lazy"

plugs_service.plugins_client = plugs_lazy_client

local M = {}

function M.setup() plugs_service.setup() end

return M
