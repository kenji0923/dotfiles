" hook_source {{{

lua << EOF

-- Disable default Neovim 0.10+ LSP mappings starting with 'gr'
pcall(vim.keymap.del, 'n', 'gra')
pcall(vim.keymap.del, 'n', 'gri')
pcall(vim.keymap.del, 'n', 'grn')
pcall(vim.keymap.del, 'n', 'grr')
pcall(vim.keymap.del, 'n', 'grt')

vim.lsp.enable('basedpyright')

vim.opt.updatetime = 500

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
	    },
	})

	vim.opt_local.signcolumn = "yes"

	local client = vim.lsp.get_client_by_id(args.data.client_id)
	if client and client.server_capabilities.documentHighlightProvider then
	    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
		buffer = args.buf,
		callback = vim.lsp.buf.document_highlight,
	    })
	    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
		buffer = args.buf,
		callback = vim.lsp.buf.clear_references,
	    })
	end

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
			showLine = true,
			locationPaddingWidth = 30
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
			displayContainerName = true,
			symbolNameWidth = 40
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
		sourceParams = {
		    _ = {
			displayContainerName = true,
			symbolNameWidth = 40 
		    }
		},
		uiParams = {
		    ff = {
			ignoreEmpty = false
		    }
		}
	    })
	end

	vim.keymap.set('n', 'gd', start_ddu_lsp_definition, { noremap = true, buffer = true, silent = true, desc = "LSP: Definition" })
	vim.keymap.set('n', 'gD', start_ddu_lsp_decleration, { noremap = true, buffer = true, silent = true, desc = "LSP: Declaration" })
	vim.keymap.set('n', 'gr', start_ddu_lsp_references, { noremap = true, buffer = true, silent = true, desc = "LSP: References" })
	vim.keymap.set('n', 'gs', start_ddu_lsp_documentSymbol, { noremap = true, buffer = true, silent = true, desc = "LSP: Document Symbol" })
	vim.keymap.set('n', 'gw', start_ddu_lsp_workspaceSymbol, { noremap = true, buffer = true, silent = true, desc = "LSP: Workspace Symbol" })
	vim.keymap.set('n', 'K', function() vim.lsp.buf.hover({ border = "rounded" }) end, { noremap = true, buffer = true, silent = true, desc = "LSP: Hover" })
	vim.keymap.set("n", "gn", function() vim.lsp.buf.rename() end, { noremap = true, buffer = true, silent = true, desc = "LSP: Rename" })
    end,
})

EOF

" }}}
