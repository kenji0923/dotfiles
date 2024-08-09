" hook_add {{{

let g:cmake_compile_commands = 1
let g:cmake_build_path_pattern = [ "%s/../build/%s/", "getcwd(), g:cmake_build_type" ]
let g:cmake_build_args = "--parallel"

augroup cmake4vim_custom
    autocmd BufEnter CMakeLists.txt call s:cmake4vim_preset()
    autocmd FileType c call s:cmake4vim_preset()
    autocmd FileType cpp call s:cmake4vim_preset()
augroup END

function s:cmake4vim_preset()
    let g:cmake_src_dir = getcwd()
    let g:cmake_compile_commands_link = g:cmake_src_dir
    nmap <buffer> ;b <Plug>(CMakeBuild)
endfunction

" }}}
