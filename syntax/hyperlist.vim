" Vim syntax and filetype plugin for HyperList files (.hl)
" Language:	Self defined markup and functions for HyperLists in Vim
" Author:	Geir Isene <g@isene.com>
" Web_site:	http://isene.com/
" HyperList:	http://isene.com/hyperlist/
" License:	I release all copyright claims. 
"		This code is in the public domain.
"		Permission is granted to use, copy modify, distribute, and
"		sell this software for any purpose. I make no guarantee
"		about the suitability of this software for any purpose and
"		I am not liable for any damages resulting from its use.
"		Further, I am under no obligation to maintain or extend
"		this software. It is provided on an 'as is' basis without
"		any expressed or implied warranty.
" Version:	2.3.3 - compatible with the HyperList definition v. 2.3
" Modified:	2017-01-16
" Changes:  Added the function Complexity() to give a complexity score
"           for a HyperList

" INSTRUCTIONS {{{1
"
" Use tabs/shifts or * for indentations
"
" Use <SPACE> to toggle one fold.
" Use \0 to \9, \a, \b, \c, \d, \e, \f to show up to 15 levels expanded.
"
" As a sort of "presentation mode", you can traverse a HyperList by using
" g<DOWN> or g<UP> to view only the current line and its ancestors.
" An alternative is <leader><DOWN> and <leader><UP> to open more levels down.
" 
" Use "gr" when the cursor is on a reference to jump to the referenced item.
" A reference can be in the list or to a file by the use of
" #file:/pathto/filename, #file:~/filename or #file:filename.
"
" Use <leader>u to toggle underlining of Transitions, States or no underlining.
"
" Use <leader>v to add a checkbox at start of item or to toggle a checkbox.
" Use <leader>V to add/toggle a checkbox with a date stamp for completion.
"
" Use <leader><SPACE> to go to the next open template element.
" (A template element is a HyperList item ending in an equal sign).
"
" Use <leader>L to convert the entire document to LaTaX.
" Use <leader>H to convert the entire document to HTML.
"
" Use <leader>z encrypts the current line (including all sublevels if folded).
" Use <leader>Z encrypts the current file (all lines).
" Use <leader>x decrypts the current line.
" Use <leader>X decrypts the current file (all lines).
" <leader>z and <leader>x can be used with visual ranges.
"
" A dot file (file name starts with a "." such as .test.hl) is
" automatically encrypted on save and decrypted on opening.
"
" Syntax is updated at start and every time you leave Insert mode.


" Initializing {{{1
if version < 600
    syntax clear
elseif exists("b:current_syntax")
    finish
endif

" Basic settings {{{1
let b:current_syntax="HyperList"
set autoindent
set textwidth=0
set shiftwidth=2
set tabstop=2
set softtabstop=2
set noexpandtab
set foldmethod=syntax
set fillchars=fold:\ 
syn sync fromstart
autocmd InsertLeave * :syntax sync fromstart
" Lower the next two values if you have a slow computer
syn sync minlines=50
syn sync maxlines=100


" Functions {{{1
"  Folding {{{2
"  Mapped to <SPACE> and <leader>0 - <leader>f
set foldtext=HLFoldText()
function! HLFoldText()
  let line = getline(v:foldstart)
  let myindent = indent(v:foldstart)
  let line = substitute(line, '^\s*', '', 'g')
  while myindent != 0
    let myindent = myindent - 1
    let line = ' ' . line
  endwhile
  return line
endfunction

"  Encryption {{{2
"  Remove traces of secure info upon decrypting (part of) a HyperList
function! HLdecrypt()
  set viminfo=""
  set noswapfile
endfunction

"  Underlining States/Transitions {{{2
"  Mapped to <leader>u
let g:STu=0
hi link HLstate NONE
hi link HLtrans NONE
function! STunderline()
  if g:STu == 0
    hi link HLtrans NONE
    hi link HLstate underlined
    let g:STu = 1
  elseif g:STu == 1
    hi link HLstate NONE
    hi link HLtrans underlined
    let g:STu = 2
  elseif g:STu == 2
    hi link HLstate NONE
    hi link HLtrans NONE
    let g:STu = 0
  endif
