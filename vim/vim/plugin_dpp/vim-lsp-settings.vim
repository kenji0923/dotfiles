" hook_add {{{

let g:lsp_settings = {
\   'pylsp-all': {
\	'workspace_config': {
\	    'pylsp': {
\	        'plugins': {
\		    'pycodestyle': {
\			'ignore': ['E501']
\		    }
\		 }
\	      }
\	 }
\   },
\}

" }}}
