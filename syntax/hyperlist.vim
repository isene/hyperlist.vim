" Vim syntax and filetype plugin for HyperList files (.hl)
" Language:   Self defined markup and functions for HyperLists in Vim
" Author:     Geir Isene <g@isene.com>
" Web_site:   http://isene.com/
" HyperList:  http://isene.org/hyperlist/
" Github:     https://github.com/isene/hyperlist.vim
" License:    I release all copyright claims. 
"             This code is in the public domain.
"             Permission is granted to use, copy modify, distribute, and
"             sell this software for any purpose. I make no guarantee
"             about the suitability of this software for any purpose and
"             I am not liable for any damages resulting from its use.
"             Further, I am under no obligation to maintain or extend
"             this software. It is provided on an 'as is' basis without
"             any expressed or implied warranty.
" Version:    2.3.17 - compatible with the HyperList definition v. 2.3
" Modified:   2019-08-14
" Changes:    Added a GVIM menu. Full rework of the color schemes for VIM & gVIM.
"             Improvement to Goto Reference (gr) and Autonumbering.
"             Several minor changes and improvement in the docs.
"             Thanks to Don Kelley for the gVIM suggestions and for extensive testing.

" INSTRUCTIONS {{{1
"
" Use tabs/shifts or * for indentations
"
" Use <SPACE> to toggle one fold.
" Use \0 to \9, \a, \b, \c, \d, \e, \f to show up to 15 levels expanded.
"
" <leader># or <leader>an toggles autonumbering of new items (the previous
" item must be numbered for the next item to be autonumbered). An item is
" indented to the right with <c-t>, adding one level of numbering. An item
" is indented to the left with <c-d>, removing one level of numbering and
" increasing the number by one.
"
" As a sort of "presentation mode", you can traverse a HyperList by using
" g<DOWN> or g<UP> to view only the current line and its ancestors.
" An alternative is <leader><DOWN> and <leader><UP> to open more levels down.
" 
" To highlight the current part of a HyperList (the current item and all its
" children), press <leader>h. This will uncollapse the whole HyperList and dim
" the whole HyperList except the current item and its children. To remove the
" highlighting, simply press <leader>h again (the fold level is restored).
"
" Use "gr" when the cursor is on a reference to jump to the referenced item.
" A reference can be in the list or to a file by the use of
" <file:/pathto/filename>, <file:~/filename> or <file:filename>.
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
" Use <leader>T to convert the entire document to a basic TPP presentation.
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
" You can add item tagged with future dates as items in your Google calendar.
" Use <leader>G to automatically add all items with future dates to your
" default calendar. Change your default under USER DEFINED SETTINGS below.
"
" Syntax is updated at start and every time you leave Insert mode.
"
" Much more information is found in the documentation (:help hyperlist.txt)

" Initializing {{{1
if version < 600
    syntax clear
elseif exists("b:current_syntax")
    finish
endif

let s:UNIX  = has("unix")  || has("macunix") || has("win32unix")
let s:MSWIN = has("win16") || has("win32")   || has("win64")     || has("win95")
if s:MSWIN
  if mapcheck("\<c-a>","n") != ""
    nunmap <c-a>
  endif
endif

" USER DEFINED SETTINGS (change these as you wish) {{{1
" Change this to add events as reminders to your Google calendar:
let b:calendar      = "geir@a-circle.no"

" Programs to handle opening of files with "gf" (programs must be in PATH)
" Add more programs if you want and make additions to the function OpenFile()
" If you are running Linux/Unix/MacOSX/win32unix
if s:UNIX
  let b:wordprocessingprogram = "libreoffice"
  let b:spreadsheetprogram    = "libreoffice"
  let b:presentationprogram   = "libreoffice"
  let b:pdfprogram            = "zathura"
  let b:imageprogram          = "feh"
  let b:browserprogram        = "qutebrowser"
endif
" If you are running MS Windows:
if s:MSWIN
  " Add the path to the programs if you don't want to mess around with a path variable
  " ...such as: '/Program^ Files^ (x86)/Microsoft^ Office/root/Office16/'
  let b:wordprocessingprogram = "winword"
  let b:spreadsheetprogram    = "excel"
  let b:presentationprogram   = "powerpnt"
  let b:pdfprogram            = "AcroRd32"
  let b:imageprogram          = "i_view32"
  let b:browserprogram        = "firefox"
