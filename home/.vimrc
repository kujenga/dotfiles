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
" Async linting while I type, fixing on save when I want
Plug 'w0rp/ale'
" Autocomplete
Plug 'Valloric/YouCompleteMe'
" sensible buffer close
Plug 'qpkorr/vim-bufkill'
" improved status line
Plug 'vim-airline/vim-airline'

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
noremap <c-b> :Buffers<CR>
vnoremap <c-b> <Esc>:Buffers<CR>
inoremap <c-b> <Esc>:Buffers<CR>

" Go customizations
let g:go_fmt_command = "goimports"

" JS customizations
" let g:neoformat_enabled_javascript = ['prettier']
let g:ale_fixers = {}
let g:ale_fixers['javascript'] = ['prettier']
let g:ale_fix_on_save = 1
let g:ale_javascript_prettier_options = '--single-quote --trailing-comma es5 --jsx-bracket-same-line'

" Python customizations
let g:pymode_folding = 0
" grey column indicator
hi ColorColumn ctermbg=8

" YAML customizations
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

" Copy and paste using system clipboard
vnoremap <C-c> "*y

" Trigger autoread on focus change
au FocusGained,BufEnter * :silent! !

" Use ripgrep for fzf
let $FZF_DEFAULT_COMMAND = 'rg --files'
" Ripgrep support using fzf
" https://github.com/junegunn/fzf.vim#advanced-customization
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always '.shellescape(<q-args>), 1,
  \   <bang>0 ? fzf#vim#with_preview('up:60%')
  \           : fzf#vim#with_preview('right:50%:hidden', '?'),
  \   <bang>0)

" JSON
command! FormatJSON %!python -m json.tool
