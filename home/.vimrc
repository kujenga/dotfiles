" vim-plug configuration
" https://github.com/junegunn/vim-plug
call plug#begin('~/.vim/plugged')

""" Improved Vim behaviors
" Sensible defaults for Vim
Plug 'tpope/vim-sensible'
" Configure vim based on the project
Plug 'editorconfig/editorconfig-vim'
" Guess indentation from current buffer
Plug 'tpope/vim-sleuth'
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
" Navigation helpers
Plug 'tpope/vim-unimpaired'
" Text insertion surrounding words
Plug 'tpope/vim-surround'

" syntax highlighting
Plug 'kujenga/vim-monokai'

""" Additional UI Capabilities
" git inline support
Plug 'airblade/vim-gitgutter'
" git wrapper
Plug 'tpope/vim-fugitive'
" Helper for GitHub
Plug 'tpope/vim-rhubarb'
" fuzzy finder
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
" tree view of files, with git status
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'

" Async linting while I type, fixing on save when I want
Plug 'w0rp/ale'
" Autocomplete
Plug 'Shougo/deoplete.nvim'
Plug 'roxma/nvim-yarp'
Plug 'roxma/vim-hug-neovim-rpc'
" for Go
Plug 'zchee/deoplete-go', { 'do': 'make'}
" for Python (hopefully better than rope)
Plug 'zchee/deoplete-jedi'
" for Rust
Plug 'sebastianmarkow/deoplete-rust'
" for JS (flow-based)
" Plug 'wokalski/autocomplete-flow'
Plug 'carlitux/deoplete-ternjs'

""" Language Syntax Support
" Go language support
Plug 'fatih/vim-go'
" Python support
Plug 'python-mode/python-mode'
" Docker support
Plug 'moby/moby' , {'rtp': '/contrib/syntax/vim/'}
" Javascript support
Plug 'pangloss/vim-javascript'
" Flow support
Plug 'flowtype/vim-flow'
" JSX support
Plug 'mxw/vim-jsx'
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
" Template highlighting
Plug 'mustache/vim-mustache-handlebars'
" Improved markdown syntax
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'
" Ethereum Solidity
Plug 'tomlion/vim-solidity'
" Swift
Plug 'keith/swift.vim'

" Initialize plugin system
call plug#end()

""" General Vim Configurations

" syntax highlighting
syntax enable
colorscheme monokai
" show line numbers
set number
" show line,column in status bar
set statusline+=%f\ %l\:%c
" allow buffers with unsaved changes
set hidden
" I proclaim it to be incorrect to put two spaces after a sentence
" ref: https://stackoverflow.com/a/4760477/2528719
set nojoinspaces
" Why fold when you have search?
set nofoldenable

" color customizations
hi TabLineFill ctermfg=243 ctermbg=235 guifg=#8F908A guibg=#2D2E27
hi TabLine ctermfg=243 ctermbg=235 guifg=#8F908A guibg=#2D2E27
" hi TabLineSel ctermfg=Red ctermbg=Yellow

" Edit this config file
nnoremap <leader>ev :vsplit $MYVIMRC<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>

" toggle hard mode
nnoremap <leader>h <Esc>:call ToggleHardMode()<CR>
" enable hard mode by default (I'm not up to snuff yet...)
" autocmd VimEnter,BufNewFile,BufReadPost * silent! call HardMode()c

" toggle mouse mode
nnoremap <leader>m <Esc>:call ToggleMouse()<CR>

" hidden characters
nmap <leader>l :set list!<CR>

" Copy and paste using system clipboard
vnoremap <C-c> "*y

" Trigger autoread on focus change
au FocusGained,BufEnter * :silent! !

