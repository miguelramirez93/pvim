local M = {}

function M.create(filename)
    local created_file = io.open(filename, "w")
    return created_file
end

function M.read_replace_mode(filename) return io.open(filename, "w+") end

function M.read(filename) return io.open(filename) end

function M.read_or_create(filename)
    local file = M.read(filename)
    if file == nil then return M.create(filename) end
    return file
end

return M