endif
" You can add programs to open other file types - and add the opener to the
" function "OpenFile()" (see example there). Example::
" let b:scadprogram           = "openscad"

" Lower the next two values if you have a slow computer
syn sync minlines=50
syn sync maxlines=100

" Settings {{{1
let b:current_syntax="HyperList"
let b:highlight="false"
set autoindent
set textwidth=0
set shiftwidth=3
set tabstop=3
set softtabstop=3
set noexpandtab
set guioptions+=t
set foldmethod=syntax
set fillchars=fold:\ 
syn sync fromstart
autocmd InsertLeave * :syntax sync fromstart

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

" Highlighting {{{2
"  Simplified Limelight - thanks to Junegunn Choi for the inspiration
"  (https://travis-ci.org/junegunn/limelight.vim.svg?branch=master)
function! HighLight()
  if b:highlight=="false"
    echo "Highlight ON"
    let b:fl=&fdl
    set foldlevel=15
    let b:highlight="true"
    autocmd CursorMoved,CursorMovedI * call HighLightHL()
  else
    echo "Highlight OFF"
    let &fdl=b:fl
    autocmd!
    autocmd InsertLeave * :syntax sync fromstart
    let b:highlight="false"
    execute 'syn clear HLdim0'
    execute 'syn clear HLdim1'
  endif
endfunction

function! HighLightHL()
	let start_line_number = line('.')
	let end_line_number   = start_line_number + 1
	let start_line_indent = indent('.')
	while indent(end_line_number) > start_line_indent
		let end_line_number += 1
	endwhile
  let start = start_line_number
	let end = end_line_number - 1
  execute 'syn clear HLdim0'
  execute 'syn clear HLdim1'
  execute 'syn match HLdim0 ".*\%<' . string(start) . 'l"'
  execute 'syn match HLdim1 ".*\%>' . string(end)   . 'l"'
endfunction

"  AutoNumbering {{{2
"  Mapped to <leader># and <leader>an
"  When activated, <cr> increments the next item on the same level
"  <c-t> indents the item and adds one level of numbering
"  <c-d> de-indents the item and renumbers it.
let s:an = 0
function! ToggleAutonum()
  if s:an == 0
    echo "Autonumber ON"
    imap   <cr> <cr><esc><up>yypf D<left><c-a>gJ:s/\(.*\d.\)\s*/\1 /<cr>A
    imap   <c-t> <esc>>>f <left><left><c-x>a.1<esc><end>a
    imap   <c-d> <esc><<f <left>T.diw<left>x<left><c-a><end>a
    let s:an = 1
  else
    echo "Autonumber OFF"
    iunmap <cr>
    iunmap <c-t>
    iunmap <c-d>
    let s:an = 0
  endif
endfunction