endfunction

"  Checkbox and timestamp {{{2
"  Mapped to <leader>v and <leader>V
function! CheckItem (stamp)
  let current_line = getline('.')
  if match(current_line,'\V[_]') >= 0
    let time = strftime("%Y-%m-%d %H.%M")
    exe 's/\V[_]/[x]/'
    if a:stamp == "stamped"
      exe "normal 0f]a ".time.":"
    endif
  elseif match(current_line,'\V[x]') >= 0
    exe 's/\V[x]/[_]/i'
    exe 's/\V[_] \d\d\d\d-\d\d-\d\d \d\d\.\d\d:/[_]/e'
  else
    exe "normal ^i[_] "
  endif
endfunction

"  Goto reference {{{2
"  Mapped to 'gr' and <CR>
if !exists("*GotoRef") 
  function! GotoRef()
    let current_line = getline('.')
    let ref_multi = 0
    if match(current_line,'<.*>') >= 0
      let ref_word = matchstr(current_line,"<.\\{-}>")
      let ref_word = substitute(ref_word, "<", '', 'g')
      let ref_word = substitute(ref_word, '>', '', 'g')
      let ref_end  = ref_word
      if match(ref_word,"\/") >= 0
        let ref_end = substitute(ref_end, '^.*/', '\t', 'g')
        let ref_multi = 1
      endif
      let ref_dest = substitute(ref_word, '/', '\\_.\\{-}\\t', 'g')
      let ref_dest = "\\s" . ref_dest
      let @/ = ref_dest
      call search(ref_dest)
      let new_line = getline('.')
      if new_line == current_line
        echo "No destination"
      else
        if ref_multi == 1
          call search(ref_end)
        end
      endif
    else
      echo "No reference in the HyperList item"
    endif
  endfunction
endif

"  Open file under cursor {{{2
"  Mapped to 'gf'
function! OpenFile()
  if expand('<cWORD>') =~ '<' && expand('<cWORD>') =~ '>'
    let gofl = expand('<cfile>')
    if gofl =~ '\(odt$\|doc$\|docx$\|odc$\|xls$\|xlsx$\|odp$\|ppt$\|pptx$\)'
      exe '!libreoffice "'.gofl.'"'
    elseif gofl =~ '\(jpg$\|jpeg$\|png$\|bmp$\|gif$\)'
      exe '!feh "'.gofl.'"'
    elseif gofl =~ 'pdf$'
      exe '!zathura "'.gofl.'"'
    else
      exe '!edit '.gofl
    endif
  else
    echo "No reference"
  endif
endfunction

