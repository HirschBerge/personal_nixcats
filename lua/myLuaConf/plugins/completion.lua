-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require("cmp")
local luasnip = require("luasnip")
require("luasnip.loaders.from_vscode").lazy_load()
require("luasnip.loaders.from_snipmate").lazy_load({ paths = "~/.dotfiles/nixos/common/lua/myLuaConf/snippets/" })
luasnip.config.setup({})
local lspkind = require("lspkind")

cmp.setup({
    preselect = cmp.PreselectMode.None,
    window = {
        completion = {
            winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
            col_offset = -3,
            side_padding = 0,
        },
    },
    formatting = {
        custom_highlights = function(C)
            return {
                CmpItemKindSnippet = { fg = C.base, bg = C.mauve },
                CmpItemKindKeyword = { fg = C.base, bg = C.red },
                CmpItemKindText = { fg = C.base, bg = C.teal },
                CmpItemKindMethod = { fg = C.base, bg = C.blue },
                CmpItemKindConstructor = { fg = C.base, bg = C.blue },
                CmpItemKindFunction = { fg = C.base, bg = C.blue },
                CmpItemKindFolder = { fg = C.base, bg = C.blue },
                CmpItemKindModule = { fg = C.base, bg = C.blue },
                CmpItemKindConstant = { fg = C.base, bg = C.peach },
                CmpItemKindField = { fg = C.base, bg = C.green },
                CmpItemKindProperty = { fg = C.base, bg = C.green },
                CmpItemKindEnum = { fg = C.base, bg = C.green },
                CmpItemKindUnit = { fg = C.base, bg = C.green },
                CmpItemKindClass = { fg = C.base, bg = C.yellow },
                CmpItemKindVariable = { fg = C.base, bg = C.flamingo },
                CmpItemKindFile = { fg = C.base, bg = C.blue },
                CmpItemKindInterface = { fg = C.base, bg = C.yellow },
                CmpItemKindColor = { fg = C.base, bg = C.red },
                CmpItemKindReference = { fg = C.base, bg = C.red },
                CmpItemKindEnumMember = { fg = C.base, bg = C.red },
                CmpItemKindStruct = { fg = C.base, bg = C.blue },
                CmpItemKindValue = { fg = C.base, bg = C.peach },
                CmpItemKindEvent = { fg = C.base, bg = C.blue },
                CmpItemKindOperator = { fg = C.base, bg = C.blue },
                CmpItemKindTypeParameter = { fg = C.base, bg = C.blue },
                CmpItemKindCopilot = { fg = C.base, bg = C.teal },
            }
        end,
        fields = { "kind", "abbr", "menu" },
        format = function(entry, vim_item)
            local kind = require("lspkind").cmp_format({ mode = "symbol_text", maxwidth = 50 })(entry, vim_item)
            local strings = vim.split(kind.kind, "%s", { trimempty = true })
            kind.kind = " " .. (strings[1] or "") .. " "
            kind.menu = "    (" .. (strings[2] or "") .. ")"

            return kind
        end,
        -- format = lspkind.cmp_format({
        -- 	mode = "text",
        -- 	with_text = true,
        -- 	maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
        -- 	ellipsis_char = "...", -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
        --
        -- 	menu = {
        -- 		luasnip = "[SNIP]",
        -- 		nvim_lsp = "[LSP]",
        -- 		nvim_lsp_signature_help = "[LSP]",
        -- 		nvim_lsp_document_symbol = "[LSP]",
        -- 		buffer = "[BUF]",
        -- 		nvim_lua = "[API]",
        -- 		path = "[PATH]",
        -- 	},
        -- }),
    },
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ["<C-p>"] = cmp.mapping.scroll_docs(-4),
        ["<C-n>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete({}),
        -- [ '<CR>'] = cmp.config.disable,
        ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Insert,
            -- NOTE: I don't like not being able to just hit enter to
            -- go to the next line if there is a cmp.
            select = false,
        }),
        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_locally_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { "i", "s" }),
    }),

    sources = cmp.config.sources({
        -- The insertion order influences the priority of the sources
        {
            name = "nvim_lsp" --[[ , keyword_length = 3 ]],
        },
        {
            name = "nvim_lsp_signature_help" --[[ , keyword_length = 3  ]],
        },
        { name = "path" },
        { name = "luasnip" },
        { name = "buffer" },
    }),
    enabled = function()
        return vim.bo[0].buftype ~= "prompt"
    end,
    experimental = { native_menu = false, ghost_text = false },
})

cmp.setup.filetype("lua", {
    sources = cmp.config.sources({
        { name = "nvim_lua" },
        {
            name = "nvim_lsp" --[[ , keyword_length = 3  ]],
        },
        {
            name = "nvim_lsp_signature_help" --[[ , keyword_length = 3  ]],
        },
        { name = "path" },
        { name = "luasnip" },
        { name = "buffer" },
    }),
    { { name = "cmdline", option = { ignore_cmds = { "Man", "!" } } } },
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ "/", "?" }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        {
            name = "nvim_lsp_document_symbol" --[[ , keyword_length = 3  ]],
        },
        { name = "buffer" },
        { name = "cmdline_history" },
    },
    view = { entries = { name = "wildmenu", separator = "|" } },
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(":", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = "cmdline" }, -- { name = 'cmdline_history' },
        { name = "path" },
    }),
})
