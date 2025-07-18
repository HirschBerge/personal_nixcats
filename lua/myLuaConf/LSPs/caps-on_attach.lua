local M = {}
function M.on_attach(client, bufnr)
    -- we create a function that lets us more easily define mappings specific
    -- for LSP related items. It sets the mode, buffer and description for us each time.
    local telescope_builtin = require("telescope.builtin")
    if not telescope_builtin then
        error("Failed to load telescope.builtin")
    end

    local nmap = function(keys, func, desc)
        if desc then
            desc = "LSP: " .. desc
        end

        -- Check if func is nil
        if func == nil then
            error("Function is nil for keymap: " .. keys)
        end

        vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
    end

    -- Check if vim.lsp.buf is available
    if not vim.lsp or not vim.lsp.buf then
        error("vim.lsp.buf is not available")
    end

    nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
    nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
    -- nmap('gd', telescope_builtin.lsp_definition, '[G]oto [D]efinition')
    -- nmap('gr', telescope_builtin.lsp_references, '[G]oto [R]eferences')
    -- nmap('gI', telescope_builtin.lsp_implementations, '[G]oto [I]mplementation')
    nmap("<leader>D", vim.lsp.buf.type_definition, "Type [D]efinition")
    nmap("<leader>ds", telescope_builtin.lsp_document_symbols, "[D]ocument [S]ymbols")
    nmap("<leader>ws", telescope_builtin.lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")

    -- See `:help K` for why this keymap
    nmap("K", vim.lsp.buf.hover, "Hover Documentation")
    nmap("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")

    -- Lesser used LSP functionality
    nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
    nmap("<leader>wa", vim.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd Folder")
    nmap("<leader>wr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder")
    nmap("<leader>wl", function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, "[W]orkspace [L]ist Folders")

    -- Create a command `:Format` local to the LSP buffer
    vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
        vim.lsp.buf.format()
    end, {
        desc = "Format current buffer with LSP",
    })

    vim.keymap.set("n", "<leader>Fm", "<cmd>Format<CR>", { noremap = true, desc = "[F]or[m]at (lsp)" })
    -- Auto-format on save if the LSP supports formatting
    if client.server_capabilities.documentFormattingProvider then
        vim.api.nvim_create_autocmd("BufWritePre", {
            group = vim.api.nvim_create_augroup("LspFormatting", { clear = true }),
            buffer = bufnr,
            callback = function()
                vim.lsp.buf.format({
                    async = false, -- Ensure it's synchronous before save
                    bufnr = bufnr,
                })
            end,
        })
    end
end

function M.get_capabilities()
    -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
    -- if you make a package without it, make sure to check if it exists with nixCats!
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
    return capabilities
end

return M
