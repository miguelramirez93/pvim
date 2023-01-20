local M = {}


function M.add_globals(globals)
  for k, v in pairs(globals) do
    vim.g[k] = v
  end
end

function M.add_options(options)
  for k, v in pairs(options) do
    vim.opt[k] = v
  end
end

function M.add_o(options)
  for k, v in pairs(options) do
    vim.o[k] = v
  end
end


return M
