local file_man = require("shared.files")
local md5_helper = require("shared.md5")
local tbl_helper = require("shared.table")

local builtins_plgs_folder_path = '/lua/core/plugins/builtins'
local user_plgs_folder_path = '/lua/plugins'
local changes_file_path = vim.fn.stdpath('config') .. "/.plg_check_md5"

local M = {}

local function folder_path_to_requ(folder_path)
    local req_path = string.gsub(folder_path,'/lua/', '')
    req_path = req_path:gsub('/', '.')
    return req_path
end

local function load_plugs_from_folder(folder_path)
    local modules = {}

    local req_path = folder_path_to_requ(folder_path)

    for _, file in ipairs(vim.fn.readdir(
                              vim.fn.stdpath('config') .. folder_path,
                              [[v:val =~ '\.lua$']])) do
        local module = require(req_path .. '.' .. file:gsub('%.lua$', ''))
        table.insert(modules, module)
    end
    return modules
end

local function load_plugs_md5_from_folder(folder_path)

    local modules = {}
    local fixed_folder_path = vim.fn.stdpath('config') .. folder_path
    for _, file in ipairs(vim.fn.readdir(fixed_folder_path, [[v:val =~ '\.lua$']])) do

        local f = file_man.read(fixed_folder_path .. "/" .. file)
        local output = {}
        for each in f:lines() do output[#output + 1] = each end

        table.insert(modules, {tbl_helper.to_string(output)})
    end
    return md5_helper.sumhexa(tbl_helper.to_string(modules))
end

function M.load_core_plugins()
    return load_plugs_from_folder(builtins_plgs_folder_path)
end

function M.load_user_plugins()
    return load_plugs_from_folder(user_plgs_folder_path)
end

function M.core_plugins_md5()
    return load_plugs_md5_from_folder(builtins_plgs_folder_path)
end

function M.user_plugins_md5()
    return load_plugs_md5_from_folder(user_plgs_folder_path)
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
