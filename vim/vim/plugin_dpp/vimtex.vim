" hook_source {{{

if has('mac')
    let g:vimtex_view_method = 'skim'
elseif has('win32')
    if executable('SumatraPDF.exe')
        let g:vimtex_view_method = 'general'
        let g:vimtex_view_general_viewer = 'SumatraPDF.exe'
        let g:vimtex_view_general_options = '-reuse-instance -forward-search @tex @line @pdf'
    endif
elseif has('wsl') || exists('$WSL_DISTRO_NAME')
    if executable('open-sumatra.sh')
        let g:vimtex_view_method = 'general'
        let g:vimtex_view_general_viewer = 'open-sumatra.sh'
        let g:vimtex_view_general_options = '-reuse-instance -forward-search @tex @line @pdf'
    endif
endif

" }}}