"  Renumber {{{2
"  Mapped to <leader>R
function! Renumber() range
	let l1 = a:firstline
	let l2 = a:lastline
	"If the first line is without a number, add a 1 in the front
	try
		if match(getline(l1),'^\t*\d\+') != 0
			exe l1 's/\(^\t*\)\(.*\)/\11 \2'
		endif
	catch
	endtry
	"Get the indent and store it in 'tabs'
	let tabs = substitute(getline(l1), '^\(\t*\).*', '\1', '')
	"The first part of numbering (like 1.2.) in 'initnum'
	let initnum = substitute(getline(l1), '^\t*\([0-9.]\+\)*\d\+\.* .*', '\1', '')
	"The numbering after initnum starts with 1
	let numx = substitute(getline(l1), '^\t*\([0-9.]\+\)*\(\d\+\)\.* .*', '\2', '')
  "Get the last period"
  let period = substitute(getline(l1), '^\t*\([0-9.]\+\)*\(\d\+\)\(\.*\) .*', '\3', '')
	"Start from first line 
	let lx = l1 + 1
	"Loop until the last line
	while lx <= l2
		"If the indent matches (we will not number lines with greater indentations)
		if match(getline(lx),tabs."[a-zA-ZæøåÆØÅáéóúãõâêôçàÁÉÓÚÃÕÂÊÔÇÀü0-9<>#()\*:]") == 0
			let numx += 1
			silent! exe lx 's/\(^\t*\)[0-9.]* \(.*\)/\1\2'
			let startline = substitute(getline(lx), '\(^\t*\).*', '\1', '')
			let numline = initnum . numx . period
			let endline = substitute(getline(lx), '^\t*\(.*\)', ' \1', '')
			let wholeline = startline . numline . endline
			call setline(lx, wholeline)
		endif
		let lx += 1
	endwhile
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
    normal m'
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
      normal gg
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
    if gofl =~ '\(odt$\|doc$\|docx$\)'
      exe '!' . b:wordprocessingprogram . ' "' . gofl . '"'
    elseif gofl =~ '\(odc$\|xls$\|xlsx$\)'
      exe '!' . b:spreadsheetprogram . ' "' . gofl . '"'
    elseif gofl =~ '\(odp$\|ppt$\|pptx$\)'
      exe '!' . b:presentationprogram . ' "' . gofl . '"'
    elseif gofl =~ '\(jpg$\|jpeg$\|png$\|bmp$\|gif$\)'
      exe '!' . b:imageprogram . ' "' . gofl . '"'
    elseif gofl =~ 'pdf$'
      exe '!' . b:pdfprogram . ' "' . gofl . '"'
    elseif gofl =~ '://'
      exe '!' . b:browserprogram . ' "' . gofl . '"'
  " You add more file openers here by using variables defined in the user
  " settings at the start of this script. Example:
  " elseif gofl =~ 'scad$'
  "   exe '!' . b:scadprogram . ' "' . gofl . '"'
    else
      if has("gui_running")
        exe '!gvim '.gofl
      else
        exe '!vim '.gofl
      endif
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
        execute "%s/\\(<\\{1,2}\\[a-zA-ZæøåÆØÅ0-9.:/_&?%=\\-\\* ]\\+>\\{1,2}\\)/<font color=\"purple\">\\1<\\/font>/g"
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
        execute '%s/\(\t\|\*\|^\)\@<=\([0-9.]\+\s\)/\1\\textcolor{v}{\2}/g'
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
        execute "%s/\\(<\\{1,2}[a-zA-ZæøåÆØÅ0-9.:/_&?%=\\-\\* ]\\+>\\{1,2}\\)/\\\\textcolor{v}{\\1}/g"
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
        execute "%s/\\(\\s\\|\\*\\)\\@<=\\([a-zA-ZæøåÆØÅ0-9,._&?%= \\-\\/+<>#']\\{-2,}:\\s\\)/\\\\textcolor{r}{\\\\emph{\\2}}/g"
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
    normal o\documentclass[10pt,a4paper,usenames]{article}
    normal o\usepackage[usenames]{color}
    normal o\definecolor{r}{rgb}{0.5,0,0}
    normal o\definecolor{g}{rgb}{0,0.5,0}
    normal o\definecolor{b}{rgb}{0,0,0.5}
    normal o\definecolor{v}{rgb}{0.4,0,0.4}
    normal o\definecolor{t}{rgb}{0,0.4,0.4}
    normal o\definecolor{0}{rgb}{0.6,0.6,0}
    normal o\usepackage[margin=2cm]{geometry}
    normal o\usepackage[utf8]{inputenc}
    normal o\usepackage[english]{babel}
    normal o\usepackage[T1]{fontenc}
    normal o\usepackage{alltt}
    normal o\usepackage{fancyhdr}
    normal o\pagestyle{fancy}
    normal o\fancyhead[RO]{\raggedleft FIXME}
    normal o\fancyfoot{}
    normal o\usepackage{pdfpages}
    normal o
    normal o\begin{document}
    normal o\begin{alltt}
    "Document end
    normal Go\end{alltt}
    normal o\end{document}
    set filetype=tex
endfunction

