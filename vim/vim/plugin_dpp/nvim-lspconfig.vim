" hook_source {{{

lua << EOF

vim.lsp.enable('basedpyright')

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('my.lsp', {}),
    callback = function(args)
	vim.diagnostic.config({
	    signs = {
		active = true,
	    },
	    virtual_text = true,
	    underline = true,
	    update_in_insert = true,
	    float = {
		cursorhold = true,
		source = "always",
		border = "single", -- Optional, adds a border to the float
	    },
	})

	vim.g.ddu_source_lsp_clientName = "nvim-lsp"

	vim.fn["ddu#custom#patch_global"]({
	    sourceOptions = {
		lsp_documentSymbol = {
		    converters = { 'converter_lsp_symbol' },
		},
		lsp_workspaceSymbol = {
		    converters = { 'converter_lsp_symbol' },
		},
	    },
	    kindOptions = {
		lsp = {
		    defaultAction = "open",
		},
		lsp_codeAction = {
		    defaultAction = "apply",
		},
	    }
	})

	local function start_ddu_lsp_decleration()
	    vim.fn["ddu#start"]({
		sync = true,
		sources = {{
		    name = "lsp_definition"
		}},
		sourceParams = {
		    _ = {
			method = "textDocument/declaration"
		    }
		},
		uiParams = {
		    ff = {
			immediateAction = "open"
		    }
		}
	    })
	end

	local function start_ddu_lsp_definition()
	    vim.fn["ddu#start"]({
		sync = true,
		sources = {{
		    name = "lsp_definition"
		}},
		sourceParams = {
		    _ = {
			method = "textDocument/definition"
		    }
		},
		uiParams = {
		    ff = {
			immediateAction = "open"
		    }
		}
	    })
	end

	local function start_ddu_lsp_references()
	    vim.fn["ddu#start"]({
		sync = true,
		sources = {{
		    name = "lsp_references"
		}},
		sourceParams = {
		    _ = {
			includeDeclaration = true
		    }
		}
	    })
	end

	local function start_ddu_lsp_documentSymbol()
	    vim.fn["ddu#start"]({
		sources = {{
		    name = "lsp_documentSymbol"
		}},
		sourceParams = {
		    _ = {
			displayContainerName = true
		    }
		},
		uiParams = {
		    ff = {
			ignoreEmpty = false
		    }
		}
	    })
	end

	local function start_ddu_lsp_workspaceSymbol()
	    vim.fn["ddu#start"]({
		sources = {{
		    name = "lsp_workspaceSymbol"
		}},
		sourceOptions = {
		    _ = {
			volatile = true
		    }
		},
		uiParams = {
		    ff = {
			ignoreEmpty = false
		    }
		}
	    })
	end

	vim.keymap.set('n', 'gd', start_ddu_lsp_definition, { noremap = true, buffer = true, silent = true })
	vim.keymap.set('n', 'gD', start_ddu_lsp_decleration, { noremap = true, buffer = true, silent = true })
	vim.keymap.set('n', 'gr', start_ddu_lsp_references, { noremap = true, buffer = true, silent = true })
	vim.keymap.set('n', 'gs', start_ddu_lsp_documentSymbol, { noremap = true, buffer = true, silent = true })
	vim.keymap.set('n', 'gw', start_ddu_lsp_workspaceSymbol, { noremap = true, buffer = true, silent = true })
    end,
})

EOF

" }}}
