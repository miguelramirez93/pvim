local M = {}

function M.installed(module)
  local installed, _ = pcall(require, module)
  return installed
end

return M