"  TPP conversion{{{2
"  Mapped to '<leader>T'
"  See https://github.com/cbbrowne/tpp
function! TPPconversion ()
    try
        "Remove VIM tagline
        execute '%s/^vim:.*//'
    catch
    endtry
    try
        "first line of a HyperList is title
        execute '%s/^\(\S.*\)$/\r--title \1/'
    catch
    endtry
    try
        "second line of a HyperList is a new slide
        execute '%s/^\(\t\|\*\)\(\S.*\)$/\r--newpage\r\r--header \2/'
    catch
    endtry
    try
        "HLb
        execute '%s/ \@<=\*\(.\{-}\)\* /--boldon\r\1\r--boldoff/g'
    catch
    endtry
    try
        "HLi
        execute '%s/ \@<=\/\(.\{-}\)\/ /--revon\r\1\r--revoff/g'
    catch
    endtry
    try
        "HLu
        execute '%s/ \@<=_\(.\{-}\)_ /--ulon\n\1\r--uloff/g'
    catch
    endtry
    try
        "strip two tabs/indents
        execute '%s/^\(\t\|\*\)\{2}//'
    catch
    endtry
    "Document start
    normal ggO--bgcolor white
    normal o--fgcolor black
    normal o--date today
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

command! -nargs=+  SHOW  :call <SID>ShowHideWord('c', 's', <f-args>)
command! -nargs=+  HIDE  :call <SID>ShowHideWord('c', 'h', <f-args>)

function! <SID>ShowHideWord(mode, show, ...)
   if (a:mode == 'z')
      if a:show == 's' | echo "ShowHide Show" | endif
      if a:show == 'h' | echo "ShowHide Hide" | endif
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

"  CalendarAdd{{{2
"  :call CalendarAdd() will take all items containing a future date and add them 
"  as reminder to your Google Calendar. If the item includes a time, the event 
"  is added from that time with duration of 30 minutes.
"  This function requires gcalcli (https://github.com/insanum/gcalcli)
"  The function is mapped to <leader>G to add events to the default
"  calendar - defined as b:calendar at the start of this script.
"  To add the events to another calendar, do :call CalendarAdd("yourcalendar")
function! CalendarAdd(...)
  let l:count = 0
  let l:cal = a:0 > 0 ? a:1 : b:calendar
  let l:date = strftime("%Y-%m-%d")
  let l:tm = ""
  let l:linenr = 0 
  while l:linenr < line("$") 
    let l:linenr += 1
    let l:line = getline(l:linenr)
    let l:line = substitute(l:line, "\t", "", "g")
    if match(l:line,'\d\d\d\d-\d\d-\d\d') >= 0
      let l:dt = matchstr(l:line,'\d\d\d\d-\d\d-\d\d')
      if l:dt > l:date
        if match(l:line,' \d\d\.\d\d') >= 0
          let l:tm = matchstr(l:line,'\d\d\.\d\d')
          let l:tm = substitute(l:tm, '\.', ":", "")
          let l:tm = " " . l:tm
        endif
        if @% == ""
          let l:filename = ""
        else
          let l:filename = " <" . @% . ">)"
        endif
        let l:title = substitute(l:line, '.*\d\d\d\d-\d\d-\d\d\( \d\d.\d\d\)*: ', '', '')
        let l:start_line_number = l:linenr
        let l:end_line_number   = l:start_line_number + 1
        let l:start_line_indent = indent(l:start_line_number)
        let l:tabs = repeat("\t", l:start_line_indent/&tabstop)
        while indent(l:end_line_number) > l:start_line_indent
          let l:end_line_number += 1
        endwhile
        let l:start    = l:start_line_number
        let l:end      = l:end_line_number - 1
        let l:dlist    = getline(l:start,l:end)
        let l:g_desc   = ""
        for i in l:dlist
          let l:g_desc = l:g_desc . substitute(i, l:tabs, '', '') . "\n"
        endfor
        let l:g_cal    = " --calendar '" . l:cal . "'"
        let l:g_title  = " --title '" . l:title
        if @% == ""
          let l:filename = ""
        else
          let l:filename = " <" . @% . ">"
        endif
        let l:created  = " (created by HyperList.vim" . l:filename . ")' "
        let l:g_when   = " --when '" . l:dt . l:tm . "'"
        let l:g_desc   = " --description '" . l:g_desc . "'"
        let l:gcalcli  = "gcalcli add --where '' --duration 30 --reminder 0" . l:g_cal . l:g_title . l:created . l:g_when . l:g_desc
        call system(l:gcalcli)
        let l:count += 1
      endif
    endif
  endwhile
  if l:count == 0
    let l:msg = "No events added"
  elseif l:count == 1
    let l:msg = "Added 1 event"
  else
    let l:msg = "Added " . l:count . " events"
  endif
  echo l:msg
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
syn match   HLop	'\(^\|\s\|\*\)\@<=[A-ZÆØÅÁÉÓÚÃÕÂÊÔÇÀ_\-()]\{-2,}:\s' contains=HLcomment,HLquote

