" hook_source {{{

lua << EOF

local languages = { 'cpp', 'python', 'typescript', 'vim', 'vimdoc', 'bash', 'powershell' }

-- Official way to install parsers according to the latest README
require('nvim-treesitter').install(languages)

vim.api.nvim_create_autocmd('FileType', {
    -- Mapping parsers to their actual FileTypes ('help' for 'vimdoc', 'sh' for 'bash', etc.)
    pattern = { 'cpp', 'python', 'typescript', 'vim', 'help', 'sh', 'ps1' },
    callback = function()
        pcall(vim.treesitter.start)
	vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
})

EOF

" }}}
