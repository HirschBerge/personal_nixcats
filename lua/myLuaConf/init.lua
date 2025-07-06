#!/usr/bin/env lua

require("myLuaConf.plugins")
require("myLuaConf.LSPs")
require("myLuaConf.format")
require("myLuaConf.autocmds")
require("myLuaConf.mappings")

if nixCats("debug") then
    require("myLuaConf.debug")
end
vim.opt.wrap = false
vim.cmd("set clipboard+=unnamedplus")
vim.cmd([[colorscheme catppuccin-mocha]])
vim.o.termguicolors = true
vim.cmd("colorscheme catppuccin") -- Or whatever theme you use

-- These are the absolute core for transparency
vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "NONE" })

-- NOTE:Unmap <C-a> from the current mapping (which selects all)
vim.api.nvim_set_keymap("n", "<C-a>", "<Nop>", { noremap = true })

-- Remap <C-a> to execute the CTRL-A command
vim.api.nvim_set_keymap("n", "<C-a>", '<cmd>execute "normal! <C-A>"<CR>', { noremap = true })
-- NOTE: Folders
vim.cmd("set foldlevel=20")
vim.o.foldmethod = "expr"
vim.wo.foldexpr = "nvim_treesitter#foldexpr()"
vim.o.scrolloff = 15
-- NOTE:Color ofLine numbering
-- -- Change the color of regular line numbers (LineNr)
vim.api.nvim_set_hl(0, "LineNr", { fg = "#cba6f7" })
-- Doesn't work???
-- -- Change the color of the current line number (CursorLineNr)
vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#D2F7A6" })
-- Enables inlay hints
vim.lsp.inlay_hint.enable()
vim.api.nvim_set_hl(0, "LspInlayHint", { fg = "#cba6f7", bg = "#11111b", italic = true })