" Mark semicolon as stringing together lines
syn match   HLsc	';'

" Hashtags (like Twitter)
syn match   HLhash	'#[a-zA-ZæøåÆØÅáéóúãõâêôçàÁÉÓÚÃÕÂÊÔÇÀü0-9.:/_&?%=+\-\*]\+'

" References
syn match   HLref	'<\{1,2}[a-zA-ZæøåÆØÅáéóúãõâêôçàÁÉÓÚÃÕÂÊÔÇÀü0-9,.:/ _~&@?%=\-\*]\+>\{1,2}' contains=HLcomment

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

" Item motion (uncomment if you want this syntax feature)
"syn match   HLmove      '>>\|<<\|->\|<-'

" Bold and Italic
syn match   HLb	        '\(\t\| \)\@<=\*.\{-}\*\($\| \)\@='
syn match   HLi	        '\(\t\| \)\@<=/.\{-}/\($\| \)\@='
syn match   HLu	        '\(\t\| \)\@<=_.\{-}_\($\| \)\@='

" Cluster the above
syn cluster HLtxt contains=HLident,HLmulti,HLop,HLqual,HLtag,HLhash,HLref,HLkey,HLlit,HLlc,HLcomment,HLquote,HLsc,HLtodo,HLmove,HLb,HLi,HLu,HLstate,HLtrans,HLdim0,HLdim1

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
syn region L1 start="^\(\t\|\*\)\{0} \=\S"   end="^\(^\(\t\|\*\)\{1,} \=\S\)\@!"  fold contains=@HLtxt,L2,L3,L4,L5,L6,L7,L8,L9,L10,L11,L12,L13,L14,L15
endif

"  VIM parameters (VIM modeline) {{{2
syn match   HLvim "^vim:.*"

" Highlighting and Linking {{{1
hi	        Folded	  ctermfg=none ctermbg=none cterm=bold term=bold guifg=NONE guibg=NONE gui=bold
hi          HLdim0    ctermfg=241     guifg=Grey
hi          HLdim1    ctermfg=241     guifg=Grey
hi          HLident	  ctermfg=Magenta guifg=Magenta
hi          HLmulti	  ctermfg=Red     guifg=Red
hi          HLtag	    ctermfg=Red     guifg=Red
hi          HLop	    ctermfg=Blue    guifg=Blue
hi          HLqual	  ctermfg=Green   guifg=LimeGreen
hi          HLhash	  ctermfg=184     guifg=#aaa122
hi          HLref	    ctermfg=Magenta guifg=Magenta
hi          HLkey	    ctermfg=Magenta guifg=Magenta
hi          HLcomment	ctermfg=Cyan    guifg=Cyan
hi          HLquote	  ctermfg=Cyan    guifg=Cyan
hi          HLlit     ctermfg=none ctermbg=none cterm=italic term=italic guifg=NONE guibg=NONE gui=italic
hi          HLlc      ctermfg=none ctermbg=none
hi	        HLb	      ctermfg=none ctermbg=none cterm=bold   term=bold   guifg=NONE guibg=NONE gui=bold
hi	        HLi	      ctermfg=none ctermbg=none cterm=italic term=italic guifg=NONE guibg=NONE gui=italic
hi link	    HLu	      underlined
hi def link HLsc	    Type
hi def link HLtodo	  Todo
hi def link HLmove	  Error
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

map <leader>v	        :call CheckItem("")<CR>
map <leader>V         :call CheckItem("stamped")<CR>

map <leader><SPACE>   /=\s*$<CR>A

nmap gr		            :call GotoRef()<CR>
nmap <CR>	            :call GotoRef()<CR>