"  HTML conversion{{{2
"  Mapped to '<leader>H'
function! HTMLconversion ()
    try
        "Remove VIM tagline
        execute '%s/^vim:.*//g'
    catch
    endtry
    try
        "first line of a HyperList is bold
        execute '%s/^\(\S.*\)$/<strong>\1<\/strong>/g'
    catch
    endtry
    try
        "HLb
        execute '%s/ \@<=\*\(.\{-}\)\* /<strong>\1<\/strong>/g'
    catch
    endtry
    try
        "HLi
        execute '%s/ \@<=\/\(.\{-}\)\/ /<em>\1<\/em>/g'
    catch
    endtry
    try
        "HLu
        execute '%s/ \@<=_\(.\{-}\)_ /<u>\1<\/u>/g'
    catch
    endtry
    try
        "HLquote
        execute '%s/\(\".*\"\)/<em>\1<\/em>/g'
    catch
    endtry
    try
        "HLcomment
        execute '%s/\((.*)\)/<em>\1<\/em>/g'
    catch
    endtry
    try
        "HLindent
        execute "%s/\\(\\t\\|\\*\\)\\@<=\\(\\d.\\{-}\\)\\s/<font color=\"purple\">\\2<\\/font> /g"
    catch
    endtry
    try
        "HLmulti (+)
        execute '%s/\(\t\|\*\)+/\t<font color="purple">+<\/font>/g'
    catch
    endtry
    try
        "HLhash
        execute "%s/\\(#[a-zA-ZæøåÆØÅ0-9.:/_&?%=\\-\\*]\\+\\)/<font color=\"yellow\">\\1<\\/font>/g"
    catch
    endtry
    try
        "HLref
        execute "%s/\\(<\\{1,2}\\[a-zA-ZæøåÆØÅ0-9.:/_&?%=\\-\\*]\\+>\\{1,2}\\)/<font color=\"purple\">\\1<\\/font>/g"
    catch
    endtry
    try
        "HLmove
        execute '%s/\(>>\|<<\|->\|<-\)/<font color="red"><strong>\1</strong><\/font>/g'
    catch
    endtry
    try
        "HLqual
        execute '%s/\(\[.\{-}\]\)/<font color="green">\1<\/font>/g'
    catch
    endtry
    try
        "HLop
        execute "%s/\\(\\s\\|\\*\\)\\@<=\\([A-ZÆØÅ_/]\\{-2,}:\\s\\)/<font color=\"blue\">\\2<\\/font>/g"
    catch
    endtry
    try
        "HLprop
        execute "%s/\\(\\s\\|\\*\\)\\@<=\\([a-zA-ZæøåÆØÅ0-9,._&?%= \\-\\/+<>#']\\{-2,}:\\s\\)/<font color=\"red\">\\2<\\/font>/g"
    catch
    endtry
    try
        "HLsc
        execute '%s/\(;\)/<font color="green">\1<\/font>/g'
    catch
    endtry
    try
        "Substitute space in second line of multi-item
        execute '%s/\(^\|\t\|\*\)\@<=\(\t\|\*\) /\&nbsp;\&nbsp;\&nbsp;\&nbsp;\&nbsp;\&nbsp;/g'
    catch
    endtry
    try
        "Substitute tabs
        execute '%s/\(^\|\t\|\*\)\@<=\(\t\|\*\)/\&nbsp;\&nbsp;\&nbsp;\&nbsp;/g'
    catch
    endtry
    try
        "Substitute newlines with <br />
        execute '%s/\n/<br \/>\r/g'
    catch
    endtry
    "Document start
    normal ggO<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
    normal o<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
    normal o<head>
    normal o<title>HyperList</title>
    normal o<meta name="creator" content="HyperList plugin for VIM: http://vim.sourceforge.net/scripts/script.php?script_id=2518" />
    normal o<meta http-equiv="Content-Type" content="text/html;charset=UTF-8">
    normal o</head>
    normal o<body>
    "Document end
    normal GO</body>
    normal o</html>
    set filetype=html
