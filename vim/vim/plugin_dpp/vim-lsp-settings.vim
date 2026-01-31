" hook_add {{{

    " Not good for Windows maybe
    let s:python_path = exists("$VIRTUAL_ENV") ? $VIRTUAL_ENV . "/bin/python" : "python"

    let g:lsp_settings = #{
	\	basedpyright-langserver: #{
	\	    root_uri_patterns: ['pyrightconfig.json', '.git/'],
	\	    workspace_config: #{
	\		basedpyright: #{
	\		    analysis: #{
	\			diagnosticMode: "workspace"
	\		    }
	\		},
	\		python: #{
	\		    pythonPath: s:python_path
	\		}
	\	    }
	\	}
	\ }

" }}}
