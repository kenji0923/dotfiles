" hook_add {{{

function s:ddu_common_settings() abort
    setlocal cursorline

    nnoremap <buffer><silent><expr> <Space>
		\ ddu#ui#get_item()->get('isTree', v:false) ? 
		\ "<Cmd>call ddu#ui#do_action('expandItem', { 'mode': 'toggle' })<CR>" :
		\ "<Cmd>call ddu#ui#do_action('itemAction')<CR>"
    nnoremap <buffer><silent> q
		\ <Cmd>call ddu#ui#do_action('quit')<CR>
    nnoremap <buffer><silent> <C-q>
		\ <Cmd>call ddu#ui#do_action('quit')<CR>
    nnoremap <buffer><silent> <C-[>
		\ <Cmd>call ddu#ui#do_action('quit') <CR>
    nnoremap <buffer><silent> a
		\ <Cmd>call ddu#ui#do_action('chooseAction')<CR>
    nnoremap <buffer><silent> i
		\ <Cmd>call ddu#ui#do_action('openFilterWindow')<CR>
endfunction


function s:ddu_filter_set() abort
    call ddu#ui#save_cmaps(['<C-j>', '<C-n>', '<C-k>', '<C-p>', '<C-q>', '<CR>'])

    cnoremap <silent> <C-j>
	        \ <Cmd>call ddu#ui#do_action('cursorNext')<CR>
    cnoremap <silent> <C-n>
	        \ <Cmd>call ddu#ui#do_action('cursorNext')<CR>
    cnoremap <silent> <C-k>
	        \ <Cmd>call ddu#ui#do_action('cursorPrevious')<CR>
    cnoremap <silent> <C-p>
	        \ <Cmd>call ddu#ui#do_action('cursorPrevious')<CR>
    cnoremap <silent> <C-q>
		\ <Esc><Cmd>call ddu#ui#do_action('quit')<CR>
    cnoremap <silent> <CR>
		\ <CR><Cmd>call ddu#ui#do_action('itemAction')<CR>

    call cmdline#enable()
endfunction


function s:ddu_filter_clear() abort
    call ddu#ui#restore_cmaps()
    call cmdline#disable()
endfunction


function s:ddu_ff_settings() abort
    call s:ddu_common_settings()

    call cmdline#set_option(#{
		\   border: "rounded",
		\   row: 0,
		\   col: 1,
		\   width: &columns - 3,
		\   highlight_prompt: 'Statement',
		\   highlight_window: 'None',
		\ })

    nnoremap <buffer><silent><expr> <CR>
		\ "<Cmd>call ddu#ui#do_action('itemAction')<CR>"

    nnoremap <buffer><silent> R
		\ <Cmd>call ddu#ui#do_action('itemAction', {'name': 'rename'})<CR>
endfunction

function s:ddu_filer_settings() abort
    call s:ddu_common_settings()

    nnoremap <buffer><silent><expr> <CR>
		\ ddu#ui#get_item()->get('isTree', v:false) ? 
		\ "<Cmd>call ddu#ui#do_action('itemAction', { 'name': 'narrow' })<CR>" : 
		\ "<Cmd>call ddu#ui#do_action('itemAction')<CR>"

    nnoremap <buffer><silent> <C-h>
		\ <Cmd>call ddu#ui#do_action('itemAction', { 'name': 'narrow', 'params': { 'path': '..' } })<CR>
    nnoremap <buffer><silent> R
		\ <Cmd>call ddu#ui#do_action('itemAction', {'name': 'rename'})<CR>
endfunction

augroup DduCommands
    autocmd!
    autocmd FileType ddu-ff call s:ddu_ff_settings()
    autocmd FileType ddu-filer call s:ddu_filer_settings()

    autocmd User Ddu:uiOpenFilterWindow
		\ call s:ddu_filter_set()

    autocmd User Ddu:uiCloseFilterWindow
		\ call s:ddu_filter_clear()

		"  autocmd User Ddu:uiDone ++nested
		"\ call ddu#ui#async_action('openFilterWindow')
augroup END

command! DduFiles call ddu#start({ "name": "files" })
nmap ;; <Cmd>:call ddu#start({ "name": "files" })<CR>

command! DduFiler call ddu#start({ "name": "filer" })
nmap ;f <Cmd>:DduFiler<CR>

call ddu#custom#patch_global({
	\ 	"ui": "ff",
	\	"uiOptions": {
	\	    "_": {
	\		"filterPrompt": "> "
	\	    }
	\	},
	\ 	"uiParams": {
	\ 	    "ff": {
	\		"cursorPos": 0,
	\		"split": 'floating',
	\       	"winHeight": &lines - 6,
	\       	"winWidth": &columns / 2 - 3,
	\       	"winRow": 3,
	\       	"winCol": 1,
	\       	"floatingBorder": "rounded", 
	\		"previewFloating": v:true,
	\       	'previewHeight': &lines - 6,
	\       	'previewWidth': &columns /2 - 3 ,
	\       	'previewRow': 3,
	\		"previewCol": &columns / 2 + 1,
	\		"previewSplit": "vertical",
	\       	'previewFloatingBorder': "rounded",
	\		"startAutoAction": v:true,
	\		'autoAction': { 'name': 'preview' }
	\ 	    }
	\ 	},
	\ 	"sourceOptions": {
	\ 	    "_": {
	\ 		"matchers": ["matcher_substring"],
	\ 	    },
	\ 	},
	\	"filterParams": {
	\	    "matcher_substring": {
	\		"highlightMatched": "Search",
	\	    },
	\	},
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
	\ 	"sourceOptions": {
	\ 	    "_": {
	\ 		"converters": ["converter_devicon"]
	\ 	    }
	\	}
	\ })

call ddu#custom#patch_local("filer", {
	\	"ui": "filer", 
	\ 	"uiParams": {
	\ 	    "_": {
	\ 		"split": "vertical",	
	\ 		"splitDirection": "topleft",	
	\ 		"winWidth": "&columns / 4",
	\ 	    }
	\	},
	\	"sources": ["file"],
	\ 	"sourceOptions": {
	\ 	    "_": {
	\ 		"columns": ["filename"],
	\ 		"converters": ["converter_devicon"]
	\ 	    },
	\ 	},
	\	"actionOptions": {
	\	    "narrow": {
	\		"quit": v:false,
	\	    },
	\	},
	\ })

" }}}
