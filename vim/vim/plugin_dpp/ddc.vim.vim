" hook_add {{{

call ddc#custom#patch_global('ui', 'native')

call ddc#custom#patch_global('sources', ['around', 'vsnip', 'lsp'])

call ddc#custom#patch_global('sourceOptions', {
	    \	'_': {
	    \	    'matchers': ['matcher_head'],
	    \	    'sorters': ['sorter_rank'],
	    \	},
	    \	'around': {
	    \	    'mark': 'aro',
	    \	},
	    \	'lsp': {
	    \	    'mark': 'lsp',
	    \	    'forceCompletionPattern': '\.\w*|:\w*|->\w*',
	    \	    'sorters': ['sorter_lsp-kind'],
	    \	},
	    \	'vsnip': {
	    \	    'mark': 'vsnip',
	    \	    'dup': 'keep',
	    \	},
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

call ddc#custom#patch_filetype('ddu-ff', 'ui', 'none') 
call ddc#custom#patch_filetype('ddu-ff-filter', 'ui', 'none') 
call ddc#custom#patch_filetype('ddu-filer', 'ui', 'none') 

call ddc#enable()

imap <expr> <C-k> ddc#map#manual_complete()

" }}}
