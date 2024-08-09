" hook_add {{{

function s:ddu_common_settings() abort
    setlocal cursorline

    nnoremap <buffer><silent><expr> <CR>
		\ ddu#ui#get_item()->get('isTree', v:false) ? 
		\ "<Cmd>call ddu#ui#do_action('itemAction', { 'name': 'narrow' })<CR>" : 
		\ "<Cmd>call ddu#ui#do_action('itemAction')<CR>"
    nnoremap <buffer><silent><expr> <Space>
		\ ddu#ui#get_item()->get('isTree', v:false) ? 
		\ "<Cmd>call ddu#ui#do_action('expandItem', { 'mode': 'toggle' })<CR>" :
		\ "<Cmd>call ddu#ui#do_action('itemAction')<CR>"
    nnoremap <buffer><silent> ^
		\ <Cmd>call ddu#ui#do_action('itemAction', { 'name': 'narrow', 'params': { 'path': '..' } })<CR>
    nnoremap <buffer><silent> q
		\ <Cmd>call ddu#ui#do_action('quit')<CR>
    nnoremap <buffer><silent> n
		\ <Cmd>call ddu#ui#do_action('chooseAction')<CR>
endfunction

function s:ddu_ff_settings() abort
    call s:ddu_common_settings()

    nnoremap <buffer><silent> i
		\ <Cmd>call ddu#ui#do_action('openFilterWindow')<CR>
endfunction

function s:ddu_ff_filter_settings() abort
    nnoremap <buffer><silent> q
		\ <Cmd>call ddu#ui#do_action('closeFilterWindow')<CR>
    nnoremap <buffer><silent> j
		\ <Cmd>call ddu#ui#do_action('cursorNext')<CR>
    nnoremap <buffer><silent> k
		\ <Cmd>call ddu#ui#do_action('cursorPrevious')<CR>
    noremap <buffer><silent> <C-n>
		\ <Cmd>call ddu#ui#do_action('cursorNext')<CR>
    noremap <buffer><silent> <C-p>
		\ <Cmd>call ddu#ui#do_action('cursorPrevious')<CR>
    inoremap <buffer><silent> <ESC>
		\ <ESC><Cmd>call ddu#ui#do_action('closeFilterWindow')<CR>
    inoremap <buffer><silent> <CR>
		\ <ESC><Cmd>call ddu#ui#do_action('itemAction')<CR>
    inoremap <buffer><silent> <C-j>
		\ <Cmd>call ddu#ui#do_action('cursorNext')<CR>
    inoremap <buffer><silent> <C-n>
		\ <Cmd>call ddu#ui#do_action('cursorNext')<CR>
    inoremap <buffer><silent> <C-k>
		\ <Cmd>call ddu#ui#do_action('cursorPrevious')<CR>
    inoremap <buffer><silent> <C-p>
		\ <Cmd>call ddu#ui#do_action('cursorPrevious')<CR>
endfunction

function s:ddu_filer_settings() abort
    call s:ddu_common_settings()
endfunction

autocmd FileType ddu-ff call s:ddu_ff_settings()
autocmd FileType ddu-ff-filter call s:ddu_ff_filter_settings()
autocmd FileType ddu-filer call s:ddu_filer_settings()

command! DduFiles call ddu#start({ "name": "files" })
nmap ;e <Cmd>:DduFiles<CR>

command! DduFiler call ddu#start({ "name": "filer" })
nmap ;f <Cmd>:DduFiler<CR>

call ddu#custom#patch_global({
	\ 	"ui": "ff",
	\ 	"uiParams": {
	\ 	    "ff": {
	\		"cursorPos": 0,
	\		"prompt": "> ",
	\ 	    },
	\ 	    "filer": {
	\ 		"split": "vertical",	
	\ 		"splitDirection": "topleft",	
	\ 		"winWidth": "&columns / 5",	
	\ 	    },
	\ 	},
	\ 	"sourceOptions": {
	\ 	    "_": {
	\ 		"matchers": ["matcher_substring"],
	\ 	    },
	\ 	},
	\	"kindOptions": {
	\	    "file": {
	\		"defaultAction": "open",
	\	    },
	\	    "action": {
	\		"defaultAction": "do",
	\	    },
	\	},
	\ })

call ddu#custom#patch_local("files", {
	\	"sources": ["file_rec"],
	\ })

call ddu#custom#patch_local("filer", {
	\	"ui": "filer", 
	\	"sources": ["file"],
	\ 	"sourceOptions": {
	\ 	    "_": {
	\ 		"columns": ["filename"],
	\ 	    },
	\ 	},
	\	"actionOptions": {
	\	    "narrow": {
	\		"quit": v:false,
	\	    },
	\	},
	\ })

" }}}