nmap gf               :call OpenFile()<CR>

nmap g<DOWN>          <DOWN><leader>0zv
nmap g<UP>            <leader>f<UP><leader>0zv

nmap <leader><DOWN>   <DOWN><leader>0zv<SPACE>zO
nmap <leader><UP>     <leader>f<UP><leader>0zv<SPACE>zO

nmap <leader>z        :call HLdecrypt()<CR>V:!openssl bf -pbkdf2 -e -a -salt 2>/dev/null<CR><C-L>
vmap <leader>z        :call HLdecrypt()<CR>gv:!openssl bf -pbkdf2 -e -a -salt 2>/dev/null<CR><C-L>
nmap <leader>Z        :call HLdecrypt()<CR>:%!openssl bf -pbkdf2 -e -a -salt 2>/dev/null<CR><C-L>
nmap <leader>x        :call HLdecrypt()<CR>V:!openssl bf -pbkdf2 -d -a 2>/dev/null<CR><C-L>
vmap <leader>x        :call HLdecrypt()<CR>gv:!openssl bf -pbkdf2 -d -a 2>/dev/null<CR><C-L>
nmap <leader>X        :call HLdecrypt()<CR>:%!openssl bf -pbkdf2 -d -a 2>/dev/null<CR><C-L>

nmap <leader>H        :call HTMLconversion()<CR>
nmap <leader>L        :call LaTeXconversion()<CR>
nmap <leader>T        :call TPPconversion()<CR>

nmap <leader>h        :call HighLight()<CR>
nmap <leader>an       :call ToggleAutonum()<CR>
nmap <leader>#        :call ToggleAutonum()<CR>
vmap <leader>R        :call Renumber()<CR>

map  <silent> zs      :call <SID>ShowHideWord('z', 's', '')<CR>
map  <silent> zh      :call <SID>ShowHideWord('z', 'h', '')<CR>
map  <silent> z0      :set foldmethod=syntax<CR><bar>:echo "ShowHide Remove"<CR>

nmap <leader>G        :call CalendarAdd()<CR>

