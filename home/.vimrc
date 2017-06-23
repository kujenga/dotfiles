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

" YAML customizations
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

" Copy and paste using system clipboard
vnoremap <C-c> "*y

" Ripgrep support using fzf
" https://github.com/junegunn/fzf.vim#advanced-customization
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always '.shellescape(<q-args>), 1,
  \   <bang>0 ? fzf#vim#with_preview('up:60%')
  \           : fzf#vim#with_preview('right:50%:hidden', '?'),
  \   <bang>0)
