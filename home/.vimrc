" vim-plug configuration
" https://github.com/junegunn/vim-plug
call plug#begin('~/.vim/plugged')

""" Improved Vim behaviors
" Sensible defaults for Vim
Plug 'tpope/vim-sensible'
" Configure vim based on the project
Plug 'editorconfig/editorconfig-vim'
" Guess indentation from current buffer
Plug 'ciaranm/detectindent'
" sensible buffer close
Plug 'qpkorr/vim-bufkill'
" improved status line
Plug 'vim-airline/vim-airline'
" commenting
Plug 'scrooloose/nerdcommenter'
" hardo mode
Plug 'wikitopian/hardmode'
" Distraction free mode
Plug 'junegunn/goyo.vim'

" syntax highlighting
Plug 'kujenga/vim-monokai'

""" Additional UI Capabilities
" git inline support
Plug 'airblade/vim-gitgutter'
" git wrapper
Plug 'tpope/vim-fugitive'
" fuzzy finder
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
" tree view of files, with git status
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'

" Async linting while I type, fixing on save when I want
Plug 'w0rp/ale'
" Autocomplete
Plug 'Valloric/YouCompleteMe'

""" Language Syntax Support
" Go language support
Plug 'fatih/vim-go'
" Python support
Plug 'python-mode/python-mode'
" Docker support
Plug 'moby/moby' , {'rtp': '/contrib/syntax/vim/'}
" Javascript support
Plug 'pangloss/vim-javascript'
" JSON support
Plug 'elzr/vim-json'
" Rust support
Plug 'rust-lang/rust.vim'
" HTML support
Plug 'mattn/emmet-vim'
" Apiary support
Plug 'kylef/apiblueprint.vim'
" TOML support
Plug 'cespare/vim-toml'
" Caddyfile support
Plug 'isobit/vim-caddyfile'
" Pug template language
Plug 'digitaltoad/vim-pug'
" Hashicorp Terraform
Plug 'hashivim/vim-terraform'

" Initialize plugin system
call plug#end()

" Edit this config file
nnoremap <leader>ev :vsplit $MYVIMRC<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>

" toggle hard mode
nnoremap <leader>h <Esc>:call ToggleHardMode()<CR>
" enable hard mode by default (I'm not up to snuff yet...)
" autocmd VimEnter,BufNewFile,BufReadPost * silent! call HardMode()c

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

" Setup for ALE customizations.
let g:ale_linters = {}
let g:ale_fixers = {}

" Go customizations
let g:go_fmt_command = "goimports"

" Rust customization
let g:rustfmt_autosave = 1
" Working errors for binaries.
let g:ale_rust_cargo_check_all_targets = 0
" Linting with RLS
let g:ale_linters['rust'] = ['rls']
let g:ale_rust_rls_toolchain = 'stable'

" JS customizations
let g:ale_fixers = {}
let g:ale_fixers['javascript'] = ['prettier']
let g:ale_fix_on_save = 1
let g:ale_javascript_prettier_use_local_config = 1

" JSON
let g:ale_fixers['json'] = ['prettier']

" always keep gutter open to avoid bouncing
let g:ale_sign_column_always = 1
" ale in status line
let g:airline#extensions#ale#enabled = 1
" delay after which linters run in millis
let g:ale_lint_delay = 500

" Python customizations
let g:pymode_folding = 0

" Copy and paste using system clipboard
vnoremap <C-c> "*y

" Trigger autoread on focus change
au FocusGained,BufEnter * :silent! !

" Utility function for calling RipGrep with parameters. Supports similar
" functionality to the :Ag command which exists by default.
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
command! -bang -nargs=* Rga
  \ call RipGrep('--no-ignore', <q-args>, <bang>0)
" Add matching files to the args list
command! -bang -nargs=1 Rga
  \ execute 'args `rg --files-with-matches ' . shellescape(<q-args>) . '`'

" Copy search matches to clipboard
" http://vim.wikia.com/wiki/Copy_search_matches
function! CopyMatches(reg)
  let hits = []
  %s//\=len(add(hits, submatch(0))) ? submatch(0) : ''/gne
  let reg = empty(a:reg) ? '+' : a:reg
  execute 'let @'.reg.' = join(hits, "\n") . "\n"'
endfunction
command! -register CopyMatches call CopyMatches(<q-reg>)

" auto-close vim when NERDTree is the last one standing
" https://github.com/scrooloose/nerdtree/issues/21#issuecomment-157212312
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
" command to refresh NERDTree
" TODO: make this automatic
nmap <Leader>r :NERDTreeFocus<cr>R<c-w><c-p>

""" Commenting the right way
" proper alignment instead of following the code
let g:NERDDefaultAlign = 'left'
" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1
