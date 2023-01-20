local file_repository = require "core.plugins.repositories.file_repository"

local M = {plugins_client = {}, repository = file_repository}

local function is_valid_plugins_client(target) return target.setup end

local function setup_plugs_cfg(plugins_cfg)
    for _, p in ipairs(plugins_cfg) do if p.setup then p.setup() end end
end

local function add_plugins_list(src_list, plugins)
    for _, plugin in ipairs(plugins) do
       if not plugin.disabled then
          table.insert(src_list, plugin)
       end
    end
end

local function load_plugins()
    local plugins_cfg = {}

    local core_plugs = M.repository.load_core_plugins()
    local additional_plugs = M.repository.load_user_plugins()

    add_plugins_list(plugins_cfg,core_plugs)
    add_plugins_list(plugins_cfg,additional_plugs)

   return plugins_cfg
end


local function plgs_did_change()
    local core_plg_md5 = M.repository.installed_core_plugins_md5()
    local usr_plg_md5 = M.repository.installed_user_plugins_md5()

    local current_core_plugs_md5 = M.repository.core_plugins_md5()
    local current_user_plugs_md5 = M.repository.user_plugins_md5()

    if current_core_plugs_md5 ~= core_plg_md5 or current_user_plugs_md5 ~=
        usr_plg_md5 then
        M.repository.update_installed_core_plugins_md5(current_core_plugs_md5)
        M.repository.update_installed_user_plugins_md5(current_user_plugs_md5)
        return true
    end

    return false
end

function M.setup()
    if not is_valid_plugins_client(M.plugins_client) then
        -- TODO: log something --
        return
    end

    local plugins_cfg = load_plugins()

    M.plugins_client.setup(plugins_cfg)

    if plgs_did_change() and M.plugins_client.sync then
        -- logger.info("Plugins change detected, updating...")
        M.plugins_client.sync()
        return
    end

    setup_plugs_cfg(plugins_cfg)
end

return M