endfunction
"  LaTeX conversion{{{2
"  Mapped to '<leader>L'
function! LaTeXconversion ()
    try
        "Remove VIM tagline
        execute '%s/^vim:.*//g'
    catch
    endtry
    try
        "Escape "\"
        execute '%s/\\/\\\\/g'
    catch
    endtry
    try
        "Escape "{"
        execute '%s/{/\\{/g'
    catch
    endtry
    try
        "Escape "}"
        execute '%s/}/\\}/g'
    catch
    endtry
    try
        "HLb
        execute '%s/ \@<=\*\(.\{-}\)\* /\\textbf{ \1 }/g'
    catch
    endtry
    try
        "HLi
        execute '%s/ \@<=\/\(.\{-}\)\/ /\\textsl{ \1 }/g'
    catch
    endtry
    try
        "HLu
        execute '%s/ \@<=_\(.\{-}\)_ /\\underline{ \1 }/g'
    catch
    endtry
    try
        "HLindent
        execute '%s/\(\t\|\*\)\@<=\([0-9.]\+\.\s\)/\1\\textcolor{v}{\2}/g'
    catch
    endtry
    try
        "HLmulti
        execute '%s/\(\t\|\*\)+/\\tab \\textcolor{v}{+}/g'
    catch
    endtry
    try
        "HLhash
        execute "%s/\\(#[a-zA-ZæøåÆØÅ0-9.:/_&?%=\\-\\*]\\+\\)/\\\\textcolor{o}{\\1}/g"
    catch
    endtry
    try
        "HLref
        execute "%s/\\(<\\{1,2}[a-zA-ZæøåÆØÅ0-9.:/_&?%=\\-\\*]\\+>\\{1,2}\\)/\\\\textcolor{v}{\\1}/g"
    catch
    endtry
    try
        "HLquote
        execute '%s/\(\".*\"\)/\\textcolor{t}{\1}/g'
    catch
    endtry
    try
        "HLcomment
        execute '%s/\((.*)\)/\\textcolor{t}{\1}/g'
    catch
    endtry
    try
        "HLmove
        execute '%s/\(>>\|<<\|->\|<-\)/\\textbf{\1}/g'
    catch
    endtry
    try
        "HLqual
        execute '%s/\(\[.\{-}\]\)/\\textcolor{g}{\1}/g'
    catch
    endtry
    try
        "HLop
        execute "%s/\\(\\s\\|\\*\\)\\@<=\\([A-ZÆØÅ_/]\\{-2,}:\\s\\)/\\\\textcolor{b}{\\2}/g"
    catch
    endtry
    try
        "HLprop
        execute "%s/\\(\\s\\|\\*\\)\\@<=\\([a-zA-ZæøåÆØÅ0-9,._&?%= \\-\\/+<>#']\\{-2,}:\\s\\)/\\\\textcolor{r}{\\emph{\\2}}/g"
    catch
    endtry
    try
        "HLsc
        execute '%s/\(;\)/\\textcolor{g}{\1}/g'
    catch
    endtry
    try
        "Substitute tabs
        execute '%s/\(^\|\t\|\*\)\@<=\(\t\|\*\)/   /g'
    catch
    endtry
    "Document start
    normal ggO%Created by the HyperList vim plugin, see:
    normal o%http://vim.sourceforge.net/scripts/script.php?script_id=2518
    normal o
    normal o\documentclass[10pt]{article}
    normal o\usepackage[margin=1cm]{geometry}
    normal o\usepackage[usenames]{color}
    normal o\usepackage{alltt}
    normal o\definecolor{r}{rgb}{0.5,0,0}
    normal o\definecolor{g}{rgb}{0,0.5,0}
    normal o\definecolor{b}{rgb}{0,0,0.5}
    normal o\definecolor{v}{rgb}{0.4,0,0.4}
    normal o\definecolor{t}{rgb}{0,0.4,0.4}
    normal o\definecolor{0}{rgb}{0.6,0.6,0}
    normal o
    normal o\begin{document}
    normal o\begin{alltt}
    "Document end
    normal Go\end{alltt}
    normal o\end{document}
    set filetype=tex
endfunction

"  Show/Hide{{{2
"  Useful for easily showing e.g. a specific tag or hash 
"  Taken from VIM script #1594 (thanks to Amit Sethi)
"  zs    Show all lines containing word under cursor
"  zh    Hide all lines containing word under cursor
"  z0    Go back to normal HyperList folding
"  :SHOW word/pattern
"        Show lines containing either word or pattern
"  :HIDE word/pattern
"        Hide lines containing either word or pattern
"        Pattern can be any regular expression

map   <silent>    zs    :call <SID>ShowHideWord('z', 's', '')<CR>
map   <silent>    zh    :call <SID>ShowHideWord('z', 'h', '')<CR>
map   <silent>    z0    :set foldmethod=syntax<CR>
command! -nargs=+  SHOW  :call <SID>ShowHideWord('c', 's', <f-args>)
command! -nargs=+  HIDE  :call <SID>ShowHideWord('c', 'h', <f-args>)

