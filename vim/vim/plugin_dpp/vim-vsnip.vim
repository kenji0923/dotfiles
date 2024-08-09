" hook_add {{{
if has('win32')
    let s:vim_base_dir = expand('~/_vim/')
else
    let s:vim_base_dir = expand('~/.vim/')
endif

let g:vsnip_snippet_dir = s:vim_base_dir .. 'vim-vsip'
const s:friendly_snippets_dir = dpp#get('friendly-snippets')['rtp'] .. '/snippets'
let g:vsnip_snippet_dirs = [ 
	    \ s:friendly_snippets_dir,
	    \ s:friendly_snippets_dir .. '/cpp',
	    \ ]

" Expand or jump
imap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
smap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'

" Jump forward or backward
imap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
smap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
imap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
smap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'

imap <expr><nowait> <C-]>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<C-]>'
smap <expr><nowait> <C-]>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<C-]>'
imap <expr><nowait> <C-r> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<C-r>'
smap <expr><nowait> <C-r> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<C-r>'

let g:vsnip_filetypes = {}
let g:vsnip_filetypes.tex = ['latex']
" }}}
