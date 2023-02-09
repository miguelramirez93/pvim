local logger = require("shared.logger")
local keymaps = require("shared.keymaps")

-- Defaults
local __signs = {
    {name = "DiagnosticSignError", text = ""},
    {name = "DiagnosticSignWarn", text = ""},
    {name = "DiagnosticSignHint", text = ""},
    {name = "DiagnosticSignInfo", text = ""}
}

local __diagnostic_cfg = {
    -- disable virtual text
    virtual_text = false,
    -- show signs
    diagnostics = {signs = {active = true, values = __signs}},
    update_in_insert = true,
    underline = true,
    severity_sort = true,
    float = {
        focusable = false,
        style = "minimal",
        border = "rounded",
        source = "always",
        header = "",
        prefix = "",
        format = function(d)
            local code = d.code or (d.user_data and d.user_data.lsp.code)
            if code then
                return string.format("%s [%s]", d.message, code):gsub("1. ", "")
            end
            return d.message
        end
    },
    document_highlight = false,
    code_lens_refresh = true
}

local __handlers_cfg = {
    {
        name = "textDocument/hover",
        cfg = vim.lsp.with(vim.lsp.handlers.hover, {
            border = "rounded",
            focusable = false,
            style = "minimal",
            source = "always"
        })
    }, {
        name = "textDocument/signatureHelp",
        cfg = vim.lsp.with(vim.lsp.handlers.signature_help, {
            border = "rounded",
            focusable = false,
            style = "minimal"
        })
    }
}

local function make_deafault_capabilities()

    local capabilities = vim.lsp.protocol.make_client_capabilities()

    capabilities.textDocument.completion.completionItem.snippetSupport = true
    capabilities.textDocument.completion.completionItem.preselectSupport = true
    capabilities.textDocument.completion.completionItem.insertReplaceSupport =
        true
    capabilities.textDocument.completion.completionItem.labelDetailsSupport =
        true
    capabilities.textDocument.completion.completionItem.deprecatedSupport = true
    capabilities.textDocument.completion.completionItem.commitCharactersSupport =
        true

    capabilities.textDocument.completion.completionItem.tagSupport = {
        valueSet = {1}
    }

    capabilities.textDocument.completion.completionItem.resolveSupport = {
        properties = {'documentation', 'detail', 'additionalTextEdits'}
    }

    capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true
    }

    return capabilities
end

-- End Defaults

local treesitter_service = require("core.LSP.clients.shared.treesitter")

local M = {
    diagnostic_cfg = __diagnostic_cfg,
    signs = __signs,
    handlers_cfg = __handlers_cfg,
    -- TODO: make this unaccessible from outside
    servers_cfg = {},
    capabilities = make_deafault_capabilities(),
    sources = {},
    dep_plugs = {
        require("core.LSP.clients.nvim_lsp.lsp_config"),
        require("core.LSP.clients.nvim_lsp.cmp"),
        require "core.LSP.clients.nvim_lsp.null_ls",
        require "core.LSP.clients.nvim_lsp.mason",
        require "core.LSP.clients.nvim_lsp.navic",
        require "core.LSP.clients.nvim_lsp.trouble",
        require "core.LSP.clients.nvim_lsp.ufo",
        require "core.LSP.clients.nvim_lsp.lsp_signature", treesitter_service
    }
}

-- add_server_cfg adds a LSP server configuration
function M.add_server_cfg(cfg)
    for i, existentServer in ipairs(M.servers_cfg) do
        if existentServer.name == cfg.name then
            M.servers_cfg[i] = cfg
            logger.warn("duplicated lsp server " .. cfg.name ..
                            " last added cfg is going to be be used")
        end
    end

    if cfg.lang then treesitter_service.enable_languaje(cfg.lang) end

    table.insert(M.servers_cfg, cfg)
end

-- add_source adds a LSP source for either formatting, diagnostics or code actions
function M.add_source(src)
    for _, existentSrc in ipairs(M.sources) do
        if existentSrc == src then return end
    end

    table.insert(M.sources, src)
end

-- builtin_sources returns a list of builtin source that are currently registered
function M.builtin_sources()
    local null_ls_status_ok, null_ls = pcall(require, "null-ls")
    if not null_ls_status_ok then return end
    return null_ls.builtins
end

local function setup_diagnostic_conf()
    vim.diagnostic.config(M.diagnostic_cfg)
    -- Enable diagnostic on cursor NOTE: could be an user choose
    vim.cmd [[ autocmd CursorHold * lua vim.diagnostic.open_float() ]]
end

local function setup_signs()
    for _, sign in ipairs(M.signs) do
        vim.fn.sign_define(sign.name,
                           {texthl = sign.name, text = sign.text, numhl = ""})
    end
end

local function setup_handlers()
    for _, h in ipairs(M.handlers_cfg) do vim.lsp.handlers[h.name] = h.cfg end
end