function! <SID>ShowHideWord(mode, show, ...)
   if (a:mode == 'z')
      let cur_word = '\\<' . expand("<cword>") . '\\>'
   else
      let i = 1
      let cur_word = '\\<\\('
      let binder = ''
      while i <= a:0
         let ai = substitute(a:{i}, '\\', '\\\\', 'g')
         let cur_word = cur_word . binder . ai
         let binder = '\\\|'
         let i = i + 1
      endw
      let cur_word = cur_word . '\\)\\>'
   endif

   let myfoldexpr = "set foldexpr=getline(v:lnum)" .
      \ (a:show == 's' ? "!" : "=") . "~\'\^.*" . cur_word . ".*\$\'"

   set foldenable
   set foldlevel=0
   set foldminlines=0
   set foldmethod=expr
   exec myfoldexpr
endfunction

"  Complexity{{{2
"  :call Complexity() will show the complexity score for your HyperList
"  It adds up all HyperList Items and all references to the total score

function! Complexity()
	let l = 0
	let c = 0
	try
		redir => l
			silent exe '%s/\S//n'
		redir END
	catch
		let l = 0
	endtry
  let l = substitute(l, '\_.\{-}\(\d\+\)\_.*', '\1', "")
	try
		redir => c
			silent exe '%s/<\{1,2}[a-zA-ZæøåÆØÅáéóúãõâêôçàÁÉÓÚÃÕÂÊÔÇÀü0-9,.:/ _&@?%=+\-\*]\+>\{1,2}//gn'
		redir END
	catch
		let c = 0
	endtry
  let c = substitute(c, '\_.\{-}\(\d\+\)\_.*', '\1', "")
  let plex = c + l
  echo "Complexity = ". plex
  return plex
endfunction

" Syntax definitions {{{1
"  HyperList elements {{{2

" Identifier (any number in front)
syn match   HLident     '^\(\t\|\*\)*[0-9.]* '

" Multi-line
syn match   HLmulti     '^\(\t\|\*\)*+ '

" State & Transitions
syn match   HLstate	'\(\(^\|\s\|\*\)\(S: \|| \)\)\@<=.*' contains=HLtodo,HLop,HLcomment,HLref,HLqual,HLsc,HLmove,HLtag,HLquote
syn match   HLtrans	'\(\(^\|\s\|\*\)\(T: \|/ \)\)\@<=.*' contains=HLtodo,HLop,HLcomment,HLref,HLqual,HLsc,HLmove,HLtag,HLquote

" Qualifiers are enclosed within [ ]
syn match   HLqual      '\[.\{-}\]' contains=HLtodo,HLref,HLcomment

" Tags - anything that ends in a colon
syn match   HLtag	'\(^\|\s\|\*\)\@<=[a-zA-ZæøåÆØÅáéóúãõâêôçàÁÉÓÚÃÕÂÊÔÇÀü0-9,._&?!%= \-\/+<>#'"()\*:]\{-2,}:\s' contains=HLtodo,HLcomment,HLquote,HLref

" HyperList operators
syn match   HLop	'\(^\|\s\|\*\)\@<=[A-ZÆØÅÁÉÓÚÃÕÂÊÔÇÀ_/\-()]\{-2,}:\s' contains=HLcomment,HLquote

" Mark semicolon as stringing together lines
syn match   HLsc	';'

" Hashtags (like Twitter)
syn match   HLhash	'#[a-zA-ZæøåÆØÅáéóúãõâêôçàÁÉÓÚÃÕÂÊÔÇÀü0-9.:/_&?%=+\-\*]\+'

" References
syn match   HLref	'<\{1,2}[a-zA-ZæøåÆØÅáéóúãõâêôçàÁÉÓÚÃÕÂÊÔÇÀü0-9,.:/ _&@?%=+\-\*]\+>\{1,2}' contains=HLcomment

" Reserved key words
syn keyword HLkey     END SKIP

" Marking literal start and end (a whole literal region is folded as one block)
syn match   HLlit       '\(\s\|\*\)\@<=\\$'

" Content of litaral (with no syntax highlighting)
syn match   HLlc        '\(\s\|\*\)\\\_.\{-}\(\s\|\*\)\\' contains=HLlit

" Comments are enclosed within ( )
syn match   HLcomment   '(.\{-})' contains=HLtodo,HLref

" Text in quotation marks
syn match   HLquote     '".\{-}"' contains=HLtodo,HLref

