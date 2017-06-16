" syntax highlighting
syntax enable
" show line numbers
set number
highlight LineNr term=bold cterm=NONE ctermfg=DarkGrey ctermbg=NONE gui=NONE guifg=DarkGrey guibg=NONE
" show line,column in status bar
set statusline+=%f\ %l\:%c

" vim-plug configuration
" https://github.com/junegunn/vim-plug
call plug#begin('~/.vim/plugged')

" git support
Plug 'airblade/vim-gitgutter'
" Sensible defaults for Vim
Plug 'tpope/vim-sensible'
" Go language support
Plug 'fatih/vim-go'
" Docker support
Plug 'moby/moby' , {'rtp': '/contrib/syntax/vim/'}
" JSON support
Plug 'elzr/vim-json'

" Initialize plugin system
call plug#end()
