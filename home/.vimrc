" vim-plug configuration
" https://github.com/junegunn/vim-plug
call plug#begin('~/.vim/plugged')

" git inline support
Plug 'airblade/vim-gitgutter'
" git wrapper
Plug 'tpope/vim-fugitive'

" Sensible defaults for Vim
Plug 'tpope/vim-sensible'
" Configure vim based on the project
Plug 'editorconfig/editorconfig-vim'
" Guess indentation from current buffer
Plug 'ciaranm/detectindent'
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
" tree view of files
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
" commenting
Plug 'scrooloose/nerdcommenter'

" Go language support
Plug 'fatih/vim-go'
" Python support
Plug 'python-mode/python-mode'
" Docker support
Plug 'moby/moby' , {'rtp': '/contrib/syntax/vim/'}
" JSON support
Plug 'elzr/vim-json'
" Rust support
Plug 'rust-lang/rust.vim'
" HTML Support
Plug 'mattn/emmet-vim'

" syntax highlighting
Plug 'kujenga/vim-monokai'

" Initialize plugin system
call plug#end()

" syntax highlighting
syntax enable
colorscheme monokai
" show line numbers
set number
" show line,column in status bar
set statusline+=%f\ %l\:%c
" allow buffers with unsaved changes
set hidden

" fzf shortcuts
noremap <c-x> :Files<CR>
vnoremap <c-x> <Esc>:Files<CR>
inoremap <c-x> <Esc>:Files<CR>
noremap <c-b> :Buffers<CR>
vnoremap <c-b> <Esc>:Buffers<CR>
inoremap <c-b> <Esc>:Buffers<CR>

" hidden characters
nmap <leader>l :set list!<CR>

" Go customizations
" This is disabled because it can block for a lengthy period of time.
" let g:go_fmt_command = "goimports"

" JS customizations
" let g:neoformat_enabled_javascript = ['prettier']
let g:ale_fixers = {}
let g:ale_fixers['javascript'] = ['prettier']
let g:ale_fix_on_save = 1
let g:ale_javascript_prettier_options = '--single-quote --trailing-comma es5 --jsx-bracket-same-line'

" JSON
let g:ale_fixers['json'] = ['prettier']

" Python customizations
let g:pymode_folding = 0

" YAML customizations
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

" sh/bash customizations
let g:ale_sh_shellcheck_options = '-x'

" Copy and paste using system clipboard
vnoremap <C-c> "*y

" Trigger autoread on focus change
au FocusGained,BufEnter * :silent! !

" utility function for calling RipGrep with parameters
function! RipGrep(option, args, bang)
  call fzf#vim#grep(
    \ join(['rg', '--column', '--line-number', '--no-heading', '--color=always',
    \       '--hidden', '--glob', '!.git/*',
    \       a:option, shellescape(a:args)], ' '),
    \ 1,
    \ a:bang ? fzf#vim#with_preview('up:60%')
    \        : fzf#vim#with_preview('right:50%:hidden', '?'),
    \ a:bang)
endfunction

" Use ripgrep for fzf
let $FZF_DEFAULT_COMMAND = 'rg --files --hidden --glob !.git/*'
" Ripgrep support using fzf
" https://github.com/junegunn/fzf.vim#advanced-customization
command! -bang -nargs=* Rg
  \ call RipGrep('', <q-args>, <bang>0)
command! -bang -nargs=* Rgi
  \ call RipGrep('--ignore-case', <q-args>, <bang>0)

" auto-close vim when NERDTree is the last one standing
" https://github.com/scrooloose/nerdtree/issues/21#issuecomment-157212312
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

""" Commenting the right way
" proper alignment instead of following the code
let g:NERDDefaultAlign = 'left'
" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1