" TODO  or FIXME
syn keyword HLtodo    TODO FIXME 

" Item motion
"syn match   HLmove      '>>\|<<\|->\|<-'

" Bold and Italic
syn match   HLb	        ' \@<=\*.\{-}\* \@='
syn match   HLi	        ' \@<=/.\{-}/ \@='
syn match   HLu	        ' \@<=_.\{-}_ \@='

" Cluster the above
syn cluster HLtxt contains=HLident,HLmulti,HLop,HLqual,HLtag,HLhash,HLref,HLkey,HLlit,HLlc,HLcomment,HLquote,HLsc,HLtodo,HLmove,HLb,HLi,HLu,HLstate,HLtrans

"  HyperList indentation (folding levels) {{{2
if !exists("g:disable_collapse")
syn region L15 start="^\(\t\|\*\)\{14} \=\S" end="^\(^\(\t\|\*\)\{15,} \=\S\)\@!" fold contains=@HLtxt
syn region L14 start="^\(\t\|\*\)\{13} \=\S" end="^\(^\(\t\|\*\)\{14,} \=\S\)\@!" fold contains=@HLtxt,L15
syn region L13 start="^\(\t\|\*\)\{12} \=\S" end="^\(^\(\t\|\*\)\{13,} \=\S\)\@!" fold contains=@HLtxt,L14,L15
syn region L12 start="^\(\t\|\*\)\{11} \=\S" end="^\(^\(\t\|\*\)\{12,} \=\S\)\@!" fold contains=@HLtxt,L13,L14,L15
syn region L11 start="^\(\t\|\*\)\{10} \=\S" end="^\(^\(\t\|\*\)\{11,} \=\S\)\@!" fold contains=@HLtxt,L12,L13,L14,L15
syn region L10 start="^\(\t\|\*\)\{9} \=\S"  end="^\(^\(\t\|\*\)\{10,} \=\S\)\@!" fold contains=@HLtxt,L11,L12,L13,L14,L15
syn region L9 start="^\(\t\|\*\)\{8} \=\S"   end="^\(^\(\t\|\*\)\{9,} \=\S\)\@!"  fold contains=@HLtxt,L10,L11,L12,L13,L14,L15
syn region L8 start="^\(\t\|\*\)\{7} \=\S"   end="^\(^\(\t\|\*\)\{8,} \=\S\)\@!"  fold contains=@HLtxt,L9,L10,L11,L12,L13,L14,L15
syn region L7 start="^\(\t\|\*\)\{6} \=\S"   end="^\(^\(\t\|\*\)\{7,} \=\S\)\@!"  fold contains=@HLtxt,L8,L9,L10,L11,L12,L13,L14,L15
syn region L6 start="^\(\t\|\*\)\{5} \=\S"   end="^\(^\(\t\|\*\)\{6,} \=\S\)\@!"  fold contains=@HLtxt,L7,L8,L9,L10,L11,L12,L13,L14,L15
syn region L5 start="^\(\t\|\*\)\{4} \=\S"   end="^\(^\(\t\|\*\)\{5,} \=\S\)\@!"  fold contains=@HLtxt,L6,L7,L8,L9,L10,L11,L12,L13,L14,L15
syn region L4 start="^\(\t\|\*\)\{3} \=\S"   end="^\(^\(\t\|\*\)\{4,} \=\S\)\@!"  fold contains=@HLtxt,L5,L6,L7,L8,L9,L10,L11,L12,L13,L14,L15
syn region L3 start="^\(\t\|\*\)\{2} \=\S"   end="^\(^\(\t\|\*\)\{3,} \=\S\)\@!"  fold contains=@HLtxt,L4,L5,L6,L7,L8,L9,L10,L11,L12,L13,L14,L15
syn region L2 start="^\(\t\|\*\)\{1} \=\S"   end="^\(^\(\t\|\*\)\{2,} \=\S\)\@!"  fold contains=@HLtxt,L3,L4,L5,L6,L7,L8,L9,L10,L11,L12,L13,L14,L15
syn region L1 start="^\S"                    end="^\(^\(\t\|\*\)\{1,} \=\S\)\@!"  fold contains=@HLtxt,L2,L3,L4,L5,L6,L7,L8,L9,L10,L11,L12,L13,L14,L15
endif

