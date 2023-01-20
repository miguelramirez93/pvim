local M = {
  install_cfg = {
    {"RRethy/vim-illuminate"},
  },
  delay = 100,
}


function M.setup()
  local vim_iluminate_installed, illuminate = pcall(require, "illuminate")
    if not vim_iluminate_installed then return end

    illuminate.configure({
    delay = M.delay,
  })
end

return M
