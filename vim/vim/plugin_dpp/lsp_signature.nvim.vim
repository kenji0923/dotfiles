" hook_source {{{

lua << EOF

require('lsp_signature').setup({
    bind = true,
    handler_opts = {
	border = "rounded"
    }
})

EOF

" }}}
