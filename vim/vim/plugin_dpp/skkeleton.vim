" hook_add {{{
function! s:skkeleton_init() abort
    imap <C-j> <Plug>(skkeleton-enable)
    cmap <C-j> <Plug>(skkeleton-enable)
    imap <C-f> <Plug>(skkeleton-disable)
    cmap <C-f> <Plug>(skkeleton-disable)

    imap <S-F2> <Plug>(skkeleton-enable)
    cmap <S-F2> <Plug>(skkeleton-enable)
    imap <S-F1> <Plug>(skkeleton-disable)
    cmap <S-F1> <Plug>(skkeleton-disable)

    let g:skk_statusline_mode_strings = {
		\ 'hira': 'あ',
		\ 'kata': 'ア',
		\ '': 'aA',
		\ 'zenei': 'ａ',
		\ 'hankata': 'ｧｱ',
		\ 'abbrev': 'aあ'
		\}

    set statusline=%<%f\ %h%m%r\ %{skk_statusline_mode_strings[skkeleton#mode()]}%=%-14.(%l,%c%V%)\ %P

    call skkeleton#config({
		\ 'userDictionary': '~/.skk/user_dict/skk-jisyo_skkeleton.utf8',
		\ 'globalDictionaries': [
		\   '~/.skk/SKK-JISYO.L',
		\   '~/.skk/SKK-JISYO.fullname',
		\   '~/.skk/SKK-JISYO.geo',
		\   '~/.skk/SKK-JISYO.jinmei',
		\   '~/.skk/SKK-JISYO.propernoun',
		\   '~/.skk/SKK-JISYO.station'
		\ ],
		\ 'showCandidatesCount': 1,
		\ 'eggLikeNewline': v:true,
		\ 'keepState': v:true, 
		\ 'immediatelyCancel': v:false
		\ })
endfunction

augroup skkeleton-initialize-pre
  autocmd!
  autocmd User skkeleton-initialize-pre call s:skkeleton_init()
augroup END

augroup skkeleton-mode-changed
  autocmd!
  autocmd User skkeleton-mode-changed redrawstatus
augroup END

call skkeleton#initialize()
" }}}