" Sort hack (sort the visual selected lines by the top item's indentation
" The last item in the visual selection cannot be the last line in the document.
vmap <leader>s <esc>`<^"iy0gv:s/^<c-r>i\S\@=/<c-v><c-a>/<cr>gv:s/\t/<c-v><c-b>/g<cr>gv:s/\n<c-v><c-b>/<c-v><c-x>/<cr>gvk:!sort<cr>:%s/<c-v><c-a>/<c-r>i/<cr>:%s/<c-v><c-x>/\r<c-v><c-b>/g<cr>:%s/<c-v><c-b>/\t/g<cr>

" GVIM menu {{{1
let s:HL_RootMenu  = 'HyperList.'
exe 'menu '.s:HL_RootMenu.'HyperList <Nop>'
exe 'menu '.s:HL_RootMenu.'-Sep00-  <Nop>'
menu HyperList.Toggle\ fold<Tab>SPACE              za
menu HyperList.Set\ fold\ level.0<Tab>\\0          :set foldlevel=0<CR>
menu HyperList.Set\ fold\ level.1<Tab>\\1          :set foldlevel=1<CR>
menu HyperList.Set\ fold\ level.2<Tab>\\2          :set foldlevel=2<CR>
menu HyperList.Set\ fold\ level.3<Tab>\\3          :set foldlevel=3<CR>
menu HyperList.Set\ fold\ level.4<Tab>\\4          :set foldlevel=4<CR>
menu HyperList.Set\ fold\ level.5<Tab>\\5          :set foldlevel=5<CR>
menu HyperList.Set\ fold\ level.6<Tab>\\6          :set foldlevel=6<CR>
menu HyperList.Set\ fold\ level.7<Tab>\\7          :set foldlevel=7<CR>
menu HyperList.Set\ fold\ level.8<Tab>\\8          :set foldlevel=8<CR>
menu HyperList.Set\ fold\ level.9<Tab>\\9          :set foldlevel=9<CR>
menu HyperList.Set\ fold\ level.10<Tab>\\a         :set foldlevel=10<CR>
menu HyperList.Set\ fold\ level.11<Tab>\\b         :set foldlevel=11<CR>
menu HyperList.Set\ fold\ level.12<Tab>\\c         :set foldlevel=12<CR>
menu HyperList.Set\ fold\ level.13<Tab>\\d         :set foldlevel=13<CR>
menu HyperList.Set\ fold\ level.14<Tab>\\e         :set foldlevel=14<CR>
menu HyperList.Set\ fold\ level.15<Tab>\\f         :set foldlevel=15<CR>
menu HyperList.Toggle\ State/Transition<Tab>\\u    :call STunderline()<CR>
menu HyperList.Checklist.Toggle<Tab>\\v            :call CheckItem("")<CR>
menu HyperList.Checklist.Timestamp<Tab>\\V         :call CheckItem("stamped")<CR>
menu HyperList.Goto\ reference<Tab>gr              :call GotoRef()<CR>
menu HyperList.Open\ file\ under\ cursor<Tab>gf    :call OpenFile()<CR>
menu HyperList.Show/Hide.Show\ Word\ under\ Cursor<Tab>zs :call <SID>ShowHideWord('z', 's', '')<CR>
menu HyperList.Show/Hide.Hide\ Word\ under\ Cursor<Tab>zh :call <SID>ShowHideWord('z', 'h', '')<CR>
menu HyperList.Show/Hide.Remove\ Show/Hide<Tab>z0  :set foldmethod=syntax<CR><bar>:echo "ShowHide Remove"<CR>
menu HyperList.Autonumber.Toggle<Tab>\\an          :call ToggleAutonum()<CR>
vmenu HyperList.Autonumber.Renumber\ visual\ selection<Tab>\\R :call Renumber()<CR>
menu HyperList.Next\ Template\ Item<Tab>\\SPACE    /=\s*$<CR>A<CR>
menu HyperList.Highlight\ Toggle<Tab>\\h           :call HighLight()<CR>
menu HyperList.Presentation\ Move\ Down<Tab>gDOWN  <DOWN><leader>0zv
menu HyperList.Presentation\ Move\ Up<Tab>gUP      <leader>f<UP><leader>0zv
menu HyperList.Encryption\ (Requires\ OpenSSL).Encrypt<Tab>\\z :call HLdecrypt()<CR>V:!openssl bf -pbkdf2 -e -a -salt 2>/dev/null<CR><C-L>
vmenu HyperList.Encryption\ (Requires\ OpenSSL).Encrypt\ Visual\ Selection<Tab>\\z :call HLdecrypt()<CR>gv:!openssl bf -pbkdf2 -e -a -salt 2>/dev/null<CR><C-L>
menu HyperList.Encryption\ (Requires\ OpenSSL).Encrypt\ All<Tab>\\Z :call HLdecrypt()<CR>:%!openssl bf -pbkdf2 -e -a -salt 2>/dev/null<CR><C-L>
menu HyperList.Encryption\ (Requires\ OpenSSL).Decrypt<Tab>\\x :call HLdecrypt()<CR>V:!openssl bf -pbkdf2 -d -a 2>/dev/null<CR><C-L>
vmenu HyperList.Encryption\ (Requires\ OpenSSL).Decrypt\ Visual\ Selection<Tab>\\x :call HLdecrypt()<CR>gv:!openssl bf -pbkdf2 -d -a 2>/dev/null<CR><C-L>
menu HyperList.Encryption\ (Requires\ OpenSSL).Decrypt\ All<Tab>\\X :call HLdecrypt()<CR>:%!openssl bf -pbkdf2 -d -a 2>/dev/null<CR><C-L>
menu HyperList.Conversion.HTML<Tab>\\H             :call HTMLconversion()<CR>
menu HyperList.Conversion.LaTeX<Tab>\\L            :call LaTeXconversion()<CR>
menu HyperList.Conversion.TPP<Tab>\\T              :call TPPconversion()<CR>
menu HyperList.Add\ Calendar\ Events\ (Requires\ gcalcli)<Tab>\\G :call CalendarAdd()<CR>
menu HyperList.Show\ Complexity\ of\ List<Tab>:call\ Complexity() :call Complexity()<CR>

" vim modeline {{{1
" vim: set sw=2 sts=2 et fdm=marker fillchars=fold\:\ :
