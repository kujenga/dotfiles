syntax enable

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

" Initialize plugin system
call plug#end()
