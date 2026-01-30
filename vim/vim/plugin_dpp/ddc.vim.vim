" hook_add {{{

call ddc#custom#patch_global(#{
	    \	ui: 'pum',
	    \   autoCompleteEvents: [
	    \     'InsertEnter', 'TextChangedI', 'TextChangedP', 'CmdlineChanged',
	    \   ]
	    \ })

call ddc#custom#patch_global('sources', ['buffer', "file", "rg", 'vsnip', 'lsp'])

call ddc#custom#patch_global('sourceOptions', {
	    \	'_': {
	    \     'matchers': ['matcher_fuzzy'],
	    \     'sorters': ['sorter_fuzzy'],
	    \     'converters': ['converter_fuzzy']
	    \	},
	    \	'around': {
	    \	    'mark': 'aro',
	    \	},
	    \	'buffer': {
	    \	    'mark': 'buf',
	    \	},
	    \	'lsp': {
	    \	    'isVolatile': v:true,
	    \	    'mark': 'lsp',
	    \	    'forceCompletionPattern': '\.\w*|:\w*|->\w*',
	    \	},
	    \	'vsnip': {
	    \	    'mark': 'snipet',
	    \	    'dup': 'keep',
	    \	},
	    \	'cmdline': {
	    \	    'mark': 'cmd',
	    \	    "minAutoCompleteLength": 1
	    \	},
	    \	'cmdline-history': {
	    \	    'mark': 'cmdhis',
	    \	    "minAutoCompleteLength": 1
	    \	},
	    \	'file': {
	    \	    'mark': '',
	    \	    'isVolatile': v:true,
	    \       'forceCompletionPattern': '\S*/\S*|\.\.?',
	    \	},
	    \	'input': {
	    \	    'mark': 'input',
	    \	    'isVolatile': v:true
	    \	},
	    \	'line': {
	    \	    'mark': 'line'
	    \	},
	    \   "rg": {
	    \     "mark": 'rg',
	    \     "minAutoCompleteLength": 4,
	    \   },
	    \ })

call ddc#custom#patch_global('sourceParams', {
	    \   'lsp': {
	    \	    'lspEngine': 'vim-lsp',
	    \	    'snippetEngine': denops#callback#register({
	    \		    body -> vsnip#anonymous(body)
	    \		}),
	    \	    'enableAdditionalTextEdit': v:true,
	    \	    'enableDisplayDetail': v:true,
	    \   },
	    \ })

call ddc#custom#patch_global('filterParams', {
	    \   'converter_fuzzy': {
	    \     'hlGroup': 'SpellBad'
	    \   }
	    \ })

call ddc#custom#patch_filetype(['ps1', 'dosbatch', 'autohotkey', 'registry'], {
	    \	'sourceOptions': {
	    \	  'file': {
	    \	    'forceCompletionPattern': '\S\\\S*',
	    \	  },
	    \	},
	    \	'sourceParams': {
	    \	  'file': {
	    \	    'mode': 'win32',
	    \	  },
	    \	}
	    \ })

" Command line completion
set wildoptions+=fuzzy
call ddc#custom#patch_global('cmdlineSources', {
	    \ ':': ["file", 'cmdline-history', 'cmdline', 'around'],
	    \ '@': ['cmdline-history', 'input', 'file', 'around'],
	    \ '>': ['cmdline-history', 'input', 'file', 'around'],
	    \ '/': ['around', 'line'],
	    \ '?': ['around', 'line'],
	    \ '-': ['around', 'line'],
	    \ '=': ['input'],
	    \ })

nnoremap :  <Cmd>call CommandlinePre()<CR>:

function! CommandlinePre() abort
    cnoremap <Tab>   <Cmd>call pum#map#insert_relative(+1)<CR>
    cnoremap <S-Tab> <Cmd>call pum#map#insert_relative(-1)<CR>
    cnoremap <C-n>   <Cmd>call pum#map#insert_relative(+1)<CR>
    cnoremap <C-p>   <Cmd>call pum#map#insert_relative(-1)<CR>
    cnoremap <C-f>   <Cmd>call pum#map#insert_relative_page(+1)<CR>
    cnoremap <C-b>   <Cmd>call pum#map#insert_relative_page(-1)<CR>
    cnoremap <C-y>   <Cmd>call pum#map#confirm()<CR>
    cnoremap <C-e>   <Cmd>call pum#map#cancel()<CR>

    autocmd User DDCCmdlineLeave ++once call CommandlinePost()

    " Enable command line completion for the buffer
    call ddc#enable_cmdline_completion()
endfunction

function! CommandlinePost() abort
    silent! cunmap <Tab>
    silent! cunmap <S-Tab>
    silent! cunmap <C-n>
    silent! cunmap <C-p>
    silent! cunmap <C-y>
    silent! cunmap <C-e>
endfunction

call ddc#custom#patch_filetype('ddu-ff', 'ui', 'none') 
call ddc#custom#patch_filetype('ddu-filer', 'ui', 'none') 

call ddc#enable()

inoremap <C-l>	<cmd>call ddc#map#manual_complete()<CR>
inoremap <C-n>	<Cmd>call pum#map#insert_relative(+1)<CR>
inoremap <C-p>	<Cmd>call pum#map#insert_relative(-1)<CR>
inoremap <C-f>  <Cmd>call pum#map#insert_relative_page(+1)<CR>
inoremap <C-b>  <Cmd>call pum#map#insert_relative_page(-1)<CR>
inoremap <C-y>	<Cmd>call pum#map#confirm()<CR>
inoremap <C-e>	<Cmd>call pum#map#cancel()<CR>

" }}}
