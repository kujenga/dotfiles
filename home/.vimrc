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

" git inline support
Plug 'airblade/vim-gitgutter'
" git wrapper
Plug 'tpope/vim-fugitive'

" Sensible defaults for Vim
Plug 'tpope/vim-sensible'
"" Configure vim based on the project
Plug 'editorconfig/editorconfig-vim'
" fuzzy finder
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
" Async linting while I type
Plug 'w0rp/ale'
" Autocomplete
Plug 'Valloric/YouCompleteMe'

" Go language support
Plug 'fatih/vim-go'
" Python support
Plug 'python-mode/python-mode'
" Docker support
Plug 'moby/moby' , {'rtp': '/contrib/syntax/vim/'}
" JSON support
Plug 'elzr/vim-json'

" Initialize plugin system
call plug#end()

" fzf shortcuts
noremap <c-x> :Files<CR>
vnoremap <c-x> <Esc>:Files<CR>
inoremap <c-x> <Esc>:Files<CR>

" Python customizations
let g:pymode_folding = 0
