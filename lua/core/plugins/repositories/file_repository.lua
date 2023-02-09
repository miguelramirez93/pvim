local file_man = require("shared.files")
local md5_helper = require("shared.md5")
local tbl_helper = require("shared.table")
local modules = require("shared.modules")

local builtins_plgs_folder_path = '/lua/core/builtins'
local ui_plgs_folder_path = '/lua/core/UI'
local changes_file_path = vim.fn.stdpath('config') .. "/.plg_check_md5"

local M = {user_plgs_folder_path = '/lua/plugins'}

local function load_plugs_md5_from_folder(folder_path)

    local modules_arr = {}
    local fixed_folder_path = vim.fn.stdpath('config') .. folder_path
    for _, file in ipairs(vim.fn.readdir(fixed_folder_path,
                                         [[v:val =~ '\.lua$']])) do

        local f = file_man.read(fixed_folder_path .. "/" .. file)
        local output = {}
        for each in f:lines() do output[#output + 1] = each end

        table.insert(modules_arr, {tbl_helper.to_string(output)})
    end
    return md5_helper.sumhexa(tbl_helper.to_string(modules_arr))
end

local function add_plugins_list(src_list, plugins)
    for _, plugin in ipairs(plugins) do
        if not plugin.disabled then table.insert(src_list, plugin) end
    end
end

function M.load_core_plugins()
    -- TODO: core plugins should be inserted from outside this repository, only 
    -- dynamic plugins load from folders (user plugs) should be loaded from this repository
    local builtins_plgs = modules.load_from_folder(builtins_plgs_folder_path)
    local ui_plugs = modules.load_from_folder(ui_plgs_folder_path)
    local core_plugs = {}
    add_plugins_list(core_plugs, builtins_plgs)
    add_plugins_list(core_plugs, ui_plugs)
    return core_plugs
end

function M.load_user_plugins()
    return modules.load_from_folder(M.user_plgs_folder_path)
end

function M.core_plugins_md5()
    return load_plugs_md5_from_folder(builtins_plgs_folder_path)
end

function M.user_plugins_md5()
    return load_plugs_md5_from_folder(M.user_plgs_folder_path)
end

function M.installed_core_plugins_md5()
    local plg_check_md5_file = file_man.read_or_create(changes_file_path)

    local core_plug_md5 = plg_check_md5_file:read("l")
    plg_check_md5_file:close()

    return core_plug_md5
end

function M.installed_user_plugins_md5()
    local plg_check_md5_file = file_man.read_or_create(changes_file_path)

    local _ = plg_check_md5_file:read("l")
    local additional_plug_md5 = plg_check_md5_file:read("l")
    plg_check_md5_file:close()

    return additional_plug_md5
end

function M.update_installed_core_plugins_md5(md5)
    local md5_file = file_man.read_replace_mode(changes_file_path)

    md5_file:write(md5, "\n")
    md5_file:close()
end

function M.update_installed_user_plugins_md5(md5)
    local plg_check_md5_file = file_man.read_or_create(changes_file_path)

    local changes_file_content = {}
    table.insert(changes_file_content, plg_check_md5_file:read("l"))
    table.insert(changes_file_content, plg_check_md5_file:read("l"))
    plg_check_md5_file:close()

    local md5_file = file_man.read_replace_mode(changes_file_path)

    md5_file:write(changes_file_content[1], "\n")
    md5_file:write(md5, "\n")
    md5_file:close()
end

return M
