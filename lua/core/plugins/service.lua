local file_repository = require "core.plugins.repositories.file_repository"

local M = {
    plugins_client = {},
    auto_sync = true,
    repository = file_repository,
    user_plgs_folder_path = '/lua/plugins'
}

local plugins_cfg = {}

M.repository.user_plgs_folder_path = M.user_plgs_folder_path

local function is_valid_plugins_client(target) return target.setup end

local function add_plugins_list(src_list, plugins)
    for _, plugin in ipairs(plugins) do
        if not plugin.disabled then table.insert(src_list, plugin) end
    end
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

local function get_os_type()
    if package.config:sub(1, 1) == '\\' then
        return "windows"
    else
        local f = io.popen("uname -s")
        local uname_output = f:read("*a")
        f:close()

        if uname_output == "Darwin\n" then
            return "macos"
        else
            return "linux"
        end
    end
end

local function setup_plugs_cfg(cfg)
    for _, p in ipairs(cfg) do
        if p.setup then p.setup() end
        local os_type = get_os_type()
        if os_type == "linux" then
            if p.install_linux_deps then p.install_linux_deps() end
        elseif os_type == "macos" then
            if p.install_macos_deps then p.install_macos_deps() end
        end
    end
end

function M.load_all()
    if not is_valid_plugins_client(M.plugins_client) then
        -- TODO: log something --
        return
    end

    local plugins_list = {}

    local core_plugs = M.repository.load_core_plugins()
    local user_plugins = M.repository.load_user_plugins()

    add_plugins_list(plugins_list, core_plugs)
    add_plugins_list(plugins_list, plugins_cfg)
    add_plugins_list(plugins_list, user_plugins)

    M.plugins_client.setup(plugins_list)

    if M.auto_sync and plgs_did_change() and M.plugins_client.sync then
        M.plugins_client.sync()
    end
end

function M.batch_add(plugins_list)
    for _, plg_cfg in ipairs(plugins_list) do
        table.insert(plugins_cfg, plg_cfg)
    end
end

function M.setup_core_plugins()
    local core_plugins = M.repository.load_core_plugins()
    setup_plugs_cfg(core_plugins)
    setup_plugs_cfg(plugins_cfg)
end

function M.setup_user_plugins()
    local user_plugins = M.repository.load_user_plugins()
    setup_plugs_cfg(user_plugins)
end

return M
