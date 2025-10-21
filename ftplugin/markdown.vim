" Filetype plugin for markdown to enable HyperList syntax
" Language:   HyperList support in Markdown files
" Author:     Geir Isene <g@isene.com>
" Github:     https://github.com/isene/hyperlist.vim
" License:    Public domain
" Fixes:      GitHub issue #12 - Folding not working inside markdown fenced codeblocks

" This file ensures HyperList syntax is loaded for markdown fenced code blocks
" by adding 'hl' and 'hyperlist' to g:markdown_fenced_languages before
" the markdown syntax file processes them

" Only load once
if exists('b:did_ftplugin_hyperlist_markdown')
  finish
endif
let b:did_ftplugin_hyperlist_markdown = 1

" Initialize g:markdown_fenced_languages if it doesn't exist
if !exists('g:markdown_fenced_languages')
  let g:markdown_fenced_languages = []
endif

" Add 'hl' to fenced languages if not already present
if index(g:markdown_fenced_languages, 'hl') == -1
  call add(g:markdown_fenced_languages, 'hl')
endif

" Also add 'hyperlist' as an alternative
if index(g:markdown_fenced_languages, 'hyperlist') == -1
  call add(g:markdown_fenced_languages, 'hyperlist')
endif
