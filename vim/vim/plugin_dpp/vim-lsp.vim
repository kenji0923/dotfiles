" hook_add {{{

function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    setlocal signcolumn=yes
    if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif


    let g:ddu_source_lsp_clientName = "vim-lsp"


    call ddu#custom#patch_global({
	    \	    "sync": v:true,
	    \	    "kindOptions": {
	    \	        "lsp": {
	    \		   "defaultAction": "open",
	    \	        },
	    \	        "lsp_codeAction": {
	    \		   "defaultAction": "apply",
	    \	        },
	    \	    },
	    \ })


    function! s:start_ddu_lsp_definition() abort
	call ddu#start({
	    \	    "sync": v:true,
	    \	    "sources": [ "lsp_definition" ],
	    \	    "uiParams": {
	    \		"ff": {
	    \		    "immediateAction": "open",
	    \		},
	    \	    },
	    \ })
    endfunction


    function! s:start_ddu_lsp_decleration() abort
	call ddu#start({
	    \	    "sync": v:true,
	    \	    "sources": [ "lsp_definition" ],
	    \	    "sourceParams": {
	    \		"_": {
	    \		    "method": "textDocument/declaration"
	    \		},
	    \	    },
	    \	    "uiParams": {
	    \		"ff": {
	    \		    "immediateAction": "open",
	    \		},
	    \	    },
	    \ })
    endfunction


    function! s:start_ddu_lsp_references() abort
	call ddu#start({
	    \	    "sync": v:true,
	    \	    "sources": [ "lsp_references" ],
	    \	    "sourceParams": {
	    \		"_": {
	    \		    "includeDeclaration": v:false,
	    \		},
	    \	    },
	    \	    "uiParams": {
	    \		"ff": {
	    \		    "immediateAction": "open",
	    \		},
	    \	    },
	    \ })
    endfunction


    function! s:start_ddu_lsp_documentSymbol() abort
	call ddu#start({
	    \	    "sources": [ "lsp_documentSymbol" ],
	    \ })
    endfunction


    function! s:start_ddu_lsp_workspaceSymbol(query) abort
	call ddu#start({
	    \	    "sources": [ "lsp_workspaceSymbol" ],
	    \	    "sourceParams": {
	    \		"_": {
	    \		    "query": a:query,
	    \		},
	    \	    },
	    \ })
    endfunction


    nmap <buffer> gd <plug>(lsp-definition)
    nmap <buffer><expr> gud <SID>start_ddu_lsp_definition()


    nmap <buffer> gD <plug>(lsp-declaration)
    nmap <buffer><expr> guD <SID>start_ddu_lsp_decleration()


    nmap <buffer> gy <plug>(lsp-type-definition)
    nmap <buffer> gi <plug>(lsp-implementation)


    " nmap <buffer> gs <plug>(lsp-document-symbol)
    nmap <buffer><expr> gs <SID>start_ddu_lsp_documentSymbol()


    " nmap <buffer> gw <plug>(lsp-workspace-symbol)
    nmap <buffer><expr> gw <SID>start_ddu_lsp_workspaceSymbol("")
    
    " nmap <buffer> gr <plug>(lsp-references)
    nmap <buffer><expr> gr <SID>start_ddu_lsp_references()


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
