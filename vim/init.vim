set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
if has('win32')
    source ~/_vimrc
else
    source ~/.vimrc
endif

set termguicolors
colorscheme kanagawa-dragon
