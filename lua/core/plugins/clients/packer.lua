local packer_plug_cfg = {install_cfg = {{"wbthomason/packer.nvim"}}}

local function install_packer()
    local fn = vim.fn

    -- Automatically install packer
    local install_path = fn.stdpath "data" ..
                             "/site/pack/packer/start/packer.nvim"
    if fn.empty(fn.glob(install_path)) > 0 then
        PACKER_BOOTSTRAP = fn.system {
            "git", "clone", "--depth", "1",
            "https://github.com/wbthomason/packer.nvim", install_path
        }
        print "Installing packer close and reopen Neovim..."
        vim.cmd [[packadd packer.nvim]]
    end
end

local M = {}

function M.setup(plugins_cfg)
    install_packer()
    local packer_installed, packer = pcall(require, "packer")
    if not packer_installed then return end

    packer_plug_cfg.disabled = false

    table.insert(plugins_cfg, packer_plug_cfg)

    packer.init {
        display = {
            open_fn = function()
                return require("packer.util").float {border = "rounded"}
            end
        }
    }

    packer.startup(function(use)

        for _, p in ipairs(plugins_cfg) do
            if p.install_cfg then
                for _, cfg in ipairs(p.install_cfg) do use(cfg) end
            end
        end

        -- Automatically set up your configuration after cloning packer.nvim
        -- Put this at the end after all plugins
        if PACKER_BOOTSTRAP then packer.sync() end
    end)
end

-- sync updates installed plugins and install new ones. `sync` is able to detect 
-- any plugins configuration changes (including user ones)
function M.sync()
    local packer_installed, packer = pcall(require, "packer")
    if not packer_installed then return end
    packer.sync()
end
return M
