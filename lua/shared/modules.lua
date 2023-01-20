local M = {}
local function folder_path_to_requ(folder_path)
    local req_path = string.gsub(folder_path,'/lua/', '')
    req_path = req_path:gsub('/', '.')
    return req_path
end

function M.load_from_folder(folder_path)
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

function M.require_from_folder(folder_path)
    local req_path = folder_path_to_requ(folder_path)
    for _, file in ipairs(vim.fn.readdir(
                              vim.fn.stdpath('config') .. folder_path,
                              [[v:val =~ '\.lua$']])) do
        require(req_path .. '.' .. file:gsub('%.lua$', ''))
    end
end

return M