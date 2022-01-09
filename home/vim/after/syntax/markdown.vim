" tutorial: https://vim.fandom.com/wiki/Creating_your_own_syntax_files#Install_the_syntax_file

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