local function enable_document_highlight(client, bufnr)
    if client.server_capabilities.document_highlight then
        vim.cmd [[
    hi! LspReferenceRead cterm=bold ctermbg=red guibg=LightYellow
    hi! LspReferenceText cterm=bold ctermbg=red guibg=LightYellow
    hi! LspReferenceWrite cterm=bold ctermbg=red guibg=LightYellow
  ]]
        vim.api.nvim_create_augroup('lsp_document_highlight', {clear = false})
        vim.api.nvim_clear_autocmds({
            buffer = bufnr,
            group = 'lsp_document_highlight'
        })
        vim.api.nvim_create_autocmd({'CursorHold', 'CursorHoldI'}, {
            group = 'lsp_document_highlight',
            buffer = bufnr,
            callback = vim.lsp.buf.document_highlight
        })
        vim.api.nvim_create_autocmd({'CursorMoved', 'CursorMovedI'}, {
            group = 'lsp_document_highlight',
            buffer = bufnr,
            callback = vim.lsp.buf.clear_references
        })
    end
end

local function highlight_symbols(client, bufnr)
    if client.server_capabilities.documentHighlightProvider then
        vim.api.nvim_create_augroup("lsp_document_highlight", {clear = true})
        vim.api.nvim_clear_autocmds {
            buffer = bufnr,
            group = "lsp_document_highlight"
        }
        vim.api.nvim_create_autocmd("CursorHold", {
            callback = vim.lsp.buf.document_highlight,
            buffer = bufnr,
            group = "lsp_document_highlight",
            desc = "Document Highlight"
        })
        vim.api.nvim_create_autocmd("CursorMoved", {
            callback = vim.lsp.buf.clear_references,
            buffer = bufnr,
            group = "lsp_document_highlight",
            desc = "Clear All the References"
        })
    end
end

local function setup_servers()
    local lsp_installer_installed, lsp_installer = pcall(require,
                                                         "nvim-lsp-installer")
    if not lsp_installer_installed then return end

    local cmp_installed, cmp = pcall(require, "cmp_nvim_lsp")
    if not cmp_installed then return end

    local lspconfig_installed, lspconfig = pcall(require, "lspconfig")
    if not lspconfig_installed then return end

    local server_names = {}

    for _, server_cfg in ipairs(M.servers_cfg) do
        table.insert(server_names, server_cfg.name)
    end

    lsp_installer.setup {ensure_installed = server_names}

    for _, server in pairs(M.servers_cfg) do
        local opts = {
            on_attach = function(client, bufnr)

                local function buf_set_option(...)
                    vim.api.nvim_buf_set_option(bufnr, ...)
                end

                buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

                enable_document_highlight(client, bufnr)
                highlight_symbols(client, bufnr)

                if client.server_capabilities.documentSymbolProvider then
                    local navic_ok, navic = pcall(require, "nvim-navic")
                    if navic_ok then
                        navic.attach(client, bufnr)
                    end
                end

                if server.on_attach then
                    server.on_attach(client, bufnr)
                end
            end,
            capabilities = cmp.default_capabilities(M.capabilities)
        }

        if server.opts then
            opts = vim.tbl_deep_extend("force", server.opts, opts)
        end

        lspconfig[server.name].setup(opts)
    end
end

local function lsp_formatting(bufnr)
    vim.lsp.buf.format({
        filter = function(client)
            -- apply whatever logic you want (in this example, we'll only use null-ls)
            return client.name == "null-ls"
        end,
        timeout_ms = 5000,
        bufnr = bufnr
    })
end

local function on_attach_sources(client, bufnr)
    if client.supports_method("textDocument/formatting") then
        local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
        vim.api.nvim_clear_autocmds({group = augroup, buffer = bufnr})
        vim.api.nvim_create_autocmd("BufWritePre", {
            group = augroup,
            buffer = bufnr,
            callback = function()
                -- on 0.8, you should use vim.lsp.buf.format({ bufnr = bufnr }) instead
                lsp_formatting(bufnr)
            end
        })
    end
end

local function setup_sources()
    local null_ls_status_ok, null_ls = pcall(require, "null-ls")
    if not null_ls_status_ok then return end

    null_ls.setup({
        debug = false,
        on_attach = on_attach_sources,
        sources = M.sources,
        update_in_insert = true
    })
end

local function setup_default_keymaps()
    keymaps.map("n", "ca", "<cmd>lua vim.lsp.buf.code_action()<CR>")
    keymaps.map("n", "gv", ":vsplit | lua vim.lsp.buf.definition()<CR>")
    keymaps.map("n", "rn", "<cmd>lua vim.lsp.buf.rename()<CR>")
    keymaps.map("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>")
    keymaps.map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
    keymaps.map("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>")
    keymaps.map("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>")
    keymaps.map("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>")
    keymaps.map("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>")
    keymaps.map("n", "ca", "<cmd>lua vim.lsp.buf.code_action()<CR>")
    keymaps.map("n", "gf", "<cmd>lua vim.diagnostic.open_float()<CR>")
    keymaps.map("n", "[d",
                '<cmd>lua vim.diagnostic.goto_prev({ border = "rounded" })<CR>')
    keymaps.map("n", "gl",
                '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics({ border = "rounded" })<CR>')
    keymaps.map("n", "]d",
                '<cmd>lua vim.diagnostic.goto_next({ border = "rounded" })<CR>')
    keymaps.map("n", "<leader>q", "<cmd>lua vim.diagnostic.setloclist()<CR>")
    vim.cmd [[ command! Format execute 'lua vim.lsp.buf.formatting()' ]]
end

-- setup initializes the nvim LSP with all the preconfigured options 
function M.setup()
    setup_default_keymaps()
    setup_signs()
    setup_diagnostic_conf()
    -- setup_handlers()
    setup_servers()
    setup_sources()
    treesitter_service.load()
end

return M
