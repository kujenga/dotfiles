" Customizations for markdown. I implement my own here because the available
" packages seem too heavyweight in some areas for my preferences.

" Syntax tutorial:
" https://vim.fandom.com/wiki/Creating_your_own_syntax_files#Install_the_syntax_file

" Enable spell check by default.
" zg in normal mode to add words, :help spell for info
syn spell toplevel

" Extensions for Hugo
" Partly based on: https://github.com/fatih/vim-go/blob/master/syntax/gotexttmpl.vim

syn region hugoString contained start='"' skip='\\\\\|\\"' end='"'
hi def link hugoString String

" Hugo shortcode regions
" https://gohugo.io/content-management/shortcodes/
" https://gohugo.io/templates/shortcode-templates/

syn match shortcodeParam contained /[^[:blank:]"}]\+=/
hi def link shortcodeParam Statement

syn region hugoShortcode start="{{<" end=">}}" contains=@NoSpell,shortcodeParam,hugoString
hi def link hugoShortcode Function

" Front Matter
" TOML
unlet b:current_syntax
syntax include @Toml syntax/toml.vim
syntax region tomlFrontmatter start=/\%^+++$/ end=/^+++$/ keepend contains=@Toml
" YAML
unlet b:current_syntax
syntax include @Yaml syntax/yaml.vim
syntax region yamlFrontmatter start=/\%^---$/ end=/^---$/ keepend contains=@Yaml

" LaTex math
unlet b:current_syntax
syn include @Tex syntax/tex.vim
syn region mkdMath start="\$" end="\$" skip="\\\$" keepend contains=@Tex
syn region mkdMath start="\$\$" end="\$\$" skip="\\\$" keepend contains=@Tex
" NOTE: This doesn't work quite right, but seems better than nothing to
" support mathjax default behavior for inline equations.
syn region mkdMath start="\\\\(" end="\\\\)" keepend contains=@Tex
