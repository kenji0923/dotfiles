" hook_source {{{

function! s:on_lsp_buffer_enabled() abort
    let g:lsp_log_verbose = 1
    let g:lsp_log_file = expand('~/vim-lsp.log')

    setlocal omnifunc=lsp#complete
    setlocal signcolumn=yes
    if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif


    let g:ddu_source_lsp_clientName = "vim-lsp"


    call ddu#custom#patch_global(#{
	    \	sourceOptions: #{
	    \	    lsp_documentSymbol: #{
	    \		converters: [ 'converter_lsp_symbol' ],
	    \	    },
	    \	    lsp_workspaceSymbol: #{
	    \		converters: [ 'converter_lsp_symbol' ],
	    \	    },
	    \	},
	    \	kindOptions: #{
	    \	    lsp: #{
	    \		defaultAction: "open",
	    \	    },
	    \	    lsp_codeAction: #{
	    \		defaultAction: "apply",
	    \	    },
	    \	},
	    \ })


    function! s:start_ddu_lsp_definition() abort
	call ddu#start({
	    \	    "sync": v:true,
	    \	    "sources": [ {"name": "lsp_definition"} ],
	    \	    "sourceParams": {
	    \		"_": {
	    \		    "method": "textDocument/definition"
	    \		}
	    \	    },
	    \	    "uiParams": {
	    \		"ff": {
	    \		    "immediateAction": "open",
	    \		},
	    \	    },
	    \ })
    endfunction


    function! s:start_ddu_lsp_decleration() abort
	call ddu#start({
	    \	    "sources": [ "lsp_definition" ],
	    \	    "sourceParams": {
	    \		"_": {
	    \		    "method": "textDocument/declaration"
	    \		}
	    \	    },
	    \	    "uiParams": {
	    \		"ff": {
	    \		    "immediateAction": "open"
	    \		}
	    \	    }
	    \ })
    endfunction


    function! s:start_ddu_lsp_references() abort
	call ddu#start({
	    \	    "sync": v:true,
	    \	    "sources": [{
	    \		"name": "lsp_references"
	    \	    }],
	    \	    "sourceParams": {
	    \		"_": {
	    \		    "includeDeclaration": v:true
	    \		},
	    \	    },
	    \	    "uiParams": {
	    \		"ff": {
	    \		    "immediateAction": "open"
	    \		}
	    \	    }
	    \ })
    endfunction


    function! s:start_ddu_lsp_documentSymbol() abort
	call ddu#start(#{
	    \	    sources: [#{
	    \		name: "lsp_documentSymbol"
	    \	    }],
	    \	    sourceParams: #{
	    \		_: #{
	    \		    displayContainerName: v:true,
	    \ 	    	}
	    \ 	    },
	    \ 	    uiParams: #{
	    \		ff: #{
	    \		    ignoreEmpty: v:false
	    \ 	    	}
	    \ 	    }
	    \ })
    endfunction


    " Bug? Filtering not working
    function! s:start_ddu_lsp_workspaceSymbol() abort
	call ddu#start(#{
	    \	    sources: [#{
	    \		name: "lsp_workspaceSymbol"
	    \	    }],
	    \	    sourceOptions: #{
	    \		_: #{
	    \		    volatile: v:true,
	    \ 	    	},
	    \ 	    },
	    \ 	    uiParams: #{
	    \		ff: #{
	    \		    ignoreEmpty: v:false
	    \ 	    	},
	    \ 	    }
	    \ })
    endfunction


    function! s:start_ddu_lsp_callHierarchy_incomingCalls() abort
	call ddu#start(#{
	    \	    sources: [#{
	    \		name: "lsp_callHierarchy"
	    \	    }],
	    \	    sourceOptions: #{
	    \		_: #{
	    \		    volatile: v:true,
	    \ 	    	},
	    \ 	    },
	    \	    sourceParams: #{
	    \		_: #{
	    \		    method: "callHierarchy/incomingCalls"
	    \ 	    	},
	    \ 	    },
	    \ 	    uiParams: #{
	    \		ff: #{
	    \		    displayTree: v:true
	    \ 	    	},
	    \ 	    }
	    \ })
    endfunction


    function! s:start_ddu_lsp_callHierarchy_outgoingCalls() abort
	call ddu#start(#{
	    \	    sources: [#{
	    \		name: "lsp_callHierarchy"
	    \	    }],
	    \	    sourceOptions: #{
	    \		_: #{
	    \		    volatile: v:true,
	    \ 	    	},
	    \ 	    },
	    \	    sourceParams: #{
	    \		_: #{
	    \		    method: "callHierarchy/outgoingCalls"
	    \ 	    	},
	    \ 	    },
	    \ 	    uiParams: #{
	    \		ff: #{
	    \		    ignoreEmpty: v:false
	    \ 	    	},
	    \ 	    }
	    \ })
    endfunction

    nmap <buffer> gd <plug>(lsp-definition)
    nmap <buffer> gD <plug>(lsp-declaration)
    nmap <buffer> gy <plug>(lsp-type-definition)
    nmap <buffer> gi <plug>(lsp-implementation)
    nmap <buffer> gr <plug>(lsp-references)

    nmap <buffer><expr> gs <SID>start_ddu_lsp_documentSymbol()
    nmap <buffer><expr> gw <SID>start_ddu_lsp_workspaceSymbol()
    nmap <buffer><expr> gur <SID>start_ddu_lsp_references()

    nmap <buffer><expr> gchi <SID>start_ddu_lsp_callHierarchy_incomingCalls()
    nmap <buffer><expr> gcho <SID>start_ddu_lsp_callHierarchy_outgoingCalls()

    nmap <buffer> [g <plug>(lsp-previous-diagnostic)
    nmap <buffer> ]g <plug>(lsp-next-diagnostic)
    nmap <buffer> K <plug>(lsp-hover)
    nmap <buffer> <leader>rn <plug>(lsp-rename)

    let g:lsp_diagnostics_virtual_text_delay = 30
    let g:lsp_diagnostics_virtual_text_align = "after"
    let g:lsp_diagnostics_virtual_text_wrap = "truncate"
    let g:lsp_format_sync_timeout = 1000
endfunction

augroup lsp_install
    autocmd!
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

" }}}