""" General Plugin Configurations

" fzf shortcuts
noremap <c-x> :Files<CR>
vnoremap <c-x> <Esc>:Files<CR>
inoremap <c-x> <Esc>:Files<CR>
noremap <c-b> :Buffers<CR>
vnoremap <c-b> <Esc>:Buffers<CR>
inoremap <c-b> <Esc>:Buffers<CR>

"" Deoplete
" Use deoplete for auto-completion.
let g:deoplete#enable_at_startup = 1
" Use smartcase.
let g:deoplete#enable_smart_case = 1
" use tab to forward cycle
inoremap <silent><expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"
" use tab to backward cycle
inoremap <silent><expr><s-tab> pumvisible() ? "\<c-p>" : "\<s-tab>"
" deoplete Go customizations, boosting rank
call deoplete#custom#source('go', 'rank', 1000)
" deoplete Rust settings
let g:deoplete#sources#rust#racer_binary=systemlist('which racer')[0]
" ref: https://github.com/rust-lang-nursery/rustup.rs/issues/37#issuecomment-242831800
let g:deoplete#sources#rust#rust_source_path=systemlist('rustc --print sysroot')[0] . '/lib/rustlib/src/rust/src'
" JS Customizations
let g:deoplete#sources#ternjs#types = 1

"" NERDTree
" auto-close vim when NERDTree is the last one standing
" https://github.com/scrooloose/nerdtree/issues/21#issuecomment-157212312
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
" command to refresh NERDTree
" TODO: make this automatic
nmap <Leader>r :NERDTreeFocus<cr>R<c-w><c-p>
" Ignore certain files
let NERDTreeIgnore = ['\.pyc$']
" Commenting the right way, proper alignment instead of following the code
let g:NERDDefaultAlign = 'left'
" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1

"" ALE
" always keep gutter open to avoid bouncing
let g:ale_sign_column_always = 1
" ale in status line
let g:airline#extensions#ale#enabled = 1
" delay after which linters run in millis
let g:ale_lint_delay = 500
" setup for ALE customizations.
let g:ale_linters = {}
let g:ale_fixers = {}
" Map keys to navigate between lines with errors and warnings.
nnoremap <leader>an :ALENextWrap<cr>
nnoremap <leader>ap :ALEPreviousWrap<cr>

""" Language-Specific Customizations

" Go customizations. Disabled due to slowness.
" let g:go_fmt_command = 'goimports'

" Rust customization
let g:rustfmt_autosave = 1
if has('macunix')
  let g:rust_clip_command = 'pbcopy'
endif
" Working errors for binaries.
let g:ale_rust_cargo_check_all_targets = 0
" Linting with RLS
let g:ale_linters['rust'] = ['rls']
let g:ale_rust_rls_toolchain = 'stable'

" Disable rope because is is horrendously slow with big projects
let g:pymode_rope = 0
let g:pymode_rope_autoimport = 0
let g:pymode_rope_lookup_project = 0

" JS customizations
let g:ale_fixers['javascript'] = ['prettier']
let g:ale_fix_on_save = 1
let g:ale_javascript_prettier_use_local_config = 1
let g:javascript_plugin_flow = 1
" disable flow checking, using ale instead
let g:flow#enable = 0
let g:flow#showquickfix = 0
" Only use desired plugins for JS, avoids unwanted use of jshint.
let g:ale_linters = {'javascript': ['eslint', 'flow']}

" JSON
let g:ale_fixers['json'] = ['prettier']

" Python customizations
let g:pymode_folding = 0

" Bazel
" Based on: https://github.com/w0rp/ale/blob/master/autoload/ale/fixers/goimports.vim#L7:22
" TODO: Contribute this back to ALE.
function! BuildifierFix(buffer) abort
  return {
  \ 'command': 'buildifier -showlog -mode=fix %t',
  \ 'read_temporary_file': 1,
  \}
endfunction
let g:ale_fixers['bzl'] = ['BuildifierFix']

" markdown line width
au BufRead,BufNewFile *.md setlocal textwidth=80

""" Custom Commands

" Better update time for git gutter
set updatetime=100
let g:gitgutter_terminal_reports_focus=0

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
command! -bang -nargs=* RgF
  \ call RipGrep('--fixed-strings', <q-args>, <bang>0)
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

" Toggle mouse mode
" ref: https://unix.stackexchange.com/a/156713
function! ToggleMouse()
  " check if mouse is enabled
  if &mouse == 'a'
    " disable mouse
    set mouse=
  else
    " enable mouse everywhere
    set mouse=a
  endif
endfunc
