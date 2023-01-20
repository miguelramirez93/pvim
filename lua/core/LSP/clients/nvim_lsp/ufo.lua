local plug_cfg = {
    install_cfg = {
        {'kevinhwang91/nvim-ufo'},
        {'kevinhwang91/promise-async'},
    }
}

function plug_cfg.setup()
    local ufo_installed, ufo = pcall(require, "ufo")
    if not ufo_installed then return end

    plug_cfg.setup_nvim_fold()
    plug_cfg.setup_keymaps()
    plug_cfg.setup_handler()
    ufo.setup()
end

function plug_cfg.setup_nvim_fold()
    vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
    vim.o.foldcolumn = '1'
    vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
    vim.o.foldlevelstart = 99
    vim.o.foldenable = true
end

function plug_cfg.setup_keymaps()
    vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
    vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)
end

function plug_cfg.setup_lsp_capabilities(capabilities)
    capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true
    }
end

function plug_cfg.setup_handler()
    local handler = function(virtText, lnum, endLnum, width, truncate)
        local newVirtText = {}
        -- local suffix = ('  %d '):format(endLnum - lnum)
        local suffix = ('  %d '):format(endLnum - lnum)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0
        for _, chunk in ipairs(virtText) do
            local chunkText = chunk[1]
            local chunkWidth = vim.fn.strdisplaywidth(chunkText)
            if targetWidth > curWidth + chunkWidth then
                table.insert(newVirtText, chunk)
            else
                chunkText = truncate(chunkText, targetWidth - curWidth)
                local hlGroup = chunk[2]
                table.insert(newVirtText, {chunkText, hlGroup})
                chunkWidth = vim.fn.strdisplaywidth(chunkText)
                -- str width returned from truncate() may less than 2nd argument, need padding
                if curWidth + chunkWidth < targetWidth then
                    suffix = suffix ..
                                 (' '):rep(targetWidth - curWidth - chunkWidth)
                end
                break
            end
            curWidth = curWidth + chunkWidth
        end
        table.insert(newVirtText, {suffix, 'MoreMsg'})
        return newVirtText
    end

    -- global handler
    require('ufo').setup({fold_virt_text_handler = handler})

    -- buffer scope handler
    -- will override global handler if it is existed
    local bufnr = vim.api.nvim_get_current_buf()
    require('ufo').setFoldVirtTextHandler(bufnr, handler)
end

return plug_cfg
