" hook_source {{{


if has('mac')
    let g:vimtex_view_method = 'skim'
elseif has('win32') || (has('unix') && exists('$WSLENV'))
    if executable('SumatraPDF.exe')
	let g:vimtex_view_general_viewer = 'open-sumatra.sh'
    endif
endif


" }}}
