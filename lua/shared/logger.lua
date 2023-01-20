local M = {module_name = "no_name"}

local custom_levels = {INFO = "info"}

function M.notify_opts() return {title = M.module_name} end

function M.notify(msg, level) vim.notify(msg, level, M.notify_opts()) end

function M.info(msg) M.notify(msg, custom_levels.INFO) end

function M.warn(msg) M.notify(msg, vim.log.levels.WARN) end

function M.error(msg) M.notify(msg, vim.log.levels.ERROR) end

return M