"  VIM parameters (VIM modeline) {{{2
syn match   HLvim "^vim:.*"

" Highlighting and Linking {{{1
hi	        Folded	  gui=bold term=bold cterm=bold
hi def link HLident	  Define
hi def link HLmulti	  Constant
hi def link HLtag	    Constant
hi def link HLop	    Function
hi def link HLqual	  Type
hi def link HLhash	  Label
hi def link HLref	    Define
hi def link HLkey	    Define
hi          HLlit     ctermfg=none ctermbg=none gui=italic term=italic cterm=italic
hi          HLlc      ctermfg=white ctermbg=none
hi def link HLcomment	Comment
hi def link HLquote	  Comment
hi def link HLsc	    Type
hi def link HLtodo	  Todo
hi def link HLmove	  Error
hi	        HLb	      ctermfg=none ctermbg=none gui=bold term=bold cterm=bold
hi	        HLi	      ctermfg=none ctermbg=none gui=italic term=italic cterm=italic
hi link	    HLu	      underlined
hi def link HLvim     Function

" Keymap {{{1

if exists('g:HLDisableMapping') && g:HLDisableMapping
    finish
endif

map <leader>0         :set foldlevel=0<CR>
map <leader>1         :set foldlevel=1<CR>
map <leader>2         :set foldlevel=2<CR>
map <leader>3         :set foldlevel=3<CR>
map <leader>4         :set foldlevel=4<CR>
map <leader>5         :set foldlevel=5<CR>
map <leader>6         :set foldlevel=6<CR>
map <leader>7         :set foldlevel=7<CR>
map <leader>8         :set foldlevel=8<CR>
map <leader>9         :set foldlevel=9<CR>
map <leader>a         :set foldlevel=10<CR>
map <leader>b         :set foldlevel=11<CR>
map <leader>c         :set foldlevel=12<CR>
map <leader>d         :set foldlevel=13<CR>
map <leader>e         :set foldlevel=14<CR>
map <leader>f         :set foldlevel=15<CR>
map <SPACE>           za
nmap zx               i<esc>

map <leader>u         :call STunderline()<CR>

map <leader>v	      :call CheckItem("")<CR>
map <leader>V         :call CheckItem("stamped")<CR>

map <leader><SPACE>   /=\s*$<CR>A

nmap gr		      m':call GotoRef()<CR>
nmap <CR>	      m':call GotoRef()<CR>

nmap gf               :call OpenFile()<CR>

nmap g<DOWN>          <DOWN><leader>0zv
nmap g<UP>            <leader>f<UP><leader>0zv

nmap <leader><DOWN>   <DOWN><leader>0zv<SPACE>zO
nmap <leader><UP>     <leader>f<UP><leader>0zv<SPACE>zO

nmap <leader>z        :call HLdecrypt()<CR>V:!openssl bf -e -a -salt 2>/dev/null<CR><C-L>
vmap <leader>z        :call HLdecrypt()<CR>gv:!openssl bf -e -a -salt 2>/dev/null<CR><C-L>
nmap <leader>Z        :call HLdecrypt()<CR>:%!openssl bf -e -a -salt 2>/dev/null<CR><C-L>
nmap <leader>x        :call HLdecrypt()<CR>V:!openssl bf -d -a 2>/dev/null<CR><C-L>
vmap <leader>x        :call HLdecrypt()<CR>gv:!openssl bf -d -a 2>/dev/null<CR><C-L>
nmap <leader>X        :call HLdecrypt()<CR>:%!openssl bf -d -a 2>/dev/null<CR><C-L>

nmap <leader>L        :call LaTeXconversion()<CR>
nmap <leader>H        :call HTMLconversion()<CR>

" vim modeline {{{1
" vim: set sw=2 sts=2 et fdm=marker fillchars=fold\:\ :
