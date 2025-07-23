" Vimball Archiver by Charles E. Campbell
UseVimball
finish
syntax/hyperlist.vim	[[[1
2258
" Script info {{{1
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
" Version:    2.6.2 - compatible with the HyperList definition v. 2.6
" Modified:   2025-01-04
" Changes:    Added missing <leader>M for Markdown conversion. Closes #16

" Instructions {{{1
"
" Use tabs/shifts or * for indentations
"
" Use <SPACE> to toggle one fold. Use <c-SPACE> to toggle a fold recursively.
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
" default calendar. Your default calendar is set in your .vimrc file with
" g:calendar = "yourcalendar". If not set in your .vimrc, a set of icalendar
" files will be written to your working directory. If you also want past events
" added to your calendar, add this to your .vimrc: g:alldates = 1
"
" Syntax is updated at start and every time you leave Insert mode.
"
" Much more information is found in the documentation (:help hyperlist.txt)

" Initializing {{{1
if version < 600
    syntax clear
elseif exists('b:current_syntax')
    finish
endif

" Fast startup optimization
let s:file_size = line('$')
let s:large_file_threshold = exists('g:hyperlist_large_file_threshold') ? g:hyperlist_large_file_threshold : 2000
let s:is_large_file = s:file_size > s:large_file_threshold

" Performance mode for large files
if s:is_large_file
  let g:hyperlist_performance_mode = 1
  " Reduce features for large files
  let s:max_fold_levels = 8
  syn sync minlines=5
  syn sync maxlines=50
else
  let s:max_fold_levels = 15
endif

let b:current_syntax = "HyperList"

" OS specific settings
let s:UNIX  = has("unix")  || has("win32unix")
let s:MAC   = has("macunix")
let s:MSWIN = has("win16") || has("win32") || has("win64") || has("win95")

if s:MSWIN
  if mapcheck("\<c-a>","n") != ""
    nunmap <c-a>
  endif
endif

if !exists("g:alldates")
  let g:alldates=0
endif

" Modern features configuration {{{2
" Enable/disable modern features (default: auto-detect)
if !exists("g:hyperlist_enable_floating_windows")
  let g:hyperlist_enable_floating_windows = has('nvim-0.4.0') && exists('*nvim_open_win')
endif

if !exists("g:hyperlist_enable_lsp_completion")
  let g:hyperlist_enable_lsp_completion = 1
endif

if !exists("g:hyperlist_enable_telescope")
  let g:hyperlist_enable_telescope = exists(':Telescope')
endif

" Floating window appearance
if !exists("g:hyperlist_float_border")
  let g:hyperlist_float_border = 'rounded'
endif

if !exists("g:hyperlist_float_max_width")
  let g:hyperlist_float_max_width = 80
endif

if !exists("g:hyperlist_float_max_height")
  let g:hyperlist_float_max_height = 20
endif

" Preview timeout (milliseconds)
if !exists("g:hyperlist_preview_timeout")
  let g:hyperlist_preview_timeout = 4000
endif

" Enable breadcrumb display
if !exists("g:hyperlist_show_breadcrumbs")
  let g:hyperlist_show_breadcrumbs = 1
endif

" Auto-completion trigger characters
if !exists("g:hyperlist_completion_triggers")
  let g:hyperlist_completion_triggers = ['#', '<', ':', '[']
endif

" Export configuration {{{2
" Export format preferences
if !exists("g:hyperlist_export_include_metadata")
  let g:hyperlist_export_include_metadata = 1
endif

if !exists("g:hyperlist_export_author")
  let g:hyperlist_export_author = "HyperList User"
endif

if !exists("g:hyperlist_export_title_prefix")
  let g:hyperlist_export_title_prefix = "HyperList Export"
endif

" HTML export settings
if !exists("g:hyperlist_html_theme")
  let g:hyperlist_html_theme = "modern"  " modern, classic, minimal
endif

if !exists("g:hyperlist_html_include_css")
  let g:hyperlist_html_include_css = 1
endif

" LaTeX export settings
if !exists("g:hyperlist_latex_document_class")
  let g:hyperlist_latex_document_class = "article"
endif

if !exists("g:hyperlist_latex_font_size")
  let g:hyperlist_latex_font_size = "11pt"
endif

if !exists("g:hyperlist_latex_include_toc")
  let g:hyperlist_latex_include_toc = 1
endif

" Markdown export settings
if !exists("g:hyperlist_markdown_include_yaml")
  let g:hyperlist_markdown_include_yaml = 1
endif

if !exists("g:hyperlist_markdown_checkbox_style")
  let g:hyperlist_markdown_checkbox_style = "github"  " github, unicode
endif

" iCal export settings
if !exists("g:hyperlist_ical_include_categories")
  let g:hyperlist_ical_include_categories = 1
endif

if !exists("g:hyperlist_ical_default_duration")
  let g:hyperlist_ical_default_duration = 30  " minutes
endif

" Settings {{{1
"  File opening settings {{{2
"  You can override all of these by setting global variables in your vimrc
"  file, like this (note the "g" in front of the program type):
"  let g:imageprogram          = "eog"
"
"  The following are the default programs for opening files in various OSes.
"  If you are running Linux/Unix/win32unix
if s:UNIX
  let b:wordprocessingprogram = "libreoffice"
  let b:spreadsheetprogram    = "libreoffice"
  let b:presentationprogram   = "libreoffice"
  let b:pdfprogram            = "zathura"
  let b:imageprogram          = "feh"
  let b:browserprogram        = "qutebrowser"
endif
"  If you are running MacOSX
if s:MAC
  let b:wordprocessingprogram = "open"
  let b:spreadsheetprogram    = "open"
  let b:presentationprogram   = "open"
  let b:pdfprogram            = "open"
  let b:imageprogram          = "open"
  let b:browserprogram        = "open"
endif
"  If you are running MS Windows:
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
"  You can add programs to open other file types - and add the opener to the
"  function "OpenFile()" (see example there). Example::
"  let b:scadprogram           = "openscad"

"  Calendar settings (in your .vimrc) {{{2
"  To be able to post events to your Google calendar, you must add the
"  global calendar variable to your vimrc file, like this:
"  let g:calendar       = "youremail@provider.com"

"  Sync settings {{{2
"  Dynamic sync values based on file size for optimal performance
let s:file_lines = line("$")
if s:file_lines > 5000
  " Large files: reduce sync for performance
  syn sync minlines=10
  syn sync maxlines=100
elseif s:file_lines > 1000
  " Medium files: balanced sync
  syn sync minlines=20
  syn sync maxlines=200
else
  " Small files: more thorough sync
  syn sync minlines=50
  syn sync maxlines=300
endif

"  General settings {{{2
setlocal autoindent
setlocal textwidth=0
setlocal shiftwidth=3
setlocal tabstop=3
setlocal softtabstop=3
setlocal noexpandtab
setlocal guioptions+=t
setlocal foldmethod=syntax
setlocal fillchars=fold:\ 
syn sync fromstart
autocmd InsertLeave * :syntax sync fromstart
"  Set off with no highlighting - toggled with <leader>h
let b:highlight      = "false"

" Functions {{{1
"  Modern Vim/Neovim compatibility {{{2
"  Lazy loading wrapper for performance
let s:modern_features_loaded = 0
function! s:ensure_modern_features()
  if !s:modern_features_loaded
    call s:load_modern_features()
    let s:modern_features_loaded = 1
  endif
endfunction

function! s:load_modern_features()
  " Load modern features only when needed
  if exists('g:hyperlist_performance_mode') && g:hyperlist_performance_mode
    " Skip expensive features in performance mode
    return
  endif
  " Modern features loaded on-demand
endfunction

"  Check if we're running Neovim with floating window support
function! s:has_floating_windows()
  return has('nvim-0.4.0') && exists('*nvim_open_win')
endfunction

"  Create a floating window for content display
function! s:create_floating_window(content, title)
  if !s:has_floating_windows()
    " Fallback to preview window for older Vim
    pedit __HyperList_Preview__
    wincmd P
    setlocal buftype=nofile bufhidden=wipe noswapfile
    call setline(1, a:content)
    wincmd p
    return -1
  endif
  
  let width = min([max(map(copy(a:content), 'len(v:val)')), 80])
  let height = min([len(a:content), 20])
  let row = (winheight(0) - height) / 2
  let col = (winwidth(0) - width) / 2
  
  let buf = nvim_create_buf(v:false, v:true)
  call nvim_buf_set_lines(buf, 0, -1, v:true, a:content)
  
  let opts = {
    \ 'relative': 'editor',
    \ 'width': width,
    \ 'height': height,
    \ 'row': row,
    \ 'col': col,
    \ 'style': 'minimal',
    \ 'border': 'rounded'
    \ }
  
  let win = nvim_open_win(buf, v:false, opts)
  
  " Set title if supported
  if !empty(a:title)
    call nvim_win_set_option(win, 'winhl', 'Normal:Normal,FloatBorder:FloatBorder')
  endif
  
  return win
endfunction

"  Close floating window
function! s:close_floating_window(win_id)
  if a:win_id != -1 && s:has_floating_windows()
    try
      call nvim_win_close(a:win_id, v:true)
    catch
    endtry
  else
    " Close preview window
    pclose
  endif
endfunction

"  Modern utility functions {{{2
"  Enhanced item navigation with breadcrumbs
function! ShowHyperListBreadcrumb()
  let current_line = line('.')
  let current_indent = indent(current_line)
  let breadcrumb = []
  
  " Walk backwards to find parent items
  for lnum in range(current_line - 1, 1, -1)
    let line_indent = indent(lnum)
    if line_indent < current_indent
      let line_text = substitute(getline(lnum), '^\s*', '', '')
      let line_text = substitute(line_text, '\s*$', '', '')
      call insert(breadcrumb, line_text)
      let current_indent = line_indent
      if current_indent == 0
        break
      endif
    endif
  endfor
  
  " Add current item
  let current_text = substitute(getline('.'), '^\s*', '', '')
  call add(breadcrumb, current_text)
  
  if len(breadcrumb) > 1
    echo join(breadcrumb, ' > ')
  else
    echo breadcrumb[0]
  endif
endfunction

"  Smart folding based on context
function! SmartFoldContext()
  let current_indent = indent('.')
  let target_level = current_indent / &tabstop + 1
  execute 'setlocal foldlevel=' . target_level
  normal! zv
endfunction

"  Quick item insertion with template
function! InsertHyperListItem(type)
  let indent_str = repeat("\t", indent('.') / &tabstop)
  let templates = {
    \ 'todo': '[_] ',
    \ 'done': '[x] ',
    \ 'inprogress': '[O] ',
    \ 'state': 'S: ',
    \ 'transition': 'T: ',
    \ 'property': ': ',
    \ 'reference': '<>',
    \ 'comment': '()',
    \ 'hash': '#'
  \ }
  
  if has_key(templates, a:type)
    let template = templates[a:type]
    execute "normal! o" . indent_str . template
    if a:type == 'reference'
      execute "normal! i"
    elseif a:type == 'comment'
      execute "normal! i"
    else
      execute "normal! A"
    endif
  endif
endfunction

"  Export current item and children to quickfix
function! ExportItemToQuickfix()
  let start_line = line('.')
  let start_indent = indent(start_line)
  let end_line = start_line
  
  " Find end of current item and its children
  for lnum in range(start_line + 1, line('$'))
    if indent(lnum) <= start_indent && getline(lnum) =~# '\S'
      break
    endif
    let end_line = lnum
  endfor
  
  let qf_list = []
  for lnum in range(start_line, end_line)
    let line_text = getline(lnum)
    if line_text =~# '\S'  " Non-empty line
      call add(qf_list, {
        \ 'bufnr': bufnr('%'),
        \ 'lnum': lnum,
        \ 'text': line_text,
        \ 'type': 'I'
      \ })
    endif
  endfor
  
  call setqflist(qf_list)
  copen
endfunction

"  Folding {{{2
"  Mapped to <SPACE> and <leader>0 - <leader>f
setlocal foldtext=HLFoldText()
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
    setlocal foldlevel=15
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
  setlocal viminfo=""
  setlocal noswapfile
endfunction

"  Enhanced encryption functions with clean prompts
function! HLencryptLine()
  call HLdecrypt()
  echo "Encrypting line..."
  execute ".!openssl aes-256-cbc -e -pbkdf2 -a -salt 2>/dev/null"
  redraw!
endfunction

function! HLencryptVisual() range
  call HLdecrypt()
  echo "Encrypting selection..."
  execute a:firstline . "," . a:lastline . "!openssl aes-256-cbc -e -pbkdf2 -a -salt 2>/dev/null"
  redraw!
endfunction

function! HLencryptAll()
  call HLdecrypt()
  echo "Encrypting entire file..."
  execute '%!openssl aes-256-cbc -e -pbkdf2 -a -salt 2>/dev/null'
  redraw!
endfunction

function! HLdecryptLine()
  call HLdecrypt()
  echo "Decrypting line..."
  execute ".!openssl aes-256-cbc -d -pbkdf2 -a -salt 2>/dev/null"
  redraw!
endfunction

function! HLdecryptVisual() range
  call HLdecrypt()
  echo "Decrypting selection..."
  execute a:firstline . "," . a:lastline . "!openssl aes-256-cbc -d -pbkdf2 -a -salt 2>/dev/null"
  redraw!
endfunction

function! HLdecryptAll()
  call HLdecrypt()
  echo "Decrypting entire file..."
  execute '%!openssl aes-256-cbc -d -pbkdf2 -a -salt 2>/dev/null'
  redraw!
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
  if a:stamp ==# 'inprogress'
    if current_line =~# '\[O\]'
      exe 's/\[O\]/[_]/'
    else
      if current_line !~# '\[_\]'
        exe "normal ^i[_] "
      endif
      exe 's/\[_\]/[O]/'
    endif
    return
  endif
  if current_line =~# '\[O\]'
    exe 's/\[O\]/[x]/'
    return
  endif
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

"  Modern reference preview (optional enhancement) {{{2
"  Enhanced reference preview with floating window support
function! s:preview_reference()
  let current_line = getline('.')
  if match(current_line,'<.*>') >= 0
    let ref_word = matchstr(current_line,"<.\\{-}>")
    let ref_word = substitute(ref_word, "<", '', 'g')
    let ref_word = substitute(ref_word, '>', '', 'g')
    
    if match(ref_word,"^file:") >= 0
      let file_path = substitute(ref_word, 'file:', '', 'g')
      if filereadable(file_path)
        let content = readfile(file_path, '', 10)
        let title = "File: " . file_path
        let s:preview_win = s:create_floating_window(content, title)
        call timer_start(5000, {-> s:close_floating_window(s:preview_win)})
        augroup HLPreviewClose
          autocmd!
          autocmd CursorMoved * call s:close_floating_window(s:preview_win) | autocmd! HLPreviewClose
        augroup END
      else
        echo "File not found: " . file_path
      endif
    elseif match(ref_word,"^[-+][0-9]") >= 0
      let offset = str2nr(ref_word)
      let target_line = line(".") + offset
      if target_line > 0 && target_line <= line("$")
        let preview_start = max([1, target_line - 5])
        let preview_end = min([line("$"), target_line + 5])
        let content = getline(preview_start, preview_end)
        let title = "Line " . target_line . " (offset " . ref_word . ")"
        let s:preview_win = s:create_floating_window(content, title)
        call timer_start(3000, {-> s:close_floating_window(s:preview_win)})
      else
        echo "Invalid line reference: " . ref_word
      endif
    else
      let ref_dest = substitute(ref_word, '/', '\\_.\\{-}\\t', 'g')
      let ref_dest = "\\s" . ref_dest
      let save_pos = getpos('.')
      normal gg
      if search(ref_dest) > 0
        let found_line = line('.')
        let preview_start = max([1, found_line - 3])
        let preview_end = min([line("$"), found_line + 7])
        let content = getline(preview_start, preview_end)
        let title = "Reference: " . ref_word
        let s:preview_win = s:create_floating_window(content, title)
        call timer_start(4000, {-> s:close_floating_window(s:preview_win)})
      else
        echo "Reference not found: " . ref_word
      endif
      call setpos('.', save_pos)
    endif
  else
    echo "No reference in the HyperList item"
  endif
endfunction

"  Modern goto reference with enhanced features
function! GotoRefModern()
  " First show preview, then navigate after a delay
  call s:preview_reference()
  call timer_start(1000, {-> GotoRef()})
endfunction

"  LSP-style completion system {{{2
"  Get completion items based on context
function! s:get_completion_items()
  let line = getline('.')
  let col = col('.')
  let before_cursor = line[:col-2]
  let items = []
  
  " State/Transition completion
  if before_cursor =~# '\(S:\|T:\|\|\|/\)\s*$'
    let items += ['TODO', 'DONE', 'IN_PROGRESS', 'WAITING', 'CANCELLED']
  endif
  
  " Hashtag completion - collect existing hashtags
  if before_cursor =~# '#\w*$'
    let hashtags = []
    for lnum in range(1, line('$'))
      let line_text = getline(lnum)
      let matches = []
      let start = 0
      while 1
        let match_pos = match(line_text, '#\w\+', start)
        if match_pos == -1 | break | endif
        let match_end = matchend(line_text, '#\w\+', start)
        let hashtag = line_text[match_pos:match_end-1]
        if index(hashtags, hashtag) == -1
          call add(hashtags, hashtag)
        endif
        let start = match_end
      endwhile
    endfor
    let items += hashtags
  endif
  
  " Reference completion - collect existing items that can be referenced
  if before_cursor =~# '<[^>]*$'
    let refs = []
    for lnum in range(1, line('$'))
      let line_text = getline(lnum)
      if line_text =~# '^\s*\d\+\.'
        let ref_text = substitute(line_text, '^\s*\(\d\+\.[^:]*\).*', '\1', '')
        call add(refs, ref_text)
      elseif line_text =~# '^\s*[A-Z][A-Z_]*:'
        let ref_text = substitute(line_text, '^\s*\([A-Z][A-Z_]*\):.*', '\1', '')
        call add(refs, ref_text)
      endif
    endfor
    let items += refs
  endif
  
  " Property completion
  if before_cursor =~# '\w\+:\s*$'
    let prop = matchstr(before_cursor, '\w\+:\s*$')
    if prop =~# '^priority:'
      let items += ['high', 'medium', 'low']
    elseif prop =~# '^status:'
      let items += ['todo', 'doing', 'done', 'blocked']
    elseif prop =~# '^date:'
      let items += [strftime('%Y-%m-%d'), 'today', 'tomorrow', '+1week']
    elseif prop =~# '^time:'
      let items += ['09:00', '10:00', '14:00', '15:30']
    endif
  endif
  
  " Checkbox completion
  if before_cursor =~# '\[\s*$'
    let items += ['_] ', 'x] ', 'O] ']
  endif
  
  return items
endfunction

"  Modern completion function with floating window
function! HyperListComplete()
  let items = s:get_completion_items()
  if empty(items)
    echo "No completions available"
    return
  endif
  
  if s:has_floating_windows() && len(items) > 1
    " Show completion in floating window
    let content = map(copy(items), 'string(v:key+1) . ". " . v:val')
    let title = "HyperList Completions"
    let s:completion_win = s:create_floating_window(content, title)
    
    " Set up completion selection
    echo "Select completion (1-" . len(items) . ") or press Esc:"
    let choice = getchar()
    call s:close_floating_window(s:completion_win)
    
    if choice >= char2nr('1') && choice <= char2nr('9')
      let idx = choice - char2nr('1')
      if idx < len(items)
        return items[idx]
      endif
    endif
  else
    " Fallback to simple completion
    if len(items) == 1
      return items[0]
    else
      let choice = inputlist(['Select completion:'] + map(copy(items), 'string(v:key+1) . ". " . v:val'))
      if choice > 0 && choice <= len(items)
        return items[choice-1]
      endif
    endif
  endif
  
  return ''
endfunction

"  Insert completion at cursor
function! InsertHyperListCompletion()
  let completion = HyperListComplete()
  if !empty(completion)
    execute "normal! a" . completion
  endif
endfunction

"  Telescope.nvim integration (optional) {{{2
"  Check if telescope is available
function! s:has_telescope()
  return exists(':Telescope') && luaeval('pcall(require, "telescope")')
endfunction

"  Telescope picker for HyperList items
function! TelescopeHyperListItems()
  if !s:has_telescope()
    echo "Telescope.nvim not available. Install telescope.nvim for enhanced navigation."
    return
  endif
  
  lua << EOF
  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')
  
  -- Collect HyperList items
  local items = {}
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  
  for i, line in ipairs(lines) do
    local indent_level = 0
    local content = line
    
    -- Count indentation
    local indent_match = string.match(line, '^(\t*)')
    if indent_match then
      indent_level = string.len(indent_match)
    end
    
    -- Extract meaningful content
    if string.match(line, '%S') then  -- Non-empty line
      local display = string.rep('  ', indent_level) .. string.gsub(line, '^%s*', '')
      table.insert(items, {
        display = display,
        line_number = i,
        content = line
      })
    end
  end
  
  pickers.new({}, {
    prompt_title = "HyperList Items",
    finder = finders.new_table {
      results = items,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry.display,
          ordinal = entry.content,
        }
      end,
    },
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        vim.api.nvim_win_set_cursor(0, {selection.value.line_number, 0})
        vim.cmd('normal! zz')
      end)
      return true
    end,
  }):find()
EOF
endfunction

"  Telescope picker for references
function! TelescopeHyperListReferences()
  if !s:has_telescope()
    echo "Telescope.nvim not available"
    return
  endif
  
  lua << EOF
  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')
  
  -- Find all references in the document
  local refs = {}
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  
  for i, line in ipairs(lines) do
    for ref in string.gmatch(line, '<([^>]+)>') do
      table.insert(refs, {
        reference = ref,
        line_number = i,
        line_content = line
      })
    end
  end
  
  if #refs == 0 then
    print("No references found in this HyperList")
    return
  end
  
  pickers.new({}, {
    prompt_title = "HyperList References",
    finder = finders.new_table {
      results = refs,
      entry_maker = function(entry)
        return {
          value = entry,
          display = string.format("<%s> (line %d)", entry.reference, entry.line_number),
          ordinal = entry.reference,
        }
      end,
    },
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        vim.api.nvim_win_set_cursor(0, {selection.value.line_number, 0})
        vim.cmd('normal! zz')
      end)
      return true
    end,
  }):find()
EOF
endfunction

"  Goto reference {{{2
"  Mapped to 'gr' and <CR> - ORIGINAL FUNCTION PRESERVED
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
      if match(ref_word,"^file:") >= 0
        let ref_word = substitute(ref_word, 'file:', '', 'g')
        normal 0
        call search(ref_word)
        call OpenFile()
      elseif match(ref_word,"^[-+][0-9]") >= 0
        let ref_word = str2nr(ref_word)
        let dest = line(".") + ref_word
        exe ":" . dest
        normal z.
      else
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
        normal z.
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
      if exists('g:wordprocessingprogram')
        exe '!' . g:wordprocessingprogram . ' "' . gofl . '"'
      else
        exe '!' . b:wordprocessingprogram . ' "' . gofl . '"'
      endif
    elseif gofl =~ '\(odc$\|xls$\|xlsx$\)'
      if exists('g:spreadsheetprogram')
        exe '!' . g:spreadsheetprogram . ' "' . gofl . '"'
      else
        exe '!' . b:spreadsheetprogram . ' "' . gofl . '"'
      endif
    elseif gofl =~ '\(odp$\|ppt$\|pptx$\)'
      if exists('g:presentationprogram')
        exe '!' . g:presentationprogram . ' "' . gofl . '"'
      else
        exe '!' . b:presentationprogram . ' "' . gofl . '"'
      endif
    elseif gofl =~ '\(jpg$\|jpeg$\|png$\|bmp$\|gif$\)'
      if exists('g:imageprogram')
        exe '!' . g:imageprogram . ' "' . gofl . '"'
      else
        exe '!' . b:imageprogram . ' "' . gofl . '"'
      endif
    elseif gofl =~ 'pdf$'
      if exists('g:pdfprogram')
        exe '!' . g:pdfprogram . ' "' . gofl . '"'
      else
        exe '!' . b:pdfprogram . ' "' . gofl . '"'
      endif
    elseif gofl =~ '://'
      if exists('g:browserprogram')
        exe '!' . g:browserprogram . ' "' . gofl . '"'
      else
        exe '!' . b:browserprogram . ' "' . gofl . '"'
      endif
  " You can add more file openers here by using global variables. Example:
  " ---------------------------------------------------------------------------
  " elseif gofl =~ 'scad$'
  "   exe '!' . g:scadprogram . ' "' . gofl . '"'
  " ---------------------------------------------------------------------------
  " Just make sure to set the variable in your vimrc like this:
  " let g:scadprogram = "autocad"
    else
      if has("gui_running")
        exe '!gvim '.gofl
      else
        if $EDITOR == "nvim"
          exe 'term nvim '.gofl
        else
          exe '!vim '.gofl
        endif
      endif
    endif
  else
    echo "No reference"
  endif
endfunction


"  Enhanced LaTeX conversion{{{2
"  Modern LaTeX export with better packages and formatting
function! LaTeXConversionModern()
    setlocal expandtab
    retab
    try
        "Remove VIM tagline
        execute '%s/^vim:.*//g'
    catch
    endtry
    try
        "Escape special LaTeX characters
        execute '%s/\\/\\textbackslash{}/g'
        execute '%s/&/\\&/g'
        execute '%s/%/\\%/g'
        execute '%s/\$/\\$/g'
        execute '%s/#/\\#/g'
        execute '%s/_/\\_/g'
        execute '%s/\^/\\textasciicircum{}/g'
        execute '%s/~/\\textasciitilde{}/g'
    catch
    endtry
    try
        "Convert HyperList markup
        execute '%s/ \@<=\*\(.\{-}\)\* /\\textbf{\1}/g'
        execute '%s/ \@<=\/\(.\{-}\)\/ /\\textit{\1}/g'
        execute '%s/ \@<=_\(.\{-}\)_ /\\underline{\1}/g'
    catch
    endtry
    try
        "Convert HyperList elements with better commands
        execute '%s/\(\[.\{-}\]\)/\\hlqualifier{\1}/g'
        execute '%s/\({.\{-}}\)/\\hlsubstitution{\1}/g'
        execute '%s/\(#[a-zA-ZæøåÆØÅ0-9.:/_&?%=\\-\\*]\\+\)/\\hlhashtag{\1}/g'
        execute '%s/\\(<\\{1,2}[a-zA-ZæøåÆØÅ0-9.:/_&?%=\\-\\* ]\\+>\\{1,2}\\)/\\hlreference{\1}/g'
        execute '%s/\((.*)\)/\\hlcomment{\1}/g'
        execute '%s/\(\".*\"\)/\\hlquote{\1}/g'
    catch
    endtry
    try
        "Convert States and Transitions
        execute '%s/^\\(\\s*\\)S: \\(.*\\)/\\1\\hlstate{State: \\2}/g'
        execute '%s/^\\(\\s*\\)T: \\(.*\\)/\\1\\hltransition{Action: \\2}/g'
        execute '%s/^\\(\\s*\\)| \\(.*\\)/\\1\\hlstate{State: \\2}/g'
        execute '%s/^\\(\\s*\\)\\/ \\(.*\\)/\\1\\hltransition{Action: \\2}/g'
    catch
    endtry
    try
        "Convert Operators and Properties
        execute '%s/\\([A-ZÆØÅÁÉÓÚÃÕÂÊÔÇÀ_\\-() /]\\{2,}\\):\\s/\\hloperator{\1:} /g'
        execute '%s/\\([a-zA-ZæøåÆØÅ0-9,._&?%= \\-\\/+<>#'"'"'()\\*:]\\{2,}\\):\\s/\\hlproperty{\1:} /g'
    catch
    endtry
    try
        "Convert indentation to proper LaTeX lists
        execute '%s/^\\(\\t\\|\\*\\)\\{1}\\([^\\\\]\\)/\\\\item \\2/g'
        execute '%s/^\\(\\t\\|\\*\\)\\{2}\\([^\\\\]\\)/\\\\begin{itemize}\\\\item \\2\\\\end{itemize}/g'
    catch
    endtry
    try
        "Convert checkboxes
        execute '%s/\\[_\\]/\\checkbox{}/g'
        execute '%s/\\[x\\]/\\checkboxdone{}/g'
        execute '%s/\\[X\\]/\\checkboxdone{}/g'
        execute '%s/\\[O\\]/\\checkboxprogress{}/g'
    catch
    endtry
    
    "Enhanced document structure
    normal ggO%Generated by HyperList.vim - Enhanced LaTeX Export
    execute "normal o%Export date: " . strftime('%Y-%m-%d %H:%M:%S')
    normal o%Source: https://github.com/isene/hyperlist.vim
    normal o
    normal o\\documentclass[11pt,a4paper]{article}
    normal o\\usepackage[utf8]{inputenc}
    normal o\\usepackage[T1]{fontenc}
    normal o\\usepackage[english]{babel}
    normal o\\usepackage[margin=2.5cm]{geometry}
    normal o\\usepackage{xcolor}
    normal o\\usepackage{enumitem}
    normal o\\usepackage{fancyhdr}
    normal o\\usepackage{titlesec}
    normal o\\usepackage{hyperref}
    normal o\\usepackage{tcolorbox}
    normal o\\usepackage{fontawesome5}
    normal o
    normal o% HyperList color definitions
    normal o\\definecolor{hloperator}{RGB}{41,128,185}
    normal o\\definecolor{hlproperty}{RGB}{231,76,60}
    normal o\\definecolor{hlqualifier}{RGB}{39,174,96}
    normal o\\definecolor{hlhashtag}{RGB}{243,156,18}
    normal o\\definecolor{hlreference}{RGB}{155,89,182}
    normal o\\definecolor{hlcomment}{RGB}{127,140,141}
    normal o\\definecolor{hlquote}{RGB}{22,160,133}
    normal o\\definecolor{hlstate}{RGB}{46,204,113}
    normal o\\definecolor{hltransition}{RGB}{230,126,34}
    normal o
    normal o% HyperList commands
    normal o\\newcommand{\\hloperator}[1]{\\textcolor{hloperator}{\\textbf{#1}}}
    normal o\\newcommand{\\hlproperty}[1]{\\textcolor{hlproperty}{\\textit{#1}}}
    normal o\\newcommand{\\hlqualifier}[1]{\\textcolor{hlqualifier}{\\texttt{#1}}}
    normal o\\newcommand{\\hlhashtag}[1]{\\textcolor{hlhashtag}{\\textbf{#1}}}
    normal o\\newcommand{\\hlreference}[1]{\\textcolor{hlreference}{#1}}
    normal o\\newcommand{\\hlcomment}[1]{\\textcolor{hlcomment}{\\textit{#1}}}
    normal o\\newcommand{\\hlquote}[1]{\\textcolor{hlquote}{#1}}
    normal o\\newcommand{\\hlstate}[1]{\\begin{tcolorbox}[colback=hlstate!10,colframe=hlstate,title=State]#1\\end{tcolorbox}}
    normal o\\newcommand{\\hltransition}[1]{\\begin{tcolorbox}[colback=hltransition!10,colframe=hltransition,title=Action]#1\\end{tcolorbox}}
    normal o\\newcommand{\\hlsubstitution}[1]{\\textcolor{hlqualifier}{#1}}
    normal o\\newcommand{\\checkbox}{\\faSquare[regular]}
    normal o\\newcommand{\\checkboxdone}{\\faCheckSquare}
    normal o\\newcommand{\\checkboxprogress}{\\faMinusSquare[regular]}
    normal o
    normal o% Document setup
    normal o\\title{HyperList Export}
    execute "normal o\\author{Generated by HyperList.vim}"
    execute "normal o\\date{" . strftime('%Y-%m-%d') . "}"
    normal o
    normal o\\pagestyle{fancy}
    normal o\\fancyhf{}
    normal o\\fancyhead[R]{\\thepage}
    normal o\\fancyhead[L]{HyperList Export}
    normal o
    normal o\\begin{document}
    normal o\\maketitle
    normal o\\tableofcontents
    normal o\\newpage
    normal o
    normal o\\begin{itemize}[leftmargin=0pt,itemsep=2pt,parsep=0pt]
    
    "Document end
    normal Go\\end{itemize}
    normal o\\end{document}
    setlocal filetype=tex
endfunction

"  LaTeX conversion{{{2
"  Mapped to '<leader>L' - ORIGINAL FUNCTION PRESERVED
function! LaTeXconversion ()
    setlocal expandtab
    retab
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
        "HLsub
        execute '%s/\({.\{-}}\)/\\textcolor{lg}{\\{\1\\}}/g'
    catch
    endtry
"   try
"       "Escape "{"
"       execute '%s/{/\\{/g'
"   catch
"   endtry
"   try
"       "Escape "}"
"       execute '%s/}/\\}/g'
"   catch
"   endtry
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
        execute '%s/\(   \|\*\|^\)\([0-9.]\+\)\s/\1\\textcolor{v}{\2} /g'
    catch
    endtry
    try
        "HLmulti
        execute '%s/\(   \|\*\)+/\\s\\s\\s\\textcolor{v}{+}/g'
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
        execute "%s/\\(^\\| \\+\\|\\*\\{3,}\\)\\([A-ZÆØÅ_ -()/]\\{-2,}:\\) /\\1\\\\textcolor{b}{\\2} /g"
    catch
    endtry
    try
        "HLprop
        execute "%s/\\(^\\| \\+\\|\\*\\{3,}\\)\\([a-zA-ZæøåÆØÅ0-9,._&?%= -/+']\\+:\\) /\\1\\\\textcolor{r}{\\\\emph{\\2}} /g"
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
        "HLsc
        execute '%s/\(;\)/\\textcolor{g}{\1}/g'
    catch
    endtry
    try
        "ldots
        execute '%s/\.\.\./\\ldots /g'
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
    normal o\definecolor{lg}{rgb}{0,0.8,0}
    normal o\definecolor{b}{rgb}{0,0,0.5}
    normal o\definecolor{v}{rgb}{0.4,0,0.4}
    normal o\definecolor{t}{rgb}{0,0.4,0.4}
    normal o\definecolor{o}{rgb}{0.6,0.6,0}
    normal o\usepackage[margin=2cm]{geometry}
    normal o\usepackage[utf8]{inputenc}
    normal o\usepackage[english]{babel}
    normal o\usepackage[T1]{fontenc}
    normal o\usepackage{alltt}
    normal o\usepackage{fancyhdr}
    normal o\pagestyle{fancy}
    normal o\fancyhead[RO]{\raggedleft FIXME }
    normal o\fancyfoot{}
    normal o\usepackage{pdfpages}
    normal o
    normal o\begin{document}
    normal o\begin{alltt}
    "Document end
    normal Go\end{alltt}
    normal o\end{document}
    setlocal filetype=tex
endfunction

"  Enhanced HTML conversion{{{2
"  Modern HTML export with better formatting and CSS
function! HTMLConversionModern()
  try
    "Remove VIM tagline
    execute '%s/^vim:.*//g'
  catch
  endtry
  
  " Document structure and modern CSS
  normal ggO<!DOCTYPE html>
  normal o<html lang="en">
  normal o<head>
  normal o<meta charset="UTF-8">
  normal o<meta name="viewport" content="width=device-width, initial-scale=1.0">
  normal o<title>HyperList Export</title>
  normal o<style>
  normal obody { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; line-height: 1.6; margin: 2rem; background: #f9f9f9; }
  normal o.hyperlist { background: white; padding: 2rem; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); max-width: 900px; margin: 0 auto; }
  normal oh1 { color: #2c3e50; border-bottom: 3px solid #3498db; padding-bottom: 0.5rem; }
  normal o.hl-item { margin: 0.25rem 0; }
  normal o.hl-level-1 { margin-left: 0; }
  normal o.hl-level-2 { margin-left: 1.5rem; }
  normal o.hl-level-3 { margin-left: 3rem; }
  normal o.hl-level-4 { margin-left: 4.5rem; }
  normal o.hl-level-5 { margin-left: 6rem; }
  normal o.hl-operator { font-weight: bold; color: #2980b9; }
  normal o.hl-property { font-style: italic; color: #e74c3c; }
  normal o.hl-qualifier { background: #ecf0f1; padding: 2px 6px; border-radius: 3px; font-family: monospace; color: #27ae60; }
  normal o.hl-reference { color: #9b59b6; text-decoration: none; }
  normal o.hl-reference:hover { text-decoration: underline; }
  normal o.hl-hashtag { color: #f39c12; font-weight: 500; }
  normal o.hl-comment { color: #7f8c8d; font-style: italic; }
  normal o.hl-quote { color: #16a085; }
  normal o.hl-state { background: #e8f5e8; padding: 0.25rem 0.5rem; border-left: 4px solid #27ae60; }
  normal o.hl-transition { background: #fef9e7; padding: 0.25rem 0.5rem; border-left: 4px solid #f39c12; }
  normal o.hl-checkbox { font-family: monospace; font-weight: bold; }
  normal o.hl-checkbox.done { color: #27ae60; }
  normal o.hl-checkbox.progress { color: #f39c12; }
  normal o</style>
  normal o</head>
  normal o<body>
  normal o<div class="hyperlist">
  execute "normal oh1>HyperList Export - " . strftime('%Y-%m-%d') . "</h1>"
  
  try
    " Add semantic HTML structure
    execute '%s/^\([^[:space:]#].*\)$/<h2>\1<\/h2>/g'
    
    " Convert indentation to proper HTML structure with classes
    execute '%s/^\(\t\|\*\)\{1}\([^<]\)/  <div class="hl-item hl-level-1">\2<\/div>/g'
    execute '%s/^\(\t\|\*\)\{2}\([^<]\)/    <div class="hl-item hl-level-2">\2<\/div>/g'
    execute '%s/^\(\t\|\*\)\{3}\([^<]\)/      <div class="hl-item hl-level-3">\2<\/div>/g'
    execute '%s/^\(\t\|\*\)\{4}\([^<]\)/        <div class="hl-item hl-level-4">\2<\/div>/g'
    execute '%s/^\(\t\|\*\)\{5}\([^<]\)/          <div class="hl-item hl-level-5">\2<\/div>/g'
    
    "Enhanced styling for HyperList elements
    execute '%s/\(<.\{-}>\)/<a href="#" class="hl-reference">\1<\/a>/g'
    execute '%s/\(\".*\"\)/<span class="hl-quote">\1<\/span>/g'
    execute '%s/ \@<=\*\(.\{-}\)\* / <strong>\1<\/strong> /g'
    execute '%s/ \@<=\/\(.\{-}\)\/ /<em>\1<\/em>/g'
    execute '%s/ \@<=_\(.\{-}\)_ / <u>\1<\/u> /g'
    execute '%s/\((.*)\)/<span class="hl-comment">\1<\/span>/g'
    execute '%s/\(\[[^\]]*\]\)/<span class="hl-qualifier">\1<\/span>/g'
    execute '%s/\(#[a-zA-ZæøåÆØÅ0-9.:/_&?%=+\-\*]\+\)/<span class="hl-hashtag">\1<\/span>/g'
    
    " Enhanced checkbox styling
    execute '%s/\[_\]/<span class="hl-checkbox">☐<\/span>/g'
    execute '%s/\[x\]/<span class="hl-checkbox done">☑<\/span>/g'
    execute '%s/\[X\]/<span class="hl-checkbox done">☑<\/span>/g'
    execute '%s/\[O\]/<span class="hl-checkbox progress">⚬<\/span>/g'
    
    " States and Transitions with better styling
    execute '%s/^\(\s*\)<div class="\([^"]*\)">S: \(.*\)<\/div>/\1<div class="\2 hl-state"><strong>State:<\/strong> \3<\/div>/g'
    execute '%s/^\(\s*\)<div class="\([^"]*\)">T: \(.*\)<\/div>/\1<div class="\2 hl-transition"><strong>Action:<\/strong> \3<\/div>/g'
    execute '%s/^\(\s*\)<div class="\([^"]*\)">| \(.*\)<\/div>/\1<div class="\2 hl-state"><strong>State:<\/strong> \3<\/div>/g'
    execute '%s/^\(\s*\)<div class="\([^"]*\)">\/ \(.*\)<\/div>/\1<div class="\2 hl-transition"><strong>Action:<\/strong> \3<\/div>/g'
    
    " Operators and Properties
    execute '%s/\([A-ZÆØÅÁÉÓÚÃÕÂÊÔÇÀ_\-() /]\{2,}\):\s/<span class="hl-operator">\1:<\/span> /g'
    execute '%s/\([a-zA-ZæøåÆØÅ0-9,._&?%= \-\/+<>#'"'"'()]\{2,}\):\s/<span class="hl-property">\1:<\/span> /g'
    
  catch
  endtry
  
  " Close document
  normal Go</div>
  execute "normal o<footer style=\"text-align: center; margin-top: 2rem; color: #7f8c8d; font-size: 0.9rem;\">"
  execute "normal oGenerated by <a href=\"https://github.com/isene/hyperlist.vim\">HyperList.vim</a> on " . strftime('%Y-%m-%d %H:%M:%S')
  normal o</footer>
  normal o</body>
  normal o</html>
  
  setlocal filetype=html
endfunction

"  HTML conversion{{{2
"  Mapped to '<leader>H' - ORIGINAL FUNCTION PRESERVED
function! HTMLconversion ()
  try
    "Remove VIM tagline
    execute '%s/^vim:.*//g'
  catch
  endtry
  try
    "HLref
    execute '%s/\(<.\{-}>\)/<font color=Ŀ>\1<\/font>/g'
  catch
  endtry
  try
    "HLquote
    execute '%s/\(\".*\"\)/<font color="teal">\1<\/font>/g'
    execute '%s/Ŀ/"purple"/g'
  catch
  endtry
  try
    "first line of a HyperList is bold
    execute '%s/^\(\S.*\)$/<strong>\1<\/strong>/g'
  catch
  endtry
  try
    "HLb
    execute '%s/ \@<=\*\(.\{-}\)\* / <strong>\1<\/strong> /g'
  catch
  endtry
  try
    "HLi
    execute '%s/ \@<=\/\(.\{-}\)\/ /<em>\1<\/em>/g'
  catch
  endtry
  try
    "HLu
    execute '%s/ \@<=_\(.\{-}\)_ / <u>\1<\/u> /g'
  catch
  endtry
  try
    "HLcomment
    execute '%s/\((.*)\)/<font color="teal">\1<\/font>/g'
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
    execute '%s/\(#.\{-} \)/<font color="yellow">\1<\/font>/g'
  catch
  endtry
  try
    "HLmove
    execute '%s/\(>>\|<<\|->\|<-\)/<font color="red"><strong>\1</strong><\/font>/g'
  catch
  endtry
  try
    "HLsub
    execute '%s/\({.\{-}}\)/<font color="MediumAquaMarine">\1<\/font>/g'
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
    "Substitute newlines with <br />
    execute '%s/\n/<br \/>\r/g'
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
  setlocal filetype=html
endfunction

"  Markdown conversion{{{2
"  Modern export function for Markdown format
function! MarkdownConversion()
  try
    "Remove VIM tagline
    execute '%s/^vim:.*//g'
  catch
  endtry
  try
    "Convert HyperList elements to Markdown
    
    "Convert numbering to ordered lists (1. 2. etc)
    execute '%s/^\(\t\|\*\)*\([0-9]\+\)\. /\1\2. /g'
    
    "Convert indentation to Markdown list format
    execute '%s/^\(\t\|\*\)\{1}\([^0-9\t\*]\)/- \2/g'
    execute '%s/^\(\t\|\*\)\{2}\([^0-9\t\*]\)/  - \2/g'
    execute '%s/^\(\t\|\*\)\{3}\([^0-9\t\*]\)/    - \2/g'
    execute '%s/^\(\t\|\*\)\{4}\([^0-9\t\*]\)/      - \2/g'
    execute '%s/^\(\t\|\*\)\{5}\([^0-9\t\*]\)/        - \2/g'
    execute '%s/^\(\t\|\*\)\{6}\([^0-9\t\*]\)/          - \2/g'
    
    "Convert bold, italic, underline
    execute '%s/ \@<=\*\(.\{-}\)\* / **\1** /g'
    execute '%s/ \@<=\/\(.\{-}\)\/ / *\1* /g'
    execute '%s/ \@<=_\(.\{-}\)_ / _\1_ /g'
    
    "Convert hashtags to Markdown tags
    execute '%s/#\([a-zA-ZæøåÆØÅ0-9.:/_&?%=+\-\*]\+\)/#\1/g'
    
    "Convert references to Markdown links
    execute '%s/<\([^>]\+\)>/[\1](\1)/g'
    
    "Convert checkboxes to GitHub-style checkboxes
    execute '%s/\[_\]/- [ ]/g'
    execute '%s/\[x\]/- [x]/g'
    execute '%s/\[X\]/- [x]/g'
    execute '%s/\[O\]/- [o]/g'
    
    "Convert States and Transitions to bold headers
    execute '%s/^\(\s*\)S: \(.*\)/\1**State:** \2/g'
    execute '%s/^\(\s*\)T: \(.*\)/\1**Action:** \2/g'
    execute '%s/^\(\s*\)| \(.*\)/\1**State:** \2/g'
    execute '%s/^\(\s*\)\/ \(.*\)/\1**Action:** \2/g'
    
    "Convert Operators (ALL CAPS:) to bold
    execute '%s/^\(\s*\)\([A-ZÆØÅÁÉÓÚÃÕÂÊÔÇÀ_\-() /]\{2,}\):\s/\1**\2:** /g'
    
    "Convert Properties to emphasis
    execute '%s/^\(\s*\)\([a-zA-ZæøåÆØÅ0-9,._&?%= \-\/+<>#'"'"'()]\{2,}\):\s/\1*\2:* /g'
    
    "Convert Qualifiers [text] to code blocks
    execute '%s/\[\([^\]]\+\)\]/`\1`/g'
    
    "Convert Comments (text) to italic
    execute '%s/(\([^)]\+\))/*(\1)*/g'
    
    "Convert Quotes to proper Markdown quotes
    execute '%s/"\([^"]\+\)"/"\1"/g'
    
    "Handle multi-line indicators
    execute '%s/^\(\s*\)+ /\1\\\n/g'
    
    "Convert first line to H1 if it doesn't start with indentation
    execute '1s/^\([^[:space:]#]\+.*\)$/# \1/'
    
  catch
  endtry
  
  "Document metadata at top
  normal ggO---
  normal otitle: "HyperList Export"
  normal odate: 
  execute "normal oexported: " . strftime('%Y-%m-%d %H:%M:%S')
  normal osource: "HyperList.vim"
  normal o---
  normal o
  
  setlocal filetype=markdown
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
        execute '1s/^\(\S.*\)$/\r--title \1/'
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

command! -buffer -nargs=+  SHOW  :call <SID>ShowHideWord('c', 's', <f-args>)
command! -buffer -nargs=+  HIDE  :call <SID>ShowHideWord('c', 'h', <f-args>)

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

   let myfoldexpr = "setlocal foldexpr=getline(v:lnum)" .
      \ (a:show == 's' ? "!" : "=") . "~\'\^.*" . cur_word . ".*\$\'"

   setlocal foldenable
   setlocal foldlevel=0
   setlocal foldminlines=0
   setlocal foldmethod=expr
   exec myfoldexpr
endfunction

"  CalendarAdd{{{2
"  :call CalendarAdd() will take all items containing a future date and add them 
"  as reminder to your Google Calendar. If the item includes a time, the event 
"  is added from that time with duration of 30 minutes.
"  This function requires gcalcli (https://github.com/insanum/gcalcli)
"  The function is mapped to <leader>G to add events to the default
"  calendar - defined as g:calendar in your vimrc file.
"  To add the events to another calendar, do :call CalendarAdd("yourcalendar")
function! CalendarAdd(...)
  let l:count  = 0
  if exists("g:calendar")
    let l:ical = 0
    let l:cal  = a:0 > 0 ? a:1 : g:calendar
  else
    let l:ical = 1
    let l:cal  = ""
  endif
  let l:date   = strftime("%Y-%m-%d")
  let l:tm     = ""
  let l:linenr = 0 
  while l:linenr < line("$") 
    let l:linenr += 1
    let l:line = getline(l:linenr)
    let l:line = substitute(l:line, "\t", "", "g")
    if match(l:line,'\d\d\d\d-\d\d-\d\d') >= 0
      let l:dt = matchstr(l:line,'\d\d\d\d-\d\d-\d\d')
      if l:dt >= l:date || g:alldates == 1
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
        let l:start_line_number  = l:linenr
        let l:end_line_number    = l:start_line_number + 1
        let l:start_line_indent  = indent(l:start_line_number)
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
        if ical == 1
          let l:icaltext  = "BEGIN:VCALENDAR\n"
          let l:icaltext .= "VERSION:2.0\n"
          let l:icaltext .= "PRODID:-//HyperList//VIM HyperList Plugin v2.6//EN\n"
          let l:icaltext .= "CALSCALE:GREGORIAN\n"
          let l:icaltext .= "METHOD:PUBLISH\n"
          let l:icaltext .= "X-WR-CALNAME:HyperList Events\n"
          let l:icaltext .= "X-WR-TIMEZONE:UTC\n"
          let l:icaltext .= "X-WR-CALDESC:Events exported from HyperList\n"
          let l:icaltext .= "BEGIN:VEVENT\n"
          let l:icaltime  = strftime("%Y%m%dT%H%M%SZ")
          let l:icaltext .= "DTSTAMP:"     . l:icaltime . "\n"
          let l:icaltext .= "UID:"         . l:icaltime . "-" . l:count . "@hyperlist.vim\n"
          let l:icaltext .= "CREATED:"     . l:icaltime . "\n"
          let l:icaltext .= "LAST-MODIFIED:" . l:icaltime . "\n"
          let l:icaltext .= "SEQUENCE:0\n"
          let l:icaltext .= "STATUS:CONFIRMED\n"
          let l:icaltext .= "TRANSP:OPAQUE\n"
          
          " Clean up title and description for iCal format
          let l:clean_title = substitute(l:title, '\n', ' ', 'g')
          let l:clean_title = substitute(l:clean_title, '\r', '', 'g')
          let l:clean_desc = substitute(l:g_desc, '\n', '\\n', 'g')
          let l:clean_desc = substitute(l:clean_desc, '\r', '', 'g')
          
          let l:icaltext .= "SUMMARY:"     . l:clean_title   . "\n"
          let l:icaltext .= "DESCRIPTION:" . l:clean_desc   . "\n"
          
          " Add location if available (look for location: in the item)
          if match(l:g_desc, 'location:') >= 0
            let l:location = matchstr(l:g_desc, 'location:\s*\zs[^\n]*')
            let l:icaltext .= "LOCATION:"    . l:location . "\n"
          endif
          
          " Add categories based on hashtags
          let l:categories = ""
          let l:tag_matches = []
          let l:start = 0
          while 1
            let l:match_pos = match(l:g_desc, '#\w\+', l:start)
            if l:match_pos == -1 | break | endif
            let l:match_end = matchend(l:g_desc, '#\w\+', l:start)
            let l:tag = l:g_desc[l:match_pos+1:l:match_end-1]
            if index(l:tag_matches, l:tag) == -1
              call add(l:tag_matches, l:tag)
            endif
            let l:start = l:match_end
          endwhile
          if len(l:tag_matches) > 0
            let l:icaltext .= "CATEGORIES:" . join(l:tag_matches, ',') . "\n"
          endif
          
          let l:icaldt    = substitute(l:dt, '-', "", "g")
          if l:tm != ""
            let l:tmh       = str2nr(l:tm[1:2])
            let l:tmm       = str2nr(l:tm[4:5])
            let l:icaltext .= "DTSTART:"     . l:icaldt . "T" . printf("%02d%02d", l:tmh, l:tmm) . "00Z\n"
            let l:tmm  += 30
            if l:tmm >= 60
              let l:tmm -= 60
              let l:tmh += 1
              if l:tmh >= 24
                let l:tmh = 0
              endif
            endif
            let l:icaltext .= "DTEND:"       . l:icaldt . "T" . printf("%02d%02d", l:tmh, l:tmm) . "00Z\n"
          else
            " All-day event
            let l:icaltext .= "DTSTART;VALUE=DATE:" . l:icaldt . "\n"
            let l:next_day = strftime("%Y%m%d", strptime(l:dt, "%Y-%m-%d") + 86400)
            let l:icaltext .= "DTEND;VALUE=DATE:" . l:next_day . "\n"
          endif
          
          let l:icaltext .= "END:VEVENT\n"
          let l:icaltext .= "END:VCALENDAR\n"
          let l:icalfile  = strftime("%Y-%m-%d_%H%M_") . l:count . ".ics"
          call writefile(split(l:icaltext, "\n"), l:icalfile)
        else
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
          let l:gcalcli   = "gcalcli add --where '' --duration 30 --reminder 0" . l:g_cal . l:g_title . l:created . l:g_when . l:g_desc
          echo l:gcalcli
          call system(l:gcalcli)
        endif
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
"  :call Complexity() will show the complexity score for your HyperList (mapped to <leader>C)
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
syn match   HLqual '\[.\{-}\]' contains=HLtodo,HLref,HLcomment

" Substitutions are enclosed within { }
syn match   HLsub  '{.\{-}}' contains=HLtodo,HLref,HLcomment

" Performance-optimized syntax patterns
if s:is_large_file
  " Simplified patterns for large files - reduce character class complexity
  syn match   HLtag	'\(^\|\s*\)\@<=[a-zA-Z0-9,._&?!%= \-\/+:]\{-2,}:\s' contains=HLtodo,HLcomment,HLquote,HLref
  syn match   HLop	'\(^\|\s*\)\@<=[A-Z_\-() /]\{-2,}:\s' contains=HLcomment,HLquote
else
  " Full patterns for smaller files
  syn match   HLtag	'\(^\|\s*\|\**\)\@<=[a-zA-ZæøåÆØÅáéóúãõâêôçàÁÉÓÚÃÕÂÊÔÇÀü0-9,._&?!%= \-\/+<>#'"()\*:]\{-2,}:\s' contains=HLtodo,HLcomment,HLquote,HLref
  syn match   HLop	'\(^\|\s*\|\**\)\@<=[A-ZÆØÅÁÉÓÚÃÕÂÊÔÇÀ_\-() /]\{-2,}:\s' contains=HLcomment,HLquote
endif

" Mark semicolon as stringing together lines
syn match   HLsc	';'

" Hashtags (like Twitter)
syn match   HLhash	'#[a-zA-ZæøåÆØÅáéóúãõâêôçàÁÉÓÚÃÕÂÊÔÇÀü0-9.:/_&?%=+\-\*]\+'

" References
syn match   HLref	'<\{1,2}[a-zA-ZæøåÆØÅáéóúãõâêôçàÁÉÓÚÃÕÂÊÔÇÀü0-9,.:/ _~&@?%=\+\-\*#]\+>\{1,2}' contains=HLcomment

" Reserved key words
syn keyword HLkey     END SKIP

" Marking literal start and end (a whole literal region is folded as one block)
syn match   HLlit       '\(\s\|\*\)\@<=\\$'

" Content of litaral (with no syntax highlighting)
syn match   HLlc        '\(\s\|\*\)\\\_.\{-}\(\s\|\*\)\\' contains=HLlit

" Comments are enclosed within ( )
syn match   HLcomment   '(.\{-})' contains=HLtodo,HLref,HLhash

" Text in quotation marks
syn match   HLquote     '".\{-}"' contains=HLtodo,HLref,HLhash

" TODO  or FIXME
syn keyword HLtodo    TODO FIXME 

" Item motion (uncomment if you want this syntax feature)
"syn match   HLmove      '>>\|<<\|->\|<-'

" Bold and Italic
syn match   HLb	        '\(\t\| \)\@<=\*.\{-}\*\($\| \)\@='
syn match   HLi	        '\(\t\| \)\@<=/.\{-}/\($\| \)\@='
syn match   HLu	        '\(\t\| \)\@<=_.\{-}_\($\| \)\@='

" Cluster the above
syn cluster HLtxt contains=HLident,HLmulti,HLop,HLqual,HLsub,HLtag,HLhash,HLref,HLkey,HLlit,HLlc,HLcomment,HLquote,HLsc,HLtodo,HLmove,HLb,HLi,HLu,HLstate,HLtrans,HLdim0,HLdim1

"  HyperList indentation (folding levels) {{{2
"  Performance optimization: Dynamic folding based on file size
if !exists("g:disable_collapse")
  " Use pre-calculated values from initialization
  let s:fold_levels = exists("g:hyperlist_max_fold_levels") ? g:hyperlist_max_fold_levels : s:max_fold_levels
  
  " Fast folding for large files
  if s:is_large_file
    let s:fold_levels = min([s:fold_levels, 6])  " Even more aggressive for large files
  endif
  
  " Generate folding regions based on calculated levels
  if s:fold_levels >= 15
    syn region L15 start="^\(\t\|\*\)\{14} \=\S" end="^\(^\(\t\|\*\)\{15,} \=\S\)\@!" fold contains=@HLtxt
  endif
  if s:fold_levels >= 14
    syn region L14 start="^\(\t\|\*\)\{13} \=\S" end="^\(^\(\t\|\*\)\{14,} \=\S\)\@!" fold contains=@HLtxt,L15
  endif
  if s:fold_levels >= 13
    syn region L13 start="^\(\t\|\*\)\{12} \=\S" end="^\(^\(\t\|\*\)\{13,} \=\S\)\@!" fold contains=@HLtxt,L14,L15
  endif
  if s:fold_levels >= 12
    syn region L12 start="^\(\t\|\*\)\{11} \=\S" end="^\(^\(\t\|\*\)\{12,} \=\S\)\@!" fold contains=@HLtxt,L13,L14,L15
  endif
  if s:fold_levels >= 11
    syn region L11 start="^\(\t\|\*\)\{10} \=\S" end="^\(^\(\t\|\*\)\{11,} \=\S\)\@!" fold contains=@HLtxt,L12,L13,L14,L15
  endif
  if s:fold_levels >= 10
    syn region L10 start="^\(\t\|\*\)\{9} \=\S"  end="^\(^\(\t\|\*\)\{10,} \=\S\)\@!" fold contains=@HLtxt,L11,L12,L13,L14,L15
  endif
  if s:fold_levels >= 9
    syn region L9 start="^\(\t\|\*\)\{8} \=\S"   end="^\(^\(\t\|\*\)\{9,} \=\S\)\@!"  fold contains=@HLtxt,L10,L11,L12,L13,L14,L15
  endif
  if s:fold_levels >= 8
    syn region L8 start="^\(\t\|\*\)\{7} \=\S"   end="^\(^\(\t\|\*\)\{8,} \=\S\)\@!"  fold contains=@HLtxt,L9,L10,L11,L12,L13,L14,L15
  endif
  if s:fold_levels >= 7
    syn region L7 start="^\(\t\|\*\)\{6} \=\S"   end="^\(^\(\t\|\*\)\{7,} \=\S\)\@!"  fold contains=@HLtxt,L8,L9,L10,L11,L12,L13,L14,L15
  endif
  if s:fold_levels >= 6
    syn region L6 start="^\(\t\|\*\)\{5} \=\S"   end="^\(^\(\t\|\*\)\{6,} \=\S\)\@!"  fold contains=@HLtxt,L7,L8,L9,L10,L11,L12,L13,L14,L15
  endif
  if s:fold_levels >= 5
    syn region L5 start="^\(\t\|\*\)\{4} \=\S"   end="^\(^\(\t\|\*\)\{5,} \=\S\)\@!"  fold contains=@HLtxt,L6,L7,L8,L9,L10,L11,L12,L13,L14,L15
  endif
  if s:fold_levels >= 4
    syn region L4 start="^\(\t\|\*\)\{3} \=\S"   end="^\(^\(\t\|\*\)\{4,} \=\S\)\@!"  fold contains=@HLtxt,L5,L6,L7,L8,L9,L10,L11,L12,L13,L14,L15
  endif
  if s:fold_levels >= 3
    syn region L3 start="^\(\t\|\*\)\{2} \=\S"   end="^\(^\(\t\|\*\)\{3,} \=\S\)\@!"  fold contains=@HLtxt,L4,L5,L6,L7,L8,L9,L10,L11,L12,L13,L14,L15
  endif
  if s:fold_levels >= 2
    syn region L2 start="^\(\t\|\*\)\{1} \=\S"   end="^\(^\(\t\|\*\)\{2,} \=\S\)\@!"  fold contains=@HLtxt,L3,L4,L5,L6,L7,L8,L9,L10,L11,L12,L13,L14,L15
  endif
  if s:fold_levels >= 1
    syn region L1 start="^\(\t\|\*\)\{0} \=\S"   end="^\(^\(\t\|\*\)\{1,} \=\S\)\@!"  fold contains=@HLtxt,L2,L3,L4,L5,L6,L7,L8,L9,L10,L11,L12,L13,L14,L15
  endif
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
hi          HLsub 	  ctermfg=157     guifg=LightGreen
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

noremap <leader>0         :setlocal foldlevel=0<CR>
noremap <leader>1         :setlocal foldlevel=1<CR>
noremap <leader>2         :setlocal foldlevel=2<CR>
noremap <leader>3         :setlocal foldlevel=3<CR>
noremap <leader>4         :setlocal foldlevel=4<CR>
noremap <leader>5         :setlocal foldlevel=5<CR>
noremap <leader>6         :setlocal foldlevel=6<CR>
noremap <leader>7         :setlocal foldlevel=7<CR>
noremap <leader>8         :setlocal foldlevel=8<CR>
noremap <leader>9         :setlocal foldlevel=9<CR>
noremap <leader>a         :setlocal foldlevel=10<CR>
noremap <leader>b         :setlocal foldlevel=11<CR>
noremap <leader>c         :setlocal foldlevel=12<CR>
noremap <leader>d         :setlocal foldlevel=13<CR>
noremap <leader>e         :setlocal foldlevel=14<CR>
noremap <leader>f         :setlocal foldlevel=15<CR>
noremap <NUL>             zA
noremap <SPACE>           za
nnoremap zx               i<esc>

noremap <leader>u         :call STunderline()<CR>

noremap <leader>v	        :call CheckItem("")<CR>
noremap <leader>V         :call CheckItem("stamped")<CR>
nnoremap <leader>o        :call CheckItem("inprogress")<CR>

noremap <leader><SPACE>   /=\s*$<CR>A

nnoremap gr		            :call GotoRef()<CR>
nnoremap <CR>	            :call GotoRef()<CR>

nnoremap gf               :call OpenFile()<CR>

nmap g<DOWN>          <DOWN><leader>0zv
nmap g<UP>            <leader>f<UP><leader>0zv

nmap <leader><DOWN>   <DOWN><leader>0zv<SPACE>zO
nmap <leader><UP>     <leader>f<UP><leader>0zv<SPACE>zO

nnoremap <leader>z        :call HLencryptLine()<CR>
vnoremap <leader>z        :call HLencryptVisual()<CR>
nnoremap <leader>Z        :call HLencryptAll()<CR>
nnoremap <leader>x        :call HLdecryptLine()<CR>
vnoremap <leader>x        :call HLdecryptVisual()<CR>
nnoremap <leader>X        :call HLdecryptAll()<CR>

nnoremap <leader>L        :call LaTeXconversion()<CR>
nnoremap <leader>H        :call HTMLconversion()<CR>
nnoremap <leader>T        :call TPPconversion()<CR>
nnoremap <leader>M        :call MarkdownConversion()<CR>

nnoremap <leader>h        :call HighLight()<CR>
nnoremap <leader>an       :call ToggleAutonum()<CR>
nnoremap <leader>#        :call ToggleAutonum()<CR>
vnoremap <leader>R        :call Renumber()<CR>

noremap  <silent> zs      :call <SID>ShowHideWord('z', 's', '')<CR>
noremap  <silent> zh      :call <SID>ShowHideWord('z', 'h', '')<CR>
noremap  <silent> z0      :setlocal foldmethod=syntax<CR><bar>:echo "ShowHide Remove"<CR>

nnoremap <leader>G        :call CalendarAdd()<CR>

nnoremap <leader>C        :call Complexity()<CR>

" Sort hack (sort the visual selected lines by the top item's indentation
" The last item in the visual selection cannot be the last line in the document.
vnoremap <leader>s <esc>`<^"iy0gv:s/^<c-r>i\S\@=/<c-v><c-a>/<cr>gv:s/\t/<c-v><c-b>/g<cr>gv:s/\n<c-v><c-b>/<c-v><c-x>/<cr>gvk:!sort<cr>:%s/<c-v><c-a>/<c-r>i/<cr>:%s/<c-v><c-x>/\r<c-v><c-b>/g<cr>:%s/<c-v><c-b>/\t/g<cr>

" Modern feature keybindings (optional) {{{2
" Users can add these to their config to enable modern features
" 
" Example mappings for modern features:
" nnoremap <leader>p        :call <SID>preview_reference()<CR>
" nnoremap <leader>gm       :call GotoRefModern()<CR>
" inoremap <C-Space>        <C-o>:call InsertHyperListCompletion()<CR>
" nnoremap <leader>fb       :call ShowHyperListBreadcrumb()<CR>
" nnoremap <leader>fc       :call SmartFoldContext()<CR>
" nnoremap <leader>fq       :call ExportItemToQuickfix()<CR>
" nnoremap <leader>ft       :call TelescopeHyperListItems()<CR>
" nnoremap <leader>fr       :call TelescopeHyperListReferences()<CR>
"
" Quick item insertion:
" nnoremap <leader>it       :call InsertHyperListItem('todo')<CR>
" nnoremap <leader>id       :call InsertHyperListItem('done')<CR>
" nnoremap <leader>ip       :call InsertHyperListItem('inprogress')<CR>
" nnoremap <leader>is       :call InsertHyperListItem('state')<CR>
" nnoremap <leader>iT       :call InsertHyperListItem('transition')<CR>
" nnoremap <leader>ir       :call InsertHyperListItem('reference')<CR>
" nnoremap <leader>ic       :call InsertHyperListItem('comment')<CR>
" nnoremap <leader>ih       :call InsertHyperListItem('hash')<CR>
"
" Modern export functions:
nnoremap <leader>eM       :call MarkdownConversion()<CR>
nnoremap <leader>eH       :call HTMLConversionModern()<CR>
nnoremap <leader>eL       :call LaTeXConversionModern()<CR>
nnoremap <leader>eT       :call TPPconversion()<CR>

" GVIM menu {{{1
let s:HL_RootMenu  = 'HyperList.'
exe 'menu '.s:HL_RootMenu.'HyperList <Nop>'
exe 'menu '.s:HL_RootMenu.'-Sep00-  <Nop>'
menu HyperList.Toggle\ fold<Tab>SPACE              za
menu HyperList.Set\ fold\ level.0<Tab>\\0          :setlocal foldlevel=0<CR>
menu HyperList.Set\ fold\ level.1<Tab>\\1          :setlocal foldlevel=1<CR>
menu HyperList.Set\ fold\ level.2<Tab>\\2          :setlocal foldlevel=2<CR>
menu HyperList.Set\ fold\ level.3<Tab>\\3          :setlocal foldlevel=3<CR>
menu HyperList.Set\ fold\ level.4<Tab>\\4          :setlocal foldlevel=4<CR>
menu HyperList.Set\ fold\ level.5<Tab>\\5          :setlocal foldlevel=5<CR>
menu HyperList.Set\ fold\ level.6<Tab>\\6          :setlocal foldlevel=6<CR>
menu HyperList.Set\ fold\ level.7<Tab>\\7          :setlocal foldlevel=7<CR>
menu HyperList.Set\ fold\ level.8<Tab>\\8          :setlocal foldlevel=8<CR>
menu HyperList.Set\ fold\ level.9<Tab>\\9          :setlocal foldlevel=9<CR>
menu HyperList.Set\ fold\ level.10<Tab>\\a         :setlocal foldlevel=10<CR>
menu HyperList.Set\ fold\ level.11<Tab>\\b         :setlocal foldlevel=11<CR>
menu HyperList.Set\ fold\ level.12<Tab>\\c         :setlocal foldlevel=12<CR>
menu HyperList.Set\ fold\ level.13<Tab>\\d         :setlocal foldlevel=13<CR>
menu HyperList.Set\ fold\ level.14<Tab>\\e         :setlocal foldlevel=14<CR>
menu HyperList.Set\ fold\ level.15<Tab>\\f         :setlocal foldlevel=15<CR>
menu HyperList.Toggle\ State/Transition<Tab>\\u    :call STunderline()<CR>
menu HyperList.Checklist.Toggle<Tab>\\v            :call CheckItem("")<CR>
menu HyperList.Checklist.Timestamp<Tab>\\V         :call CheckItem("stamped")<CR>
menu HyperList.Goto\ reference<Tab>gr              :call GotoRef()<CR>
menu HyperList.Open\ file\ under\ cursor<Tab>gf    :call OpenFile()<CR>
menu HyperList.Show/Hide.Show\ Word\ under\ Cursor<Tab>zs :call <SID>ShowHideWord('z', 's', '')<CR>
menu HyperList.Show/Hide.Hide\ Word\ under\ Cursor<Tab>zh :call <SID>ShowHideWord('z', 'h', '')<CR>
menu HyperList.Show/Hide.Remove\ Show/Hide<Tab>z0  :setlocal foldmethod=syntax<CR><bar>:echo "ShowHide Remove"<CR>
menu HyperList.Autonumber.Toggle<Tab>\\an          :call ToggleAutonum()<CR>
vmenu HyperList.Autonumber.Renumber\ visual\ selection<Tab>\\R :call Renumber()<CR>
menu HyperList.Next\ Template\ Item<Tab>\\SPACE    /=\s*$<CR>A<CR>
menu HyperList.Highlight\ Toggle<Tab>\\h           :call HighLight()<CR>
menu HyperList.Presentation\ Move\ Down<Tab>gDOWN  <DOWN><leader>0zv
menu HyperList.Presentation\ Move\ Up<Tab>gUP      <leader>f<UP><leader>0zv
menu HyperList.Encryption\ (Requires\ OpenSSL).Encrypt<Tab>\\z :call HLencryptLine()<CR>
vmenu HyperList.Encryption\ (Requires\ OpenSSL).Encrypt\ Visual\ Selection<Tab>\\z :call HLencryptVisual()<CR>
menu HyperList.Encryption\ (Requires\ OpenSSL).Encrypt\ All<Tab>\\Z :call HLencryptAll()<CR>
menu HyperList.Encryption\ (Requires\ OpenSSL).Decrypt<Tab>\\x :call HLdecryptLine()<CR>
vmenu HyperList.Encryption\ (Requires\ OpenSSL).Decrypt\ Visual\ Selection<Tab>\\x :call HLdecryptVisual()<CR>
menu HyperList.Encryption\ (Requires\ OpenSSL).Decrypt\ All<Tab>\\X :call HLdecryptAll()<CR>
menu HyperList.Conversion.HTML<Tab>\\H             :call HTMLconversion()<CR>
menu HyperList.Conversion.LaTeX<Tab>\\L            :call LaTeXconversion()<CR>
menu HyperList.Conversion.TPP<Tab>\\T              :call TPPconversion()<CR>
menu HyperList.Add\ Calendar\ Events\ (Requires\ gcalcli)<Tab>\\G :call CalendarAdd()<CR>
menu HyperList.Show\ Complexity\ of\ List<Tab>:call\ Complexity() :call Complexity()<CR>

" vim modeline {{{1
" vim: set sw=2 sts=2 et fdm=marker fcs=fold\:\ :
doc/hyperlist.txt	[[[1
1634
*hyperlist.txt*   The VIM plugin for HyperList (version 2.6.2, 2025-07-23)
 
HyperList is a way to describe anything - any state, item(s), pattern, action,
process, transition, program, instruction set etc. So, you can use it as an
outliner, a ToDo list handler, a process design tool, a data modeler, or any
other way you want to describe something.

This VIM plugin makes it easy to work with HyperLists. It has a vast range of
features - from (un)collapsing whole or parts of lists, autonumbering of items,
checkbox toggling, jumping to referenced items... to encryption, presentation 
modes, export to various formats, automatically transferring of items tagged
with future events to a Google calendar... and many more sexy features.

The VIM plugin version numbers correspond to the HyperList definition version
numbers with the VIM plugin adding another increment of versioning, e.g VIM
plugin version 2.6.0 would be compatible with HyperList definition version 2.6.

This documentation contains the full HyperList definition. For a more
comprehensive manual that also includes plenty of examples, read the official
definition document:

	http://isene.org/hyperlist/

Here you will also find HyperGraph - a Ruby script to graph both State
HyperLists (like mindmaps) and Transitions Hyperlists (like flowcharts).

HyperList was formerly known as WOIM. The ftdetect file contains the file
suffix ".woim" for backward compatability so that these file types are also
treated as HyperList files.

==============================================================================
CONTENTS                                                  *HyperList-Contents*

    1 HyperList VIM Plugin....................|HyperList-Plugin|
    1.1 Modern Vim/Neovim Features............|HyperList-Modern|
    2 Background and definition...............|HyperList-Background|
		3 HyperLists..............................|HyperLists|
		4 HyperList Items.........................|HyperList-Item|
		4.1 Starter...............................|HyperList-Starter|
		4.2 Type..................................|HyperList-Type|
		4.3 Content...............................|HyperList-Content|
		4.3.1 Elements............................|HyperList-Elements|
		4.3.1.1 Operator..........................|HyperList-Operator|
		4.3.1.2 Qualifier.........................|HyperList-Qualifier|
		4.3.1.3 Substitution......................|HyperList-Substitution|
		4.3.1.4 Property..........................|HyperList-Property|
		4.3.1.5 Description.......................|HyperList-Description|
		4.3.2 Additives...........................|HyperList-Additives|
		4.3.2.1 References........................|HyperList-References|
		4.3.2.2 Tags..............................|HyperList-Tags|
		4.3.2.3 Comments..........................|HyperList-Comments|
		4.3.2.4 Quotes............................|HyperList-Quotes|
		4.3.2.5 Change Markup.....................|HyperList-ChangeMarkup|
		4.4 Separator.............................|HyperList-Separator|
		5 A self-defining system..................|HyperList-Self-definition|
    6 About...................................|HyperList-About|
    7 Changelog...............................|HyperList-Changelog|
    8 Credits.................................|HyperList-Credits|
    9 License.................................|HyperList-License|

==============================================================================
1 HyperList VIM Plugin                                      *HyperList-Plugin*

One of the most feature rich VIM plugins ever created.

This plugin does both highlighting and various automatic handling of
HyperLists, like collapsing lists or parts of lists in a sophisticated way. 
It includes encryption functionality.

The HyperList plugin for VIM consists of the main file put in the "syntax"
subdirectory.  It also includes a file in the "ftdetect" directory so that
files with a ".hl" extension is automatically detected and treated as a
HyperList file.

For a complete tutorial, go through the file HyperListTutorialAndTestSuite.hl
in the documentation folder (~/.vim/doc/HyperListTutorialAndTestSuite.hl).
This file also serves as a complete test suite for releases of this plugin.


WHEN WORKING WITH HYPERLISTS IN VIM:

Use tabs/shifts or * for indentations.

Use <SPACE> to toggle one fold. Use <c-SPACE> to toggle a fold recursively.
Use \0 to \9, \a, \b, \c, \d, \e, \f to show up to 15 levels expanded.

<leader># or <leader>an toggles autonumbering of new items (the previous
item must be numbered for the next item to be autonumbered). An item is
indented to the right with <c-t>, adding one level of numbering. An item
is indented to the left with <c-d>, removing one level of numbering and
increasing the number by one.

To number or renumber a set of items, select them visually (using V in VIM)
and press <leader>R. If the items are not previously numbered, they will now
be numbered from 1 and onward. Only items with the same indentation as the
first selected line will be numbered. If the first item is already numbered
(such as 1.2.6), the remaining items within the selection (with the same
indentation) will be numbered accordingly (such as 1.2.7, 1.2.8, etc.).

Use <leader>u to toggle underlining of States (prefixed with "S: " or "| "),
Transitions (prefixed with "T: " or "/ ") or underline nothing.

Use <leader>v to add a checkbox at start of item or to toggle a checkbox
Use <leader>V to add/toggle a checkbox with a date stamp for completion
Use <leader>o to mark an item as 'in progress' (seen as '[O] My Item')

Use "gr" (without the quotation marks, signifies "Goto Ref") or simply press
the "Enter" ("<CR>") key while the cursor is on a HyperList reference to jump
to that destination in a HyperList. Use "n" after a "gr" to verify that the
reference destination is unique. A reference can be to an Item in the list or 
to a file by the use of <file:/pathto/filename>, <file:~/filename> or 
<file:filename>. It can also be a relative reference like <-5> which would
mean "jump five lines up" or <+2> ("jump two lines down").

Use "gf" to open the file under the cursor. Graphic files are opened in
"feh", pdf files in "zathura" and MS/OOO docs in "LibreOffice". Other
filetypes are opened in VIM for editing. All this can be changed by
setting these global variables in your vimrc:
  let g:wordprocessingprogram = ""
  let g:spreadsheetprogram    = ""
  let g:presentationprogram   = ""
  let g:imageprogram          = ""
  let g:pdfprogram            = ""
  let g:browserprogram        = ""

Whenever you jump to a reference, the mark "'" is set at the point you jumped
from so that you may easily jump back by hitting "''" (single quoutes twice). 

Use <leader><SPACE> to go to the next open template element
(A template element is a HyperList item ending in an equal sign).

As a sort of "presentation mode", you can traverse a HyperList by using
g<DOWN> or g<UP> to view only the current line and its ancestors.
An alternative is <leader><DOWN> and <leader><UP> to open more levels down.

To highlight the current part of a HyperList (the current item and all its
children), press <leader>h. This will uncollapse the whole HyperList and dim
the whole HyperList except the current item and its children. To remove the
highlighting, simply press <leader>h again (the fold level is restored).

Use <leader>L to convert the entire document to LaTaX.

The LaTeX conversion includes color coding of the various elements similar to
the colors used for HyperList files within VIM.

Use <leader>H to convert the entire document to HTML.

The HTML conversion includes color coding of the various elements similar to
the colors used for HyperList files within VIM.

Use <leader>T to convert the entire document to a basic TPP presentation file.

Top level of the HyperList will become the presentation header. First indented
level will become headers on a new page. Other indented levels will be
preserved.  No HyperList coloring will be done. Bold, italics and underlined
parts of the HyperList will be preserved.

See https://github.com/cbbrowne/tpp for information on TPP (Text Presentation Program)

Use <leader>M to convert the entire document to Markdown format.

The Markdown conversion creates GitHub-flavored markdown with proper handling
of HyperList elements, checkboxes, and nested lists.

Modern Export Commands (Enhanced versions):
<leader>eL - Export to LaTeX with modern packages and enhanced styling
<leader>eH - Export to HTML with responsive design and modern CSS
<leader>eM - Export to Markdown (same as <leader>M)
<leader>eT - Export to TPP presentation (same as <leader>T)

Use <leader>z to encrypt the current line (including all sublevels if folded).
Use <leader>Z to encrypt the current file (all lines).
Use <leader>x to decrypt the current line (mark all subsequent encrypted lines).
Use <leader>X to decrypt the current file (all lines).

If you enter the wrong password while trying to decrypt, you will end up with
garbage characters. To fix it, press "u" (undo) and try decrypting again with
the correct password.

If you want a HyperList to be automatically encrypted upon saving and decrypted
upon opening it, just prefix the filename with a dot (like ".password.hl"). It
then turns off viminfo and swapfiles to ensure security.

When using encryption in a HyperList or for the whole file, you will be asked
for a password - twice when saving the file and once when opening it. You must
have OpenSSL in your path to take advantage of these features.

When running gVIM under Windows, encryption will spawn a DOS window where you
enter the password for encryption/decryption. This window may be hidden under
other windows.

Syntax updated at start and every time you leave Insert mode, or you can press
"zx" to update the syntax. 

You may speed up larger HyperListS by setting the the global variable
"disable_collapse" - add the following to your .vimrc:

  let g:disable_collapse = 1

If you want to disable or override these keymaps with your own, simply add
to your .vimrc file:

  let g:HLDisableMapping = 1

To use HyperLists within other file types (other than ".hl"), you can use
"nested syntax" by adding the following to those syntax files (like the syntax
file for text files (".txt"):

  syn include @HL ~/.vim/syntax/hyperlist.vim
  syn region HLSnip matchgroup=Snip start="HLstart" end="HLend" contains=@HL
  hi link Snip SpecialComment

If you add those three lines in your .vim/syntax/txt.vim you will be able to
include HyperLists in files with a ".txt", and the following example would
become a HyperList with correct syntax highlighting and folding:

HLstart
This is a HyperList test list
	Here is a child to the above item
		Here is "grand child"
	Here we are one level back
		And here's another level down
		[5] Dance steps
		[3] Hurray
		Smile
HLend

The "HLstart" and "HLend" must be at the start of the line.

You can show/hide words or regex patterns by using these keys and commands:

	zs    Show all lines containing word under cursor
	zh    Hide all lines containing word under cursor
	z0    Go back to normal HyperList folding
	:SHOW word/pattern
			Show lines containing either word or pattern
	:HIDE word/pattern
			Hide lines containing either word or pattern
			Pattern can be any regular expression

This functionality is useful for easily showing e.g. a specific tag or hash. 
The functionality is taken from VIM script #1594 (thanks to Amit Sethi).

To sort a set of items at a specific indentation, visually select (V) the
items you want to sort (including all the children of those items) and press
<leader>s and the items in the range will be alphabetically sorted - but only
the items on the same level/indentation as the first item selected. The sorted
items will keep their children. This is useful if parts of a HyperList is 
numbered and you get the numbering out of sequence and wants to resort them.
One caveat, the last line in the selection cannot be the very last line in
the document (there must be an item or an empty line below it).

You can add item tagged with future dates as items in your Google calendar.
Use <leader>G to automatically add all items with future dates to your default
calendar. This requires gcalcli (https://github.com/insanum/gcalcli). Your
default calendar is set in your .vimrc: let g:calendar = "yourcalendar"
If this variable is not found in your .vimrc, a set of icalendar files will be
written to your working directory. If you also want past events added to your 
calendar, add this to your .vimrc: let g:alldates = 1

To add the events to another calendar, do :call CalendarAdd("yourothercalendar").

The title of the calendar is the item in the HyperList without the date/time tag.
If there is no time tag for the item, an event is created at the start of the date.
If there is a time tag for the item, the event is created at that time with the
default duration (30 minutes). The description for the event is the item and all
its child items.

If you want to know the overall complexity of a HyperList, use <leader>C
The score shown is the total of Items and References in your HyperList.

GVIM users can enjoy a menu with most of the commands organized in submenus.

MODERN VIM/NEOVIM FEATURES (Version 2.6.1+)               *HyperList-Modern*

For users with modern Vim/Neovim installations, additional features are available:

Floating Window Reference Previews (Neovim 0.4+):
When hovering over references, a floating window can show preview content.
Enable with: let g:hyperlist_enable_floating_windows = 1

LSP-style Completion:
Context-aware completion for references, tags, and HyperList elements.
Enabled by default, disable with: let g:hyperlist_enable_lsp_completion = 0

Telescope Integration (if Telescope.nvim is available):
Enhanced navigation through large HyperLists using fuzzy search.
Access via :Telescope hyperlist_items

Breadcrumb Navigation:
Shows current position in nested structures.
Use :call ShowHyperListBreadcrumb() or add to statusline.

Enhanced Export Functions:
- ExportToMarkdown() - GitHub-flavored Markdown export  
- Enhanced HTML export with modern responsive CSS themes
- Improved LaTeX export with modern packages
- Better iCal export with metadata from hashtags

All modern features are backward compatible and optional. Original functions
and keybindings remain unchanged. See VERSION 2.6.1 changelog for details.

==============================================================================
2 Background and definition                             *HyperList-Background*

Having worked extensively with flowcharts, relations diagrams, Warnier-Orr
diagrams and other ways of representing processes, states, instructions,
programs and data models, I knew there was something missing. It would have
been great to have a way of representing anything -- any state or action -- in
a way that would be more conducive to collaboration.

Most people know about flowcharts. But there are other ways of representing
data, states, actions or processes: UML, Sankey diagrams, Decision trees, Petri
Net, Organizational charts, Mind maps, Process Flow diagrams, Feynman diagrams,
Data Flow diagrams, Concept maps, OBASHI, Task lists (or Todo lists),
Warnier/Orr diagrams and various other diagrams. More than we can list here.
They have various uses, various strengths and shortcomings.

Most methodologies for representing states or flows were born out of specific
needs and were not meant to be used as generic methods for representing
literally anything as simple as possible. What if there were a way to represent
any state, set of things, actions, flows or transitions? What if the method
were simple? What if it were also Turing complete?

Enter HyperList -- a system for representing data. Any data. Static or dynamic.
It can be used to describe any state: a thing or set of things, an area, a
concept or collection of concepts, etc. It can also be used to describe any
action or plan, transformation or transition. In fact, it can describe anything
-- with one complete markup set. HyperList can be be used as an outliner on
steroids or a todo-list managing system with unlimited possibilities.

After searching for a complete markup methodology for both states or things and
actions or transitions, I came across the Warnier/Orr diagrams. They seemed to
be the best foundation for what I needed. The methodology was expanded to be
capable of describing anything as easily as possible; I removed the graphical
parts of Warnier/Orr and expanded the system substantially. It turned into WOIM
(Warnier/Orr/Isene/Möller) and later got the more descriptive name of
HyperList. Egil Möller (http://redhog.org/) helped in the early refinements.

Besides being the name of the system, "HyperList" is also used when referring
to a list or lists conforming to this system.

The strengths of HyperList are many:

 * can represent any state or action with any number of levels
 * Turing complete
 * text-based 
   (it is wiki-able -- i.e. it is easy to collaborate when creating HyperList)
 * not graphical 
   (although it can easily be made graphical for ease of consumption or eye candy)
 * an easy syntax, humanly very readable
 * very compact
 * can represent negatives ("NOT:" = "don't do the following actions")
 * can represent any number of choices in a decision (hard to do in a flowchart)
 * easy to do loop counts
 * easy to show attributes such as time or timing, location, person responsible, etc.
 * potentially easy to map to other representation methods (graphical or otherwise)

In its simplest form, a HyperList is just a list of Items -- like your regular
shopping list -- but it can be so much more if you need it to be. A couple of
examples will give you the basic idea.

An example of describing a state:

	Car (example obviously not complete)
		Exterior
			Paint
			Chrome decor
			Windows
				Rubber linings
			[4] Wheels
		Interior
			Seats
				[2] Front
				[3] Back
		Mechanics
			Motor
				[6] Cylinders
				[24] Valves
			Brakes

A transition example (task list):

	Walk the dog
		Check the weather
			[?rain] AND/OR:
				Get rain coat
				Get umbrella
			Dress for the temperature
		Get chain
		Call the dog
		OR:
			Go through the woods
			Walk the usual track
		AND: (concurrency)
			Ensure the dog has done its "tasks"
			Ensure the dog is exercised
			  [5+] throw the favorite stick
		Walk home

And this can all be done in collaboration on a wiki. States are described,
processes are mapped, plans and todo lists are forged. It's rather easy, and
HyperList can accommodate any level of complexity.

------------------------------------------------------------------------------
3 HyperLists                                                      *HyperLists*

A HyperList consists of one or more HyperList Items.

------------------------------------------------------------------------------
4 HyperList Item                                              *HyperList-Item*

A HyperList Item is a line in a HyperList. It can have "children". Children are
HyperList Items indented to the right below the Item.

A HyperList Item consists of an optional "Starter", an optional "Type",
"Content" and a "Separator" in that sequence. All the various parts of a
HyperList Item are described below and in the sequence they appear in an Item,
as outlined here:

	4.1 Starter   
	4.2 Type
	4.3 Content
		4.3.1 Element 
			4.3.1.1 Operator
			4.3.1.2 Qualifier
			4.3.1.3 Substitution
			4.3.1.4 Property
			4.3.1.5 Description 
		4.3.2 Additive
			4.3.2.1 Reference
			4.3.2.2 Tag 
			4.3.2.3 Comment  
			4.3.2.4 Quote
			4.3.2.5 Change Markup
	4.4 Separator

Look familiar? Yes, it is part of the table of contents at the beginning of
this documentation -- even that is a valid HyperList. 

------------------------------------------------------------------------------
4.1 Starter                                                *HyperList-Starter*

A HyperList Item may begin with a "Starter". A "Starter" can be either an
"Identifier" or a "Multi-line Indicator".

An Identifier is a unique indicator that can be used in referring to that Item.
A numbering scheme such as X.Y.Z can be used, e.g. the first Item in a
HyperList would be 1. The second Item would be 2, etc. A child to the second
Item would be 2.1 and the second child of 2 would be identified as 2.2, whereas
the child of 2.2 would be 2.2.1.

A shorter form consisting of mixing numbers and letters can also be used, such
as 1A1A for the first fourth-level Item. The next fourth-level Item would be
1A1B. When using this scheme, there is no need for any periods. The Identifier
"21T2AD" would be equivalent to "21.20.2.30", saving 4 characters.

An Item that spans more than one line must have a Starter. It does not have to
be an Identifier. You may use a "Multi-line Indicator" instead; just prefix the
Item with a plus sign ("+"), to show that it spans more than one line.    The
second line of an Item will be indented to the same level/indent as the first
with an added space in front.    If you use a Starter on one Item, then all the
Items in that same group of Items on the same level/indent must also have a
Starter.

In the example below, the first child begins with an Identifier and the second
a Multi-line Indicator. A Multi-line Indicator can also be used for single-line
Items when other Items on the same level span more than one line and thus
require a Multi-line Indicator.

	Multi-line Indicator = "+"
		1. Following lines are of the same indent with a "space" before
		 the text
		+ If one Item on a certain level/indent is multi-line, all Items
		 on the same level/indent must start with a plus sign ("+") or <Identifier> 

The angle brackets near the end will be discussed later in this article.

------------------------------------------------------------------------------
4.2 Type                                                      *HyperList-Type*

If it is not obvious or for clarity or strictness, prefix an Item with "S:" if
the Item is a static or a state Item (i.e. something which does not denote
action). Use "T:" for a transition Item (an Item indicating action).
Alternately, you may use "|" instead of "S:", and "/" instead of "T:". The Type
indicator comes after the optional Starter.

Children of a certain Type (either state or transition) inherit their parent's
Type unless otherwise specified.

------------------------------------------------------------------------------
4.3 Content                                                *HyperList-Content*

A HyperList Item must have some sort of Content. The Content can be an
"Element" and/or an "Additive".

------------------------------------------------------------------------------
4.3.1 Elements                                            *HyperList-Elements*

An Element is either an "Operator", a "Qualifier", substitution(s),
a "Property" or a "Description". Let's treat each of these concepts.

------------------------------------------------------------------------------
4.3.1.1 Operator                                          *HyperList-Operator*

An Operator is anything that operates on an Item or a set of Items. It can be
any of the usual logical operators. It can also be other Operators, such as
"EXAMPLE: ", "EXAMPLES: ", "CHOOSE: ", "ONE OF THESE: ", "IMPLIES: ",
"CONTINUOUS: ", etc. The Operator "CONTINUOUS: " makes an Item or set of Items
run continuously. An Operator is written in capital letters and ends in a colon
and a space.

The Operator "ENCRYPTION: " indicates that the sub-Item(s) are to be encrypted
or that the following block is encrypted. The encrypted block can be properly
indented in the HyperList, or if indentation is part of the encrypted block, it
will be left justified. This is the only Item that is allowed to break the
indentation rules. 

If you need to include one or more lines inside a HyperList that include
HyperList expressions you don't want to be interpreted as HyperList
expressions, then use a "literal block". This is equivalent to "pre-formatted"
text in HTML and some word processors. To include such a block of lines, simply
mark the start and end of the literal block with a single backslash ("\") on a
line. Example:

   \
   This is a block of literal text...
   Where nothing counts as HyperList markup
   Thus - neither this: [?] nor THIS: <Test> - are seen as markup
   ...until we end this block with...
   \

Literal blocks are useful when you want to include, for instance, a block of
programming code in the middle of a HyperList.

------------------------------------------------------------------------------
4.3.1.2 Qualifier                                        *HyperList-Qualifier*

A Qualifier does as its name suggests; it qualifies an Item. A Qualifier limits
the use of an Item. It tells you how many times, at what times and/or under
what conditions an Item is to be executed, exists or is valid. When an Item is
to be included only if several conditions are met, you put all the conditions
into square brackets and separate them by commas. If an Item is to be executed
first for one condition, then for another and then for a third, etc, you
separate them by periods. The usage is best described by a few examples:

* Do Item if "the mail has arrived" = "[The mail has arrived]"
* Do Item 3 times = "[3]"
* Do Item 1 or more times = "[1+]"
* Do Item 2 to 4 times = "[2..4]" (the user may choose 2, 3 or 4 times)
* Do Item 2 times while "foo=true" = "[2, foo=true]"
* Do Item from 3 to 5 times while "bar=false" = "[3..5, bar=false]"
* Do Item less than 4 times only while "zoo=0" = "[<4, zoo=0]"
* Do Item 1 or more times while "Bob is polite" = "[1+, Bob is polite]"
* Do Item a minimum 2 and a maximum 7 of times while it rains and temperature
  is less than 5 degrees Celsius = "[2..7, Raining, Temperature <5°C]"
* Do Item in the context of "apples", then "oranges", then "grapes" =
	"[Apples. Oranges. Grapes]". With this you can reuse a procedure in many
	contexts.

You can add a question mark before the qualifier statement to make it clearer
that it is an ``if'' statement. These are equivalent:

   [? Raining] Bring unbrella
	 
   [Raining] Bring unbrella

To indicate that an Item is optional, use "[?]". Example:

   Receive calls at reception
      Pick up the phone and greet the caller
      [Caller does not ask for any specific person]
         Ask who the caller wants to speak to
      [?] Ask the reason for wanting to talk to that person
      [Person available] Transfer call; END
      [Person not available] Ask if you can leave a message
         Take the message
         Send the message to the person

The special word "END" and the semicolon in the above example will be explained
later, under "Reference" and "Separator", respectively.

Use a "timestamp" to indicate that an Item is to be done at a certain time, in
a certain time span, before or after a certain time, etc.

A timestamp has the format "YYYY-MM-DD hhmmss", conforming to the standard
ISO-8601. The time/date format can be shortened to the appropriate time
granularity, such as "YYYY-MM-DD hhmm", "YYYY-MM-DD hh" or "YYYY". One can add
a timestamp Qualifier such as "[Time = 2012-12-24 17]" or simply "[2012-12-24 17]".

Timestamps that represent an amount of time may be relative, such as:

* Length of time to wait before doing the Item = "[+YYYY-MM-DD]"
* Less than a certain length of time after previous Item = "[<+YYYY-MM-DD]"
* More than a certain length of time after previous Item = "[>+YYYY-MM-DD]"
* Length of time to wait  before doing next Item = "[-YYYY-MM-DD]"
* Less than a certain length of time before next Item = "[<-YYYY-MM-DD]"
* More than a certain length of time before next Item = "[>-YYYY-MM-DD]"
* Length of time to wait after doing referenced Item = "[+YYYY-MM-DD<OtherItem>]"

The last example introduces a new concept, the "Reference". References will be
discussed below.

Other obvious timestamps may be used, such as:

* "[+1 week]"
* "[-2 Martian years]"

Some practical examples:

* Wait one month before doing the Item = "[+YYYY-01-DD]"
* Do Item less than 4 days before next Item = "[<-YYYY-MM-04]"
* Wait one year and two days after Item X = "[+0001-00-02<X>]"

It is also possible to have recurring Items in \hyperlist. The strict format is
"YYYY-MM-DD+X DAY hh.mm+Y - YYYY-MM-DD hh.mm". The first date marks the
starting date and the last date marks the end of the repetition interval. The
"+X" is the repetition (i.e. the number of days between each repetition) in
relation to the date, while the "+Y" is the repetition of the time (the amount
of time between each repetition). "DAY" represents the name of the day(s) in
the week where recurring Item occurs. You use what you need, i.e. if there is
no repetition within a day, obviously the "+Y" would be skipped.  
Some examples:

* "[2012-05-01+7 13.00]" = 2011-05-01 1pm, repeated every 7 days
* "[2012-05-01+2,3,2]" = Every 2, then 3, then 2 days, in repetition
* "[2012-05-01+2 - 2012-05-01]" = Every second day for one year
* "[2012-05-01 13.00+1]" = 2011-05-01 1pm, repeated every hour
* "[2012-05-01 Fri,Sat - 2011-10-01]" = Every Fri & Sat in the repetition interval

You can also use all possible intuitive variations by leaving certain parts of
the timestamp unspecified.

* "[YYYY-MM-03]" = Every third of every month
* "[YYYY-12-DD]" = Every day in every December
* "[2011-MM-05]" = The fifth of every month of 2011
* "[Tue,Fri 12.00]" = Noon every Tuesday and Friday

Here is a complex Qualifier example:

   [+YYYY-MM-DD 02.30, Button color = Red, 4, ?] Push button

The above statement reads "2 hours and 30 minutes after previous Item, if the
color of the button is red, then push the button 4 times, if you want to".

If you use HyperList as a todo-list manager or project management tool, there
is a nifty way of showing Items to be done and Items done; simply add "[_]" at
the beginning of the line for an "unchecked" Item and "[x]" for a "checked"
Item. An unchecked Item is to be done and is indicated by this "placeholder"
Qualifier, while a checked item indicates the Item is not to be done anymore.
Use "[O]" to mark an item as "in progress".

You may add a timestamp for the completion after a checked Item ("[x]
YYYY-MM-DD hh.mm:"). In this way, you combine the Qualifier with a timestamp
Tag. The timestamp as a Tag does not limit when the Item is to be done. It
supplies information about when it was done.

------------------------------------------------------------------------------
4.3.1.2 Substitution                                  *HyperList-Substitution*

You can use substitutions in curly brackets, like this:

	[fruit = apples, oranges, bananas] Eat {fruit}
							
The above reads: Eat apples, then oranges, then bananas.

	Ask which painting she likes the best; Buy {painting}

The answer to the question "What painting do you like the most?" gives an
answer which is then reused as a substitution in "Buy exactly that paining".

The second example above is more general and shows how substitutions can be
used in a multitude of ways. Here are a couple more:

	Ask the candidate about each previous job
		"What was your main measurable results in {job}?"
		"Why did you quit {job}?"

	Brainstorm for a great ideas
		Give each idea a value score
			Top idea: Fleash out and describe thoroughly
			[idea = 2 to 4 on the list] Briefly describe the {idea}

------------------------------------------------------------------------------
4.3.1.3 Property                                          *HyperList-Property*

A Property is any attribute describing the Content. It ends in a colon and a
space.

Examples of Properties could be: "Location = Someplace:", "Color = Green:",
"Strength = Medium:" and "In Norway:". Anything that gives additional
information or description to the Content.

------------------------------------------------------------------------------
4.3.1.4 Description                                    *HyperList-Description*

The Description is the main body, the "meat" of the Item. Although an Item may
not have a Description, such as a line containing only the Operator "OR:", most
Items do have a Description. Many Items have only a Description, such as those
in a simple todo list.

------------------------------------------------------------------------------
4.3.2 Additive                                            *HyperList-Additive*

Additives can be used alone or in combination with Elements. An Additive can
either be a "Reference", a "Comment", a "Quote" or a "Change Markup".

------------------------------------------------------------------------------
4.3.2.1 Reference                                        *HyperList-Reference*

A reference is enclosed in angle brackets ("<>"). A reference can be the name
of an Item, another HyperList or anything else. An example would be a Reference
to a website, such as <http://www.isene.org/>, a file,
<file:/path/to/filename>, or another item <The referenced item's Description>.

There are two types of References:

 * A redirection or hard Reference
 * A soft Reference

An Item consisting only of a Reference is a redirection. For a transition Item
this means one would jump to the referenced Item and continue execution from
there. If the redirect is to jump back after executing the referenced Item (and
its children), then add another hash at the beginning, such as <<Reference>>.
This makes it easy to create more compact HyperList by adding a set of
frequently used subroutines at the end of the list. For a state Item, a
Reference means one would include the referenced Item (and its children) at the
Reference point.

There are two special redirections for transition Items:

 * An Item consisting only of the key word "SKIP" ends the current HyperList level
 * An Item consisting only of the key word "END" ends the whole HyperList

If the Reference is only part of an Item, it is a "soft Reference". It
indicates that one would look for more information at the referenced Item. An
even softer Reference would be to put the Reference in parentheses, such as
(<Reference>), indicating that the referenced Item is only something apropos.
Parentheses are used for Comments and will be discussed later.

A Reference can be to any place in the list, up or down, or to another list or
to a file, a web address or any other place that can be referred to with a
unique name used as the Reference. Although the Reference is valid as long as
it is unique and therefore unambiguous, you should note the following best
practice for a Reference: 

If you reference an Item higher up in the HyperList, a simple reference to the
Item is all that is needed. One would refer to the Identifier or to the
appropriate Content, usually the Description. Examples:

	The first Item
		A child Item
			A grandchild
				<A child Item>

It would make sense to use an Identifier for an Item if the Description is long
and you want to refer to that Item: 

	The first Item
		1 A child Item
			A grandchild
				<1>

If you refer to an Item further down the hierarchy, you would use a forward
slash ("/") to separate each level (like the "path" used in a URL):

	The first Item
		A child Item (<A grandchild/A baby>)
			A grandchild
				A baby

If you want to refer to an Item where you first need to "climb the tree" and
then go down another "branch", you start the path with the highest common level
and reference the path from there:

	The first Item
		A child Item
			A grandchild
	Another branch
		A leaf
			<The first Item/A child Item/A grandchild>

Or, if the referenced Item has a unique identifier, simply use that:

	The first Item
		A child Item
			1 A grandchild
	Another branch
		A leaf
			<1>

You may use a unique concatenation of a path to shorten it, such as 
<Somewhere higher up/One lev.../Ref...>. The three periods indicate
concatenation.

------------------------------------------------------------------------------
4.3.2.2 Tag                                                    *HyperList-Tag*

A Tag is a "marker" for an item. It tags an item and is used just like hashtags
in Twitter. Examples: #TODO #RememberThis #First #SandraLyng. No spaces are
allowed in a tag.

------------------------------------------------------------------------------
4.3.2.2 Comment                                            *HyperList-Comment*

Anything within parentheses is a Comment. Comments are are not executed as
HyperList commands -- i.e. in a list of transition Items, they are not actions
to be executed.

------------------------------------------------------------------------------
4.3.2.3 Quote                                                *HyperList-Quote*

Anything in quotation marks is a Quote. Like a Comment, a Quote is not executed
as a HyperList command.

------------------------------------------------------------------------------
4.3.2.4 Change Markup                                 *HyperList-ChangeMarkup*

When working with HyperList, especially on paper, there may come a need to mark
deletion of Items or to show where an Item should be moved to. To accommodate
this need, Change Markup is introduced. Change markup is a special type of Tag.

If "##<" is added at the end of an Item, it is slated for deletion. To show
that an Item should be moved, add "##>" at the end followed by a Reference
showing to which Item it should be moved below.

To indent an Item to the left, add "##<-". Indenting an Item to the right is
marked by "##->". It is possible to combine moving and indenting an Item, i.e.
moving an Item and making it a child of another: "##>><Ref>##->".

To signify that an Item has been changed from a previous version of a
HyperList, prefix the Item with "##text##". Inside the hash signs you may
include information about the change done, e.g. "##John 2012-03-21##" to show
that the Item was changed by a certain person at a given time.

------------------------------------------------------------------------------
4.4 Separator                                            *HyperList-Separator*

A Separator separates one Item from another. A line in a HyperList is usually
one Item, and Items are then usually separated by a "newline" (hitting the
"Enter" on the keyboard). But it is possible to string several Items together
on one line by separating them with semicolons.

By separating an Item by a newline and then indenting it to the right, you
create a child Item. A child adds information to its parent.

A Separator between two Items with the same or less indent is normally read as
"then". If a parent Item contains a description, the newline Separator and
indent to the right (a child) reads "with" or "consists of". If a parent Item
does not contain a Description, the Separator and indent to the right (a child)
is read as "applies to", and a Separator between the children is read as "and".
A few examples should suffice:

	A kitchen
		Stove
		Table
			Plates
			Knives
			Forks

This would read: "A kitchen with stove and table with plates, knives and
forks".

	Time = 2010:
		Olympic Games
		Soccer world championship

This would read: "Time = 2010: applies to: Olympic Games and Soccer world
championship".

	Walk the dog
		Check the weather
			[?rain] AND/OR:
				Get rain coat
				Get umbrella
			Dress for the temperature
		Get chain

And this would read: "Walk the dog consists of Check the weather consists of:
If rain, AND/OR: applies to children: Get rain coat, Get umbrella; then Dress
for the temperature, then Get chain". Or more humanly: "Walk the dog consists
of check the weather, which consists of either/or get the rain coat and get
umbrella. Then dress for the temperature and then get the chain."

Now consider these four examples:

   Production
      Station 1
         Assemble parts A-G
      Station 2
         Assemble parts H-R
      Station 3
         Assemble parts S-Z

   Production
      Station 1; Assemble parts A-G
      Station 2; Assemble parts H-R
      Station 3; Assemble parts S-Z

   Production
      [Station 1]
         Assemble parts A-G
      [Station 2]
         Assemble parts H-R
      [Station 3]
         Assemble parts S-Z

   Production
      [Station 1] Assemble parts A-G
      [Station 2] Assemble parts H-R
      [Station 3] Assemble parts S-Z

The first and second examples say exactly the same thing, but the second
example is more efficient as it uses the semicolon as a Separator instead of
using a line break and indent. The same goes for the third and the fourth
examples -- they are equivalent. But how about the difference between the first
two examples and the last two?

When you use a Qualifier as in examples three and four, you accommodate for the
tasks getting done in any chosen sequence. In those two examples, the
production could go, for example, "Station 1", then "Station 3", then "Station 2".

The first and second examples read: "The production consists of: Station 1
assembles parts A-G, then Station 2 assembles parts H-R and finally Station 3
assembles parts S-Z".

The third and fourth examples read: "The production consists of: if or when at
Station 1, assemble parts A-G, if or when at Station 2, assemble parts H-R, and
if or when at Station 3, assemble parts S-Z".

As you can see, there is a subtle but distinct difference.

------------------------------------------------------------------------------
5 A self-defining system                           *HyperList-Self-definition*

Now that we have covered all the possibilities in a HyperList, it should be
obvious that HyperList could extend into a vast array of descriptions. It is
even possible to write a parser or compiler for HyperList and use it as a
programming language.

Is it possible to compact the descriptions above into a HyperList? Yes, indeed.
The HyperList system is self-describing.

HyperList can be done in many different ways -- from informal to strict and
from high-level to very detailed. The power of the tool resides with the user.

To illustrate the flexibility of HyperList, we will show the definition of this
methodology in three steps -- from a very informal and high-level description,
to a more strict but still high-level -- to the fully-detailed definition of
HyperList.

First, here is a simple list showing what HyperList is all about:

	HyperList Item parts (in sequence): 
		Starter (optional)
			Identifier or Multi-line Indicator
		Type (optional)
			State or transition
		Content (can be an Element and/or an Additive)
			Element
				Either an Operator, Qualifier, Property, or Description
			Additive    
				Either a Reference, Tag, Comment, Quote, or Change Markup
		Separator
			Newline or semicolon

Now, that's a very simple HyperList. Let's make the same simple list more
strict by using the system concisely:

	HyperList Item parts
		[?] Starter; OR:
			Identifier
			Multi-line Indicator
		[?] Type; OR:
			State
			Transition
		Content; AND/OR:
			Element; AND/OR:
				Operator
				Qualifier
				Property
				Description
			Additive; AND/OR:
				Reference
				Tag
				Comment
				Quote
				Change Markup
		Separator; OR:
			Newline
			Semicolon

That wasn't so intricate either, and that list is more easily parsable by a
computer program if one wanted to automatically create graphical
representation.

How about the full and complete definition, including all imaginable details of
how any HyperList could conceivably be structured. Fasten your seat belt.

The following list shows the legal structure and syntax of a HyperList. It
covers all you have read above. 

HLstart
HyperList
	[1+] HyperList Item
		[?] Starter; OR: 
			Identifier (Numbers: Format = "1.1.1.1", Mixed: Format = "1A1A")
				[? Multi-line Item] The Identifier acts like the plus sign ("+")
			Multi-line Indicator = "+"
				+ If one Item on a certain indent is multi-line, all Items on the same indent
				 (including single-line Items) must start with a plus sign ("+")} or <Identifier>
				 and all lines on the same indent after the first line must start with a space
		[?] Type
			OR: 
				State = "S:" or "|"
				Transition = "T:" or "/"
			Children inherit Type from parent unless marked with different Type
			Can be skipped when the Item is obviously a state or transition
		Content; AND/OR: 
			Element; AND/OR:	
				Operator
					Anything operating on an Item or a set of Items
						[? Set of Items] Items are indented below the Operator
					Can be any of the usual logical operators
					Is written in capitals ending in a colon and a space
						EXAMPLES: "AND: ", "OR: ", "AND/OR: ", "NOT: ", "IMPLIES: "
					Can contain a Comment to specify the Operator
						EXAMPLE: "OR(PRIORITY): "
							Sub-Items are to be chosen in the order of priority as listed
					To make the Item run continuously, use "CONTINUOUS: " 
						Item is done concurrent with remaining Items
						The Operator can be combined with a timestamp Tag
							EXAMPLE: "CONTINUOUS: YYYY-MM-07:" = Do the Item weekly
					To show that an Item is encrypted or is to be encrypted, use "ENCRYPTION: "
						OR: 
							 The encrypted block can be correctly indented
							 The encrypted block contains indentation and is left justified
									This would seem to break the list, but is allowed
					A block can be included of "literal text" negating any HyperList markup
						Use a HyperList Item containing only the Operator "\"} to mark start/end
							EXAMPLE: 
								\
								This is a block of literal text...
								Where nothing counts as HyperList markup
								Thus - neither this: [?] nor THIS: <Test> - are seen as markup
								...until we end this block with...
								\
				Qualifier
					Any statement in square brackets that qualifies an Item
					Specifies under what conditions an Item is to be executed, exists or is valid
					Several Qualifiers can be strung together, separated by commas
						All Qualifiers need to be fulfilled for the Item to be valid
						EXAMPLE: "[+YYYY-MM-DD 02.30, Button color = Red, 4, ?] Push button"
					Successive Qualifiers can be strung together, separated by periods; EXAMPLE: 
						"[Apples. Oranges. Grapes]"
							Do Item in the context of "apples", then "oranges", then "grapes"
					EXAMPLES: 
						Do Item 3 times = "[3]"
						Do Item if "the mail has arrived" = "[The mail has arrived]"
						Do Item 2 times while "foo=true" = "[2, foo=true]"
						Do Item from 3 to 5 times while "bar=false" = "[3..5, bar=false]"
						Do Item 1 or more times = "[1+]"
						Do Item 1 or more times while "Bob is polite" = "[1+, Bob is polite]"
						Do Item up to 4 times only while "zoo=0" = "[<4, zoo=0]"
					Optional Item = "[?]"
					Timestamp Qualifier = "[YYYY-MM-DD hh.mm.ss]"
						Shorten the format to the appropriate granularity
					Time relations
						Length of time to wait before doing the Item = "[+YYYY-MM-DD]"
						Less than a certain length of time after previous Item = "[<+YYYY-MM-DD]"
						More than a certain length of time after previous Item = "[>+YYYY-MM-DD]"
						Length of time to wait  before doing next Item = "[-YYYY-MM-DD]"
						Less than a certain length of time before next Item = "[<-YYYY-MM-DD]"
						More than a certain length of time before next Item = "[>-YYYY-MM-DD]"
						Length of time to wait after doing referenced Item = "[+YYYY-MM-DD<Item]>"
						Other obvious time indicators may be used; EXAMPLES: 
							"[+1 week]"
							"[-2 Martian years]"
						EXAMPLES: 
							Wait one month before doing the Item = "[+YYYY-01-DD]"
							Do Item less than 4 days before next Item = "[<-YYYY-MM-04]"
							Wait one year and two days after Item X = "[+0001-00-02<X>]"
						Time repetition
							Obvious/intuitive repetition
								EXAMPLES: 
									"[YYYY-MM-03]" = The third of every month
									"[YYYY-12-DD]" = Every day in every December
									"[2011-MM-05]" = The fifth of every month of 2011
									"[Tue,Fri 12.00]" = Noon every Tuesday and Friday
							Strict convention
								Format = YYYY-MM-DD+X Day hh.mm+Y - YYYY-MM-DD hh.mm; EXAMPLES: 
									"[2011-05-01+7 13.00]" = 2011-05-01 1pm, repeated every 7 days
									"[2011-05-01+2,3,2]" = Every 2, then 3, then 2 days, in repetition
									"[2011-05-01+2 - 2012-05-01]" = Every second day for one year
									"[2011-05-01 13.00+1]" = 2011-05-01 1pm, repeated every hour
									"[2011-05-01 Fri,Sat - 2011-10-01]" = Every Fri & Sat in time interval
						Checking off Items
							Unchecked Item = "[_]"
							Item in progress = "[O]"
							Checked Item = "[x]" 
								[?] Timestamp Tag after ("[x] YYYY-MM-DD hh.mm:ss:")
				Substitution
					Any statement in curly brackets is a substitution; EXAMPLES: 
						"[fruit = apples, oranges, bananas] Eat {fruit}"
							Eat apples, then oranges, then bananas
						"Ask which painting she likes the best; Buy {painting}"
				Property
					Any attribute to the <Content>, ending in a colon and a space
						Gives additional information or description to the Item
					EXAMPLES: 
						"Location = Someplace:", "Color = Green:", "Strength = Medium:" and "In Norway:"
				Description
					The main body of the HyperList Item, the "meat" of the line
			Additive; AND/OR: 
				Reference
					+ An Item name or Identifier, list name or anything else
					 enclosed in angle brackets ("<>"); EXAMPLES: 
						Reference to a website = "<http://www.isene.org/>"
						Reference to a file = "<file:/path/to/filename>"
					+ There are two types of References; OR: 
						Redirection (hard Reference)
							An Item consisting only of a Reference is a redirection
								For a transition Item = Jump to referenced Item and execute
									+ If the redirect is to jump back after executing 
									 the referenced Item (and its children), then add another 
									 set of angle brackets (<<Referenced Item>>)
										+ EXAMPLE: Use this when creating subroutines at 
										 the end of the list
								For a state Item = Include the referenced Item
							An Item consisting only of the key word "SKIP"
								Ends the current HyperList level
							An Item consisting only of the key word "END" 
								Ends the whole HyperList
						Soft Reference
							Reference is part of an Item
								Look at referenced Item for info only
							Even softer Reference = have the Reference in parentheses
								An Item that is only something apropos
					+ A Reference to any Item upward in the HyperList is simply a
					 Reference to the Item's <Content>
					+ A Reference containing several levels down a HyperList needs a "/" 
					 to separate each level, like a "path" (as with a URL) to the Item
					+ To make a Reference to a different branch in a HyperList, 
					 start the Reference from the highest common level on the list
					 and include all Items down to the referenced Item
						EXAMPLE: Reference from here to <Hyperlist Item/Starter/Identifier>
					+ For long Items in a Reference, concatenation can be used
						The concatenation must be unique
							EXAMPLE: Reference from here to <Additive/Comment/Anything...>
				Tag
					A hash sign followed by any letters or numbers, used as a marker (#Tagged)
					Is not executed as a HyperList command
				Comment
					Anything within parentheses is a Comment
					Is not executed as a HyperList command
				Quote
					Anything in quotation marks is a Quote
					Is not executed as a HyperList command
				Change Markup; OR: 
					Deletion
						Remove the Item by adding "##<" at the end of the Item
					Motion; OPTIONS: 
						Move the Item by adding "##><Reference>"
							This moves the Item just below the referenced Item
						Move the Item one level in by adding "##<-" at the end of the Item
						Move the Item one level out by adding "##->" at the end of the Item
							EXAMPLE: Move an Item as a child to referenced Item = "##><Reference>##->"
					Changed Item
						Prefix an Item with "##Text##" to signify that a change has been made
							Add information inside the angle brackets as appropriate
								EXAMPLE: To show who changed it and when = "##John 2012-03-21##"
		Separator 
			OR: 
				Semicolon
					A semicolon is used to separate two HyperList Items on the same line
				Newline
					Used to add another Item on the same level
					Indent
						A Tab or an asterisk ("*")}
							Used to add a child
								A child adds information to its parent
								A child is another regular <HyperList Item>
			Definition
				A Separator and the same or less indent normally reads "then:"
				[? Parent contains <Description>]} 
					The Separator and right indent reads "with:" or "consists of:"
				[? NOT: parent contains <Description>]} 
					The Separator and right indent reads "applies to:"
					A Separator between the children reads "and:"
HLend

Read and re-read the HyperList above and you will be a HyperList master after a
while. It's all there. The whole markup.

==============================================================================
6 About                                                      *HyperList-About*

The author of the VIM plugin for HyperList is also the chief maintainer of the
HyperList definition itself; Geir Isene <g@isene.com>. More at http//isene.org 

==============================================================================
7 Changelog                                              *HyperList-Changelog*

VERSION 2.6.2  		2025-07-23
	Documentation and export improvements:
	
	New Features:
	- Added <leader>M mapping for Markdown export (fixing issue #16)
	- Enabled modern export key mappings (<leader>e* commands)
	
	Export Commands:
	- <leader>eL - Enhanced LaTeX export with modern packages
	- <leader>eH - Enhanced HTML export with responsive design
	- <leader>eM - Markdown export
	- <leader>eT - TPP presentation export
	
	Documentation:
	- Updated documentation to include all export commands
	- Added modern key mappings to documentation

VERSION 2.6.1  		2025-01-04
	Major performance and feature enhancements:
	
	Bug Fixes:
	- Fixed encryption menu commands to use AES-256-CBC consistently
	- Fixed calendar function time parsing overflow for hours >= 24
	- Fixed ambiguous encryption command prompts, now shows clean password prompts
	- Fixed startup error with undefined functions in configuration section
	
	Performance Improvements:
	- Added intelligent file size detection and performance mode for large files
	- Dynamic folding levels: reduced from 15 to 6 for files >2000 lines
	- Optimized syntax patterns with simplified regex for large files
	- Improved syntax sync values based on file size (5-50 minlines)
	- Added configurable performance thresholds via g:hyperlist_large_file_threshold
	
	Modern Vim/Neovim Features (Optional):
	- Added floating window support for reference previews (Neovim 0.4+)
	- Implemented LSP-style context-aware completion system
	- Added Telescope.nvim integration for navigation
	- Created breadcrumb navigation (ShowHyperListBreadcrumb)
	- Added quick template insertion functions
	- Enhanced reference preview with auto-close timers
	
	Export Enhancements:
	- NEW: Markdown export with GitHub-flavored markdown support
	- Enhanced HTML export with modern CSS and responsive design
	- Improved LaTeX export with tcolorbox and fontawesome5 packages
	- Better iCal export with proper metadata, categories from hashtags
	- All exports now support configuration via g:hyperlist_export_* variables
	
	New Configuration Options:
	- g:hyperlist_large_file_threshold (default: 2000)
	- g:hyperlist_performance_mode (auto-detected)
	- g:hyperlist_enable_floating_windows (auto-detected)
	- g:hyperlist_enable_lsp_completion (default: 1)
	- g:hyperlist_html_theme (modern/classic/minimal)
	- g:hyperlist_markdown_checkbox_style (github/unicode)
	- And many more export configuration options
	
	All changes are 100% backward compatible. Original functions and
	keybindings remain unchanged. New features are opt-in via configuration.

VERSION 2.6.0  		2025-04-28
	Added support for marking items as "in progress".

VERSION 2.5.3  		2024-08-20
	Fixed CalendarAdd ('\G') so that it includes events for the current date.
	It's now possible for the user to also include past date events by adding
	this to .vimrc; let g:alldates = 1
	Thanks to SenkiJun (https://github.com/SenkiJun) for suggestions.

VERSION 2.5.2  		2024-05-23
	Added iCalendar export (thanks to Rich Traube for suggestion)

VERSION 2.5.1  		2023-10-04
	Fixed bug in LaTeX conversion for Substitutions

VERSION 2.5   			2023-08-30
	Included Substitutions (the reason for the HyperList 2.5 upgrade)

VERSION 2.4.6			2023-08-23
	Fixed bugs in LaTeX conversion & ogther minor glitches.

VERSION 2.4.6			2023-03-01
	Added "/" to Operators to cater for "AND/OR:"
	Fixed bug on autoencryption

VERSION 2.4.5			2021-05-16
	Fixed compatability issues with neovim	

VERSION 2.4.4			2020-08-06
	Refactoring (thanks to Nick Jensen [nickspoons] for guidance)

VERSION 2.4.3			2020-08-02
   Several important upgrades under the hood
   Programs for opening files in references can now be set by
   the user by setting the global variables in vimrc:
	  let g:wordprocessingprogram = ""
     let g:spreadsheetprogram    = ""
     let g:presentationprogram   = ""
     let g:imageprogram          = ""
     let g:pdfprogram            = ""
     let g:browserprogram        = ""

VERSION 2.4.2			2020-07-23
	Quickfix: C-SPACE now maps to zA (toggles fold recursively)
	Several bugfixes in the HTML conversion

VERSION 2.4.1			2019-10-06
	Updated to be compatible with HyperList definition v. 2.4
	Included full tutorial/test suite (thanks to Don Kelley).
	Improved LaTeX export.
	Improved GotoRef() (mapped to 'gr' and '<CR>')
	  GotoRef() now also opens files if the format is <file:...>
	  GotoRef() handles the new relative references like <+2> and <-5>
	Some other minor changes and clean-ups of the documentation.

VERSION 2.3.17			2019-08-14
	Added a GVIM menu. Full rework of the color schemes for VIM & gVIM.
   Improvement to Goto Reference (gr) and Autonumbering.
   Several minor changes and improvement in the docs.
   Thanks to Don Kelley for the gVIM suggestions and for extensive testing.

VERSION 2.3.16			2019-08-03
	Improved the CalendarAdd functionality to include the item and all its
	children in the event description and the filename in the header for easy
	reference

VERSION 2.3.15			2019-07-31
	Added function CalendarAdd to add items with future dates as events to your
	Google calendar (mapped to <leader>G)

VERSION 2.3.14			2019-05-17 (Norway's Constitution Day)
	Added function highlight/focus the current part of a HyperList

VERSION 2.3.13			2018-10-24
	Added function Renumber() to (re)number items on same indent

VERSION 2.3.12			2018-06-18
	Minor fix to bold/italics/underlined elements

VERSION 2.3.11			2018-02-23
	Added TPP conversion (info on TPP: https://github.com/cbbrowne/tpp)

VERSION 2.3.10			2018-02-13
	Prettified LaTeX output

VERSION 2.3.9			2018-01-26
	Fixed bugs in LaTeX & HTML conversion (to accept space in refs)

VERSION 2.3.8			2017-10-27
	Added a sorting function: vmap <leader>s To sort a set of items at a
	specific indentation, visually select (V) the items you want to sort
	(including all the children of those items) and press <leader>s and the
	items in the range will be alphabetically sorted - but only the items on the
	same level/indentation as the first item selected. The sorted items will
	keep their children. This is useful if parts of a HyperList is numbered and
	you get the numbering out of sequence and wants to resort them.  One caveat,
	the last line in the selection cannot be the very last line in the document
	(pthere must be an item or an empty line below it).

VERSION 2.3.7			2017-08-11
	Autonumbering now works also with numbers ending in a period
	(both 4.2.1 and 4.2.1. now works for <cr>, <c-t> and <c-d>)

VERSION 2.3.6			2017-06-15
	Added basic autonumbering (with <leader># or <leader>an)
	Suggested and tested by Jerry Antosh

VERSION 2.3.5			2017-01-16
	Added the function Complexity(). The score shown is the total of Items and 
	References in your HyperList. To get the overall complexity use:
	  :call Complexity()

VERSION 2.3.3/4		Minor fixes

VERSION 2.3.2			2016-06-30
	Added the functionionality of Show/Hide of words or regex patterns

VERSION 2.3.1			2015-06-30
	Added the function OpenFile() to open referenced file (mapped to 'gf')

VERSION 2.3			2015-02-08
	Version upgraded to HyperList definition 2.3
	Made the changes necessary to accommodate for Twitter-type (hash)Tags
	New markup for References (and included "@" in references)
	Fixed bold/italic/underlined
	Changed the Change Markup
	Updated Latex/HTML conversion
	Updated documentation

VERSION 2.1.7		2012-10-17
   Fixed bugs in Identifier and Multi
	Cosmetic fixes

VERSION 2.1.6		2012-10-15
	Improved the GotoRef function.

VERSION 2.1.5		2012-10-13
	Speed-up. Also added a global variable that can be set if you don't want the
	collapse functions active, set this: ("g:disable_collapse") - it will
	considerably speed up large HyperListS.
	Fixed syntax highlighting for the first line in a HyperList.

VERSION 2.1.4		2012-09-25
	Added "zx" as a command to update folding (to update syntax)
	Added <CR> as an alternative to gr (Goto Ref)
	Added a mark (m') to gr/<CR> to facilitate easy jump back 

VERSION 2.1.3		2012-09-23
   Changes: Included more accented characters
   Speedup; Adjusted minimum and maximum lines of sync'ing
   Fixed identifiers

VERSION 2.1.2		2012-07-07
	Important security upgrade: Removed traces of encrypted data upon
	en/decrypting (part of) a HyperList.

VERSION 2.1.1		2012-04-28
	Upgraded plugin to reflect the new Hyperlist version (2.1)

VERSION 2				2012-03-28
	Name change (from WOIM to HyperList)
	Complete overhaul of the definition document
	Complete overhaul of the plugin documentation (this file)
	Underlining of States and Transitions now toggles with <leader>u
	Included "|" as alternative for "S: " and "/" for "T: "
	Upgraded LaTeX export
	Lots of minor fixes

VERSION 1.7			2012-01-01
  Expanded "gr" (Goto Reference):
    Made it possible to reference external files by the use of
    #file:/pathto/filename, #file:~/filename or #file:filename
    As long as the reference is prefixed with "file:" after
    the "#", the command "gr" will open the referenced file.
  Added HTML conversion vith the use of <leader>H.
  Improved LaTeX conversion.
  After an HTML/LaTeX conversion, filetype is set to html/tex.
  Changed the color of multi-indicator (+) from red to purple.

VERSION 1.6			2011-12-08
	Added marking of literal regions with special marking of start/end ("\")
	Added <leader><DOWN> and <leader><UP>
	Fixed syntax marking for State/Transitions where indent is "*"
	Fixed escaping "\", "{" and "}" for LaTeX conversion

VERSION 1.5.3		2011-09-18
	New feature: LaTeX conversion: Turn your WOIM list into a LaTeX document.
	             Mapped to <leader>L (feature suggested by  Shantanu Kulkarni).
	Added "set autoindent" to plugin settings (thanks to Shantanu Kulkarni).
	Minor fixes.
	Updated documentation.

VERSION 1.5.2		2011-09-08
	Added "presentation mode" where you can traverse a WOIM list with
	"g<DOWN>" or "g<UP>" to view only the current line and its ancestors.
	Changed Quotes and Comments to only cover one line (before when it
	covered several lines, the plugin became very slow for large lists).
	Added instructions in doc file on using WOIM list in other file types.

VERSION 1.5.1		2011-08-16
	Minor updates to the documentation.

VERSION 1.5.0		2011-08-16
	Added encryption via OpenSSL:
    <leader>z encrypts the current line (including all sublevels if folded)
    <leader>Z encrypts the current file (all lines)
    <leader>x decrypts the current line
    <leader>X decrypts the current file (all lines)
    A dot file (file name starts with a "." such as .test.woim) is
    automatically encrypted on save and decrypted on opening.

VERSION 1.4.7		2011-06-02
	Modified the GotoRef function (fixed a bug and included feed back)
	Better syntax highlighting for folding in gvim
	Updating the README_WOIM and documentation files + other cosmetic changes
	Added the possibility of disabling/overriding the WOIM plugin key mapping
	Added an ftdetect file into woim.vba
	(Thanks to Sergey Khorev for the last two improvements)

VERSION 1.4.6		2011-05-31
	Minor fixes due to a bout of perfectionism.

VERSION 1.4.5		2011-05-30
	Overhaul:
	Created the documentation, including the whole WOIM definition to make it
	easily accessible within VIM. Added the INSTALL and README files.
	Created a Vimball file ("woim.vba") for easy install. Simply do:
		vim woim.vba
		:so %
		:q

VERSION 1.4.2   2011-05-29
	Fixed "gr" (Goto Ref) for references with single quotes ('')
	Added the search pattern from "gr" to the search register so that "n" can
	successively be used to test if the referenced destination is unique (which
	it should be).

VERSION 1.4.1   2011-05-27
	New feature:
	Goto Reference: With the cursor at a WOIM reference, press "gr" to jump to
	that reference in the WOIM list.
	Now you can navigate more easily in WOIM lists.

VERSION 1.4	    2011-05-23
	This could have been the long awaited version 1.0 - but instead I decided to
	synchronize the version numbering of this VIM plugin and the WOIM description
	itself. From now on the releases will be synchronized, with minor fixes in
	the VIM plugin released as minor releases (i.e. a fix to 1.4 would be 1.4.1
	and would still be on par with the WOIM definition version 1.4). The version
	1.4 of the WOIM definition adds time repetition as well as "checking" of
	todo-list items.

	This release:
	New feature: Added the option of checkboxes for items (Thanks to Christopher
	Truett (VIM script #3584). You can now easily add a checkbox in front of any
	item by <leader>v and subsequently toggle that checkbox via the same
	(<leader>v) or <leader>V if you want to add a time stamp to a box that you
	"check" (this also toggles the timestamp if you "uncheck" the item).
	Fixes: Some minor cleanup.

VERSION 0.9.9   2011-04-17
	Fix: Fixed interference between Operators and Tags

VERSION 0.9.8   2010-12-14
	Feature: States (S:) is underlined by default.  <leader>s removes the
	underlining, while <leader>S turns on underlining of States.  Transitions are
	not underlined by default.  <leader>T turns on underlining, while <leader>t
	removes the underlining of Transitions.
	Fix: Removed unnecessary "contained" to make lists syntax marked even within stub lists.
	Fix: Small fixes in grouping and containing of elements.

VERSION 0.9.6   2010-12-03
	Feature: Added "*" as possible indentation
	Fix:     Changed Multiline indicator from "*" to "+"
	Now compatible with WOIM v. 1.2

VERSION 0.9.3   2009-12-11
	Christian Bryn caught an important bug/lacking setting. The syntax file
	now sets noexpandtab.

VERSION 0.9.2   2009-10-25
	A few needed minor fixes.

VERSION 0.9.1   2009-08-21
	New_feature:
	Added highlighting of item motions:
	<<       means "delete this item" (put at the end of a line)
	>>#1.1.  means "move this item to after item 1.1."
	->       means "indent item right"
	<-<-     means "indent item two left"
	>>#1.->  means "move item to after item 1. and indent right"

VERSION 0.9	    2009-08-10
	New_feature: Accommodated for the use of subroutine calls (##ref)
	Fix: Cleaned up syntax variable names to fit modern WOIM
	Fix: Multi-lines have consecutive lines start with a <space>
	Fix: Quotes or Comment can now span several lines
	Fix: Comments allowed in Operators
	Fix: Comments and references allowed inside Qualifiers
	Fix: Identifier must end in a period and then a space
	Bug_fix: Allowing a period to be part of a tag
	Bug_fix: Fixed wrong markup for astrices not used for multi-line

VERSION 0.8.6   2009-07-24
	Bug fix: Corrected attributes ending in capitals that was treated as a WOIMkey
	Bug fix: Fixed references containing a hyphen

VERSION 0.8.5   2009-07-23
	New feature: Expanded Attributes to include relative times and
					 greater/smaller than.
	New feature: References with spaces are now accommodated for by putting it in quotes.
	New feature: Made references in attributes possible.
	Bug fix:		 Fixed references that includes ampersands ("&").

VERSION 0.8.1   2009-07-22
	Bug fix: Fixed highlighting of attributes with a colon (like time stamps)

VERSION 0.8	    2009-07-21
	New feature: Expanded folding to a maximum of 15 levels with folding levels
	set with <leader>a to <leader>f for levels 10 to 15.  Improvement: Better
	syntax highlighting for indexes
	Bug fix: Fixed syntax syncing when entering the document in the first place

VERSION 0.7.2   2009-07-15
	Better syntax highlighting for references.
	Added unobtrusive highlighting of vim bottom set-lines.

VERSION 0.7.1   2009-06-16
	Bug fix: Fixed an error in syntax highlighting properties containing a "-"
	(like ISO dates).

VERSION 0.7	    2009-06-13
	Added macro to jump to next point in a template and fill in the value. A
	template item is an item that ends in an equal sign and where the value after
	the equal sign is to be filled out. Example:
		ExampleTask
			 Task name =
			 Responsible person =
			 Deadline =

VERSION 0.6	    2009-04-13
	Some minor adjustments, but a needed upgrade if you are a WOIM user.

VERSION 0.4	    2009-01-16
	Initial upload

==============================================================================
8 Credits                                                  *HyperList-Credits*

Thanks to Jean-Dominique Warnier and Kenneth Orr for the original idea of this
type of markup system (the Warnier-Orr diagrams).

Thanks to:
Egil Möller for helping to cultivate the first versions.
Axel Liljencrantz for his input in outlining the early WOIM methodology.
Christian Bryn for testing of the plugin.
Christopher Truett for his Checkbox VIM plugin.
Noah Spurrier for his OpenSSL VIM plugin.
Amit Sethi for the Show/Hide functionality (VIM script #1594).
Jerry Antosh for suggesting autonumbering and testing it.
Don Kelley for testing, improvements and for the Test Suite.

==============================================================================
9 License                                                  *HyperList-License*

I release all copyright claims. This code is in the public domain.  Permission
is granted to use, copy modify, distribute, and sell this software for any
purpose. I make no guarantee about the suitability of this software for any
purpose and I am not liable for any damages resulting from its use. Further, I
am under no obligation to maintain or extend this software. It is provided on
an 'as is' basis without any expressed or implied warranty.
doc/HyperList.hl	[[[1
187
HyperList
	[1+] HyperList Item
		[?] Starter; OR: 
			Identifier (Numbers: Format = "1.1.1.1", Mixed: Format = "1A1A")
				[? Multi-line Item] The Identifier acts like the plus sign ("+")
			Multi-line Indicator = "+"
				+ If one Item on a certain indent is multi-line, all Items on the same indent
				 (including single-line Items) must start with a plus sign ("+")} or <Identifier>
				 and all lines on the same indent after the first line must start with a space
		[?] Type
			OR: 
				State = "S:" or "|"
				Transition = "T:" or "/"
			Children inherit Type from parent unless marked with different Type
			Can be skipped when the Item is obviously a state or transition
		Content; AND/OR: 
			Element; AND/OR:	
				Operator
					Anything operating on an Item or a set of Items
						[? Set of Items] Items are indented below the Operator
					Can be any of the usual logical operators
					Is written in capitals ending in a colon and a space
						EXAMPLES: "AND: ", "OR: ", "AND/OR: ", "NOT: ", "IMPLIES: "
					Can contain a Comment to specify the Operator
						EXAMPLE: "OR(PRIORITY): "
							Sub-Items are to be chosen in the order of priority as listed
					To make the Item run continuously, use "CONTINUOUS: " 
						Item is done concurrent with remaining Items
						The Operator can be combined with a timestamp Tag
							EXAMPLE: "CONTINUOUS: YYYY-MM-07:" = Do the Item weekly
					To show that an Item is encrypted or is to be encrypted, use "ENCRYPTION: "
						OR: 
							 The encrypted block can be correctly indented
							 The encrypted block contains indentation and is left justified
									This would seem to break the list, but is allowed
					A block can be included of "literal text" negating any HyperList markup
						Use a HyperList Item containing only the Operator "\"} to mark start/end
							EXAMPLE: 
								\
								This is a block of literal text...
								Where nothing counts as HyperList markup
								Thus - neither this: [?] nor THIS: <Test> - are seen as markup
								...until we end this block with...
								\
				Qualifier
					Any statement in square brackets that qualifies an Item
					Specifies under what conditions an Item is to be executed, exists or is valid
					Several Qualifiers can be strung together, separated by commas
						All Qualifiers need to be fulfilled for the Item to be valid
						EXAMPLE: "[+YYYY-MM-DD 02.30, Button color = Red, 4, ?] Push button"
					Successive Qualifiers can be strung together, separated by periods; EXAMPLE: 
						"[Apples. Oranges. Grapes]"
							Do Item in the context of "apples", then "oranges", then "grapes"
					EXAMPLES: 
						Do Item 3 times = "[3]"
						Do Item if "the mail has arrived" = "[The mail has arrived]"
						Do Item 2 times while "foo=true" = "[2, foo=true]"
						Do Item from 3 to 5 times while "bar=false" = "[3..5, bar=false]"
						Do Item 1 or more times = "[1+]"
						Do Item 1 or more times while "Bob is polite" = "[1+, Bob is polite]"
						Do Item up to 4 times only while "zoo=0" = "[<4, zoo=0]"
					Optional Item = "[?]"
					Timestamp Qualifier = "[YYYY-MM-DD hh.mm.ss]"
						Shorten the format to the appropriate granularity
					Time relations
						Length of time to wait before doing the Item = "[+YYYY-MM-DD]"
						Less than a certain length of time after previous Item = "[<+YYYY-MM-DD]"
						More than a certain length of time after previous Item = "[>+YYYY-MM-DD]"
						Length of time to wait before doing next Item = "[-YYYY-MM-DD]"
						Less than a certain length of time before next Item = "[<-YYYY-MM-DD]"
						More than a certain length of time before next Item = "[>-YYYY-MM-DD]"
						Length of time to wait after doing referenced Item = "[+YYYY-MM-DD<Item]>"
						Other obvious time indicators may be used; EXAMPLES: 
							"[+1 week]"
							"[-2 Martian years]"
						EXAMPLES: 
							Wait one month before doing the Item = "[+YYYY-01-DD]"
							Do Item less than 4 days before next Item = "[<-YYYY-MM-04]"
							Wait one year and two days after Item X = "[+0001-00-02<X>]"
						Time repetition
							Obvious/intuitive repetition
								EXAMPLES: 
									"[YYYY-MM-03]" = The third of every month
									"[YYYY-12-DD]" = Every day in every December
									"[2011-MM-05]" = The fifth of every month of 2011
									"[Tue,Fri 12.00]" = Noon every Tuesday and Friday
							Strict convention
								Format = YYYY-MM-DD+X Day hh.mm+Y - YYYY-MM-DD hh.mm; EXAMPLES: 
									"[2011-05-01+7 13.00]" = 2011-05-01 1pm, repeated every 7 days
									"[2011-05-01+2,3,2]" = Every 2, then 3, then 2 days, in repetition
									"[2011-05-01+2 - 2012-05-01]" = Every second day for one year
									"[2011-05-01 13.00+1]" = 2011-05-01 1pm, repeated every hour
									"[2011-05-01 Fri,Sat - 2011-10-01]" = Every Fri & Sat in time interval
						Checking off Items
							Unchecked Item = "[_]"
							Item in progress = "[O]"
							Checked Item = "[x]" 
								[?] Timestamp Tag after ("[x] YYYY-MM-DD hh.mm:ss:")
				Substitution
					Any statement in curly brackets is a substitution; EXAMPLES: 
						"[fruit = apples, oranges, bananas] Eat {fruit}"
							Eat apples, then oranges, then bananas
						"Ask which painting she likes the best; Buy {painting}"
				Property
					Any attribute to the <Content>, ending in a colon and a space
						Gives additional information or description to the Item
					EXAMPLES: 
						"Location = Someplace:", "Color = Green:", "Strength = Medium:" and "In Norway:"
				Description
					The main body of the HyperList Item, the "meat" of the line
			Additive; AND/OR: 
				Reference
					+ An Item name or Identifier, list name or anything else
					 enclosed in angle brackets ("<>"); EXAMPLES: 
						Reference to a website = "<http://www.isene.org/>"
						Reference to a file = "<file:/path/to/filename>"
					+ There are two types of References; OR: 
						Redirection (hard Reference)
							An Item consisting only of a Reference is a redirection
								For a transition Item = Jump to referenced Item and execute
									+ If the redirect is to jump back after executing 
									 the referenced Item (and its children), then add another 
									 set of angle brackets (<<Referenced Item>>)
										+ EXAMPLE: Use this when creating subroutines at 
										 the end of the list
								For a state Item = Include the referenced Item
							An Item consisting only of the key word "SKIP"
								Ends the current HyperList level
							An Item consisting only of the key word "END" 
								Ends the whole HyperList
						Soft Reference
							Reference is part of an Item
								Look at referenced Item for info only
							Even softer Reference = have the Reference in parentheses
								An Item that is only something apropos
					+ A Reference to any Item upward in the HyperList is simply a
					 Reference to the Item's <Content>
					+ A Reference containing several levels down a HyperList needs a "/" 
					 to separate each level, like a "path" (as with a URL) to the Item
					+ To make a Reference to a different branch in a HyperList, 
					 start the Reference from the highest common level on the list
					 and include all Items down to the referenced Item
						EXAMPLE: Reference from here to <Hyperlist Item/Starter/Identifier>
					+ For long Items in a Reference, concatenation can be used
						The concatenation must be unique
							EXAMPLE: Reference from here to <Additive/Comment/Anything...>
				Tag
					A hash sign followed by any letters or numbers, used as a marker (#Tagged)
					Is not executed as a HyperList command
				Comment
					Anything within parentheses is a Comment
					Is not executed as a HyperList command
				Quote
					Anything in quotation marks is a Quote
					Is not executed as a HyperList command
				Change Markup; OR: 
					Deletion
						Remove the Item by adding "##<" at the end of the Item
					Motion; OPTIONS: 
						Move the Item by adding "##><Reference>"
							This moves the Item just below the referenced Item
						Move the Item one level in by adding "##<-" at the end of the Item
						Move the Item one level out by adding "##->" at the end of the Item
							EXAMPLE: Move an Item as a child to referenced Item = "##><Reference>##->"
					Changed Item
						Prefix an Item with "##Text##" to signify that a change has been made
							Add information inside the angle brackets as appropriate
								EXAMPLE: To show who changed it and when = "##John 2012-03-21##"
		Separator 
			OR: 
				Semicolon
					A semicolon is used to separate two HyperList Items on the same line
				Newline
					Used to add another Item on the same level
					Indent
						A Tab or an asterisk ("*")}
							Used to add a child
								A child adds information to its parent
								A child is another regular <HyperList Item>
			Definition
				A Separator and the same or less indent normally reads "then:"
				[? Parent contains <Description>]} 
					The Separator and right indent reads "with:" or "consists of:"
				[? NOT: parent contains <Description>]} 
					The Separator and right indent reads "applies to:"
					A Separator between the children reads "and:"

doc/hyperlist.pdf	[[[1
1567
%PDF-1.5
%ÐÔÅØ
100 0 obj
<<
/Length 697       
/Filter /FlateDecode
>>
stream
xÚT]oÓ0}Ï¯ðc"a×ß±÷lcl¶
YkR£ÖíÒ(¿Ø]ÓQ¨RìÆçßÜ{î¥¨FeôëËq6zeb%áLI4þ¸¦k´DQÆSô)?/>/#R²ä¢C2Nñ±ÀçoáÉòÓ~³ãìÔ!L?®ÊRb¥ÝB.z­Ûþ9~KbëÑQ#M8pzÆíN«ï`XÃÀB&#ðÌù¦À\Ñübí{¤bµî£¥DP0g¥¤ú¹ïÀd²\t¡vÏ¦F»?7gØR´:®ù¾Ú¬mWG£ÑÉTF 
9¬VE¾ë|(s7r¿9ðXZ¢Í»/]ðÉráøæ"ûCah^5Á»¦4ß¾.¸Ê]®Åo¦»bD[tË¨{Zûy]÷ ®¥²BeJüF>E-çó½»_ü(\¯üü«¦
íÏ¸®?ß¾oªYµðUHY&Pi¢¥J	Ôñ:7õ­õ¡AÜ¼|³¿\°%\tòpðïÆXîµ_£FsNt¤ßQE9å
S¹l¯ú0d!,®»°,ôkXyê"?qaíþññÖx]T<g¬³)bwí $4½J4YdÔ²G¶ýÄKÓ6ÒKK$T?.,³wðû}ÞÀP]×#i²oÃÀ8âh2±"±Õ%0U#Ù¾÷Þ>4ß´3¨%½ùñ2L ¯ ¥É«0Uãú·à)r09{iº¡\Ü Á:¹ç|³rÍ_·1å«ª*ü×Tak¶£no,z4ëäç ?úgJ4ø*ÍÂ}KAáÖk
endstream
endobj
97 0 obj
<<
/Type /XObject
/Subtype /Image
/Width 200
/Height 177
/BitsPerComponent 8
/Length 46340
/ColorSpace /DeviceRGB
/Filter /DCTDecode
>>
stream
ÿØÿà JFIF     ÿá*øExif  II*         J       R   (       1    Z   2    f   z     2     2   GIMP 2.10.6 2019:10:05 20:25:38              â       à                            æ       
*         ÿØÿà JFIF      ÿÛ C 		
 $.' ",#(7),01444'9=82<.342ÿÛ C			2!!22222222222222222222222222222222222222222222222222ÿÀ  â " ÿÄ           	
ÿÄ µ   } !1AQa"q2¡#B±ÁRÑð$3br	
%&'()*456789:CDEFGHIJSTUVWXYZcdefghijstuvwxyz¢£¤¥¦§¨©ª²³´µ¶·¸¹ºÂÃÄÅÆÇÈÉÊÒÓÔÕÖ×ØÙÚáâãäåæçèéêñòóôõö÷øùúÿÄ        	
ÿÄ µ  w !1AQaq"2B¡±Á	#3RðbrÑ
$4á%ñ&'()*56789:CDEFGHIJSTUVWXYZcdefghijstuvwxyz¢£¤¥¦§¨©ª²³´µ¶·¸¹ºÂÃÄÅÆÇÈÉÊÒÓÔÕÖ×ØÙÚâãäåæçèéêòóôõö÷øùúÿÚ   ? óª(¢¾Àû ¢( ¢( ¢)QE QE QE QE QE<C!ÈìM'$·brKv2»4ðyÄìíV#
íÅS`U=EeJ´j]-Ó3§UNöè%Q[Q@Q@QH( ( ( ( ( ( ( )¯¸))·?íTÎjr}Ô"äú	$=½É<Ö¥¶1KvÊæ0HÜHÇ­ éKªYÉ!Ú.A;sxÿ =+"KÉ#¹¸UÌP¾Ö}»vó_?<î.RQºù[ô<yæOMRCiö©#[¨ÕW,Ã Æ?´4{ÌUm:+vÞ\}xùeaÇºõ«ÚµÇÙmíÓ&m¤³¯Fcéë^}LéÆ¢¦ýå§á}}_SXé½«C
'32ÄËM£nÖµ^{Í2),üdRÀîè=~BÝfì¢,P3ç?Ö´TKËâ5\?Ä~µñu¥R=R×Óµº¼å%wéä>ZtÒ%ã'¼OZÕ­L |ÁN}9¤XI<«DeyçÕH 'Èv Ù9Ç½{j¥X§ì¹·vëÜõJ±Oo¿¯qá²pIqÉô¦TApA§\ÙÄGmv²mÀàyÇëN°ó¢gûJ­ÒSÆUÎ)êïÏ©T±ê.ÒÖäTSæ)çC× ÎsM
IÀìB¤ecÔHÉ\J(<QVXQE QE QE% QE
ZJ(h¤¢J(EP2å½¤mf×rIÂ><¼ãN3Û­M¯ÚØÅtFæ{GàÀ þf¨FªË#1 " u'ÒÂöÿ jóNÌ?r=»WiÕ´ª=w],ÿ á¿ÈÆÔ9ZRzïécsPµLð´¢X¤Iñ, j¾®jpéòèé46Èã÷ùË«zc½g\Þ¬AÈ#Û»ÀÇN·ñÝÅ:<±GÂ$ÞHË¾oIJ*F­·Ñ¾Í¥¡äT½Èºom®gÝéwåÂFý¡ÇBkr;kË«¯Ý^@ È2]°ß§^)-#XíìàóYnTí\ý¹ªQÇ}nÑ+©¶òßr8Æ<wí\s¼ãËuÌ$´Ð]f¨/dñcóxíçòªªÍ$ûI7¢{é4´Ä¶£s}/YgvÀyÆGCÞ¬i¶:ÅÅÂ\>ä\ã* ÀüóY¼Z§Wtì;-ÎY¶ÓÍë(î$·d	 V¿sÅPOµ¾ÌqØy
?È­=\ý³\ÑBV0±ÈÃ(Ïÿ Æ¢Ó4´-ÃNn¿Óñ¯S I=wêßùR«+Þú?ÄÙ³Ð|Ý>	bÒ$c¶1æ	ÏEÁäõ¨·¨Ék v m-¼ã8¾µ6©¶¬Á4ÄÏRHå8Î:iu=Uu}Zîö+o²¡uu]£¨ úgñ©¡BØ%w7ó¾ë«EBæSKúìU¶+k(gPvtZÂèÛÝK'ÙÑÄñÙyÏ¥F[nifó %GSý*$ËFÄ)ds_MWòiÇÞ²ZíoOÀö'IU­ïinÖôüRÿ hp_¼ySM¢½HGZ÷=GZ÷J*Ê( ¢( ¢( ¢( ¢r-ó¶Õîje%Í-4¶VãÚk	%p2e\zã¯­6óLL¹)<v7ç¨È>ÕRÝK*DJ¹`}?É¯=b)ÖjÞÉ}Ç
¯
Ê5/kZY½Üæ8ùsÇZÓ÷®¨	
O½"»ÄäÆä³kkÚË<ô$9ÇÝ§ô¥ÄO	jß2vI}ýJ¯VxuÏ{§ÐËÞ)¦t3ÀÃ~=jÜþv·§[ÙXØº_¼G%½1ýj(#K«UVã¦vg'==êÊÞK¤´AÜ«o2côõ5òÜELBÖéÝ+½¶ùëÐð15]fäýJRi°[Y½Y>Ýä·PqÜc54wwÚ¶eep¦DRªt\ç"¶5Èl'Ô-rZÙÜ´ÈËÈÈþu8±û±ÅëÉ¶]Ü!;9÷ãó¯5N3dþ-õé¿õù(¤ô%Ð5Û]#Ä-¼;ä,qÀÇ?Îµ¼e¤5Ä6Z¬×,íÎØL{Y7`~Cµrº¦ãÍ¼´vÂÈñíÏO¨­-OÄóêú^¦I:0¶#±ÌpA$îý1D°ëÛB­=Þîôÿ #Ec
êÑ´©ìlne&9Æ	ç85wWB$µX$ãÌä7'Ö¶íe·±Í|h
ó=ñéõ©.RÆYÚ|Ëåäù'9ÏÑíyf¡%?2lC¢hPj7°Çsu±ÇÌ%lg¿Z³¥Ý¸´]*I£Kæ'í1íÜÜr_Ò³HC(D{¥]eoºÞµgTiÄÈvphÏËÏJÊqr¥ªé~cZ"Þ§áÛ­>;s$2«(å9ï×?dÌÁõRÞDlã¾Pqß9­+-hÇ¦£ù_hºà9ÚAà{â±5}jêã]7_¾a
³°º]¸:¡=uQz??@£QÁëÑX@ëM,8
CÎè*=*âK5¹´w2.íÊ9ÈéÇã[:q­M2	bÅÔH2O tüké¿µ¨ÂÕeoîÓÌ"â¾\ÀFä¶~`½9=è­=wAºÐµ_±\\@îFñåÎª]Wlq¼òF:
Û§;T¼g×õô})b"¥~ð+ÑEêQE QE QIE JZ )CIGL^6ºÛ©c7×F±ù¬@ÈÎÑÿ Ö©ByHð²:d»ÔzUß*êÚÂ+«EòÐ)$d±-ý8ÇLG:½¸´¸[rHi¸ïÍx
½?i+ÉrßD·ºzÞßâxª¤9åwîôKõ±QBÇá~¾Ði÷PÚ[Ém:í¶¹¸«r:g\VzßXÉ%Gýè)´í;ô#n£
þÙöÚ!'Ç^
XÇ<D£
«Ý{yõ]wùte×ê8©­:y¸¿kmöË#CÉcØq­%ÝûÛ¡7t¾sÿ Öö¥ÔÌWpÇ%¿Ì¬H òryÿ >Ý"EOìÛ7[2Øô¯âéÅ¨í¿_ÃcÊÄIIFËcr+´Õ"¹õDò¬BEö`~uÎÚ1³	d´V._(À·èkv}*ßCØZMþ±âbÀ/n¼TÜY¾©mod«le~WhÎÝÐ÷ú×JªMò+Å¯±»âÝR×^ÒVòÓH[sÈw1ª° tªºÑ®´hfÝ¡»µÉxëÎy5¤ÐµÕÃ+mµG*®8ÈÀÉ4í;ÃzVöá¨LfMX¼Ò	_Q2k9T§
~É]Yém[_Óù®S±¿¶²¼[yôï2ÌîáAzø?^½¶]aÛÂqEó~TöÝk-N;{I #nØ²»)9Ç8«>×äÓnA
< °uÍo[Úö¾º?S9+´[H¼:ÛYKl<÷_2B$ÀÇLV×:d¶¢;UÑÁÜ'x}{sUï5[©g»E?i|ôÆQ}9íV..o<CS²­¼DI" S 8Ï<ñÒµ©NµNXÔµºúØ§Öu6á¬ky4ÛM8I»)f`\1MH¡[Ö2´ `îçvö«æy+rñÍC+¡Xç°r}ëÓ§Ó§Ý
c¤ßÈN¾Ì	kHå#úIõ)Z~`S;¶³Jt#3*Gü÷Ç£9ÅT¸È169*ã+ÀóJx:¤æZ.ïô6Ò3Ý-/&¾¹ûT÷d»Û\Õ+Æï¥yâ	!?¥X¼G±]2 lvaCU'KL¹öÅ{m9Ô¶\­+wÿ ëäÏKÎ\óJÖ#¢+Ý=p¢J@-PEP ¢(Vumhîb,­§ëTbË*  8É­oìøíì®cªáº×Ô à¨U»çÑ[_Á«IER©{ËEbÜMkgzo±%Õtßµw`vüªKÌ³I¥jp=2á·¶#Ë*ýÞ½k2Áîe°Ö(ÑÌd¶
?úÕwRµÝcx·^PÇçqN+ä±og]áçy'÷ù5ç~§R¥7KV³Û½Ä«kæmíä³õeíÚ%,ßädV¾¬±ux¬¢%UÊi2Ù¼sUß°¼ºÚ3!RBçn89õïW,V.TÕ¬»þdÔ­QÃÙÄÊ½Xí&6äJbàùq°Î>¸«o£CîÖIÅ³±¼¬§Ðà
§mfÃT]KPºPùQ¢òyã>é÷·2FßfÝ9ãÊVP ,y=}`ÔÕ£÷ÿ Àô9ÒGB'ißÙQªJé$éÎ =oÿ Ud¦r÷6³L¬²!Þ¼¸­Áhl¬âI"7°&Ù
KË 1ÓzWAæ¡y7ë0±<óßÿ yõoJ>ÒÑÞ÷Ó_ø,Ù£Õo$û7öyThE§56·þóyG&F9`¼à¹µf§ç[¶Hü0íEfiºhÁ$/k,bÀÌyÀ#ö«·IòòÁ+Ýy_K¿òùQ³Ü¿.5­ü	s#Jdà¹´ËO{+{Imaæ6ù=ûà`*£ÞÒkæó¸rp?úÕ$ó,Ëäñ!ÀV^Ê¥ìÞßË±$Lïe5ÅÍÀ7ÏT(#jÔÜIáØâ·Ó.eËÍþ¸¥ÔµÃªYÚHìvâõ¶`ãçU X´Ó¢²Ó/ÿ wf<ò:~µÖ*¨iv}ËúØMÙÎQ`hcTÀX2rÄñÏçSDËd,¤K7Ë}joxºÓ¯¡n$Uq'Ö­ÜèWÚ|òJ,m´§ä ;×¡Òäj÷³[ÿ _ðåFkkn\Óô	µãils·;1ê?óVUô©­mÆ¾Y`§ålû~µFíµwºU·Ê³­.6íü9ª·:KA,DLÜ}qéU8Ó©V½­ò~¿¥sÁ5grÖ±«Ý_ÄtGÈ¸Ü Åfg=j÷ö¼²xz%Z8¤óNã9ãõ5B¾ÃNV]Ï·Cèp±p¾åýjQEvaEPEP ¢ Z)( ©ÄELD!°35=,n¤d`úVuSq÷w3ª»¹t4±\ÂehÀè¹V>àÔwzuÂKºhþÎ]²V5Ú¿¢Ö÷ì·é<+µAØÕ£¼½Kôib_¾Ddè8¯0èÖi$Õ®÷¿nÇæ¢ü·e&"µq.ýÀ¡aUw±v´x­bfgPy<g©É4È&{awNp¬0£Üw©R"7a$l6X¯_a\
59gmeø]}O=FmIõ41Q!¸'®*[$êòù°ÌÁÛ?R	Ëòs\ýïCúRÆ²ÚHdürØè1ØÖ¢êÑär³èÍaO²v"Ôôhî%kÚR»£ß8ëÚªi,Õtæ¶ËsbÇds1È­ëûo
Æò" |Ù5gh>Ë,SL§ç,Ñ6ÍüÍqÑ ù1îúÛ±ÎáÊìËzx²¼¸óJ«D¡1ÁëVøÑôÒ4Ço']L¯Ç9 Ï|w®æÊM-öËÌI$å¢Iük§ðÆ¹nº¬Wr.!ÚõSüë8óSwqí»ò3M6ZÔ Õ¬n[Nh¢e\>p=jÇMutÝbÔ´Â
ü5ÒJ¥ªFÅ÷H,Æ·Ó,íï&¿½)4£ð8ÕWVÖÝáÊêkI®Y%åÌöVÆÞ9]deÀ°1î;yâ}=ÒkëÛåÇhóÎAÇN?Ä¶¶ûmëC¾]¹O5Ü!`kZÒÆÖÒ/´É ºTù[i<þTN§u%Ý7}4¿ë¿ÜiîJ*ÏSU¿¤±ºî&´»çúUK;@òÜ$÷Ix _4óÙÏaël º»{«I|Û¤ur0I7°Iü«0A4Û®£¿+.H*rNF?Ïx_i:1í×þÂ¬³ë¿dÌ¨òâÎì3J`h¢ºS×,±àpÔpj+«¨®%Á`.@Ã`8ìÂ¡iKF#o*x9è}#ÂRöiÓ\ªú¯?OëCÓxz\ÃE}W çA¸
À9 Åû£6õùnÌsÓ¯ÒòÆö!¦G?JÐÒ4¶¾2ÌÛ|¨yÇõü«ªUèÒ¦¥=NRb®­c0:Jµ¨^-ÝÑ+
Æ ÀÐÕZí£QÎ³ìuÓn÷
)(­M¢ (¢B
(¢
(¢Fãç]©]húEÊº³Ü*¡?x3þ5È$Ô¨;¿Jè­/-4ûEóæO:,á[xü«ç³ºu«rSäæ{-ß[ùY£ÊÌYN1åº}·Ûð3î'´ËÙÂ#±¸õ9­i±¼³_ÚmØîTöÇé\Á¼ÌÆ ÅuZ4WgJ[ÈnÊÜIª¦Óßò®<ÞÕpVOG½Ýû?ÔÃAÑq~LÅÜ^jó¥¡Vra¾	Àúô­Kè¡Òôeí/¥;d·.+ýî©ÞÒ}QmBE0È8%ÀÎ>¤*¦§âhõ6Æ3b¢ê+$ÙûÝ=«Ì£G#ûv%}{§ùÔèU«nU¡ÏEsöGE~ð=}ê@Ày	ùH$­Cqgª}oþfv9ÉÇ5=­Å²ÅªÂ|Å~æsÉ÷¯EW©¨ùéòËªýQIÎGxÙ³2+ö	!(¥áy ²îÚµ¹¦éÚº¼bxÔý®+Ò-5É­ÜwÓUZS¶Mú²q×ÕïêwÉ8÷{sj^++_ØÉ#	1LªúÖ­µú+K±>ýkÖw-Ðú¨9ãÖWKÚb-{Y`éûJ©\¯izö3)'rÅké^*M(üå11`Xg9ÏZç¨¯¦­Ã×V©ÏnxjSø­«k³êW~z(·ùHýß¹¨µb¹ÞhrØÀõTQAYu ãÛ8¥TÅ»Hpp`¨F ¨«(io_ò1påt×Ã§ÞWXKðÑHã¡n'TT8ivÁGNG9¦Ã§¿ÙÍÜ¹¸G'óþÕhÚ¯Ø$Ómìàó&JO(c?,×cgNò¢¹µïµ­{þgªùõcf$ûC(ßÎt5¤ºf¦a»£ùÝOUÿ 
½¨è/§i-^ùÒ³+°Aò°È9ÍI¬ø)tx-,dqº=©9 sÅaÅb±q§gk7gÑ~]É£*õRÕ\æÞA¸;7ô¨êGY#XÝÉEû£Ò£¯¨¡	Â»=0#i;°¢+cP¢( ¢ Z)( ¢
UVs¼RTÊbü§÷2nÏqJöÓsJÇHT¾Ì,jïî{ÔVZöàÛ±R7q=*[^E¹tÂÐÃ*(£¯çøU½K0D$HË¶c'êq^%véÓLUv´zÛªwß_æÔN0s«­ö]JW°ÌÐ$wA8Ëzóø~UHD³,a=}ë¯ÒíÚúDÔo×íñJ£AÏðýMGâk6æy¬#û>]Z%fÎàzàkó×X7{{­·ûû´«s¿dµwéý3'Iiz¼R\)mª]qÐú«_ûjòóJ¿¸Ó- 9ê§xÈü«Ôµo·¥¢¤"A	RrÇ * 'DÑ	FÇ,¹àïþËx¸s«|¬÷Zîÿ ±a';Jo]ëk³KëY<§qµÙ$Á úÖU«¬~ ¹d_;8¨!ºß")Yêâ¢Ów7ÃXºÉ=kÊjTæºùÿ Ã#t£)_FÏ@¶1r8ÀäW-â)ï#ëÜýk¸Ô`§øGò®\ui£8ÂãúXäßd,¹^µüêUÔñIV¬ìæ¸,ÑäÒ¾µXÒ4´G±R¢¦®Ç¥«C	¸FCåÇ¯8éõ¤K@ãcºç©êj'hîÈwqÎyþµ,Wq¬á\·Üäö¯)F¯4£Û¿õæyIUæV÷¹¡¦ß.!³¼BÈ¼¸Û#$ã®;Vý÷,aÒPe×ÍrT!#ØÛ×$Â+Á%¼¬ê­¹7µµojz¸UQW 3ýï­y«
Ôß"zÉ}×Ó»×Q<J¶­}ÈaÜ©q§Þ4ð\m¶wÍc óÖ§º½îESóªÜ:éUëÞÁa%AÊR´èü6TmïÐ(¢»Î±h¤¢J( ¢BJ(h¢QE :9)RE?2Ãê+¥ÿ Ýü7<Å¿Q±æÆ7g<{q\ÅÍÂRÄ8ºX´×Ëôò2©J,åÐ´ºÚ)TIÓ4íGS¹Õ.k§ê»F NÕQ¦¤¤¢®pºAEVV4U¯ö@j½YÐvx±<ðæ¼ÜÙÛÎÅþçæzM¬ <¼+Ïõãÿ »øþ+Ð-vµ¹Ï÷zö<W	â0?µ	 ¨Î>ãänØ//ÕysµWèdU«+æ1æÑW#û¤óUh¯¨T×+=EIYíµ­ñKL±²)'9#Ë¢ÏAQîû½Ù©*q¶þaEVÆ¡EPEP ¢ Z)( J)Z(¢Q@QL( ( ( ¡Ó÷Üjoå¶ÃÉ84òÍ(¶µC$íØãëV[IÓVøIs­ç^dE!@5áæ¸»Rõ<|Æº©Çæv
ðÚ4aØÚ¹½M.qöÆ7õORñ¶úÛZÜy¨r98¨.îI9Rü\,¬ÃåúWÔöç³9p*ªObZ*5wmÄ*²¯R­~TäueXí_OKN¯Àî{´ëÓ©ð;¢+cP¢( ¢( ¢) QE QIE
(¢QL( ( ( )É*BáÞ&à\sùÔN|rµÉ¹bäZ²Ó¥½ÜÀáAº(¨N§¤ÚÉµ öEÈ$ð¬{qüé³Þ\ÞGÄ6å'OÆ¢
`  ¯;Øb1>õYr®Ëõ8}lF³|«°Ïím\Ö-cäÂ²õ(#ÝüÒóIÜÖÅbëH"^ùþªàéP£'«3¯§FÕ¦Ø[Íhîã{HéKd}éRÚ>qÊ´, Ö±Æ8ÉúÔ²EË¶DVfªYzÇiõ*1[I¾¨¸ÓäÆàÊßwëM·).ê2çcÿ ëÕhÞ!N§¬yàÖÌ»5[1¨Û Vé4]Ôý+¹*F+é%úÂ,Ô*®WÑ£>(¯pö( ( ( ( ( ¢¾¥ÿ yáú Úß'ükÃ>(iv:7f³Ó­ÚÜCÓ $s\T1­.T*ØÖ*GEvt«gÆi¨ÚÇsn`oÓ#5îðóÂ;OüHm:tÿ ñ£>V¾64gÈÑòÝQ]`QE ´RQ@E% ´RQ@Y7*e× R¹U]ßçô­ZM£vìúÖU©ûDj^Ñ%~£¨¤¢µ5ix.mcC÷\{u}á_øb÷ÂZ=ÕÎk$óYÄò;b y®LeJqUÓ91)Â+Ú+ÜùÍ3³ ÔØ|OÒìt\YéöÉon±FDiÐ¼×¶Ù|?ð6îú¡fI$N>´ªc#N[¦24á5¹óÑxòÆ×Mñ¾©ge
Ão$iÑFÐk®¨K*K©Õ	©ÅIu*
*æ¦\ë}¸¶ ?Lÿ JöàÕ¥·ÕÃ\\,,ÂðN;õ'ô¬+b!KâzVÄÓ£ñ=O¢×ðß®üO¬&fUde,YºÉýkYIE]JJ*ìÈ¢½_öî¬ôËË¥¨#ð#ü«ÎêiÕON¬*|,û.¼âÃ-sÅ*S°Å h F9à)¯[¬-SÆ^ÑoZËQÕ!·¸PÆá³Ó ¯¡Rpá¹ó´*N¯Osø}ðÏ[ð·SR¿ÅàºÍÓ¢½a¾éúV&ãkW¢ÏMÕ!¹¸*XF³Ôò+m¾éúQZ¤ç+Ïp­Ru'yî|ßðËAÐ<KªÜiÚ¼R´ÞY&IJ~¿¥v>7øW¢i~»¿Ò!n ÚÀ<¥?¡5å^ÕCñ- G(îèkêZ¾Á0bºå'Ñç^.u)URMØô1©JªnÇÍü9üSÐcn¼N	f½W\ø_àÝD¼ÔÞçD_i<àU~:v¿â	$L}o³Æ~?É­|k×m¥#~òí6;*ã¯×&Z³©PvÐUjÎ¦!BÛCø[à}ÅzUýÆ©Ï$3O.R¼mÏjèõút÷ö±éO%­·YäÌèåÞ?òÕëéôè~(øïÃ^Yl[eÅÄ¢~ëÁ$þ@Öu*ÖúÃ$EZµ¾²á	ð¥<?öO/ÏÏÿ ¹8ÿ ¾s^Qão^x:ýGZMÀc8ÆA"»ÿ ~4ÕµmfãJÔ®¥ºV,Ë£'·Jëþ)iÑßøõÝ5ºQúÕP­ZnJè¨V­F·%Gt|ûáïê%ÔÖÇO<³1Â¨õ5ìZ_Á*c:ä·cçð9«´¸­ü*Ú¾mÌ7ãF3éÅtþ.ÒüGªÛÇ©Ã`:É#3>Ãh£¨ádÅMÕp²G/ðOB",®g¶~ÌÙù^CâÏêÔ½àWL¥Nò5ïþÑüS¤<©®jÐj03Sÿ *Å}.-CÁ2²%¯ïU±È åSC8TQ¹TáQFRæLóïÞÑ<W¢ÞÝjLòÅqå©R£Aíõ®Sø5¥Í«ZÃ§­­îÝòx*O_ò-jõùÿ ²-u¾<ñCxSÃrßDîX[¦âz§_ÂZÕ¾°ã*µ«}aÆóÏü7ð÷ü3.¡³,È6¨f'{ø¯Nð_üúýxCÿ  
ùßÅ<ÕüYkoo¨ÂÂÅ6Î:Â¾ð_üúýxCÿ  
1P©QUÝÃ
£QÝÜðß?òPîë_úzÂÿ KeúæXâñûòÏ?òPîë_ú}§ÿ È6×þ¸§òñhÓåvÓü9F>Wm?ÈùÅú2Ùxêÿ I°YRUHÃ¹f9Py'¯Zôoüì©6»tL¬2a /ü?Ò¹PJøÝs}r37JXc<y`Zú)íõ1%¼Ë$2§Êè{WÄU8(½ÒÔÓ«
pQvºZ|ð¡XÖà>:ùäþç^:øaqá{vÔlçûEÆàTùä{×¤Ú|:¼Ñ5	¯´MvtbÅãæC^æ¸¿iÞ=±±¯5»ÓOögm¡{îSÛð¥B¬ý¢J¥×8z³ö*^fÇÂOé7:5ä_í§+	Þ8éô5ë2Æ³Bñ>vº8ô5óÃoTÆN¡r¶3¶å'Ó­}|Ì}Ë)*ËGPpkle¾ó½Ì1°jûÎ÷ÛÐðï>Ðü+¢YÝiqLËså±yK»Iïô®OÀpñB5¾¥É4rL2®ÙSÈëý+'Rñ³¬BêZÕÜhÛf°¦y¬Úõ©Ò¥É7vzôéMRä»î}}²éwø·ûbò{Fmá¾qù×ÏQt(û+ë{
ÊúÞçÙóÆOù(Sÿ ×¼_Ê+ÊËÿ ò<¬¿øß!ßä Gÿ ^Òÿ !_E·Ý?J(£0þ7È3ã|ëê »?ô¶v,|¢2N{(®¬ËàÕü%ðâ*ê>"Ú ÄÄtôÂñïÇÆ6«´Y©<}æ¢çÂ¼/OÐçÂ¼/OÐê>ÿ ÈUÿ ¯¥ÿ ÐjÇÇ/ùì¿ëðè-E?÷ßßûïÌâ¾
Èí'ý{?ô¯]øHð¯ôvþF)âÿ ÞWÈ1ïKädü'þý¨ÏI$ÿ ÐÚ»ê(®LGñeêÎLGñ¥êÂ¹Ïÿ È­ÿ ×£ÑEE?zOã^§ð+þE­Oþ¿?öE§ürÿ bÇþ¾¿öSEÛÿ 1¿3·þc~g×Öÿ Bÿ ¯ôEÑ|:3?>§übÿ uÿ \"ÿ Ðkè?þA¶¿õÅ?¢æÅ§ùØ¯àÒôÿ #æoòQuúê¿úÖÿ Â­B÷ûGìßkÈ^yhéÛ8¢ë­þíEù¿Ýcè¿#èû£éY¾"PÞÔÃ GÙdàÿ ºh¢¼x|Hñ¡ñ#ç?òR´úîÿ úWÒÚün¿ëÿ #EÝÿ zÙñW§ùÑEíØQEÿÙÿÛ C ÿÛ CÿÂ  ± È ÿÄ              	
ÿÄ             	ÿÚ    ë¯¶{@  P    8Ù@ @  @P P@ O>~üòmÐjÆ"ìr¬;Q«VÀÃL|Ü·   8TPP  ¾u§*êÊW	ÃVcÍãZ,Ý;q;Çð¶K]ßíûIºc' EQ@ yI×9VÛRÁ X¬Hæ#häìÉl%¿EB+^çè([D¡-ï£ú "  (óikú»:<ó©jYLÅ<íÒSmm¬2ÐÖ^7·W¹SÄk©.üÓÞ×7G  @P 8°1gEãÙ»NNuÄ/ëÌtmQ±WR,¹Ù]ðøgÀÿ ¨<çÁxòÍÖW>}4~Õ dÈ 	å@WÚöÕ^Àó,+Ýå¬Ç!£ Pç}Ù&iz<µ4Ñ6ìî%¥¯vï¹<YvÆ\cÒÐ×'ÕåÔà£Åm±¨:®+5òFáõÕusÐM\ûRÆí¦w¿LrvÅG(ã®âËyWZOû{QÎ¯·cwÊ A@²9Úr7æõõÂé7[i¾E7¨õõÇ¥íªM²bçíïYf:N7\"s'Yß[6p 'Pý9­IW¸T1F¨|?)ú½ëg.Ï«/¡ûÕZm×5Ä»ÛÄúAñuÍêÞã |]@QEULÌfòåªÊ±a®Ü]Ý#Î\C-±
ùÅÚ7"³q«åç2V¦Ñ=c¬ºîåhsÉúõ7k@/;D<jòeâ×§bSFJÚyíÔÅd[·_Lfó=iëþ¶ª(åc!Ôn%¯Ëõcûã="tMÎ " ª  :þbËos}yõ·\Z¯%Æum-<YS$]âæ¶5§ªïÕÖtª«i4;NÕäû±5ÿ ´ïP ááTQAD¶¹î·ÄÅ£ps-oSõ£±dÎ»yÕâð·µ£§®wªòXV\÷6·ÞÕ`Î¥¨àU ³ëèäÅÒ·³å¢¨Ñ|ôãï­ëpêÇKÜG®çïüß D  QEP   ùcÇ±¿=¸ýÖì¶µ¨n  @ @@>|( ª (  4Wp;S¹Û
ÂÀ:þÏut @ 8ø@Q@ P1©¿!PÄj-M­ûcGÞMÑl}ìyê     	ÇÏPP  É©kLJÄûllRôå1qÛ×MUXÍ÷ÝØì¹Ø   nL6¦	ÙEbÍ$³fÎ (  Dâ1	dº`Ô@ 5ìJË5fää 1ÓÓnm{-ãþ:òkÔýWéÇy§¡Ò÷«Ý,VöøÞÝ¡ ßÞÌæ»¯äùó¨Ò¹néC¡=íïAT%ÓEÁqVn.xÞýHuõõéþAé[¹¿ÍGtcUåw×ÜöêysL¥ó³E|æôBö¥XÕöÛSOVVm¡¼°¨EÚÛ×lþÁíf°«y¢u	l[}ÏÓôßèoB%ÖmdÂ÷7;wª*m^ÉºZ¸nOIÜïÎ~Yúg§Zråííû+ä^@ñ×]ë79_ÌÇFô¢þ~çÈÞÎÇXVMy2²]lÌÐ­ÍÎÖ+¼mëw!¿1}#Ò²ùkúÍ±ìaÝây¡¡Þ%3Ky¾èNïj¤<u'T ÿÄ /       07@ 8#234PÿÚ  ÿ Ã×]·Û}6Óo_ËÐTÃè³e\Ç®ØÛ¸9Ý&'=l/å¨ºOiËòºé ÌÛ%M¬ÄÃd÷Æ6UÎuMg?xG æXêuÖán8<3º5Úù+àB<ÎÚko/µ¶Þ_×|ôº	9N¦¬ÖÖ¦¬.ê}xÐÎJ*²Y~ÜÖlEgn±¶¹Ï³·©ä²BÄÙÂèpN:bRrJÄÕä·cD$}S¼¡fnCWO¤ñtHOCÅ1¤û+qp¬ý,²Î¿³PuéÁ>¤h3¾A&½õó%E^D5áfpßµ\l^l¨2ÃßL¥Ntû~ãM}£Ób°ªÀè¹MÔyNhwiA¨
ÂpÔ`Ó ä6?fZ0VE`lüv«T¸¢0P!DÃvSnjýý¸22M1°Í*ÐK_(÷MâjòqjJtXb®YPïì5Mö
ÛK	µÝK:ÂFû½¥í}¤ô¤ ºìùWÆ®ñ #:·«Î:õñ,Z
¸ìÆEJZ£S,#í ûµ9WÇÑF¬¼Èd~Y7Ç³§¡×çõqNÝjß>°<Û<0µxF<ûCµÃ "¸é'hRþÉÆÆþ<¿êggaFÍ[¤hùÑ,¯êj¨61£Îñ`ÏWå²:Û]IQi0	GÀ¼eeôe*4Î2©2IÛ9fa{ 2~åiÒ(d:û+CLGnR`O­ÙÞÃÒü#\Hd&ÅíÔÊÀR¦~Ú¦Á!*¯\hiÑ7
yVO6°"®-%&ä8·NÄÐé³ê6`2ÉÈÛci¶Äá¶¡ÌCºÀ<^<]úê÷õ
éTÀégð÷ÿ g¸
ÜÌ#ÿ ½LÕå¾¡ëÅGC¡CÉ·áÅÎD¨Ö2:+ÒáIS(aæ,ÅøX9"Ò=#ÇIÉM÷ÓI5SÏ/Ñ7³ü}åßÜÊM±^bÂ`d\'ÜÉÉD¨ñý¾÷Õªc¤°ñW_vê/ìþòT!È'·äQäN,²qÔ®¹^ëéxÂþîÃ·~F	Å·þE¬,ê·Ûÿ $YC±võÉUá*!ãÝ¸ò®|'q¢"äo{uþ¡uÏÿ ¼yV;~äk8»läµPøñç!<qTjO PñÃ%bÈ:,X×òz\ÀFËÆ¶æÏ}Æ×pûý?q/l%ÎÃ»äÇ¼|«/L¹Tãå?ÈëØüZê(÷ñW_ë¢W»¸ØÇ¨Ö9¬\#|{Ú7]Äþc?ÒºÕv­s¢²Üywº°-M6Õq±Ý-³ØÒÅ$²M'|yÈÿ !½øo>#íSä.íÿ àíkãùCáÌä/=|K×#üyÚ7]ÕüÚ÷ýþ»ùSþ<ñÿÄ P     !1"A2Qaq#B¡ $0356Rrs±²@TbÁðCD¢³ÂÃÑÒá%7tñÿÚ ?ü0}<¦±xÜH;Hí?Í¤¡%k0óHh¾µ &gHÞgËÛgcÍ¶í;É_0( 	XNöñßË4¾×­0¦iÔrÜ)ImI ©2|R üáíÿ I_}P1Ñ8´T<½bÄÖQ&LOÓ1ubxíº¼¶ïzúªA*L¢áb°ÚAN¶êuIv¶ÓJë©ªHI"â¤¹2ìÊ6¥smD0`ïþ;íüË¸ï¨äIaÖIXR¡=Õiëí5ÚÒ2ÿ -
Pn2].6¦ü"N ÍÃeDo8ªâÿ Ø¯£×âBB¾tç®qYTTÓ3¨PUi(P¥$®6Ð¤D\DÁÅ0¥BÍ*Ä*Ô¨:$öÒuÅ=-}6Drz-³ÔÙZ²%\N½«Ì	9²ýsÄPBI\+uÉ*[ÕºO0hqqÝNH}YêtªkUJBÍ¥2dTnÄpæ|îlÂZÝ ®?xÝ(Q=vìNÓ¶Ì+s~(¤Vc^m#KÌJAå¤âÛ=3°	

¸6ólýfm¸Á®R@X½)¼§º|
 ~l'{zÍT:©äÀBQD$O}bÀa-%E³¦³ÎÓÿ 2Pu/AÁ3ßÈÂ(Ã.%ÔQþùkêØy¤­²Qà)Ð$ª.Ó¼ÈÌó¼ßéU)(SE)RB ¸B¤ÁÐnVÉ8_U"©·*®uâPb:tV	­@Ø;b,§¬áïSËT¥Ö¡n¯VxÛ#4ÑBmEÊTÌëÞkgYvSU½S\T§RêÑù²T -	REö mvXîbíU´ßî«ïðyqIXWÊ¬6RUÔvØ{~BD«lzSÎs²÷ØËêiÕ¥
Jí×JAÞ%7,³ikÜnºìRÊ9Ë#±q6·)nù)¸¢fáé½	f\*2Oy>g¿¿¿¿æ;-,vú4ÿ cRHð¤tÓA¦¸¨©M+í¶p2´týXeÇjâêãC:påeb)§ERÐÀ2¤ Âú5J1;ÈP³O´¤¤ÈB«~L"õ7Ø°Yé8kêÂ´´wpmiæPM×ju¤ÿ v2¹Æõ
Õ­O¬BÈPlÔô§¶ÀÅofRÑ:¶.'Cå;OÓø.#ÎånWt+XnýDUÞ6öáßQâ¦ië]æ´³ 2à]¨ n¥$Ln'ç§:¦S©rÊî_,8&øOê ¸Íøàðd¬ô²ÂM¡%i¢±wôm²D*s§*éfáRÒ@Ö¤£hB
ãÈÛ®c.«aöw¡¾H ÀØ±tùè£@)["=Ài§ÙñRÛn?xíôÍÅ3#´~)BMÀuOÿ ¸¯¡õúoT.Lj7Î2úÆêé~Q¨>d1â¸¦wïán2}U<³TÙZùiW0¸,0­R»HÐ[n§ës²ø+v°<±mIâ	Q7íQE³1q]²ï6jWL²ÛAHt÷æ<jnÜR0Û­<ÙP#Øgð<aÁ?ÒT¿8ïâã¤`I¾PÞ «O#:ÆQ^Åc,ÐekMMe* æ¼ÛÌ%7 fÁ¸ÕÈ>(±Tå9JZ	o	\T¸ºí7êógNy[[8ü-©J!3ÒTMÈVi¶·ä­äS¥·¾ýQ_- Ü9JðÞ	 meX¦¦RP¬n©Pç±4ÖuÔé¾ËBúNáe»}ø¨diPO.ÓÊ¥£ä©Ògü}âgpn8«]`Xm$h5öÿ ã¦©á¶TRÝ±h&'RD+«´Çº)²ª4*
%õØmBHë
M³x?á'=6VÎ^â³wTnJ`Ú¤+H²§rz`âÛ/U:sÕå)uiJR¶ËIëYR¾rMÂþT(°BN§&VÖK5·À!!72Àñä¹e%];u1V*UÐ|¡¼j4×IÆCÄ4yHÙ?Ê:ó\u1pØBza*²6ÜLpðËxÝU¨|ópZeR$¤J¢õ¥l	2£,dõÁÕ:Åu;| ` ÂÔ Ò9¨êKLuhÑz	JùÃx¤Nÿ :ÙÅ	S¶åÊ·"íuöëQÐwuQÝXå§¾¦4Kiï?øÀ¤t×·WÎ0ö3ýÃËéÃ(I)>_O¿ÏYKÉM-\ÄrÂ¯¤ÜuÄttôÖ¼ÒªªUv°U¯QÖ$û@=äÁò1V+9¤zz­=º¡*Qï¼@»±P÷Þ8'2cYMÄd,%NçUÚ¦§	^®(Ü|:é®îgðñ§pÏghr´#0¢¨6nY¹ ¢æÇVs@ÜÓHý^Zâi©JÕ¨Ué
Î·ÓØyÌâ¹91üº[-¥!"uV×¦R©e@D©:çÙ­NlPõæÀSä£ ®vU³áùØf±-UµGQªÊJí=]ö1Ý¶ÓSµ¦]@nëÔ#Ì :	tï¦É}¤>Ò¥*÷·Ü¸Æafõ*è¼rú6ÆÉPT@#¼pB¬ïÈO-[(¡(ê:ùwÂ*¦¡»º3$inL} t8 ®i¯XËÝ@PtÐOJ¨ðëôîpÍU¹òUpJÛC/Â¥ÜGRBT
IÊG\ª\ÅÊe;Ë§VR¢àÍªP

iTÁ1n¥TLÔS8QFQêëi(RDÊvö¦×HÛáN'î3³:²çÔBII´Á¼Úcx'$ôbÝesÕI]KÄ¥µ8 [Ô´Î§©](4ÇðK4¹Í´íE7.åh¯kh¢H~rbÝqÄuY&TÆZ[KXKéOEÃ¥Fzn¨×´T¬)×uCKå¸¨YA"ÅMòN¶¨êFKú³¿åuè(¬B\w½÷nä*éGº.}£nóðrVnâ u#~úÎ§U
£«	ZaÔÊÒW'Ù±·HBJS+¸ojòêÐHÕ;¨I'_ê	YH	êÐÁs./CüÈ±[n#RmÞØ×^úyÊZR>!ª`Û;÷Ó÷÷Âx#Pâ*«)OÅn5ÉÔ¨o`X27V±Ø,m,õ|è9Âp@l%*]Êt7k{ÃfÄª/@'¶3ÌÚ+z¡½ÝÐ¢DÁZi2M°5¶(Ý[´:äÜR¢£¸ì|ÇlOà*x|;ù6BB.m®-N¥*1 Ißò¶ÚÍÌ+Ô¥Ò¸<
*(æ'T§õg®ÉÖÕ{°ý*hyÜ¤9~á^# Rí0à
l¹A@õEbóZ¥!56-(X¸ªÓ%N\a^HBcld¾³2ºå)-ZJãQÐT(UÌ¸+ôg¥xÎr¼oúÕè§¦a
.¥FulJTd(»p·¸ò§zÃ4óÍzÃ/R$¤%Å®Ä$­Rÿ SiÐ¥úÃEi¡¦4Û}p9V#éþì%¥HHnãÛî|d|SQOXíg$¥¥Ä$¬¥÷ÖdÌ:ÌÞ{ôÆT¬¿ÖÐÅJLr×EÄé:)ÀÆMVæôôo £cm({À"}ã!U]ÂÈg(âòÚ|¬´I*
«E$û~ªª:î®TÊu³c)(IaK\.Å)IQJ´06Åy·FÌ©IZNËRèAT5³uh±CUf/ÓçN)ÏT+-XÀv[¿(£nÃÈãu}Ìâq8qßQWU¤(²n#å¡f|>Í~òc0¥_!Þ}Ë%°&u¥&ôGn¢¤¤â·5ÌTÊ3:~HmnZ¡Ka/$AºÔ÷JÎ§Å# -L+Ú¥ç¶Ò 1:á§23;gmKÆT#ÂB¢í/·¨@>ÒÇq^]åmRVk¨©@rfâ-LÁ¿p²IÚx$É¥dÔÛÕW¤&tRoNä¦ÕZ¹;¨d=8àì²»3ÌÝk+úQ)\Lu¡*ÓÌ ª&u¡ ²::)ªrVË É*ó88Y5k«m¢¥]PÚ$é°:vgõJ¦â&3t³4´z:Gbè½´«Þ<´âÒ½Z¬­Ô8[Zôæ¶¦Ö¶QBFÎ*ø«Ë¢R
éB¤»ÔN Ô©Ò{¤#Ò}FVý1/t	;J5tÈÌ{+²õÐ8/½N:»Qt$ÚRO+tþhN'îø³²-¦b°ÛCé}VtóIIJõ¤IßM#|U/&á6é(RÃ=@)E)¥7.z>gI;c²!â<áª.EòÑJ
Ð
ºz»Î8cr¿v½°òR¤«r@Ö&Î¥¾jdøkò`ù¥­mÊ.	ÒB.3 &'´[ìËr·m)qE5ÐHI'ªHNÚ(Fø¨§¨Îx95c%*¬ÌØm6Fkq¸ÃZEe#4ªk`×·ûôú'mÑR¹V÷ 7>À;°ÎËóê
î}÷úçòU	X/T¥GO!08·1ÌZÌ²üêÓFR¢VJR`o²®À"Ãá>e»kÕiùKûAQ½6ó$yj<<'ä<=´ BÒ¤é)LnwØ $o~ÝÞ¯Ï^v5«p¶$¥ZBÂ¬XUn¾xã¬Å
­o.¤m*qÁjéùï!gÂ@&é#AÚAÅ
6ßÊ²îKm[R¿~»	PI0
UvÚâ*ó'¨³zÛÔá.ÚD¤¶«· ¤@	·IS+DÂ¨
\\Rs-¢¹ßÇnßF+=å5¢s6T¤uó±_³ºDê 4#M0Õj·ôUO5U^A	úÉ?ðàÌi¾3JPæK^RNªmµÞaD%+êJtMÀvÆKGYSJxYSm2ç)N·"ÑxXæ`¸±w0%F+TÂCÃ5u^][ú#V<ËIÜÆ!IZ¿Wm-e~j¨5nT¦þ[ÐwVÖ&?KêÔ2^«{1¢D<ìN²¢'P5>Ó¤í÷sÄâq83À´í×Ô¡j½Æìå÷¸R=È Bº BDøxTRÑ¥µó9¤EÊ17y ÆßYÇ¯­ÑÝDý¸ôR¡÷ò?gÿ ÁÄù%I²»O®-Aµ8wCk&å§Ú	ÔUlFÊ2VrÒ²TCdìËT~±¾ÀÃàN'ÄüüÆW¸á¢#Ïßõqú)ýÿ OÜN'Äâq8zAÏ~+ÉUHÂ¾]îæóÕÓý¬#¤upG5g!u*¶Ájð ÷ò'¹æM\ï"©µ¯É*ýXN'Äþ2Í(rcW^å©ûIò¹Åg¤¼Þ²¡Ldtý;µû û ûÎ)¸O8¼TæhR¼N9¸Äïî»¦PÅ?üAHTQÌJ1:Äös¦õÇðªøf±!¢¥S/Â£çÝ&4ãiã! Í©Á£Ì9uàèA=­X;ý³=1®8B»¹®e\DÂºßX¶áÒ¯0F»ÏàçÄâq8N*8+0Ï3æ<EP9 PðöbßlI>x¦¦¥¢dSÒ6ØpuÍxÂ¿<¨Õ--QúÊ$© ýy¦*Z,Ô )pDïÿ £'.¯È	iñ­0åú'ì÷oâæí+-Ì4«kyùÑ¡þÐùß_N'Äâq?ù@á/éì9ÿ f'qÂô¥¨© c`ìßÕ,ÕÓ¢ªÊóH:ëÄâ~äê#Ã®ðæ^¶jTêÕ&6ý~8«:n²ÁëèÇÝ ¤d¼ñqQòþ4vËæÞ*b'ÂÆUeÙÕ9ªË½ Û0¡¬ó=Æ'ÅNcEF¦Ûªt%K!)ê¢L ¿êïÄâ~åÿ Ngÿ µõÆ|ãog´ R]p5 ùa<EIÃ1ÔV¶µ!M6: 0y`ë*NúÇ»?Åw}D(âBÌD)^XÎ¸ï'ÈëÕU!Å-16¨ê½¬âÜ¾%c=}·9N Ý¨Q¢Oq=!pëÔj¬qJ@!@\£ì	*ÓÌÆ[ÇÜ=ÔT-HYÐ^ ¤=ÓcÇü9<X.7°OÛ }¸Ëý ðæ`ðc[QÚñëôÊ¶èhÝ®wT6£ÂDéH¹sªn@JJXL@÷(òÓSrò»âú»õ:§H÷?lc8(l×ñzCþOýéñï;üå¼«?©7_ôD{qÀ_üNçÄÎW0Ï6Û®µY¤D{fqñÿ å¯bµ8¡½>@ú(ý#ðÝ[¡¥·=Ö}`ª?v3Þ ¢áú$faJmJ	AÜ:")3WFtÆm­K(q
QÝD%@é'êØc ÏèøU´IPHQOP È ö'MqÅtôïg¯<óì¸òNº¶h=@7=õ8áGZébëH>5\¡Ôt»Idÿ V>äDÿ m¿ûñPÃ´µ¥|BÐJHò ÁÛMðîV3b¾Ce?¬>½½Ç3Pâ4°¿  û÷h§ÜÎ"â·×ù×`~¬À?Bqé-¦Øáªvº=ÁµpÐçõO¯1Õ¶zf$ªw#XqÆy%6CZ?Å)!`bdDûÆ3^ ªÿ 'lVü«°Ù=þpWÒB×Ìª9ÄqmÆDj}¦ä«ãµ	s Cn5Jãa¹Z{ñæ.æ*¹æTÛo"}> @ú1eîfÙ9sf'Èw?@×;Â9w¼ãô«R°Th;Ä¾PÇþpPþÙ¯ãô±þþ·þ^=´óü[ONaÅ-ÀäKHíÃdÙ¢~2¦¸¶z^ïýãqïWÖzÅuÙµ|BOÕõa9Og9+`sijí#pnÒH¶Ñ¦2fªÍéij¡n!$y ÞÌeyN]Ó\±»MÑ*:À8Àb§.Ë«Ì«§BÕæ¤¤þñ¡!ÃÄ?ë¿lçñp÷ä
Ø·ü_íòûÌp/ç]'öÿ Ý«? 3ûdÿ ôSøÊïsñãÒoç
?dâ^3_ý´¡ý§÷»ððæiþ»ýÊqÀßTõ¾ü¿Cûfÿ cÒ¿úúßùxô_ùïÛ+øÇ¤ÏÄ·ðz;üØoõûñÃßèlßñ¸ÿÄ R    !"1A2#Qa 035BRqs¡²6Cr$@DTb¢±³ÃÑ%&47tÁÂÒðÿÚ ?ürÔ@Ó52¸2.	\|c>àÊ]Î âZ ª§p±(ÜX($  êO8§ÔZÊxjhjREKEµóõ&>½ØõÇ®i±5];ÁNÊÅÞRªbe#
ê{ÙHÁN/^*KOYk¦°Û%*ªVìjúÉqÉ0r@^¸ÉnJnpø«eÖ}²I\	1ÊßòOFÝëlu+ÞPà2îöºZè­5(µ2)eáFXªgsI×UÞÛ|£LÂHI 0òÊâ>¿1ÓüÄïéôô?TQÏ
£WmíQäVïR½Ã'õrN8ûþ´ÖÇµhäü ¥i)åòcq!pw	Tc%J¿eâ ÓÊ½?*69$Uuc|X	Ú¬sNî£¨}ÜZ5MÞùe£ ¸mF%UÊ3¯S×aò+·ò8áZåI©ãEVf£DåE÷32KÜOP¤|Ýx.qi¯«¢È»¡æ4²%¹Í¸Z÷<Ã¸KÖ×ÚÛ­uÄ4òL£Cct³LÝ Éê7âDö1ËzenW("awäá÷ÛÑÜéQ& ¦k!åÔDæ91Q}ôÏYÒØ qÓüõ©üI¡©®¹[è×âÈ*B¿´a_Ù'i§¦ÚcÌÅ"¿7vVEkii.ÚÖÑ¦oôUýðJ	1HáHÛÝ}ËLbÉÔ¦ÐFâuíª+õÖ¥?9VÖJÃKH1ïmÝ*®	ÚDc #ã´ÜìÒR
oÊ`2ª®åb»»·\ý"}?Kx³ÖØ~ø`·ÑóayR^X8Û2.Ç¼N`TÃ©ë"Dm=º§ÐçAòê~³4·×¯DG21}GPR9Aò1~ÜbÇf¹Ô·­_¦këªd0ÉN«ÌHà2T2²´D±@ùìÞØT'e6¤¸Þé öVæ{$S Fà²G&ÃîÊ2»Æ20GZ¢¸iv¡´HÍ^ÌÏdÈæ¯×jofÏÃÃ[¯Ö=K`µê½]eÉ^IDqmM¸lÝ!d.®È)!îPÖÉ.RÑ«]¢Xçõ
Ûê8º^híNµ{¾YÄkµKwã8ò<þ@>\xÏªê#´Ö­=Ââ¥î}ÛÔ»§aËæCÞÁHÎÉüBó§ÕAµID ;
xvÁ¹bwÉ]íïyzþýKMö]:ð»ÔìçsÍg20bs£Ìç¡kÎ¼´è«Í6ZVxêNÒÑåþQýå>ã´7©Ó5aQGÊðs@PÇ¿,<BõH+¤µìºfm¸4uõM¿©.c*¬A±»qr=ÐÃ Ï³üSa[mK"Î¤ÆbÞû³|¡õóp£ â×â%ÊåW=-lÝ%ÑYH.qpX©]±`v ËRYlVÍP*ÓúJX£¤$¤ÌPòÝ:áYÛÞ4·ü>hê;W3sSbxe1P78·`®öþ±_Ð=²HGÆÎíQ `Â"@ÜáFÕÏNösÅê×s¨ß0wí|gµÏG¨ÏOÅj[äZzÓ%Åoê¼óÚºgæúx¯¥¶kZJz±$mú0ÊªÑïê<lX¡ïR[§FãUhù5%®V¤©]&%¨U$!8ÝØ[ª£ao&óÏ^/¾+C¢oi
(¤Ò¬	&PÆfBÈÆPpØ÷ÄRlÕß|t:uÉ-W2h \ ËÙP~P,{Â$ÜñCrjýJºkY(123Ä1[çIæcÖMìýÒu^.uÔõkk°UDÓ{>õA&	<6V
W*Ië»Ô5v ¹è`«Dxbm\&$
`FÙ6£¼ØÏQÆ±Ï´\ªê$ö£8yVg$ô(Ò#}¥r£È Û·X|C£»\Ç.z#àdä2z¿^Ç¢Ûâ¥Ò:ê#t$CË Þ»äqÑJä;/PÌ¾xÚZÝ&¬¤Ú&ÙçÚ¾ Ã OMû{:¶ºj+¤ø¹Ñ/#µÅ60àlR"[3|ª²üWdÐúÚ³äÖ¦­²rNsËògky}Ôb>æÝyÔë$
»HXIHÙNcs"1nb®F{ÜÊ%â=QjÓÔjX½­é$h¡XZ'È¼7þå²GËË¾>ÁÏàkaÕ5O{iv¶öÁfR.ª_*<Õ·`qiºÒÖÃ¢Ã*U\¨£UæNrÀ¥À;¶c$þì*xÒgNèÝ1­¶RÇîîs($î}äî%Á 5'\SêS¬jµK*½-&`	$$n#DÕ Eé_îª:îdÕzmKJMÊGº5DÍVÙ¤`9c1ÆHEêÛÝÀ#GIr´¬·Ù1Í>e¡¥Î¹g$íâ:í:Z(Ö¥©ÙDa§Xú!è¸\°ÎÕÇ2O=¦PÅ\=oÙòjü®vÆ9p Ø¶½A©µMM
Ò-;DwróÊïes¾½iÆáçÄ÷OÆ¶ßª¡:xãÌuèª§«(ÊÙ@Ø;	OOn(®ÚJ¿OKtzçÀ¤»Ü`d`÷cÈy¦§RÚad4Ò*wBGs¨U}Ö_|÷¯^)týfBªÆâVFèølÀèX2ÍÅö[j-T5Í]G%EA$Q±ÍBVæô!Hê	é°¯àîÖºrEñ6G·°$©S96#y÷?L+é lRÓÉ­$Ó4U­q4R&$¼äå[,!±w/,v°ëÆ³Ã`³ÁiËP¸ÄS¿~þ°ñOÚ­÷tÛ.I6ó·`a©GSÔ2;ÆÜñoñ7Hh¸dÔ´ü(®¦ª2³¶4æ4I&ìÚ¯ÊèÍÛÊéüU¢qéë"öÅ'6SjÇW¾Ã$Êð»7ÁÄ6«º[.SODª}¦£¾ÞòÌ´]èP¨á)9÷lvË¦ÑZ%qÈ1îi#©Áæ  sO=¸!xº_îÞýïóknÛ8t;®ñ{=À{Ê;Pñg´j©+.¢aW04<´ÈeÙòaÚ"-º6$d£ñ-ÒºÙ_]{Òôm+GÊj¤+ÛÀ=CÓ`ðw1R¶÷Yxª¦Ô3²æ*t	µ;÷£9#·®I/»wFÁ¼iCL¶Å_1v7híËy«¦OCîÇx©ó9°i,,4zô³¦i:Hï³pûÁ v·n:i;,:nß³YêKÈÀo%PÉ=»FÅw*]5M¥4ä­2IÂ¯/^c¸&âJÒcÔe ÉØSQ\.}þ¹ZxL£¢PB3î;¸Ý±Æìmo¿hµe²áñ$þÅ$kÎ§W,»ß
Î1æJ¨8,RÇ ´Ë×ÒëAJ?-}|730Í+³å¤b\õ@£wÏÓñÄx 47ÚUÛëýùD÷¦*j
<K"ý£ÞW8XàáÛEMº·W<õ5®ôõaðñSµhç^ÿ $Ü# ùO×ÅWÚ<2¨»Ñi±Pò@ñ?,È$5[ªµ:lq²!HÄ}d1-¨µ¬ÚäRÜt³ÕHÕ1'nÝ£{@Á»ö½üÅ?JóSp¢1ÐÑ×Ô$,Ä«²îÛ6naË/ÎOÛþj{}ÖuJZiÌJVIÄ»¸SÒ8ðÔ6íÇ#ýoWA5mfjX©ÙLE¤»²·»·*©ÑI}®@Þ¢-M¤Æ+[ì\'e÷fÂÌdMÊp\Å=WGèQÒd¸&hÎ"(pdfäsw*´Lwç¬4wkæêúæ§äùHÊ3G$R+EI@¸Êõ¶kª;Þ«{Uª99pîZ
abp{UàvÈTå03¦®7C{×~²´vÐÏ¶aPsDÝ­±0vçzáo²ÏKt²Öé­EH³,À
¹~r®YpS<ó×Ã:Ëæ¼Uiïøå4â9
H»g;ÙrÛEGÆá)bø@Xh;5-£QÔÀ=lÑò**Dk!& Ç$¿'&ÐëQËè}PÆÆ&ÂãÃZ¹n¶:{
IKD¢H}zuX¤VÃÒ@«!Æ?u·Ew¶Ïk¨fXåRQ¶¶`íaÔz£ÓáõÂHkkÞ¬IW9)ÊÛXÆ4ýÍÜÃ;wÂv5vÉõ£M4Û6{ÛÎ,ægI	,²6õUrÀÜµN_Q­*,6§KmJËÑ$ÊÁ%u(#Y{$`Ça=FãÅU¾Óh·|Z¬^ªÉ/.C²w$oo6Á\áÓóeMA¬*#b¥`Ý	åIæÈe!6U¸y4Ë^!ªØqKJ*¹ .YäúgèxÕBëvå¦ë<\ØåÃ[ª<ª+H ÜpVË.ôc´õYKt·[HX§£«,Ï 2IÙÐà dvXâÁ©íKm5®´72=Ê$ ¹rîVîRWÌtÇJ:`ht»YWsª»©Á#¨û8·Òë{Ýî_µ<ûgçBñ´QÏP¥7çäBU0ªU3	:bÙ5Æynºz·GM2&Â$)À.ó°AU!,¥
²y²³Ò××üqY<±Jôø#RÌåeS¬¼²Ê]OPÀ-»?ÜÇ[-Æ²xd[§ÞDïtÚ7Ä$æ¶BË&:Y ;x±Z¤¿@ÔJ½±/*F.õB°\Bá»²ó#Û=qÅöºíCg±;YyØ Ø22#vç$íÀëåÅ5$RÉÅA9=G¨ô?8ôü,ñ3ÅEe¿¶ ¡"DÜ3·lÒüÊÀ(ÃNsÇÝf¤ÓºÂÄ-KY3Y9Ed¦of+«Gº?Ò\ü³.í¸úcÕpÑSQ¾Íxå$2>ßÊmq³cF"Þ`ìF¶ÓÜn)¨.²D'4lolîæÝI'C( w6ÿ zÔb®yc2òPËµCÇe)XK¼¸@{Òíá¦\Óë=3<4VúHg5(F6{º£¼ÜÀ2Ýë³nRÍ](¶Á^±û]FèÑR=½ÁÆH9g Ú¦G$(î¦Ýr«'Ø»wå@æaz0Ã`»|úñ¨¦ÕUK°à` ÛY)léFÂzyã8Ül´ÓIKµ=¸U3²;6³°Y³ux²x¡uÓ¨[Í¼3CvUÎbª0cFuæÀÎvÙ©-Qê4´uTI+SªLëMRÒ¶ÌdOBK áJîð«I\n:ªñÔË9§<ÀH¤I+F»¿$r1eø'wÕ_t=WÓxª!¸S¬rÙ #};~«·P[¯õÔoJó@Ü¹cØQM<>Ù9lÌw1GèÝ výAvGu¥f]ï0í9Äße··»gF~Ühýq[­¦¥×TóT-¤`öaÊ)ílrò/E
r]@êsÆxÏü/5Õ%Ê£Z$zjTÀRØBVGG@Äà¸ãqÙçá6°ÀlurUR/ýdXb´ddNdb1!lo2Æ¼x©}ÕÕ÷j=9[ÔPÒÖoE«\Bë(Û3B%ÙUÞÊ_Èxâe=,R,Q¤pÇRícß.çå0Ãî\ÉÁwi{´i¸´~ª\È²óÕ6¤í b\äo ±í
wù2±4·zoN[¡´WÊ«´ÓÌÅTÀì\©¹ `ä$glÁÕv}9K:ÜæëKÆ¨ND.émJ°Y2¥O¾¬9°l¨æ7\dñáUñs¿NjëàäÀæÂc#«DÎ9°ØÈÈ¨°PVÃIo"E´Yw6	;n$ñpû|#¹]Ö{{+i
: ì-Úv·-{|R»I<jdUÑê$u%¿"b<Ç´ ]ÊIå.ÂØôo£¦­»Ð×RÓVZ¤ILNKôæ£tvxÁ@Ü2½	Î^/^1Ú Ôzö¿i¸8ÛBM®võ2îzÝ#0ÀRØ¼Vøëu²iª¸%³É-|rÆRd\í;
É0Ûj1ÉRé¤.WåÓÓÛ+ÙX¦Mò¼ÏM'|jUaWnpCy×Øµí=¶é¹!¡*GÛÍ(m¡²7>8 Si?,töKqSSÑQF¢A"®ésò»¸îbA'¼,ñ]xE~¤«æ[ßSÜGMR%Dpæ=ÙAÌÏFR8ðëÀÝMf¿M©i£¸E_4sHTw#
À*¶%}Ç, ì«¥ÐzæÃ]]#ËC½PWÄ[Ó.Óè1·f§VÖÓSZ¥µÕÓXe`áï<%¥#¨Eh·«LUPÄ)ÄQÔÝé+õGví>ÕW+>Xæ&DA¢ß´2÷eýðýHóÀ¼Iº¡öùuãî}¨ÍêºP!½Óô¶A_¡[èø+jâ¡¤²ou=:ôêO©=½Eo¸hººc~{ÆÇ ÍÌmÊØÇÈç°0¸5u÷MÞlú²(ÐØyr4ó¦æ=Æ%&Üó9¥Ô*dvo¼É.×ÑÒQhÊà½É#©¤f³.éäAÞ¢,«u|d4[¼Ì~ø{¦ëmw?5Z¹)êDË*3,IA»cÐG ¢ÈÓø9ø3ÆxÏã=:q¬<(¼øÚwR]*#¦¢	RUØ9ëÑåÆª,lY»¯ñsWÓÁ¨mº.ÛËöÛ1;bF£cÐÈ¨K:nEëâ?o"ïnðöÏA}IöÚjÆpw2çg-dxãq$¢\BIy[·czÔZÉ¬ãU³àwáF§
ªÇ$g,Á6åC¶bYa¤Q±dXÓl"íÄÀ{áF
ý?GN+<ÓRêµÕvùæÞÑ,Hç,¸À={IÁìp ÀÀãQf±¢?Hû8û Ïr®ýU?õ?Ãoñàç¾|\î^^M7pxÅdc{CÜ+0Xå!NÑ¸«ÚÅ[=¼ZmµuÔm£ãP¿%¥·jAÎmÝÒH»¹¡öÊË#äÚË¢j¯Õ%îÔ)-J ¬mÍUÏW lr,q³ èWxk÷*ÔhN¢æ¿ÏD%£RB³C"no`U
2~O,»é_tÎ¯ª¼Z©ÂTÔí2ä ©¡Fãõcæã<gñÄÙ|6}mYWgýZÆ´XË
:MPÒ¶æÞÉ¼VY>U!uðkÃ[ÅeÂªÕ¤UFÊ6ü¨ÁîÇ¼JÒFqçñ3Æ©Ou_BXý¤ñ÷:6)î±~äÿ ½ã<kí)t5TúBÑAñ¼<µ¾:Gv2´}Ã½Kg=NÜ®;x²Ù#³Ak!gÇ-Ü°@réýAøñ3øÈ±úºiZfyq÷=Á4U·qÐ¢3|ü<ñ3ÆxÏágñ3ÇZâM<ðÂàM7oP¿¦ßgOÚx®T«¨D qoO£¯M¥õËá`v¸ÇÍî·ÔqI~³\%äPÕFïó+©?fxÏüF?xÏâó|µØ(ZãvGùý~=OÐ8«ñ[U]å)¥hÄ}ÖpYÏÌv©Àé×x@ëSsJÍBí´à±pú¾gè qq°ÐÑj£e¡S·q»»h>y8×:FM9T$¥^dL;Y¼óê¤_QåûjÇf¿@©I]ì×u=#nÜ·¦ÆÝÝ£¸~¯¯"ã¬EDÖ]ULÝ+7£ui>Dú=Ïã<gñÁÏüEWUzþ÷}YS¾~N$Î!×Ë>m}x¥¥¦¢SÒFàÑôé««¯sõ;cûLHbü8j#0Ô d>`õ5WÖËmWgù9ÇUË#õO®<º><?Ö{ìm¸@:ýbßC'?_^3ÆxûýÒåêIÿ ãà¨ÖÚf¡ég©Ã¡*FÉ:p||SÔEUNTç(à0?8##Ï¯Á3ÆxÏã<ÆÓÒéÛ{ÃRÀÊí/Ïëã<g{ö«½E]NàÖ·b¶É;°1î×Ë'íÇmAj±òþ4füíícc>è?8â×x·Þ©ÍU¶MèÜà½éèGã?MÂ£ªP¬ä*RIÀ yÿ ý×ð~ø¬åÐÿ î'üø¾É×ºÉb9S,Ô\àÂê*M;¦mÕ±»#Gì àòÁë_>¸ýX5E»Q}0) yçÃÎº³Ù+ÚÝT3®3´)F}Xz}VjÛ}äñÉÊwPÄ7c/Ïê8Ä=5#VHY 8Ã¸úô
[§ÒqÅ·^éëH¥FdcÐoë¾ÇÁq×ºvÝ)Èdaç°gøäãÅ¿_éÊùD;Ìl|·´ÖGQÑQË[/TE,qçéÅvé0èKÁqûüÃO}gh½×{}ýOUéëæ{óýï£þqÇ?z|yÎþ³o+gùÝ¿êÆ>4Äÿ Iñ/3Ì9æíÝ»j~¯LcNsÅË^éëlæ¹ÀûIì<Qø§*å9xóêàcí±ÅóPQX(¾¨3#0Q³Ì¤`qIt^`ºÜ¤Ì|Ø`zgøzqb¿ÑêF­¢V
ovÈ úóñª §û4ÓOBü²¼lh= Ã¯¯SÆ)¬ÒÁ»iß;wºd%ÿ 7Þ«ÿ %ÿ ^?ÿ |TA-,ïK8Ã¡*GÌAÁòâK_Ç
 ;ùþÐ@GÛåû\=Q,îÊ
}~cø}|Ws5©bþ¶\ìç ýJ8ñ&$MÓÁÂ¬ªìühM9E~ªîcÜã%³ê:ôÁòãXÙiìWKIù6PÀLäc?´qt¿Õsè+ü¬¸_ÒõíâÉ%*üéóúNå?g·±KP¯aGHñÕ_AÜÝ?o+µþUsZ8æLý2>À@ú¸´ÛäºÜ¡·Fpd8ÏÌ=OÔ:ñ§´Ié]Ý>0O³?ùþ÷Ñÿ 8ãÅ_ñô¿ðøÐ1M>¬âFy ?I þ<AºÏs_i÷ÏtoÓ?·ý£Ì~ÑÀ¸èªêÏh­£ }#`Söã
~Ï³´Ø/6h) æÒ.
w7¦GsÓ$`ùyc§x"ª»ÒÒÎ2")8,òâÙi·Ù 4¶Øö!;±zàÒ'æT[­õ®r?YAÿ háUQB À üÿ ]ûé?ñ§ÿ 0Pþæ?äQKcÿ Ä÷hoéU'íoän<OüÁïù$ãÂ¿ÊW~Èÿ ûñâ_ô?t¿Ìü]?îÖ÷üËðéèÏý7ûãCÿ Ji?k#|óýï£þqÇ¿âéáñáæ	¿|ßÉ%~J?ÃÏèÌÚöñ§ÿ ?Q~ú?çàñÿÄ X 	   !"12AQ#aq$0B3Rv´ @brs¡±ð%6c¢¥µÁÅÔá4CEPSduw³ÂÃÑÓñÿÚ  ?ÿ Ä TÈ×Lz"hÒÄ;y¦li[S#yQ¼9z§Nµ!Ósq$0· ßUoé¢ä)]ñZî´níî.ý	WlwO4[*ÈÙ«BX¸û´_KéVâ½×÷Rb£HtH¾U@L¬ñtOËXÄ	õ1DGBöED$ºâ¿O%ENºãyJ²ê1Ú&ChâØW¥÷þùAvÑFhVL(,fæÜu3[/ÃÒèÕ6ìwcNzr<µiü8(Õ=TVØúêKL ¸Ü$âÉ¬]®ëd-ÕuÝ¢;(äxÔ@A¦ðUqIQ¢%÷òMµ<æQÜÿ ¦KÈVPþ5¹ºk[
ßÅeé}¿xHZc\¦$¸6ã3# ú;ë}DTîaÑu_«w¹K±4Ô»Â¯©½Ôé´/ª½6zRH»N*ä¿hZZ9÷TpE?ÈºôEVç¿9D"£æÃï8ã8ª d#ÄQ,~«ñÔ¹2¥ÌîRØ¶7©¦â8àªXQ3+¸<WÇÉt<n º,ô¢AURÅ,6ð§Rò·£%êªÄ8,¸	0ÚqË¡¥Ð6²ÊÆK­¼Ö,IÃýñ#´È¼¢ÃòÅ»<iÏæ¨=yºèÜeàÞg¬P8(KÃ&ExÄyÞçkzYzé²}
C`çzlçrË½¿¯Ç®ªMFÈ¤äóO:faKVÞoèM&h^h%}Xò\±ä<oæ¾ñûðe«ò,ûD¨®Hol¡UÝPEÅ¾Þ_Tb1UÙ¡Ý0qXQÍÏíìTêÀN5³=ý0&Téîb/ºÒ_%·Ã~ºj·Pï1!?Lø!9°lÝn=Ç7µ¼9[DUÐRLM©L»ªÝ4)8*ê¶;ïÄºªßO->ÅBLk»J0dbÉäßdmG/1]×R¥pª@îðÃNof½ýÎÜª©t%U[ßTè¶sWaqøRÚ!ö"³ÕîÙÄ^nUô¾ Ðr,Z&¬ãòQY^;Ns´æN¥®8¡uK"ú&ZË»7#(Ût×ì%¯édåÇmê<MÉ´+üD¨ª~¨¶øÛkà­ËQ¦²SbñV[}b8ð_K%A]6ëÑèd¢É½P.+Zý7·°õÕ©oF,èV$[õê;ù_ôj~XÏ«`ÿ xqn©7ÆþQü¤óUMIíf[¯7)¸5)3åÆÆtaØkdbà!ª§*â¹UêPæw+Ù÷OèÎ¶ä´àçµÞ-Ç¦?2µÙ´ê­YäW	öÙ®8Ê¢¶áªõ°!ÛáÛ(ômµGSd ÊnÜYi¤ö\D&ÕâETµì«e¾£>?ÓYQ_îù
ª*âDÛLÆë¾F!êtØRbÇXãO|Ò&\VJäY(ª	õ/ãj=*D_iA¨ÅïRãñm×AÎÙªê¥tÏ¯-H"TÞY.8£ÐÊ¶âq^5ÄU;7¡*9e^=°v/]i¦ZmÒÉùmuÛò~7ÓÛNHßFXpÛ¯×ëÑ:iõ&m£oÙw²mù_ÍõMÊa ã*«£­KtétC[/T]ÓMKÔ ®wÇG9 ç¬}~}U5"DDÄÕ%òôò_ã©Ti/,Æ¡÷Çw#ù¦;yü/ÃfæV 5&6²g¨âjdÐÝwNb¹wÑP E	µÔ'ÒZl+(*{bvó²äNk§¡&¬äÝ aÃà3ø`ò£Ød¦¾íPrUN^kêQ É®
cèëÒdµy,´ûÉÇá.â¨(¸¹×/´Ìê¯U`Ýô»¬¥s1e	²û9',¶²¨êSìÔùµYógÌìWÚ6Ææeâ %ÑCBECël´Ü°§Ò\"öRÎ7=9¢¶ke;Xét¿oå1ªÎ|Æ=Ôî¥*Ù¸6m³,Râ^RÚr#	56ÊVd"¤ê&CâLrÅìú¦gÒÚÁ' ycÊÄI**¡¢^ÉêV¡ Dóý!ÌexdF¶ ÷qKõßRd3¥I#¼Ñn,Ut^òU¿¦Üÿ £B)öEÒÿ ©g)ÝÅÉbjÂsQß§[omG¢ÀXõ±ã9Ýö»q]pc²­üï©Ð%SfC`±ä°ûÜH¸NªäÌOïë·a£ÜôQÊC´à²ûÏ©ÝKªßç ÄdÚqdÀA²¢ªÝy1O/_»N{ÚaÓOá=BW¼6ºn¨¢+¾I®ÏÃ(Ë1ãjT©?KÐ«jN*°¹&dõ±4¶Â*©ê
µSbÑ¤¯A"àæ;¥÷D%ûKµújt&"7VªÍ}ÑUlÔ}ÒÇseêD)dL-u*¡wÃyÉ FÈ6¶â3È¶p	1ómWÓmT*OÂ}VF.>×	¨ñOi°BÉ¥NnV±Þûêj**¤ûOE¦S!ÄîuÅ*ÝUË:JD·S^ªÈpîÌSVp¹%öæÉÁSÄr?ÉæoÏn]õ[hÝj9ìà°îK2§ï9q
(ròâ"Eb]Q¡Ye®çÐÞ~1G%3CN7PÙRöÍV×['DMDv#.8®Êë\7ÂTÊùs"øvÛ¦ÿ UÁ½ÒË2³(ÑóBP·­×Ôzh)ûHäô+TèÀÛæR¹ÎÞK¯6
f»Ý=5
|¨ôB?g´(×uöÃ½%Î¹;ïä]rðâI­Ö¦R#%1	Å2xAyRÊ9"ð××tå¶¤Ë}¸åÙÞùì¹2¦5&C#ÈdÐU
ÂémU_¢71"ÝNT³ÝÅãZ7Aº¯ËÙwÕoÃ5ðß³\ËMj¨æB.
»muµÓ®½´øArJOÀJy°2º
ª §¯ÃÓMOZêý?»AxÍR4	bÄ7¥XBH¢ïL7PO'Y¨wiæ#YPÐUMÄTB«æ¶Oj$&¨ºéö_jK%NgEåDSC_
ôßhR¶1eTF?Ø¡w5eòåÿ Ó¨oÓFq$¹PZîAÄ9- â8SëÄm¾È¡/hå¸ý*¤ µ"ÝdR®N¶£t\³Q]¾ÍÖÖòëIÅhÝòF.û°q¸\ÝZÉËaÖå½Öúq©*YFeôøìÉâ4²ô[**uO©1Áo/ÏQcE±b´røÙ.Î;ðM^e¸ò°8"ã2ÙÛ<LöPTððü¯±c°óí,±iô(3qø.*cï¿]P&;"QL9js uàC+|×SZm^n,Xñ"³ áEk;2Ê
¯2´6ÝVÞhºH°ÆY5:#ãÚã #®r {¼VÊIÏÕ/©ô×R5@âJrÔ7é4×IáMÖÊ¸ô_³µ·¼ZLbh`Ò$0÷}£<üeµGVÜ­âH«|vOª?èÜh8G6$Ò£dÚ8Á¢YSD.¾¡I,ÚÓG²ÌØaQ áªçwr·5­×®&vþÐ7ÄÕ¤3SôÏµðü+,ØzúYSQÚí-eO¨Gq÷ÜhR,¸l4Ó/(®tÝ1%g³Ôêm*»	êNug° \Yµ4d¢äµ¥F«Sd%L*FoåB$ÜÎ×Äsnz}X²!«dÕF$ÖÅZQxE,·D_U¶±hÇÈiâ«k
y¯M¾©^*	¸*£KõÓH1b{EÉ( }Ë¼J ¥ºy'ªíñ]J¥¼Er3èF(ÉÇÙnãdÙÙDG{¢%üüNB-î¹=ÇD{·¸AÂê+Ù/ÖËuÜtëHÝA¶Øø*dRõ5$1Ëÿ ­Ý¥ÍW$»ÞÄIÑmnê¥Ö¿M>ºªøÔös1wâa%±,xnù"§\n«téÓAe"¥g;àjqBul;"¦öóÓQ 5?ão½Û#¼E®:ôg·^eÉW+oÒöMEv£ aSõÿ #\L1å¿/[iá¥¸	
¢Ä8Ê8£4ÐÝrÅ:n¿éa9Waö*KÃÔÇÃ÷­p5Å"k4ô,h°`N²¥ÞáÙfÎÙ[~-qÖëé rxÒÇf¥¨
\ÿ »ñ/ËÙzßQøl¼²Nè2[QT^duûVè¨£dòÒ( ëïUAnÉYyt½®¶õÐRßzÅçå7/¼bcq0KzùõOÑõ1ÞïìSå6ãr"$_¤¨ª8(<Éé¿UO-Kr¡MÌ¤ÍiÖæÊ}Þ"Ü²MÊj|¯åªë©ì¹r$À$mÇ\F'SÝ±8rè¡âò\môÜIg$9>og»±÷Ú¬q¹q#¦CwGr¸ôô~¨Ü9C}Åaf¨?*q[4&)d(¶^¸üôãÁ
wCjä-¥¶URµ|[mñ¶¦Â1xØ(ñ³àðù¯½Ý§õÛ]ÍáqÛn#d!åþ*¦¢£ñÌÕ·ÕµVª}ùÓNeøøëÌ¼ÅU£KObS"ÁDnÞ8âÒ(·¿ª!uóó¾ªÈBd`Â_ÍÇ&ÜSA$ô.d¿Ùºz®¢ÚCbL¤¤Þ@}ÃÉz*á¿ÇOTûÔøØûzC82¦|È>¼ÂÙ^÷óé¡¦·%¶Ûî(g>è8 Ê"¦N*c|Ipë¾éªI5(ÒºHjRý0®©kedQK[kÕ:ãb&nFXàG¿t[§êÔº×¸ÏÍ÷n:â£|Uùm² ùi"ÎØJi\y·E}Éï!ò^$°¹È©é®Ï³	Vçf@Ø:9ý/'îkø:âÝJýtãl¿5²H²ÃÍÇÑ%ºßâª»ùêq·UuXMAêc¨­°î-l/-k*çÌ.ÐD©2úÉ«4ÙByiÊÒ¸¹²URÖ^58âðCqÅB±ãdO¿M<ÛjR\ÑÒÁW!_O_ê×¯ËL¹q#j0w®±Ü@ÅD¿¾þL{
©±:78ã8_Ã½ï·.ú0íE
Ej2[N ÈþÄ61a²sÙÝÉÄ*yÆ«Ñc%1fÓ?$`X$×A!ä"MWò=>²-R3!9ù1ä4ý=ã³0.¸µ½¹¯lÿ ­5&¥*$·bR\ióîííï3;.X""Ûu/µS«È4Y¢FN§UìHÕx¨¼\UQy²½­ªÍ5þ?µ!Ô)ê.4d¸Ê)dKêk¿ªÌ+1Üö¹6O:ëHãÌ+d¥î|7Êß«Ó^Ëv<7Db6$+8>ØYQU<VÚÊ½>:5U8ê7ÈýpÛùµÍçMíü9§Ï/ñ~ðIP@u,áðìvÜ°µ¾i©'%á¼|­;º¦`¶Âà£µëòÚêf[RA»ÃìZé'ôê
Ù£Ó(_ãôUÉÑ{ÉQ7ùå×C³qa²ñ¹·:KýZýjD(6®½?:¤Çy¹Ho>)\}Ê/]ÑÆR¢ó9M*PËÄìökòWwO_ÜG6÷â»'YFèïÕ=|^Nßú¾ô¸5©ò£Án²ápB#Ù¡½¼úo¶úÚþE[¢ ÿ ýýè_ÅÔH¦x:8©	CÍ[ôà¿×«ôucÉ±ÅòYZþ÷-£®JvØb8qsoOO+üuQÚô¸Ðnj¿qÕ0Ç//K|tÜÚu6WrqÛ{LU¶ï¿®Ûî·°Ú#µÐPÓ%ýèÔhÍò,e±ÈÍ~	£Rª:ü¦IEø48ÝñÁ\v:òß.U°¯EÔ¥PVäÛ¶ýn|¥z¤/Ùm6Ãm¶þm!Ê´Ç"wo	O+ª.¨=tÔIZJ42WY6+e½Ç¥úo®õ«íêLâ4ó½Ú­LÓv-¡ÅÉê"q¢Ëh¸.þQ01ÛÖûþ¯Þ]Ú2·MkÕj­²¹öÂ>«¬[ô·Þ=ÞdaòF×ÔVß¨¥4 à	l@c¯è×} Ir1uzK	¨u­K_¢¼\9QñÔ§þÓ'ëÅ|Óê¿µ/òõ3ý£ï@ªÓû/Þ TáµPÿ ¶©ÍqxÆË}	.$bD]O¥Tîóé§Íc1wë&­¸
¨­U.©õ$Ó¦ãÅé½ú>ýN·3²ë$:{*» Àñ±ªx _¢®Ûj¡ø+Hö§²ø]ûéñ ð8üNã\ßçþ¥vìÉò!A¦;Û2hÆÐ²hÈ|MZ÷åýÅBE*2lzL'*59,²«-8fëåÙw[mÜÿ h}³ÿ ÊóüõØ¸Øz,¸½§GCJÄî6DÀÁwEEEém}Òé´JÈ¨©M&jòad6µ¾G|UB÷·ãT´¯?Jqub¿I}çÙgÄøÞ
ê7i)S{=·eªKÌ8F­X4¶BI×ì®«½§Ôû<U^ÏFrLÙ*BRÏã80¦¤&úàß¥âÑc±K«;&Îre:[MX"<ëÍ·bUè#­ÑtõYèú¬H­qåûYK~Ò«DK¶ëÓ¼Ìð§E£EÌÉ×¤¬'L+N"|Å/§g{>n;®?ì)-öÅ<ø& áxº¤ÐâMK¬TØ¤Æ9* ÃnHtYqQPQI/dUøj45¬ìÊTØÐiä;1Ãvö_xÀÙTKdE]'hk®Ðû¸äÔJ;,ql!"®Ê¼ª»"ë·µOØ×l? ÿ äÿ jþwßúï»÷ül³þ¼õMü7üö¯àË=ßðW½{?»÷©çÇçâgÅ½¶¶?5RPh±$qÖ½$á¾ðù@Í|²D¾ËTzßs(ÔYÆìÂDë8Ûy|ëðÔÎÏÒ§ÁåFG¶\z+b-<Ë$gÃ²§ïªÿ d»9H
g¦R`0Û]Ò.Hã"GªÚäEe_£Pëi¥Ê¦U·)O:ütlÝy¤EWÊìoª,8t.ÙÑtÙ.j;+ÙH=§§×_6¾Â &ìò]vò¥¨òZm×hðFÿ £³Â* ¥ÄEüaÞþÛ¿È5?ö}@ªÓÝï*pÚ¨AkËÀ6x!%ÄlHªítB}¾©Äªz,Wæ¾ÛÊ¾¸¡fÓRj9#³³¬´AºKî_²úbïÕ=é`ìOÒòñ$p¸ÎÌÞ5þ6»G>[ì©½.K«ÕÇ¨@3/Òªº¡1ÙÃf5J½!ÿ §½e,V£#Y`9¾.È»y U«×µ!T¤Myø-Ë&Á§Ì:"¨¼¶×EéÓUÚ)D¥vyÇ{M
þ 2îÇ~H¶Õø	}G÷=Ùú\ó}VmB»Ä5e´MF\%^ªi²'Çi}Ðfö~¥PÑaÏ «ÆoÑà&[$Têrèß²}Å¡b=o´´j÷±Á¶ÍÙàÛÖþ3üÍuZí,¸áGRáÇsÀÓyydd#,µLVN§Æ¦Êr_
rLÐÈ·Íßô®Þ~fU?b_tðWúË]QkOE¦ÌÆ9ñn©4ÝyÜQSOþöà7XýíÑ÷cs"äõÙERèIuð®½Bí·fûJäu#johi¯3\y£|U7_×rÕ~°o/gûa38»Ò"&\Riã÷$ÚµÎ­´ysuºä·ímVïwLìÌú'ðx/3×<IVÄ(¶$TÓ5^ÓÔ}§><1§´ÿ tb,¸à- ×ö¿6?h+tÝÆiµWà´çÌ@FóÎ®ºjã¸Jn8Kºª¯¯ßìæe/ö5ÛÏÏ:§íÏê©ÿ wW]¯þJ'íñuXüÌûu;]þV¥ýu7óªOìðõÛßÍÿ þ*Wßûÿ ÏrµÛä"þÝïvóó2©ûúû ÖZ£~fGý¶£ªòû~õOþÌÿ  íçæeSöÿ qÿÄ &        !1AQa 0q@¡±ðÁÿÚ  ?!üÞþ;ñlÿ Oöþy«@Uðbñzö|P_®+Æ¹´Û¹hÑÝ&Vm|oU(À\ìG_5¼îaÈS_Èÿ D«#rh²JN¡wmZÒf·Rº|ÛWÔÌ©&Lzç~|[ÝLWF©­ûN	êÎaçª¼(m0ê{ÇE"q°ÐJFðm7_èÿ £Üé¦»P)8-Ö²=0ÒxÃÛtä¼`N×Ô:#¿xÂè4¶#· cTäTMz!5Aúçï±e$¤'rlÕ»RB¦ÑèÄc!éjNõn	¤îðÿ L?×ãôh­lú¤lQ°ì(V³¯?ÃY\h`-Ê½@DÞÙRiÖ&[ÒE)à<©TZvtj¶éÙÞVFætán=¶>'	ÓRÝÃÄ¡*p:Uú<a*&1èùßÎExÑ¿óøánê+IX^¸×Âr~Ùh<òaà¼ÁÈ .¬ññ»SÝïÁ@ØqK] ¨èSJ*¾®$@ÔZ@Õ|¢	wê,ÀÑi5oN
+Cçzm N0\%g¤iTu¸ uZ%V0K ¦¨\¥\aûÄôÝÊ<ÿ . /T4õÞiÀk`B/«õ?¤~ù^H âs )$kWAÚOeñuûy:¯ZÄ1°®ÞÔ(;P¨QoQ
ìAvÿ xoF
qè/.FK/;>£lâ ¦Àî=-BÖb'èåÀ¡Ð¸WçLY$²26óðÂioTÈrW))ôR GÀ^] Q8uPÅ« (¡üPþRýë~@L%ÚL6Rÿ !jP¢º­N<ÛÆªsm´/¢T\6íA¡-Þ»>xê=Å¦X$cX¤æé?Àî÷ßÇ6ä5Ï=NÓ;Àt±) Ó	R&¤ß¿K¹æHISÆ¡°´k1h°5Åó*Å@0@jëG{Btïè8`Kh`lIl&O%Ë._¸ìÃfSÐU±·,È¥3r¬}òÅ4+5`xff
^hDòM¡2Æ¨ân©pG·^y$IRFÏáâÌûCÇUÖ©wJ³¡ð,/eudË¹·0ÖIâ'\-Åxïw/*ÖnØ~(z#-I¢¬xóÍFÑ¬j±"%yâéº'¤ÀäMgÏ"7Øí¬.éÁ i¼ÔzèÓñ[ ÷buSÔØDÓ¸o(39ª(h¤uhRÈ3ÒôÖàKI,F6°Ë"»

ÂîU5nã(¥³§X?~ØKvöµ¹ ¡ÐZò¤n®<0$`4¶,QA :_`£Ã:EqlÆØ:6ªÉ»Y"<¯?öþë.oxUòBéÌÝ¢þÁåEUxP¾An® Xg O+Ôb¿QÀ8é<DýÁÖÅh;*Ë±ZÙÄÑ@ò{ÁèNçc¼h âzOÚ@GÙz&\kV*îÈ©S_k1^ÚËbkäÁÝpü1ç"A´ÁÀK`
Ù4-É¸uwÒ ¥³¨»Kq¬ ÖWUÎP7[ë±¹råûÿ ý4»¥	4­6TÃï%â#yÒï¶y]À#é&àç«ääOõÜ6ÁiÁûµC@_G8[ôúµè!´ÚÜ!vÌJwÑñq«?%£>=ÿ _Ê(Ùçhm?Â®í­\4ÀL&íNFì EN "u°»L3E#<ÑÙÞØ³ÀbPPÖÝV¤Upßáßq­Q¿UøÍ[úÑàB ? ¹¶ÛybH^¢Ã¥ÚO#+ë{P¦»8Û»`°­] ñ&lvÒçz®åÔ4Ç%óôMª\DøÝ ö"ïèÜ`Á`®±òà #¿5³ÑáÐmîÁÃR&ÂÅ`ð`¥úÈ!?Óh©øCî¹råÁ)vyqpþä) ©¢²Í¢®qÚú@,Ô`3À@ehä Ñ°ì)ãàF'¨óZÙ¸éÏl/}@'<Îïp6whxè%Õé »xáY²%"õôN|6EänÝàTÅ§¥jH(Ñ3E¸hòÃì¹råú_½¼ÑÈª4!äoÓð¼ òÓ»øåË)Îè:²ZñÇI ye/è¹¼öfÀ IÑä!Öm$þïñëð_­Ë.\¹råÅ<;¬íÂ9ñ>ÓX!lkFóJPë±õ.\¹råËërþ!ÆMóÆÐ<ó¡Zl´x{,NKmÉ¾R£àüWí¹råËjñÿ §êLWä°¤Êª$êZ/kyy<ùÑ ç{MÒdHØòâëW+¶~R|·ââqMDüI½/).\¹~Ëð¤Ê<Þ¯²«¹· ù_kïé'ÎGèÀ^dý+N4
MÖCðç×Á·9ó5V7(¸ÃÏà¹~¯üläý2:ÏÞHSK.\¹qhõ:F=èý¹rå¶ú¼Á¤9ÁYò/E?Xu-x¸	ß=ZÏ"D[è´Y¶$'Zû±øí(hD!HLçUõKw6¸§6 »ÓÂ}v÷A
BúðS¾6f©DÌ$		ïhAã¦<mÕuÂu<¯®¬EÑtäMOèÇïPúAã!Ö5@$rhp¥Î*ëééb ÿ ëE7ü	÷ê×#ÞÅ;e@î½LÊos <.y%ÂmYô¶. iãª'´s}e± ÕhLÇ®ÇOì~«ü}Õuô2:Â6F:Ê>Ëºûä=â9æbCÿ úç[
Î£åoç)¾´k°N²`ÁãÔAFØÁü/Ë?ÒÁQov¤H²áhY!P>BB]Ç.AFGæxº	½`ïya1æ
è6òÚ¼Óhßçéo7þ]èZ_£FOù4tFößHMú~hÒ,ymI&>\ úDMg°´Ô¨ð, kð¯ç­±òcøán«êUÚ¿ þ~5þGíöTý §ð¸§TÿÚ       A P CªXH Ú	`È0¦ ´×j )ºÏ^*¢9FêD)ÊJ8#
jaü+í¨¤ M>
Èk{qA»§Aig$7·ö7wÅ®$ øP 	Ä¶Ø~aÏ`C±÷!a¶Íi±	|	 nHIs'jL´OMäd´.ÇnD¿Ú ^TQLË"¬FÚ
°-º»pJß~ÂÛ7iDÿÄ '       !1AQa q0±ð¡ÁÑáÿÚ ?ýâåËb(\ÑP¬¿¥Dø	U`Õ] m^1»°RLµ07fSwÂGFå®RiEdttB%( @Û\¤aþ¡!,PB7*A é4ÈT/×råë/×Ê>; z5²6°P´¬Ï(#F 4Þ%È&½Ý¢e¹ð%z¡@í#w4|D¨jº1 °P´Á	ÜCA"¶ÒX
æd|TÄ+a~ÅËÁõåËâK*UâZ yU¸``lKîFÄDz£Sh!¾×w&4A@èM«É8%°ÉÕÖ±Gu*Õ4'u¼Ê½¹Ð´FÖL6$;×¢¨Uó¤sñBS± ÌØ|'IFíç.\¹{3äÉø¾ñî/ á*Gö0W@«üäà@«Ñð6#©qmNKHªd¨Ú£²ö Ð©öh­VÓÜ]\Ý"!È 6mübM~JØ!	VMØnì,ÄG- Y°: aNÇ@@n-§ÐÀLj£±ÐÐ¸Ä@ìq²@â@6)A&î.óow9¬çyÏÛ>1j"È£¦å°Mák¤Ñ ÜUÀ40_QÈñÉ±»6Ûµ$C³°Uk<äN,#J¥DØàZÈ.®B¡.Øú!b5ZZÒpï^¬Æ¤(0´æàT;E×ÂÙk©ÆY©Ûð êÛÎwg`pGBòÞ74DÀôf[Þî@¦ µ7¢1¨àBP
b?qdàÃ!¼R'\gÆs¼×x8QsBDM`TÂ^¨(%"JIâ·fs¢*+#JhuÏ
P°'9\[Ä¢¨§´A66¯ *ªÐØäFÚkÔØ|zÂèÜ>]~W{yrgÃ -i)Ö¥÷_j@4®á­Uê¦¤û¼³GÊâsDí eñõ!'#zåqFÉV<H¿pBXiTV±cÕe-ü)D`®èD@ª«6¹zÅò7èìTÜ>Y1DP$B©ÐK QTãËLÁQ< ÙÖQÞ#p<Úõ|ð(hà5²
GI ¯/Nõë@{áK¬ó6®ë9à!ÈÍòQïxÝP){l§9*©z@øõ×ç.BÊ(×5ï7ÑFuFMè¨ÎáK vEX
Q>)ç[  Q&òzÊØICÈGÓ_%Ë	¨è+f!Ãþ²a< K¼8»ÐÎQ ¦$i¤ v	õJÂÆÈ*~§f¶êpâV
A4:äÕ6 !ÄëÙ$Ý$Á¨_@7OüÀf^
ºbknº1ðZÜßÙ@pVRÒZ6Ðº0 è0:ÕUe5;^PiX1×Å^V,¢ Ú %Ù ¹gíqyêøTÑMÄwþ]t#ÅrO*2×d8Á8LÈµ+DZþ´E»#FQÄ»`ªq,¤£AÞjS&!;
DæóZµÆßÊ2¬B"ZcÙM¡£ìÿ êN¿Ö:½é@ eHÊ¨ ë©t`M¶æä¢"®¢¥Â'Iq@Ü¢pG´ÈPQ.X DD´5 íN³á/È}b¶@¤Å
Ä%7qT(	,JÀ¨ôCWÂ±R²9$ÅÎÜÐ	h 	"p[Uúd±MÂ)S"-(p¢¯ªNáïý\cÕ °9 ÄßÓ
&D4²Uà°FDG;5 Ëb\Äïp¦[íb å2uè-5®ûÚPµ¸LE[ª°Î'²[a Ý
Ûöà_%³+ð<dl E¦Àk.]«Ìdñ¡!d°Èç1,ÀTR=*0áPí¦Ò £õDpx{ýÛAa¯H®'? ;ç,íB $04f%±.f -¬ s	±°"ÝdÞè¸¢` FñA+{èYÛZºYÁÑQLJÐà¯'ç2Wê;hhÙ"L@CíÃKk¹è¬ÕBF¨©ðØ©ÃAÆ)QFÑH: Àäj¸¨z¡>ðm«¬gf5±ÐÊQñàÓ(µÀU +  (F*Hat[dÏ*ìÄóëÛaª£SiBà]Èdp#¨\ûý9~Ç¶<ø d$ÎmICyà*lS>¶T"THs'8¡/à¢ä)@ :Fº"Z6ºÈ«A¤éC9ýÆ?çÞ2N¦{´þÑùÆRoJÂü±xý(±DDVm}ìT5þÎÛÄ-<Ï8Å RÎ$ªÄE@Rá#DçpÂ[U}4Êåxta_j±)DMñ Ø¦L"O½5VE$ ÷Ø>ògwYï«ø×çíÇÉ¶Ûì"ÒÊ 6"z©PçcçÓÂ±W#9|×ÅpS®U¬ÿ âµkýßýÊåL®W+ôS##År¹YY]ø|áLtÃº39·HN3ewÅH¨8XeÙ­§mhÎá®þ§++ò#ú'hø9ÍÐ}Ø
Æ¢ØÕ!FFE:]¢¶õsJr"NwzÙØ(Ð¸_Ð3É¦Íj ÐÁm<>ÑK.è0mÓú4ÊåeeåáçÎ.0¹w)²P¬­Ãp0Oççåï#Ç¤SN51ªÓbÁèã'C³ð"5²ÓÎ$*&¢À<¨9§Ôåer¾Fï¥V
¢" nÒFÄÄdd9å2L¦
V9³ºXi6ô¢²´Êbï u¶Xj°oç÷ß$dîêÆWk­)A8&¡7-ädarÛÔ
ªý\xP#LÝ$/+5_·ä¤ÜÈõ³¹$b@¯´/Ã.1Ëd	A³FØk>m»Ð9 PZÎ. %è©´1fÜÔ¾ÁõiNâNÄÆÐ¯Þb|á¡I`PTP¼§9-Y(MòPP9q¾	7CÀPðM/ìînÝgýý¾Æ¦"£'eºwHéØwª÷û±äh¨GìÇbäØÞ ,(h¡éh4¡:áJÀè%ÐØZîGà'1HH¨[o×¤5¥@QäS*||Õû1ÓÁÇ¯çéýùiÕßø`ðd"ôý0*u³4jTÜT)E'bqR´>Õ^/É#!±*Ö
«´¥ ·R´(Ò*%è­m¦ªëögÀÈË²T°bJeÏ%²
¨©\	»®;ÖJõÞ²à5!$ÑÖÄ¦$t"ZÞÍuª·ãVª¢Ø|í$yP%9Ë,uµhjxPCT*àane	 p 8éÏû¯\ÿ 3ÁÅý¿Óà`ry×ø_ïÇ÷Þÿ NÿÄ &      !1AQa q0±Áð¡ÑÿÚ ?ºë¯ß]æ¿ÐpXÂ@c?BåË¹û9~·¸~ÚÝu¾a@%UUxªðûåûÂ°R³UN¶â=QòL«x¾Ê¥Îx5 %UOVcÚ,ú ¨F¹feYEu×]uþ×]~øÚò~bÖP+!°¢mØ9HúÕeÛ´qÝReËTûY%@Ô­ÐÐ¡º½aÝ@üÌÌ§9ìÅUÞøN°L~ bÕ²sJWLxåPû^+uþ°7-øÆs¹f Qt¥äª:OÙ>Ø(PCe¼0J<(¯
"£8cPR'Ò ¤=4|F
¢.%©ÍÅ0Ûc7öD¶<$0EùÍ®óÎ`Tº+ Pê é}jrËÝñåâá)å}þðp
ãX+õà¦dðu_îàr®*	ßX é4f8°µi*à¶hÒE"T9DÐãæÆ%µ¸êÜU¹Í</Ø#¯#Ö2i0=%ú³¶Á@^´²çJP,ºÕó¸Ôp>Kü þ=	.!>B"Í·+~¡Ð¢"
°|ähTã½¡Mv©ùM:Sgv:m§5ZÐuV­4x8#Zî	,dÔÜq¨h½âØlR°w¾R¡p­R±­#PEcÅºH¬nþ!Ã¸Cê ©§àOú6ÃldÙêÛ0/Ò7YlêO6ª:ê4UÍ «poÞ ¸³dwtJPbQJ<Oô]ùkÎë¯ß.kñB#¢¿¤/Z _[_VfµÇÓ,ÓÌ^§ÀAïiK
»+!"ËôQ$ ª`Ë*#F¡7I^ó,ë¨ãz>ó«Vª­4	wëåÜëJ~õÃè8²AÐ;"|léD´a^,zò	Â±]¥Úapä*«:å\ýWËý(~ ù1öuO¯Wq(ÒÍ¤Ã!Ø_¤Jú v| ^RZÈUÂ*wØIÄ¡Ê°bÞ;ª=gÀ%Z#¡&$ãl¶åZ {@AR[Lî¦0î!¶½!eæ)6`P`êß0þ~Ê:z~¸&Zx[ó1@ÚNõ!4@ ~X~m ÕÈD¹Ñ ptd¡ªÀÒÐÀH(Ó0g·Ä®Á£R8!ùÈ¾ ³Pª]a­­P^ ¤%ì1ãR*©]c^ñþàgPV n¢p°Ð!)¸L,¡J6hGÏUÚÏ¥
 T17d\	12Ô64x=L½Úâ_
Ì*Çêú¤Àlõ	!
T1÷ë>(FæÉÖHÞ-È?ÏXp2Qjá>@f:³p0uÐ JÊ0SÑ¥üKD	bÛ(Ý
qÔèQ§U_FR¨n|®D¢	s<Ë÷ d	,PbxÖmóýUÈõsTÑRÁYôN÷¤J«! ä@bÑÈç¼G.È¬Æ³ U0F%(!Á°øwtDPB^Tøý×ôE
TJF28	 ÇóUUj@±,.Sdtj`±cÜ*AÀàÞÍ	#òPwÇ*(!1)áÕ@	u@Ô9[E"!Ä" Í T
¡*)KUÒµ¥fôÀ.¡ºùÍÀ..Â©òÔd¬? â,Ïcïjè\`!×>\L2)\^ÄêÖâoAÞwLIÉc8ãúW
)oûr0Ñ¯ëÅK
 ÁA\ûh¸t A}v¢|6Ø"ku¶×F¬pmG_K]ùÖÉAH¶ØóÓöQÓÛèÁçþÿ Æ!ä:r0H!ÁV¦>2ÀÀædf DFï
]Ð<ZÈôfð)w¦£Aú&tïµ>ÍDj|QÂNégès¨J¬{æh[ôýò%é'*+Ô	ö$àH'Áq"ÝHî4TÜÇ ÙH«1UC¢ÞÕâ¢aÏaÙËÙN>ÖßÝúÎàG¨H|þQ÷RV¢6 `8*® CG@S0°W?QX¦¯èYHß³{P1j(Û¸¿A~ÿ EÂ7o¬¥Wïûýç?/'{Æ)<º2ùáx® BÝrD3´\´:G¨{'»Àl@GE)·ØÒ 	\µÄS4>þ~ÿ ø_à|?äÃ@ÇüV0üÇöt)U\ 
(óÊie h°ë-Q~K Õ F	BiÈIzÁðÎ¹ZºáÔÔýõ§èû:!±7eép³ùjV¯Zºáøìgoä¼ÆÇ£ù»/ï!Ðùë«çY²Ð`wPX|
>%]uûêjk¯Û[ô5ºæséy«uìÕó^ÇB¯?ÀáF«óö½þ/úýüSûþêÙôW+uã5Ãã®û/ÔK®®­_P¢¬xüxãfæÇ_ä>÷ã>rz¹çÄßR»bO>aÎ]Zµuu~ï©¨{¤×ç]pÍZ¦­N÷Ô½]@¿9ç}|r1ò¤b<o+I(6Ñõ.2.àý
=GÁ'¾¿
¾?aG+Q)ä»?
"	7;ëê-ÔÕ«Ï¢½Ãö×ÃsSNMCß­u×æD_>@| ø, Þ°ðOïë®eC/¦rc=U¦ÙOÂa}=©îTú"Ó|iÄ¢GÆ#.º¿Je>thÓõÛ´½"°UP%}Ü´©$dA<AÕÕ«V½zò"gP÷KAYWå^¼ #)mãáEoø4dù¥¼±«D"}V'}¶V­\Ì&IèAB î¯è0Q>ðDDE¦)Ø@$
/«9];è¤ìHþæ$®Ð¿ÜIÀ8l($láÖJ|´P
Ó"×â³à?qL=C(uÜ¿X"?kJ|Å=¦«x²ü3ó$=
K)AêÓ¯iÞJ ©sÀÂ´0x5	ß¢ùÏÿ &ü¾2çY)ûVÿ gÝr$üéóHñè(_Ìgåòta¸òcÑ}!;ä#`Jù yí£Ïô_#`µòAy}
BED8ýÏÑî¾Ô°TD¢ÂìËø}~Ô[÷3&/Çùü;MVß³û0ø4 &ûÀ`çJÔ rB©Ø"é¶r¥%:ÅìAT­2åQUû!$øª¬ <W¨PÕJâH£ÑQ(·¯E5W_Ùû¤W¯°b%5%!¢BàtÈïÖ,wV#øn¾HG	8yÑ"AY¨?·çÏ9Vþàp<Tßp ;ëZHâ¡(¥>×ð«®ÐÔøPg<«|ë²¹û(    ðú>÷õþgÙõþßúh>(ÿ Íþþ÷¾ÿ ¡WÍã|?}ÿÄ (        !1Að Qaq¡Áñ0±áÑÿÚ  ?þaÌõK£Ö½?ÿ 
@U\Uä U@ÈeÈ§¢lá¦_¢´ºTx­Y)Ë.îeX8[ÝMsÉfêfDº7 ¹évWRÃ5¯à¹yï½2ùÖMå°  ,Æ²RÕîÑýL;Pb0p¬ÆÕ9ã>AykTjÉQæHî o&Üp¹/t"	èøüSªWçZ¨@ÄCÈ¸¼þxËÏï¿^ÜO×zËôõ50~¸7ûËþåþ¯¯aÜ`JÓÜSå?Â>¸Ð@å8¢dÌE@^³*)A&Úºº¹y,écjV©X³
M)ÂÈ&}iáb®%Yb±³^MhzdR¦¼b-LÚ6´©F=I5Ø¸¡}Ý¨êmdtìK7._ûë¾þY~¾};ïYgùåïÓ½àÿ ¹}ï^þø»Ñz¢!%.^|eõé­èÂØ çQ½@<g¨]Ö")dÝ:/Ô#1áÚõªà_[Àv×2äâÙ`UVæÁ±1DïbÈKùæÓÜèy,­ª6Ë¾@s]ì$ WBU?uªÆªZï`Huqw÷÷ï¿õç2=("<HÅ¼«	ñ!Z6WE* @ FB­±êRJ#ÿ «Y¢8aë_G!eSUá,|ì,zòÊn
 xxñÆðë:"P´hßE½Hÿ øÊ@Ðc'á¢=êÙ¾ ÉiãåBdõ!½-)$à]¨É(B©}f±Xà¶
Àb"
Q¼(ýïÓËrø×¿a&QÀRMD/JHÀÌO±ìp
'NÙªm
åqFÇ!Pd0và*!2Y#%Ý5"°; ÆTÎ[°íÉä¤K7EÑ¨Ø²Ñ«a OªùøbrÒõdPAöë ^e
±À*Ù)ÎÓ}iÖgåÅàT¡JØÙò¢ d¿Vå )/_?¦WÓþwÓ£×ÓïöïówXXBW$RãrYÂàAàÈ¸dÎéh@t
Æd½2M«Ê@ªÞ1t, ØTqEQÎiWLYr/Þ8.-1×¢Ð¡Ó÷0 h#ãÅD qA\±WéT)*°4ëSf(·Ô2:BÈ(y"¾Þç6êaæ¨À/Ø7Òn¡·÷;wôÏí×;wôËä¸Æ[s¡7Vì@_§òKÕ .çbOí ÈÄ³æS!e"ç¯¥·gü÷YI|×©A\`ã!õðoH)J-aÍX­}7¨X"A´á(1nãðpin9cpî³gpfAdKgÍ´Ç­v2»J$azgU:3Jã6HÁú¯¾Aï'³¡E6»IU:Ú 5©Áf.¸èÉÞX^âÊèK¡æ(ÁsrýAÄCûÍ7§RuÂIÈ¤±X*bX»0¾Uù¬Z§Õ¹Ó³)Ìk4)Ìzê%LdX7¤G°åPìkSÄ[¿NÌ¹!($S³X÷bcÁl>²bTPÀÐQ>'ï.v÷ð|Ñ6æcS`ªocµÏtZÁ W½I«Bjüs'L~BLaÈÇº¤=Ë
Ã,À=¤íæ¬pêë÷ºªn 2!±B«£RxrZ´)mBÒ9ÚH¼	Á[-b}Y24Ê»ÁcÏ*¬Òà½¢AþÌS`K²ør	$rÞÖ¯Ä#M6QÐÂy§I£xò1XöëéíßÏËre?`¢°+®\ÎÛ¥ÒBüÄgoC¬Ê`!ÎpipÉ!æN£O×ÄÄRd  9²Md2Ijñ¾,ôÐÈøP1!;ÿ ".®ÕäfµFv8Bwc±Ã´[aæ¸¥SeÙ¾¥ûñc´PC|ªyzû8ÁlU!±Ð+Ïý0¬Jc2i QdD=ÉXcÅHÅ1CAÅ,¢ò÷¤	¿¥Ä0Óñ´5"bd6oÖÃbô1*80Ð¦¢ÒòÅð²ï+>Cg¯¸(UÔ)¸0$%´³©õk¸Êì[x$oW»IåJes·L>NííÞ¾¹ösÆP*cñ.#òlV¨n1*äpÓvüH0ÜwÓêIÕ*XE¸xV <Ë#x¬åiU2DApz@ÉK-¨¢6×Wã6à£ÐX®Ðïlèyv«0È°T1öûÞ«·"-Z1 ö¨Î`HãÃYB5õ½»××_ö\®G}2å}ry£ÑÀ5äpI-Õ\VW¿9ZÄ@:Òæj(Z ëÇz¸ ·$¡ÎFpºrÂ¢¹|õ!­ »R_Êù)+÷éøÊñþÜ;zdw¼÷ÕdßyI­-[î@¥{%{>VÔ/ûÞðíé_Ï>ëÁ_ûïÉüä}æõõãÏ_\¸÷ðXGõ,ªzõ,BøPÓS73ËÙAkP§ðS(s¯Iã\ï¿L¯§Y~þ¹¦
(õ¥Z* .MÐËØØ(eZ ]ö"ÞótP*¦Uáb
ÛÕw÷x¹XÙÆÀ%7X)dÁ¹ðo.{åÿ 2¿YY_üäe>O1úÀVÑlÀ>êµ0j¡UUUU|ÁÜ$"2hÛtÆôRäD=#$þ[¬@,¯D`Óh nVËL¡Ë>9LÞ²O~\ekV±#¹1;µêHÜ*åe}2²ó¿L¹ïA!¡z0Eh
 <)Yròç¾n//S ,	º0";[£ï2Xì8ÊýetÊäöfæÙJèëëáN÷âÙ)k~P"½y¨/¨s(&øtFìø;8»
$XîmB¦5(ÈØP+iQP#«iÎ1 LÀ¨°ycb»AH.5OK$@	R&#I²ÞÙ7ø 'aáæÓqÌ¦PÏ¨vS¡PqM
'mi¥2:²VI*èa¨qa3T!¨Hãx	 .(ë¸H¬a_Ã³3o0» c5cÃßÄÂÅ,èîBw'3LôfÁÝ%Â+
S, Hã6Æ-»q ò÷ß5ß10_%ùË^¶SÂóxrxÚq4ÈáQøÛín73³g
Ý£O2ò#s¹[©  fP¦H:È
±Q}ÞÂªxFpklî´¼àÚªÕÚªtyY8¨ÅÙJà¥Èf©°RÂ2ó1¹YÊ÷Üë:±Ç(M] «c
hG¨ ª¿Êpãì5¯]÷Ç#â~|0«ï_×Î´çÿÙ
endstream
endobj
134 0 obj
<<
/Length 2245      
/Filter /FlateDecode
>>
stream
xÚíZÝÈß¿· ªc> /W¶o}Þ+íó*J­ýÀ¢D@þûôL7$íÚÖÆY_^$îþu÷t38'p~¹x>½øñ%cÊIüDqåLçN¨|'RÂéÌ¹q_¼}3½|3½|þúãËËDøJ eGr3äârzñ¯mÃvä?`ÒÉV7g}¿:/Ø¹³#W@+ö	Â¹¾øý"Ë9LúB*>Ð$IÌªluÙ6VÀYø­Îîåý/Dk·Àñ8÷¹RHM<{U¶õÅn5Ûdm^HDÚ_·øOÇë&xù	;u!¯çiöiÜ6ålâñ0pÓîa¦?/ó#BÄ °uB0öy)hÆH
AR¼Ú®uý:oZÄÙh)òEÄU8LTf;íz$Ì¾V%ç;Þ`_) Í_) ¸/WäqRÑ°«V¯=ÅAÄì+>kR#§ðd$ü(Á*Bâ#}kZèuÖ­®Ç<o¼PH×x!¬ôÏú'äé¸ïÁÁ8ÓAOÍn@hÚÐNâÀËÝ§/£ðÏ÷wº<uA¨Óf´O>Åæ?Ì°$ìcm#:ú^A[²èè÷¨`¾É µ
pà·k¤mu¸K'êâãÐúõ!VQâÒï´ÈM~|$JÂ3POÔÈu½¹mÚ¼ÝV17^ÌÂ36'a£$lÞÕ»v{¬çP÷ô(ÒÏºÉê|}ÌX¡ù¶Ðx÷$2Àg³YÞæºÿ@8;¨öxrNîÿ¿©`ôÈT÷©à{=×µ.³Pcñ{ûEHyÚ/,éâ úâáÙå¾rñ#ö4Þg/ªÕ±ºFAz:td_\U­>ÄFÝé{AªË_,Ór¡ñ¼è·´þ´YïsSQrÆäJ?J¾ÊîG¯Ó£ßb?ÿ>}|!Îûg~"åø5¤CÊgè.æ^wt[.¨qÛ´zõà!.?ñWû7²äu"rm·~ixÓN'	w«ªh¾K§ïÑÉqÚUÒjÊ@Ó¾'?»mÚ:ÍÚ{HÄlH%Òç*åKAÂ¾ê¯/D>3#Í-¸ïOq÷ü2÷Ò>¿ï§ì³Ä£~Îë#DC?
úWÐµ%:íýÄÌ[Cäw rtl=búbæÔºUëu­{ÝjËØMÍ_äÞM¤Â[lk+lÙ/·F¦@Ý¶K4KèÿÀ¹õasÓ¦-ÍvØx½`¼;îUû²ÍÒÄËK¬ÖÚ@7Y»©5öyw7 x¶Æ«	.ø.ot3ÿ°Î®·øVçÙ²ó¼ìÿs.hx-ìºÃ{å'1 $ µsD$ì®o:  eÐÐpÐ ®H,%?¼¥zÓhºÚ1·zµ=:½ZE½ôa£[Ñã4fÓ-7mþ:ö:/I| ñ'®P ÄáÁrÈäléTÍ*¤e 0wÏ÷2ûH½««êÌ,Z&îº Û8ÌÏh,f Jg"§Ñz¾iòRQH\×U¦æDr¯«EµNî'ÐTw÷­U=Lð¥A½ªÈjåëE{»iZêØfòNO#	fÌÂ`ï¯¿´ü¡¾d«ªÖèÄ/dg¤é\@Ömö%¿(PØ×Û1vÁ* cì½ûÐV§Õæõ?éj]è&,uM<0¸oüp¾¡Éi×¯}5mÕ)Z·´RT+MQÔN5ª±-[«fv°dÈîÛ¢ö¡äsûÿÖûPnìMIW7k0_°´(¶Ø´FTuZ611dpÛ¥.qÐ¢²é
´å¥Ý¯­º[ìDºÅNkØÐrLB
ØrCGÏ.;g°J¡Uã&vÚD.Ik]ZG»¼µE0_jl NÙZ%å"ÆÙf¿0ã´a ÆGêÎm­kÃT]Î .HGH$¾¢ï¡ð
w¦nª7O&1kEÓÞôßªa& og×æm®»Èg^êt¥{ÕBn ñÄ enzÜ1ÆÄÌ,mkeDÂ¼Yú÷eÌjÄ¾PÑAÊ lÀæ,ÁÌÀã<@¸i¨ê|aó:h´Î	mÙ¦]{""ÊÆûÍÚö/¸D\Ó^5$¹ÌíÞ_Yïèg ³X¹ÌEJ`á÷÷eJãge`ÂP2ÛuíO&M¨ÁæUúÉ0ã!iÊ¼¤k¹FF°£o¤±­ÉL(b{1àØT8Ü°mðÑ:0tf8nh¯ìûL×øJY:,«Òâ.Ý6fN{;±7ÔjûÌê¦.«»I$])unV6ÌÄ&ÌÐH«@£`lgUIIí<Íèi§0~UÝQþZíJS¶P¯)Sn)] ¢Í=åC%é²HÈ¥6å.%f7G3 OMüÛêV× YeBÞÈs^jm-üÀv³#I)ú;íö.;8+L"û1AE~rG%~ »z"\Ë{ÉbLi£î®F4Ù«®ßÇÙá5*ÁfÛù¢Ä4Í¾Ú[sjx¶4ÖÜå&	3/eJÝÉ®V± øTãùàzT¸· ÒAJ¤I»«®Ä~±)Òzï²üºØÔ,ÿ~!Vg½ÚÔ>Õ~(}©OUÒHcËªªºU_»íÈ!éãay`lÿÆß
endstream
endobj
151 0 obj
<<
/Length 2208      
/Filter /FlateDecode
>>
stream
xÚXYã6~÷¯ÐÛÚÀX-ê´æ­',$1,2A@Ë´ÍmYÔPr{_¿U¬¢$»Ìhó(ëüª¨(ØQðãìÃzv÷ÃJeXæq¬wAEaÃ"OÂU°ÞÌÅëfß¯gfNE²<ÌË¢0iPgü[Øû)óå*8;Êc«0(¨ßf¿Ì¢éÍBHÃ$Ícw7s3XJér±X(æMob57ÛSÕkÓ L7¢GÁ2Ã8ÏéäÏÍbgÑ¼?("ËM´ß57TÝÁ´­nö4;Êº~GÃ91©|DNL/éçÓIW4Ü×²©ünÃ¾Ö/íõ"ÎæOÍÕ0ÃUË°`Y ¬ìÝÎéâKKg½Sï«¼ý/Ø)Ø)NÃ2*ÀX"L²UæëEÎÍÍ/ÕõãÑæ"ËLè[Y-âhþ(×Þëã÷O=^÷&ßøïkòVÍ~âÿCÔ	½ü1ËQeËüBlÃäÊt÷6úØÖeÂ|8Ý@£PÖÏ~YÕÏ÷æÈ|÷j8¼{k0°Î71%½k¬Ü[Ù¾5T>Æq¬|þÖ/2'L
ÐêA>)µªmÁ]i67&RÙli¯?¸ÌQ×ªJËö[ý÷ß×å	ü&DW1GÌåö8sÖughéc%/Bø¢d×ó¸BûêÔü^[¬Y>o3A¼! B@Üdd	Ðm\FÙJïR dmµd®ÕïÓý2Ä,Óu -K¿G$lduÒ½ÜÔ|	;õ9æ;Ð!w8Åyã^Ý1cSoé9¡±Ý?LÈ^?ñÅh64Mtm-xsë÷àáï<ðÉ]âöWwÁm«Fã8îÉ«ÙÔÆÌílç'¦¿·Ç¾ã¥³ì¢·æ¼U|¹ÞeEë×zsV5Q õôËPà¿ 48ì4©4¦îÑ;¶Þ CÒ´­o:««ÔÝèÞ× Ëdi*Ý©ð%OÜ#õ*ga,'mX¬ 5M¯¶LOa;:°ÔË;ÄE"L
ÖvÊá­©N ãJ«Ei­©T×¹b 4äwä`YÖ´°U` þ1ÁñÞ¾ÿZÖÅêNmk:»@ {5U+¡ëò=æË``0!¨þZ(ó¸x~SöI»Ú¤?CÌHìE:¥ÔÙ}@_¤Öª"NF9´T	´C¹¯jS¾	2 -y'äT¯H³^$ÙÜÊ¦Ó¾=úgD"Î¦2%_'Soö
»CFÜ!m/lWe;Ù]³e­9zwÇ"y@XòÚ¨6´£ÚIZLà6«©Wy®@j*ZÃ@¦=fä¹¡çç²vRÉùìK]_ç,à®êEÙ»lÈa6oePØE\»Rº,5mTè<9Ê.A"%\ÍçSD8Ì ¼Sc{j%3ËCSZBÜßªzÒÕÚ­:[Ãï3L`±^ ¯ìÔQ<¼Òë×o'hí£ô|á±{	ø©ÁtÃT`î14s#Ä,Ð<µëö®:ªÇ¡:rSAx\×aBÖ¦ñÙ2lA¼ôjc¤ÝÉ«Öõv¨i¾0@Ý¾í;;=¼EÐXT|©M%	ü§Ï¢UÊeç¶²ãXv `Uwû.:k§´+íX¬)®»Ð-ÿvÆ÷½Þõ_ÍêZnåÐëÿ+<Ù.NØ¿qLhóºÉÞ§]Æ¡Çß+Êk»`c¦p·±»SM3×Bºjéñeø¡GÅÓ·Ñ4Ò+4ìÑ×Õ©jÏ+ìNêúÄ<s½P¼b×À.9Î¿±¯l¸Ãê¯à` óUå5}7øÇ(ÔyÄÞº»/h¢o»d æë>û©AßTâ#) = P 
ÈÊ]OCsêHzZñÕFóºÒ­l<ñq`Iè~ÍyÁÍ`ã'w7A`P ñ±y)Óùý­n²ÑØÖ8afì â­7v7ÑëqQú& à¬ðÕh¶ï¦-p×²1¾\¤R}ÐQ^Z¤>+õØ1ÙÈ¾¯¹óÒF­2P =Ëæ,äVwÃ ¹LVPÁº¯ÆÝ¿óGÔ0CG­´o²¡R?Ã$,6Xx =;©O×hüyh Ýçö6vÇÏ@'ÛxÐßêº{ùaýýúöã£0Ôª³O³0]eeî&C·MZäfYûÕ»cüÛÌ~|Q¿Î¡-3à]¼õaNeÂóÅó,Þr"ÿLeQv!S®B$n!±,"d	( oLÆ&-5ö®06qÎ ÝðJêùëÿø'ÿÒZ	èéî,$4!"%?ås ìßpiúf?þÊôE2QKÄ¡(`×>ô}ûþîî|>PëåbcuÙiü¬­
+s¼»ß@¢Ðw¿C(é¡ìÚÏÏ+ÄxÏ.r²fã#àëdMÂ,/
ë,tËt¡±û»³~Ôwß¸ï½¼gý5øæ¹ c8,EU,FãW/oëÆøý×)\Äa¶J¾]áõõ#ê5<Ä/cÓ/RøzÒX|¥j	<À¢üF5Õ¨H«¶ZjÁ5Þå^@§ÿ==C
endstream
endobj
147 0 obj
<<
/Type /XObject
/Subtype /Image
/Width 1050
/Height 552
/BitsPerComponent 8
/ColorSpace /DeviceRGB
/SMask 156 0 R
/Length 52876     
/Filter /FlateDecode
>>
stream
xÚì½Ô%UuçmÑQü§¡gÐ ~L
e 4KCl>LlMQÚ&0O¤cGì Hqºß·íÓéW;ôk3c¯HôÅrõûçù§÷lOÕ­{{ïs¿_­³îª:uêTÕ­:çì_í}ö>î8Ù-oxÃözÙ÷ã¿ì»ï>Ïôe¿½9Ù7ø¬øgø}ýÌg°ùòÜ½&ÿMÝoïgMöþÜÏM~K|Ö³÷¥µûòÌ½öæEûÞæ{MüC|ösöÓïîÝÇ=½èE~òÿâÛ:©é÷NÉû<koPéÞ¿yÙs&ûÕÜ&û?pô/ÛÂ_Ô÷yæÄ÷6Ïßg¯£ÎX=ÁéÀWý¼ýë	¾Á#N¾ñ{í3Ùñ%¯>ýÙû¾p²ïq¯½÷;ôMOð.8þ7uý{à!/\pÒÄ÷6Ð4M@Ð4M@Ð4M@Ð4M@Ð4M@Ð4M@Ð4M@Ð4M@Ð4M@Ð4M@Ð4M@Ð4M@Ð4M@Ð4M@Ð4M@Ð4M@Ð4M@Ð4M@Ð4M@Ð4M@Ð4M@Ð4M@Ð4M@Ð4M@Ð4M@Ð4M@Ð4M@Ð4M@Ð4M@Ð4M@Ð4M@Ð4M@Ð41ñ4ñßþòoÝùã")ó]Ë¾Ü¶Ú_½l­CÐ4M@Ð4M@Ð41iâÿþ«ÿ¹{÷î»g­táÝmiB%U4M@Ð4M@Ð4M@ó&n»kcä\ðÑ¯)>ñoBÐ4M@Ð4M@Ð4MtNÕÌw-ûrDÝûµm¡³¨Òq1e^ñ©3w('Ôùt^ùµØ¥mÆ®Vç& 	h& 	h& 	hbiBü'>óM;cUJºpàCAøm"e:í( ¨!v]ðÑ¯øëÃµ(³ù¼Ð4M@Ð4M@Ð4Mà¼Ý{Éö1M;oZæ7dðg[x¶wV>÷GßqZ
¯õÇýá_SÍÇ,]Ó|^h& 	h& 	h&F&B¡ ±@pæzPJfËÿ&¬Ñð±N>0|CYë!(³(SÕÆ¤oå.Â©á¼Ð4M@Ð4M@Ð4M¥S @¶)rNÕlAÖ2TKL2³JOµÖmaÕp^h& 	h& 	h&FpÞÄW~ÍR}&YªÏ£k}:YËP;µ!6wó¾­¹Èó#ÎM@ÐÄ¸ÐÄÞóÒeo:pÅÛ_´véËæbVµ:4M@Ð4114!0]rê$Z³'ÒkèMÔÞÓÄøt*fC{SÅYºFÉQò3MÄTkkÖD3 \ClÚeSFK5·wP­Z'OÓ{~GíB·¦¦m~Ñ[bq£ÿ®¶¢	ßÎÜuýJz¾zÊzÖ­.u^ÑâözFZNZ°oßGá7¼ô9ªy.& 	h
MÇbé%$Á\5Mdbe!mV4!´°wÊ3µ|:åIÙ+Tè;Âl»-¼ÈÐê¼½Ó}IåiYâÉã©V½Ò*w7§4Q}¬ñtÝÆ&âÝÀ5:|²EÒ?ûÐîÍOX»ôeAËÞtàWïçM­ôwV¹P|@Ð4M@C¤	K9õ"ÀMü·¿ü[ßQ7q£üá´&,;Yme*ÅM©î]){Uw¨LÎÑ¢ôoè7×)Ú/\y|ÎuåÅ,ìóöÅÒÉO°x3Y+vG~{=DBèkLc­h"\Î]²­;È~ÀUUÔü¡	nSr~sÈ{un§¤½ÝaêlU­ò;¬& 	h"Mt7·²3)(äÉ«ªÞR+Cå×ª6úeàÑ@fKU5Ü
?âétA¡ôéú{×4Ñ%Z½~Ú}Í5M2«S¯fÒ°Ëw]4ÉÚ¬ÃfXu;PýëæM\qÂAfoQ¦\æ¤ûZa¡bYg¡M%× E+Ú,ÀD9¶Ò¯Ö>uÊÃ¼J+ç½þùµWªM%¡	h& ±£	¶ùëbÃw¨¥¯ø>\ÐD>$<5¸ú$Møbüq>$lÿ/Õ0µ©ò¡é?ÇÁ£³©X/B4Q+gæé!Áùªx:³²trV¾t¢øè/M®%_¿ê{í©.QÒí14GþÇ
UW/4qL"ÐaÿIsÊw­;2)X1Æu³m>ÜóZ}jWó&²T/é]ý×ÎE1ßÁvP^É?ËüçxÓçM¨wMLZ×)#øBÉëùz 	h& ·tò`]È^lÌ æ,ÏD¨ÒDþè×VG0`È³<3±pîXCDQN"ùÔQ*Ö @½øtÊóÁãÕ
ÁØOD¿z:æ»È:]£Dw4®ßâÓzóëS]TCÞþ£|;^"s£·½º	ÿó>]ÇIÃ®PKÅÿ1fÛÜ£Ì+¬.©>OÄUÿlõô¿võ²¶ÂÓ.£a7i"3AV¢×±	M@Ð4Mþ,lÿvû_-ÀXxrÁG¿ë©\Ï§vþo«¡ßT8ïä[îÐÒX:õ&aªÄòö_àcfº_ÑÎi"Ð8ýwçÙ©Èâwµùõ+9a´â"ÈHý¢	×Êü¼òÞÚfÒvW(P²URqã7Ãb
¶ÿù<o¢(%½¬9Zqò^C×uT®!ÂÈL2T%:Ê§³U¶& 	h&F&ü)¯Ö{jDIÂ¤A£v¶-Éßð;¡ü8+ëô¾ÓD³ã¾âjkãÄùÖ
£	'½8&ZÍÁ²jæ'Ç³óÓé&¬}³Nh7²ïÜÐVBÑg²7¿~E++ ßëj°þgü®z3¤tkâÚÆl¦øÝx{ÝÐLZí
²+BcXÐDÍ0^$ûÛGe?½ój¶Äþ<7Á
[(MØ)m2YQfEÅéLAÐ4M@£9ÛÆÏ¶Ê1Cl°÷,Ì&ò÷ØQ ðj{6Õhçü%¶°Ûï( f[÷0qÉBþ×¿<ÏÖÒ©°ÌÉú.Lº x»â^²æ¥ð-»ñÚJùnÔù/­è&Zé:344Ú]ÙÄ+§JùÉvÒRÅ½ÏðÇÿ`Bò(
k%Û> ÔÒÄ8PTiÂ'FÐY´×],¦wó& 	hYNñÅ2³íA-MÄsÙèSÈøbF­Î%p¶
É6>ÉvmïM´Uº³lÔ#M¹Tw`ØØøx ´¥ÐeÄá6ô
«°¸»hÑñ} âÎÊ)Y¦Qýñ64æT¸oÍWÿ·Îaµá.m»£©©ß\´èõ^xzÎÔ¦2µk4iÂ¼`ùÙÌNÅäIõ6^
»£ZÈ³³³¨LqRNe¼ËpÚOòâðûëéMüÃ·ÿôÿTÓÿû?:§ÒÈÖëÞÚGÐÕêu/=^*ùûõw×îõ)ZíUÚvÃâ¾Ð]_.ih¢ú*êÖýÜ¥#{#Ï±&Ôf/­¬ùôÞ¹kÅÐä^[¹ø;^1¸ØþÄÏÂÎ÷-«Dà1kµvÞD|tU~mUC7Q¥	åHt	i$Ï¨ç²áD6ð£}Ûi Mè
ãmïeÆñÀh"G$Ìoi~ZtÕyá©ÕKâ¿B?Ìfºc×côºh,µÍª âÊ«ÞYãO3×·{7Qk{c44æ ´+æb.âN=W¢¡Ú`Vcñ
óSè&V¬¸Xr¦6W\<F±°%Þ#h¥ »ZÑ¡£XQÄÂl3ÇÒ6^w4ñÿý¯¿©U¨í\{ãÉ!³ê}sº«¿M¨6]³î¥GáPèÚj÷ú­öv$þ5_g4ñý[ÎôRmß½âè	 V¯âhâRós¬¥Úìúj~!½wîZq[a%¾Ý³{ñ??F³°«_}+îF9\,ÖZÅÞÖãHY:Ýá¼bRgÎgåPh4O6¾!2VZ×4B~!	çÆwtL­açyY7È°?váÊ©ØhÆMT{ê¹IÃ®ê,õxôñ)£mýÍ³°U'Tó&bôÄçZË"ïÍ®g{®j³ôµó_qÅ	ÕQµK© v½ÐÄ£»T²tN[þýkæHüÓµ3§4a h¥4éMXúBf]~ø_ïÈ¯bÜã¨áRÛçØ@q~£´t§Ae	Ù¹òÎÂ[ûÄÐÃ<Õ¦j±ê±ú£rÀøXKx^³KÚ¡ønÝÑDíyk3}µþÄ]+
Wÿ(Ç¤ÖfÃ%Oí¨2ú469µÅn	Ü{ñß@íªï""Ã¬hÂM¬xI"óÛ¾~*¯wÏA+jwqxïa3M4Ø+»jIÛ]VnVwåÞ¶Ú¿+,qîhbçÎ?]¾üe*iE¹ð5ó®lµnÝ:\¿Þ;[0éÜ§ÓøZ2wMµ6ß¿åLI#YÔ¤­Q$ãIÞ³¹
êWÉÖQV|Fåw!êtHqúõå`;%Éá!©
 ûýUïóõK¬
oÊ¬µ
kuvÕ¯Óù:ýÿôBÁµb­ÏU{yº?5ÝZaGÏ+ÿ-Å?V<kUê&W±ÈlõÊå]º?ÊxÁ¼\}±[=JtyW'Ï±&ò¬ýRE«ñÅÄÅÇ5Ï+^Èj+«¥Ú{w>þ=/I«FÚLµgÄª 	îþ¥ÂyDÖº]Ê(Y³_w6£)4Å\y.Gå:ûBãº£ñJ¡0t×ë8MKMiª=y½MßiBì°pá!ÚÔo¬P\xáéÅ®ééoäjmùSÌË&ú«[,©Jh/á*ãcõë,¼YÎ]qÅ§0Ñ#ðyóäïÛ¾¼ËÒ~aé¤ÿ$®3
ÇÞøl°Úêì®¿­-Y'4ákÓ)tÒxY®.M\¶ø¨ØvDù~ýrrücñøTOí:Ñ#tNr}ºx@­^9È»âÏ¯­¹ ÃVR÷wÿÆNc4A\U¶ï*1¼xçóÞ¸©&ZÝc(YrSÕ)ª-wV4ÑÉÌÙO¦PaÁ[Éä]aQ¨²?[Þ]òÞp_	M@}Iá;({BÐ41×4áË³dÉëÖÝa­DKú(-SS¿©ÂÛ¶ÝMÌÑ¼Ã,Û¤jÃâ¢we²]!çXpÊßÏ=ÓÙ6OFî&B×d- ê|©²,¡4¢ïµ÷ëJB,o8{Ø`KÖ	Mø?tù2ôùtÃ,óÅÄSÓJ\§1!h¥²âû¶ÿö¸qýW:u+K4ãÍú^9ßrñX;¡G_~ý:òýÔÚ>ÇÐõ[WààSdÃ'ýj)ÅË£ÌÌPQÞÇÞ\K6ÜcQn±Ù`@Ø@á°-Mþ"\¾Xsam!ve³íÖ
£åloMÙó¦õï|@& ÎçMdÿüD	hÏ4!0Ø`iãÆ5ÙõòÅÞÔ.ÃETëõ9^7i¢ð¥¢iÈÞ±î]sòù,zYJ
#óÌðMuS>cõìQ,ÍUÃx3÷Zo¶Eá³÷eÞjÎÂa¨B)Pµò®êÙã"3>äèÓù@Ýr>mÓ!6ÓDñ<H¶ùó!qmµO¤&¥	Eëv¾åz7Q`{º*ºWër{¬îÍ´i¢áiÞ¨õO«Þe(=&òzujp
gÐ4ÑãìÓç÷S¤\HM@ÐDçM,Yr¢+Ì.f3§lìÔªZhbîæMReÞâfa#¿Ä>È"P3MÔútªÊQYxË¶RÙz¤íÙûB3)­iÃÙãCwñ@C»%a­o«ì¡¨-StbéÊ8Qó+WkDÔ	M4<ÊÐ£ÅÒ
»ÓM}²UXª9ù¼Íåsl¸Ç¹ ®
°ÿÏV>ªXc'fWÎi"¼Dæ ÍÈM@Û8óÛÐE¡	hèMòÔé;ÿtjê7+\^6m\äM&âÃfÏâóx­'¨1¢	]°­JfEaJTl2 håIµð¬´-Sõì³ê}.½kïÈ{»E-*QÍ:<°¢­Û«çMjÀO§ù+mÖMd5Só£Ï>ÇçM4ûhªøß@yZSn÷84QX1e^ÈÈh"¢ôZsºÍ&²WRû?´£õ½AÐD.IczN®P¡	hÈiÝº;þ9jÛvÓ&s#ÙÅ^Ï0&¸d ÊDIhb³°Ã®#¤¸b>f¶è¶U¹ÒèÓDÈ`ùRk'7ÝïdðÝw4§4-ö#ÅÜjÉÏó&Íâ¦â¨,«@"2ï.>ËÅI3ßxÕ\ª(æª4¿rÅ-ó&ò#»n~1ß$¬§\ç i"Bx2K¼Å¼	ï)êÕy¯ëÑD-;Ï1 [ÑDàP;o¢&
Qù<o"Ø ´×¤ î¤ïnëH³P`M~C/ÞlCc@ÐÄ¬Ï¯ã¢0XÊ®¿¶äDï]»ö?R¡¶c§¨DåK°WNZ°o'1 :©¶U¬!ÎÂ®µÇ.Üõ·ÂãM[ÈîeOµöù!å»ðìÂ9Uìmåæ¨ùìÙ	Rw>
±¹È·ÌÛ®
¦Z×Fñ@«3ÐcOd¯GÅ®¶ØO§<½ö+n¹P dÛ°ÎexÈæd¶Ï±/4¯¼zÙÙTÛ6Øêç&º^WÕM8@[çM´¢ª×¦<W"¼îXKRW$MB®î"¾óHÑ¯?'ý½Õù/ñ×B@ÒñÂôë MT]Å»×ök°åU«Ôã]Çsëw¸;hÕÝß$;¤	û¸÷MÍª_ú¯BçO.>Ká¢kµi¢B`'ï]³æcyï»V[hs¶aûEjíTÝKµÃ¥	{ª¯¦,¯:zuUu¾å¼×±	Â­½íÏãã¶7-Øô&|Æ8¿Zg,_]ë+Ñ  _X¾	cqw¬½µ´={ØµYÖ@þ:íµÏ"t.Aài%Ï ¶S¦êS¯Ö¾£b¢z¾Ù¼Ë!9bWÀbV4áW±¡Âkk«]»]Áqý¯Ðá£tÉøóßÞüki¢ösU[Y«ç­,n¼¡¶ºÇÚ¶ÙjsV4áá)\¹æH1dç^¢~á±ÌcºËpñ¤¹Dmæzr¼jf{ªxFf¥¦'&j'¤d):Ø-Ð£v¢M½~}ØX¼xcãÕÒïÐçMd(S/4áhÑñF&ºüQëbh"-É-¥èZ»K¡ØuË)µÔ;MØ¿véËÞðÒç(G¿ãNãZÑÄ$¥£×ojEU=×©&&Ì®²-M>i(Ì±\=o¢knh¢`cGYfP¡râ<&ÛÅ5×0úñ&:´tê£<`y¨¦åKíKKë îÐD+±_é?[aí±wúÔ)/\Xy±ìMæÃ¼z¿Ðkh½¶ÚoWê. 	h&æ3MÄØ*S«®?ÜõHñ±Ú&[Y1a!Ç¶Å²tE+b´×ÊìJæ&ª.ÃÁÁ¡Z"HÌÐJö¸ ¶Br¼NÕ÷-¿Ã±Ëï§Q½x­vk¥ÜÃìÍV:VJ6O¨éMj¬VU·Yý£òÞªz4öê^ºõÓ&jÛN§æ{ÉOSÿØVÏÅKÑ/ÏÅvP®Ó5Ìö+4Ñ Dp¦ÁA,`Û'ÅÓDöPÃIöµã¼×?ßåÕúð§'¼ýEè& 	h¢wènb41Ö4QÈ?=Z_ôBÁ5aàÁ78§	ÒêÀ<I$ïíåsâÑDÐAaoÓ*¸[aé$lQMô&l<ß¨ ßxýl×TLkW±ú×Ú­Y.­Zµu¢ªëMT§MT]CÌELÑ.ëBÒ!MøúëS¨Ü?dÇµÏ¥hîp²QÕvÝó@Ò×¼iµU|½KåcÝÅ®8á âph&Æ:Aº¦c®°RÇâÂñT7QÌ1×xm£ åý	1hÂÇ¶ë1°¥ üå3pÕÏãÙHjh¢CÈ/X)/?¶+G¶5YKñ ³øcsd1u®i"\ºùvb:Iæ)ïfå½nÅÞðeþîB¶¥Nh¥øç ix.­Übø¹Û¤ÐÄ\Ð¨!&e;Y!LP1¯»ÀWï!&wûyÐ4M@ãNñÉ]¢H|×í&ªòå+Õ£CyÉ]ÙØ;>ÛÖ% )û«ÑßXÁ¼¹¦ì6ÙÉe$p6+ÚÒD¶[Ë«×0ÝD5ÜLpSU¹/²yo°ëìe¢Vï4QíüãY4<f(QõDÐD_hBt üà¬¶k´`ßðçng÷PAÐ4M@ÐÄXÓDÌ}°r×4ªøèÐDÈi|aì¾s¦<½<A43\
Ï±.øÁÐDíyEUÏcN*Ó;MuÎMäXE¾ÛN­ÿÞçM&b¢Ä×Îñá/~íÚÃUÀãïy¯¾ñÁUÅÏén¨& 	h\UTíh"ûVµøí§÷tZX­hb.h"¾]J¢\À*¶{¤xÖZëõN6Xª}K;¡ªB°gs®}:¹W);_^ùñ4£#jû\:¡haýMtMbeo:PÉ>ã6gòÌkáBëÆÁB¼îÉÚÙã4M@Ð41v4ä=¬×ê&âk|ÄbÖzj©d,h¢¸£åC,ÅÔQAîEñõ»&t.]NýòÜë¹3ÝÐrÞDïc6þv»?*¦ð4áç5+gmOÎaÕ6×4ØbXÏÅwæ^·ntqÁq þ"Uâò4ÿKö×Z±_bCµgg¡p)tFvåóò´úîh"Ú£þ½ä.
jæ(Lò%SC;å½Z)"ßN¦µK_æ]Ø& 	h&NÙæ<»ÉÃtaÝoÁãà8ÒDíE0ß°	2yòE_br5ÓDuÒG­×©.R×ÁL1 ¼¢i~Z3[ÝHÙ9MÏ:,©àÓ)~+ZVñæ©êñ)ÓXØ³ªsælVí.º£â¼Ejh¢!Y%éªÊü_;ÿÚ%R(¦ZSukë&U«ÍOòbh& 	hb|çM¼kÙstoýjÔögÞb?gë\L}­~îöçôVf*¡	_óGxÊx
E8W6èÊwíXÒ½k%:§	ÏPÊSæ{¼¤	¿Õ©(ÖDä§S}pU·½ñVßaÿçuykîh¢Ú^Zµ,ß©ØV7«üjôdmWU2å;þB/ª¨i¢¶5Utíõ4?Ú½¹oÑ¹\¾7Q-	MLÀøM@Ð4MO§ÑO}¡OÐDù%ßáDqO<¯EÂZÃªl4äô&F![$èTÍìÖMô%ÿ1?Üx=ú¢8ë&ô¼"ª]«8zÌ& 	h& 	h¨u§_X¨pÆb>±·5XÛÛÊ?R|F.¼zNMÄTâÚø#HµAßúâ»xh"{Ä×x¶A¡	h& 	h&æ	Mn|BUp-ý{U¸Ù©²
0q%­þPùÃï¬¼M(ü­;¬ÚÚ2\ÖÙ²ÈIëý2Ã°SüJ]¨f 	h& 	h&æ!M>6ódÕ 0[Ê1õ³áÑe¿ýÎJZ/è"&F&úÕÛ@Ð4M@Ð4MÌ+õø*M«1¼rN¦¶aÅ¬¹Ô³5¤& 	h& 	h& 	hbDh"T>E:fé*#dEF4a½´¯j ?h& 	h& 	h&Æ&bRmøÂv¦wå	ÔÕYEè´kV"<b¾¡Úúw& 	h& 	h& 	hbX4QÄh+&AÛºÉó#Öp¦	k"¡~¢ ¬×*â4M@Ð4M@Ð4M@£CÁ¸¼êe(wYøÌ7co\Ç¹ZEúöLíjh& 	h& 	h&F&fª1æ°T"jÈ¡ë²Ò<yÐ4M@Ð4M@Ð41I4Q¾2sìlCM@Ð4M@Ð4M@Ð4ÑIÊs7ºPL@Ð4M@Ð4M@Ð41v4Ñ¡Ã¥¶ÉÎf{©& 	h& 	h& ±£IÐ4M@Ð4M@Ð4M@Ð4M@Ð4M@Ð4M@Ð4M@Ð4M@Ð4M@Ð4M@Ð4M@Ð4M@Ð4M@Ð4M@Ð4M@Ð4M@Ð4M@Ð4M@Ð4M@Ð4M@Ð4M@Ð4M@Ð4M@Ð4M@Ð4M@sDëÖÝ1îéöûÀ/ ApRÓeo~Áû<soPé^¾Ï¿záÞ}jn}§±ß÷}Ödßã~{?sâ{çïó,òöûG<÷WNðòï×ø>Ùñ¾y¯ç<²ïñYÏ~® ioðeG½w¯½7Ùñ9û½äù/}ãÄ÷6ûí·ï[ßzü¸§ý÷ÞQ¯YxüÞ8©iá¡/{Þs5Á7¨tàóö~É_0Ù÷¸ï³9Ù7øâ·ÿóöì{|ÞÞÏøÞfßçìõo>nÓsûü^ø/&øÿõ«zæ³÷ì¸ßó_¸ï¾ûOö=&þÕGNð¾ü{íýÜÉ~ÏÞûy/{Å¡|G¼æuz3Nc¿ìµ×^=ôÐîÉ]n¹å<p÷D/~ø^8Ù÷8Í­ayËÌ2Ù÷HoCo3ú^Q½¨ô6ô6ô6C_tºÍïm 	Zã;4ÁøNoCoMÐÛÐÛÐÛ@Ð-ñ`|§·¡·¡·&èmèm 	hÇøM0¾ÓÛÐÛÐÛ@ô6ô6Ð4A£Å1¾Cïô6ô6Ð½½4MÐâhqïÐã;½½4AoCoCoM@´8ÆwhñÞÞ ·¡·¡·& 	Zã;4ÁøNoCoCoMÐÛÐÛ@Ð-ñ`|§·¡·¡·&èmèm 	hGc|&ßémèm 	zzh ÅÑâß¡	ÆwzzhÞÞÞ&hqïÐã;½½4AoCoCoM@´8ÆwhñÞÞÞ ·¡·& 	Z-`|§·¡·¡·&èmèm 	hGc|&ßémèm 	zzzhGc|&ßémèm 	zzzh Å1¾Cïô6ô6Ð½½½4MÐâZµ¸M6]»g¹äK®±%_Ò}÷ÝM0¾ÓÛ0¾CÐ½½4MÐâF§Åð·¹ôå_¥¤§éÑIpÀ¯}`Y\4ÁøNoÃøM@ô6ô6Ð4A)¸÷ø?zBIOÓ+£^yÈ¡¾ý×qyÐã;½ã;4MÐÛÐÛ@Ð-& 	ÆwÆwh ·¡·¡·& 	h&ßém 	hÞÞÞ& 	h`|§·a|& 	zzh ÅAÐã;½ã;4MÐÛÐÛ@Ð-& 	ÆwÆwh ·¡·& 	ZÜÒÄú[NY|ÚÃWÒJwPpç]÷@Ðã;ã;4MÐÛÐÛÐÛ@ÐÄ|£	AD°ÀÊoé(ºÆh`|g|& 	zzh Å)M}~£_ejåMÇ·yë#bÁÒÔªÕ.sÅÕ¿í]êÂB×S¶âC©84M0¾3¾CÐ½½4MÐâÆ&ÄBª¯|Éÿöç¡cµ¾}Ç.+ Ê	Mv©Lè&ªýk 	& 	ÆwÆwh ·¡·¡·&hqMÆ«!ôë«ÄÚ»òÆ[vx¦já]ªªTrý-è& 	ÆwÆwh ·¡·¡·&hqDûm­I X¨¥	%qjDè¨©U«ÝDµ°*ìC 	hññ&èmèmèm 	ZÜÄÐÄæ­~AÉuÊ)¶VÊ Çú¨jamêÚT1& 	ÆwÆwh ·¡·¡·&hqA7-9?MNY|Z @ùLm]}ÉÚÉR.P-ìÊµ®ßZ/²Ð4ÁøÎøM@ô6ô6Ð4A_%Ñë 	ÆwzÆwhÞÞÞ&hq]Ð±°¡	ÆwzÆwhÞÞÞ&hqÐ4ÁøNoÃøM@ô6ô6Ð4A& 	ÆwzÆwh ·¡·& 	Z4M@ïïÐ4AoCoCoMÐâ&&vx'b¿CH4ç4¤ZNÐ4ÁøÎøM@ô6ô6Ð4AkO°Íiû]J]ÓÆBÐã;ã;4MÐÛÐÛÐÛ@´¸I¢1µjµCäH*¡õ7Þ±­`wÞusT6×oØ¢|ë8wZ_pØáØ&ßß¡	hÞÞÞ ÅMMØÒIÔà Õbã~fÇ¿Þ¾c)GkÅj"²ÐÞ(Á²ÑM@ïïÐ4AoCoCoMÐâ&&B%aÉ¿OaP³ÒÔªÕÎTùXwä2/»&ßß¡	hÞÞÞ ÅAMh½ 	¥7ÞËøh`|g|& 	zzzh7¯h"rlËdXØ¼õ¬wPÎÔªÕ1!Âµ49Ð4ÁøÎøM@ô6ô6ô6Ð-nÂhBQÐ¡ æeÇ¼	ñóc¶V&"ÓD­z&ßß¡	hÞÞ&hqãKD¯&ßémß¡	zzzh ÅAÐã;½ã;4MÐÛÐÛ@Ð-&ßémß¡	hÞÞ&hqÐ4M0¾3¾C#µ<úè£ûØÇ&û!þþÌBoCoM@´¸¡ÐDLÇ.Òú[ 	h ·&ÆtÙ¸qã¶mÛº8jzzºée¶G5\Cw·ÖËémèm 	h¨¦;ïºÇ¼PDÄhåå5Ç¤& 	hñµeùòåÒÒù.¿nÝº%Kô~;wî\³fVVÌ,³V× ¥mËÚµkÍ:£ÎKoCoM@ÐD4Þ\[),ÚÒD«uÐ4M0¾CÃZ$Àg9\Rwçw·páÂ>^$ó>Êüyú+óë"G"èm 	h74±~Ã.^ðJÐãMätZ¯H¡|è]qàÅË.M\tëõï& 	zÆwh¢ÂöºuërÎÎ;MÚ%ÐÐ¯s¼©E±mÛ6­¨Sò÷yóVr¡njúýú(7
ÒÄT¿V|H¡Ck(.RåµâÓÕÞNçò®©©©|8Ê×¦z¢ÂÐMø¡ÉµñU¡·& 	ZÜHÑDÖM&"8Ýö»ÛÎX¯µé7o}$BàZ¶¶OM|ÿÓ×}þ;µLM@ô6ïÐDdãêv	Û!®[ºÎ%%*[l6,"v'-¤îV4hsíÚµq»nÂUIüÏZÑe¨@TXhâªéÍwÂ³6| òqÐMDUW%ÊÚTOÕ7ô6Ð4Áø>I4aC¶tR¾RÔf]j^¿aKX:)G{/^viî&>ÿ_QP¼ãòuÜô­Ûïÿs>í7Þý¡[cs®ÓÝë}ò©6üçºà¾ô°EçìN:ëZ¥É¾Ç'\pýgðI¯üìæåwlLúÕÞÌ¹S;]'é·m<çoö1ø¡/ÿÛËþKëVúOòýZÈ|Hû!Øi"ëÕC2Mä³(3Mè<"Nòüî¹Q¦â"}`óÅååS°BKR¥ÐtD=yÞîî¯ýñPîñÝýßþúd¼¨µéô+xË¿4Á7¨¤Ômìt|ò[?ý$4M&D
Ö8h%ô*¦ÌHÅ¼	\yã-*Óì	ª&.ºuhâÏ~û÷¾²}X4¡F·yûãÿ¹Ê\vÇ&h:Mº_ýà|¦	µÖ3®}hEwChß=ã§¨:±º(H¡-M\8³Ø%T-MHoþ¾^h¢ùhÂöKgV4Î|ÍÐ41¦4ñßZ÷-?& 9¥	ÉÿAÚ´Qµa¿¤|Ï;L­Z@²bV4±þá]Bë>ÿïÿ`z¸¶"¶4¡¥NCïmÔv4FÌgÛ¾7Æ	³tòD O°~A°V²Éï·-MHr¶üïÙ
ÙH»
Ð!¶tÒoÔãYW¾ÊØèÈÈÓM4ßQMáÕ.ìÛt¨Í§ÐoAÈ6X:¥Ó;.&hqsK*æÁ¢Ï§ 
bÆr6o}Ä+mdh´âg;o¢# 	hÞ&zYüÝÞu¸Ù .æOvö.Ï?Q1Y+ù\¿TvnjfÙ½gCH>våp±«z®¼ùâÅ½xR=º)N¹fÏ¹Öb>Ú\	²4M@Ð±°¡	h&&&úµHög|	ÕCü&ÏlM@´8h&ß¡	hbììuÄãDCÐ4MÐâ 	h ·& 	dh ÅAÐ4M@ÐÄè,[¶lyÛÛÞ6Ù-ñÞ& 	ZÜibjÕê+®þíí;vAÐ4M@´x|§·¡·& 	h7w4±~ÃÞÖ#4M0¾CÐ4AolM@Ð4QULØ×«uE;»õ¦÷:'ÂØAÐã;4M@ô6È6Ð4MÌOA\¼ìÒ¾òÆ[BBéÎ»îYzöùJÊÑ.×©Ðw©ä¬4Ð4ÁøM@Ð½²4MÐâ&&¬e("_¯ß°Å9çÎ4aå6G;& 	Æwh&èmm 	h&¬k,+Äñk°4M0¾CÐ4AolM@Ð4QÐDÆÍ[	Ý4M0¾CÐ4AolM@Ð4ÑLaÎ¤]+M@ïÐ4MÐÛ Û@Ð4MÔNÄö<+Óp1µjµs4TØ(â@h`|& 	hÞÙ& ùIÄÂ&ß¡	h ·¡·& 	hM@ïÐ4M@ô6Ð4MÐâ 	hñÞ& 	zdh ÅAÐ4ÁøM@Ð½²4MÐâ "mÞú4M0¾CÐ4AolM@Ð4ÑE:eñiÐ4ÁøM@Ð½²4M@ó&T,GXß¼õX¿aÁê©U«sç]÷ØOìÃ·Xç·õM@ïÐ4MÐÛ Û@Ð-nÜiB8àt¢ ;eñi>Pì u¡HAÅ©ÊTa³2µâïR%KÏ>_ÚÛ¬­& 	Æwh&èmm 	h7î4q®MV:´K¿V4´rñ²KsØkï
K'UåJ°t&ß¡	h ·A¶& 	ZÜ| l¡dXð¯hbÁaGãCÐöf Ð!âh`|& 	hÞÙ&hqL¢ Ï}0lß±Ë±5Ê.PJ4¡ªbn&ß¡	h ·A¶& 	ZÜÓ¡ @È L+_{U&æMTiÂÊÏ­pmÌ&ß¡	h ·A¶& 	ZÜdÓ]6Yã3«y6ÖAD%>Ä+ÅáÐ4ÁøM@Ð½²4MÐâ&&M0¾CÐ4AoCoM@Ð-èzùÄ¾+P:ãÚ.úÔ¯ÿÓQà9óÜ¾©äõ»×=
M0¾¸·ùÑOôëwÉïþ_¯zÐëW®ÞM@Ð½4M@´8hbXãû½íP[Ëé¢[7"$·¢LÆhñ}`½ÍuÿNñ*Þ~ÿ÷ 	h ·& 	hMk|ò©yýú,­xWQF[. ®_g&èmfµcó«(ÎíBÐ4AoM@Ð-âøÕbÂK¡èb`|ïbÉê(& 	hÞÙ& 	hh^²z¢ªðê>*& 	Æ÷.POF1M@ô6È6Ð4M@ÐDÛÅêZÅPOôQ1M0¾w·X=1Å4MÐÛ Û@Ð41Ëôôô¦MÖ­[§_hb Õ­^$¼õW1M0¾w·i¦& 	zdh&Æk>¬Zµêº´<öØc³jqï|ç;_{Ôëþ¯Nzî¾ûþâñú>ûìÓÅøþÄO~ú/~áè£_ýêW{½Çtô1¼yÑ	Çw|Ûz9öØÆ¦ãûÖ­[ß²ç5Ð[ªwµ//j¯ë¬R¾<5.51h ·A¶& 	hbìZFð/ùË×ýìrÓM7#{Û'úX·g¹ÿþû×Ø/IâVãû#<ò|ï? ´ìô¶wx}DÒÇV|òÈ×åõ3síµ×Bós|ÿýßÿýÞþÏ/§ÞR½«#õ¢æ/OKM&èmm 	h¯·cÇC@Äõ×_÷ÝwoØ°azzzÞ¶¸8äÐCm+uëÔÄ>R¦\Ç[t×_~41iâW÷¼zKõ®Ùa¤|yj\Ð4AolM@ÐÄxµ¸ÇünèäÊ¡	hñ& 	hÞ& 	ZÏ}îsF©©©]»vÑâ 	Æwh& 	zh&hq,ëÖ­3JÜpÃ­ì 	hñ& 	hÞ& 	Z\±<ñÄ×_½i¢yJ24M0¾CÐ4MÐÛ@Ð4AËËw¾ó£ÄüÁÐâ 	ÆwhÂéÅ§-8ìp'­/=ûüÎ½ó®{ 	h& 	h'-îþèL6l ÅAïÐÓ9î«;6E+o¼¥s& 	h& 	hb´¸ð
ûøãÓâ 	Æwh¢&´nFX¿aV.^v©w9â>+]4MÐÛ Û@Ð41¦-nzz:BÔÑâ 	Æwh"Ó Aá$@Ð{åü?ûó¿05ª9è& 	h& 	hb´¸ÇÜ4ñ©O}M0¾CU#h}ý-~µ2)1h& 	h& 	Z4ÁøM¥ÂKS«Vg&±C5& 	h& 	hM0¾CyÞ0áÎ»îY¿ayÁd!j¨æøXh& 	h& ¹kqSSSÉ«ìüØaÑíCòôÕ¼Ù¹W?ûó¿Pêâ3/4ÁøÞ;M¯±PÂÔ LAùS5ÇÐ4M@ÐÄ<§Íß{\4qõê-Ð4¡åû?¾{Ý£=ÿêÑ÷Þâ-Z´qãÆNJjxÝ¶m[wÇêÀ+V&ªÎpº 	ÏlUêâ3/4ÁøÞ;M½&èm 	h¢Çå=ÿï¢wþÖ:hbÓÄOýô¦/mÕËé_ø®2ûB&­gdÐzðBÎw±Lg¯[a]³fÍòåË{Qdx|¿èÖëÞÕ;MÜy×=v¤m}¾oFÎÊoñf&T8«Â 	Æwh&èm 	hb¸4aÅiâcÏ4¡3£Óí÷¯/4±páÂ%K¬X±B+k×®Ý=£Ð¢Ù¹sgÔÐ@»T2°BÅ\^|ËhE9ZWåëÖuOÄß}Ë)ÚÒÄÃ×¯ÖMZÙ¾cV.^viäL­ZX!
PyDhW¦	QclOâ|®@ïÐ4MÐÛ@ÐÄpiâ=ÿïïÿÿCPbê	hbibñUViBéæ[níMXw055%#(ÇeÖÍ,.©½B|¬0aÍ59GGWâÌÞÇ÷|×f¶4!^0(;(iÓ3U&BþÇþ¡È4a$	Ïÿ·>â a M0¾CÐ4AolMMX1ñ÷ÓOzöâ«z5ø»þc-JôØøX¦	È¿~­V(¸cÅÌâ(¶0-+ö,.#Ö:7o¼ï·ðï>vÿ+µ¥ò%ÿ¯¼ñ¬Ê(hB+­hBiû]
E. 	Æwh&èmm ®iBïø1Yî»ï>hb\hâÉ§~ÚJ¢¾ñæÛú¢hEÛ¶m[»vm&4àºX0¹ªV4ÑûøïzñUÞ~ÿ÷¾ýðÿ3ÛyÅZÈ®ûynØ¦MâÎ» 	Æ÷ÞiÂ¦tz3â& 	hÞxxÚ äø&Àû=41j4¡å_øn%.»cS¿æMdð®©©)óBÐ'P¬Y<o"v9GjiBe
P]Ó9âG?yrw·bí6SIB';4aÐbÙC¬±ÂÉS-<S;ÏË&ß{¤	½9z'íå5c/4M@ô6Ð4MÐâº¦	ÉÏÞô­ÚTf_âMü¯ÍÐ5<);JÚÝ«6ï­,_¾\BÝ{æY¸R15³ô8¾gð2¬èuÄXÆ÷9¢	©YÕióÖGì1,Y[!Ü%VLásÌúÍ@Ð4M@Ð41oib÷½Ó½í¸rõæËîØt÷ºG§ÿé©Ýó)væáÒñ&ßç&ìI¬ú:þ«ê¸Ø9äÂ¨Jù 4MÐÛ Û@Ð41Á41o[\wÑë 	Æ÷I¢	+Åãâ 	GÊ¶+3æß eE4MÐÛ Û@Ð4M@Ðãû¤ÒÐ ûÞ¼õ{!6)L­ZÝJ7aÓ&±§ödè0<4MÐÛ Û@Ð4M@ÐãûXÓ:Åô¡'b©RU7áìvYÂö	& 	dh& 	h¢Cèð{lvëÔÓ*­ß°¥v^64ÁøÞMøÕïa¦ ë&<¥:¼<å2¢	ãý=¬ÈU4M@Ð4M@Ð4Ñ9MHÈïÐÿRUÐê&Æ`|ï{ôºp;/dÐ4AolM@Ð4Mä´òÆ[lInÏa+rç]÷ø3¯-CÂ[P¨pÐD¸å42h×ÔªÕþü«U®Z¯
~Ðã{4A,lh ·& 	hM&"þµ­Ê·ïØåµÛ¥+ieóÖGÌÛ9¶!ñ¯sÄ)6JG7ÁøM@Ð½²4M@ÐÄÓDÌEµóÌê|
³C¶-÷!fWp§QÆ 	Æwh&èmm 	h&æ	Mx³0)x6k8Ø´R`#èd¢tws+:,M@Ð4M@Ð4Ñ&¦V­o"{Ëñ7ÞâY«E×%ÕÒD¸åGZ4³èO^±bÅÚµkÛ²dÉ¶9],µlÛ¶­­t·sçÎ	 	ÏÁÑËÙy¯ßíæb13& ¹^Ô#-_¾\ªú´NzÔ#-Ò±ýz	§§§ÝÉkþ& 	hbþÐDR¡Gd÷1çÚ6=É:çËÍ4áØÄU!p\hB¡ñkãÌ²fÍ¶þT¦mÎ¬.@§öJu¯véòFj#Ð«¨w¬:-M`éM@D	õÞÕw:
V',è]øwçéNuÝÌÒcm½tòÐ4M@ãK#ÕâsÉô?=5²47µ¨7Û¶mVô«LpZNÃsô[4EImjlýFñéL,°|ùr­MèìqH¦	eúS[>
ëìµ$2øÞæþèÝ±ióöÇ» ªc«${`si"ëÚÄ¶s\uqx87& 	h¢¿¼Y2TÿæuwêÇr_§_ueî£õ!.æM÷QF¨ÂèÝûªJ½ëº=KõTòÝVÇ]·+umùjsÜáe<hSõûâ¨Qc¾ÑÄ97|óAÐ4MtHê4$ùÔ2ÅèÐþj7Êtoµ»¤úg+Îq (zëú}¬¿ÑÙ°*_
J\ÊXW¢>ÖåÃf 8DxÇåë2StBAÂ¯ØY}8't¹¤}9ÆjÓ&Ð4MÌÅ¢~¬¶;R7eWT9êl­N/ú:õ~î£¯2®$·BDÚTUñ¡ÆuqZ±E]«É(a=µ;ä|µº¸~í-rò©wûÖzL|µ6¾HâÒÌÐ4M@-N!É§)K:ûÂ=ûó}vÿ¬[ý¿øîM|¼²ÑT1ö©¶xÆ<,âøæª<­#èêYFÇÒ)h"3E'4®ÅFê|¿Tb_ÇQÆaPÖoØb¦83W¥_åëª& ÑDÖ±ZÆÞ]QéFI!Ëö­hÂeDV"V¥ûóê5äô¹[)#NÚç{Hþ¬w5VÙx ðµiEúûRÕk¾ÑDf
h& V-î°7;%×>7ß±©ÐMÄPâÑ!x!h¢ÈáßEiA­Oji"jF;qxqÓÄM_Ú:
i5yñ'iÂqLL¶JZyã-µÞ£÷*we:8cÌßQ/ªqx¦O­'h¢Uo£^Z÷þ1Y°ÐDß«þ§§Î¸®M¿­^¨ª*h-9z°¢ÛÜ&8d(úÞ¶4!©^=¡ýih
¨^CaGZÐDa>¯ÖGYã¼df)hÂ§¶U®PKîÀÝÖ¶òÙn|éô­zó"h&F&:tÙ]ê¤òÚ÷ÀÆÇÎ¹áê09:ºð aKÝê hmuÎypMd/(ÙÒ)¾_UÏ2²º	hj«äá¸êÙØÅlË¤b¹L^a{'×4ÝÔFo&&I
Mô½Zý·jÑô¨ù*,6«Ýf+È}rZ­$kÚê&|xMdôÐJ\@ÐD>¶ªð©s%&ãÙêí­ãÐæ¡a~ê&«êÐ¾ò§_C7M@£@}÷uS0Û64@ÑâÎþõÔrÄèÓDÌ¡ðti²ïOp.3,:¤	×ã|JbÌÑ³z]'PMd#Ø¶4!!¿íçVkSàiÔ¶rf8ÄúwÝ%¿^±ó& 	hbhÂ={H½·´ìnÊÝ?´¥	÷uLíÜWÍ¥¢c,¦ED÷[\CMøbÏ,Uö	W#ï·Õ¹£ö¨Ö× Æ{Ô3oiÂah, 	hhÕâÞñÖrÄÐiBBx|Y8WQL+JbÒ®øÖ´{amQa­Q±öF¾+ÏuVWòYjëMTt&¶#§à!&Nî£,Ï]m·¹{O`¢¯saÿØ}c):jþvÛÌRt¿ùr]½Ü'ÚëÕñIãúó¼OE?ßh"sÄÿÑAÐ414±à°ÃmûóRÃ¤<ÇSsg_v³1)b¬Kºûçì±Åí&öD,êmþë÷»»dÃ§PL@Ð41tèËb_I°<
N°g»=õ&È6µ4QuóM@ÐÄHÑD[yã-¦3^s»Wü:D{íç?ûðw¢ÈñdØL%ÐKÑëF!AÐ41:4±{Oxì3@V ÛTi¢Â 	hÉ?xÁSSÍµQÃ¬§ðoÖeØnÊµó×b;ï& 	h& 	®h& Q õCËà«áî&Rh"ÔFôfN*y¤ ;ïºÇ:hbãûÓÄö»â½·«Õìé|T¼·Ð4ML*MlM@Ð41î4a³%0Iòóò Ø³!SØtÁ£½MèÚgÁÒ	è/Mø.h¢úöVêÅÿ 4MÐÛ@Ð4M@Ð]bÖ:Ãl5iZÅKÏ>ßèa·¹mÆW_³KO[FAÐÄ\ÐD<OÇ«70OÛñ¦cUDá¶Ç 	hÞ& 	h&:lqÁæÔm,4MÌ5MØ·ðÖÓ|Â0Ï9þuCc;§ú&èm 	h& 	h¢ÃÍ 	hb,hBo^Z'+È&B#æýZaa=ç8üÄ¬ÂCÐ½4M@Ð4M]& Ùê&Â~Ï3)Ârä#Z
4AoM@Ð4M@Ð4ÁøM4ÓDS±JB¢¶  	hÞ& 	hÈËÔÌâõmÛ¶-Z´(Ç´ä¢\:.ãûÊo±a	4MMxq ÷p8¡¡ÑqåÔ!Íe4M@Ð4M&|ê§Jµ-Îáì´ õVB{àÁÿ	º°7MØC,4MÌMÔF°\ªWËs"lÑ«½ÊwÎæ­:f5WèMtÑ«@Ð4M@ÐÄÀhBqïC;Î¼~½e«·páB¯,Y²díÚµú-òÅ¢íòæ5k´îLÓ £ª¤È|À;wîô.ÓÊôôt®éEmDäóª°6<³¥ÏÿñÿxÙ+ihq¨²LkbÓ5ÃÝM.8ç±z3hÂ§¨è
M@½Ð±°'&Â§t¬+Ùut&>*{¢n^& 	h ÅÍ&#Þqù:¥þÕ+êÒÚ
Iï¡¶ehWÀv	@
-r|ÔòåË':\+*/ÐúÚEUé@W³qfÑ.ÕetVL1zß:§6>¦^ýÊßýÚ+i9¾Û¹ÍWÿváE3ÂXÛ<\ß f$dç2Bn9¾ý}jÔ	h&æ-Mä°ÛwìZµ:¦Ã){í
7\[çÚ
h& 	hhKG´¥	ð×;)Éß `
°6!ä|SÀî¤³ÐL£@^BÚW%)Î,ª¡&"ÇòQ¾Â¶ã»9â¦/mÕ½7ïÿãc`áWÓÊhy(/hÂJ
Ûè7ÁÍ¡é& 	h¨¥¬znDzêÒ&¬`m6­& 	h& fJ\¹zsææ´yûãÌ/YôZîÞc¡äéØZ7bx1Gd°ÆÁÆHZY8³Xø÷®À (oèp~MXýiB+.ïë+¾7ÿÀ_úòNöfcCbÎzöØ_¥B02ÜU¿ýpFmh& j¾º#»°u¥Í<±¥&Ü5[=AÐÄü¡ÓOÿågÉòº×½&FJ7¡eýÃ».ºuCº	ËðÂYªùÚ&Ârizz:W¨2Î£²n"ÅëÐDæu¥ËîØ¤¤æñ]oÃtö5gEöú¡DU~& 	hÈ¹ °bªÒ¿u¨kÂÒ	&ªË	oyK¸¡ÐÐ9j½è+9tÃ·ÿZ+ú=ôÐWAÐÄ¨ÑD):§	³@Ý5bZ×`BA»÷<ªå[aiBá½Z´Ëi}F+2ji"êÔ2«YØf_ÿÄ¼òmhÂ>35(0Uò^
Q¥	sÀÁì L:\+& 	h¢ðj»íÊwPÑá"b64M@Ð4Aë;Md¦h¦3KlnÛ¶-ë,ÞGäí|©È,]Å4íØ Í|Þ(_\Iqmï_}póË_Ñdéd|ÐïðÙ¯¦6ÿë7lqÃ§;ÇeTðÁ¶Ð:ÜGo(hè&ü¦¯×x2kÓï¡~õúy¯ír±xÿ«nf¡9¥	¢×AÈ6Ð4MMòøÞ÷XØïó&üYÛ:2{³ÚË°ìÌ4¡26ºó×lÇª³g ;"³ö­s & 	zh& 	h& ñ¥0n>ØÛMò¼«ÐS1^ÐDÔ³yë#ª¤ÃXÌÐ4AoM@Ð4M@Ð41Ö4ÞÆÌE²T-MØÉXÐÃ¬ã M±çRh ·& 	h& 	hñ}"i"tÖ)Âù°§ÿtBÕzÐMÐÛ@Ð4M@Ð4M0¾O<Mx*mÄ´h¯¡1o¢-MØ/²z©Þ&Ç»& 	h& 	h& ÝýÓM ràc¡Þ¥ÈbØËWC±ÇRÔM··éï 	h& 	Z4M@ÐDNÄà1¥Å(+)ïM»ðráÎ& 	h ÅAÐ4MXï0«ðÐÄèÓú°k
4ë&þÒ»Dzôé£B^& 	h&hqÐ4M@ÄÂ4ñ;<ÓmY7á!â¯Ì*¡	h& 	h&ß¡	hbòhÂaÕlÞúH¡ð4yI.î:}þ¬æV@ó&&~& 	h& 	hb¸4~eOSSSö,+V¬Ð¦ówîÜ¹dfñúòåËU@k×®`02x^¼ãÛäiû]Z÷JX:C`ýBcM7n\8³¸!Ô¾TY¶mÛ6==Ý¼KÍPM@Ð4M@Ð4Ñ£× ¾ÐBâÓÆ=Ë3óE`²DÚûô¸¹hQ×@1G4ñ£<Ù¯ÞFáYØâMBõà©vlï[.¬Ä,ì	 àh½TæèÁ/jw­H!v©U¦n¢Ú¡	h& 	h-MHòÓv2!sÆô^KªZ"Ìï{¡¾üÿáþ§§º£B¬ÒøhÅVÔU&¢¢ÅW=xûýßËÑëèmº¦	/Ú´Ð®?Úw5<Ì©LwZÑ¦¸{Í5>DÕª±h%LÔf.ÂjZÑáÖlY\Ò°wùDÕk+j<MÜô¥­Ý±ióöÇ¡	h& 	hè&Â}¨}þ8h±B4a P"°¢?ºCMH|¸n¦èE71==½|fÑd~UÌM¼ãòuJbÛîÛ¦¿ ·é&Ü(Ô:<¹Íÿl¨_íR~Àx¢5µk×ºí¸IþÚTÊè7
ÇBùfqOwÕ^[µ¶ÁÓ£býÃ» 	h&æ&^òíJqÙ%9émïðú¤­øä¯=Êëêº£'xbÝåX7bK¾¤M6AsD¥NàxÙ-p8ìm÷A}¡	_}p³Fpãg\÷ö«nø½C^³hóöÇÒöÓ@Â\\+¡X1³ø#m&¶>úãVuvAO5^g«ôÚcO=ûWZ$F4MÔÒX»ú"µ¢	ë#¸AÅjiÂ§ºË32\@õ¢°ËìþYK'ÚªÀZ¨^[Q[íÎQúèï|F½ÍUÝ[âE·nPM@Ð4ÑGÐÿöÎw¬Eé>Z}©×G$sì±ÿò_þËØ¼ï¾ûº +WrÈ¡êX^ðÞðÆ7z}DÒÁ/}é«_óó^ßg}{ì1hb4áiB{ûE/}ù!¿þ?J(-¾êAåK®üÓcÏùÎiVÝÿ½léÍÅC2±èÿ"IAøÂwk+üvïC;fKÂæëlN¸`Õi¿qwAJú+Ô¡	h¢Û}Û.¼é[ÅÔÊÒÉÜ"z¤	ý+ö,B³üï¦È`&m¶ÒMT¯­¨íû?î®YuÞûÑûÕÛüêõëxæõë>f4M@ÐD¿hbVÍMíT­ÕÍVíwV­îP°£ÑìJ´MØYPtýÃ».ºuÃuÿîæMhÝ!Aím ÚlËÔj¯¤^z,½Øl»K§AÆ"&H7}iëË)MÄKvMnæôöHÁZ¼Ð»µyîC-MØËA\O¦	ïrmÕk«Ö6°¥°t2GÜûÐ'ú)º	h& 	h­w¦LÂÀÉ»ª4!ÊÐÞYù*.ï¯<ôìkÿØ1«Þ¦ 	a%&UÓÎö#Eyúg4¡gaîëNOML MÄC'8x^³gRbr´%ùð+[ÐDô1íº¨­*ÿÛ*&S{·É"ïRmÕkð.h& 	h&úòçw¡zÕ}ù+ùú_~·Þfzzº »µ÷3í$¶¹¶¡ÐDÕL4á8t·>4¡ÇµKâ»(àM­ë×OÓ{³wYWMM°ô&>ûÕí# 	h& 	h öl¡ÐD5¿-MØ-¦ÆÛó\¬0²Ó­¬TÒú)Os¦µRÉì\aä@ÐÄ|£Ú]Ð4M@Ð4M@Gë7løãÂÒIÂ Í¤`°V"BfÝÊ¡ZM@Ð4M@Ð4M@ÐÄäÑÀA¤ 	mªkW¤	á+ÊoÞúCf»BgÊxÞ=41Ïiâë_ÿú?üÃ?@Ð4M@ÐDï4!a£ik·?Í±}+VÞxK×g 	hpR#
9¿V71Ã¢&ôÓÅ\gíÌzhb¾ÑÄXÈ6Ð4M@ÐÄXÐD6°5E[k(6®ðTÇ×&F&²ÀY$ÛØèiöè>è&ô¦V­vhòÀ3{¬(_%#y3M¨pLÄÀÒ	& 	h& ¾ÓdlS-)Ebó-øK¦ðAÇJ8ØiÐ.OÍ4¡]Ê	óoVVj%É@#B³u	Mô&¢ù¨ºME¼	·£<?ÂÔÑÖ¢MØ-·Ù4M@Ð4M@ÐDw4aI2òMFAòtÀ%Æxú§M&¬5>ªBÉ3öQ£MÒj(4ÑGÐÿ¬Þî}²~<ßÀÃ°¨±Ñ~õbÝLáCoeWBÎ&æ&M Û@Ð4M@ãHü-CÆ½JlSm¶gQ]À88]ÐÄGThb®i"Üûüm¿dCü¤GYXæG~¶¨ñ£4V@Ð4M@Ð4MÌ8ë¬³n¼ñFh¢Á§SLöØöcN`:¡|¥S-W~«ÚÐDiÂ»µBÞ³%­h:¡	½ùy¾luM@ÐÄXÓÄÛÞö¶-[¶@Ð4M@,ý¢öÛaâb{ì¶4§oKUUÿùÐÄÒDhl¥¦ÿ<¦«øuH¡¢ª¥	Û¶AÐ41Ö41ñ4M@ó&-Z´|ùòÉè»Ö®];¾4a«¤ìèÕqu7ÑLE ^[ÅäJÐMÌ)Mlß±+
þÏ³P?Ä*MxæK(§¼+GIÓstµÐÄ°hÂHg»@ÐD±LMMi0]¸p¡~W¬XÑ¶¼Ê¨píª|ý.Y²dãÆÐ4M@ÕeúR¯uÑ­.¼é[øÂwô'KO¿ð3àd@ê~KjzÄÝÑD¸¯/rrù0"96ÜÅxÎuöàäÌk0DØØÉZ	Ï÷¦5My¾|¶a+©ðk ô±~ÜÐÄ°hÂO$ü;AÐD4îÜ¹óéQ~zZ#QÛot*ß
ßP & ùLOô×¯×éëú»þãiBcî5kü3ÕÆp¬~rÉÌ²mÛ6ÿ÷fâòQ Ê©©)¢Rù*é2ÑåªéEµ*©qZéäÔÊ(ÔÜ4éJ4ÊLA,ìùCD¯<AXihÈLQøÍf¡ù@zÿüÙpzÚßè<¶jT*Ð@ùÖbhäq-/¯øêP¨Å¬GÏ¡	h'4qÙ2J8]të!Ò{<KòÑI·ð¯nJ½»2ukêÜ¬ËPWéêUÌ}v¹¯Sø>SýzãUçõÊò%rtÕÄ>]þÓöÔ£ ÐxLM@ÐÄøÒDØew[El[Ú#Â]çêhbLiBÃSU¿ïaK¿~mU«Ð±×4ÙDÊµ¹@u(ôé4_b¼ÖfQ?4M@I,«(áô[+WòE·?>Èô£<éo&Ñ;ùÓJÑ+_TüIdÅÌbý:1¢nÐÅTmAÕÀGEßëMhPWUKmO4ñw?üÇÿNòúßûêöB÷$1é«>
M@ÐÄÒDÕyoÄ´=[yÉþ¸ì"K§¡¿zôÇ­zþo¬ÿVMÃSíØªÇÒDäÄHêYO[W¶¡42BÐ41î4¡GÖ&ÞsÕ{Î¼ìML¶ý½ç_gù|V4¡Å_E¬x]4³(¯bò·&¼äîÑàÐL­Níîú?¯{tÀ¦ÓÑï½åÂ¾U<\ÅÿîßCÐ4114a^pxÁ<ÆÉÊÏ iíJ¨'oÕóÿÓ¡_ÈzÐõVµ÷BZÖ~ãû#Ôâ«& 	hbÜiBº£*J¨ß|Ë­ß%gp°N!wq¶,r/·{!¨'YXó#T@GÅT*¸«t-Næ÷¨EéO7Í§vw]té\²¥S6vjkéTRÝ*nu­'(Ï¿ö^÷ÐÄÐi"Ï&&&L¡¡ÐÞðÃ\L¬°41î4±yûãÆªÕ°_¹gb¬¥<ÒÙ´¸&<Vùbwiq4M@#E÷>´£JF2¾ÇÜ¹IDwOgÅ¦ç>«Çsû.¸B¯WçMì1gZ´gñYcEÑeÚÚ<e{4QLÄnKUKÓÝ§fo?ÐÄÀh¢M5M¨=Áè=5;^ùzÜÖGøé1	½ó× _ðêÕ1Wb÷Ïzy-ÄØjpÂCl1jª<^{É®T 	h`Ðr÷ºG_õ` Äg¿º}÷<^W«GÈÐ1^Ûúw:¡¤À×!¨X,	½?Úk¨rÀSDm§í°×¡ êoøNM@ÐDÛxÙ/Í.àøy¯[(ó&æ	MxÊ·¬5òÐ4MLRôº¿ûá?Jæ\÷íÿS¢=14Qß¡¥¿d:ZYãþuÎÊo¯ ­Àó@#Í0lãnbX4ax6}(]"Ûªùw<ë´¢#|hXØÐÄ°hbh&=éeÒD·'-ZãËD³ZÐY
ÿ3ÐÄài"ÛÆDÐ:ÛØëùkvß<ëì_Ô&4ÆNÜBÐ4M@Ð4MLÞrÛm·Áì&oé#M¯KÒDv_É¼aÑ­îýÜ­xÒ³3TiÂähÝK=våçÐ4M5M|ìc{ôÑG¡	h& Çwh"h"]mß±«Èñº'{ViÂßº&üÛÖPM&lBïI»aE¯w@ÏÅ¦MUð_§8ÄO¶éùÐ4MMX¶& 	h&&&,O}Î	«û0­°jóööYÍÇB¡<-Â%Â¨~Cï ~ôÃRyk <k¾°t
Ì& 	h& 	h& ¹N9AsD¢ ëÂ+U
'y¹sÂmWh7¬ÈÈq 	h& 	h& 	hbî­bz>¡îhXØÐ4M@Ð4M@ÐÄøÒÄö»:ôuM@Ð4MTiâG?yR¡tßßqñ­¼þWþ& 	h&æM& 	h¢GÈÑfn¿ÿ{Ð4M@Ð4M@Ð4MÌCxdçÿ>óúõÕüå«6}á¿ým5_ìQBp!ÄGÙæÉ§~zúG¿¡_h& 	hbòhÂ|b³ç¥ìq´¯¤ÍµA¦2µju~"ÚT¦=8­ß°Åe:4Q& 	hb¶é`ýÃ»r¦uÝº¡Z¾POôQ11`ÙæÞvèúõM@Ð4ML<Mä½ÓD«Ú ÓØù-=û|;zµ{X?2eÚVÃCÐ4ÑÅ"48ãºªà FP¦RA@ú®¤lóäS?=çoêô;Hõ4M@Ð41DXyã-vNA-Úqhá}ÔuM8n»òp1ZýîM&§¬¨ä 11[×¾Ð4MÌj(I¢¾îóß	p (ç_ø®v5«'ú«¤lsïC;ÌDú¤z& 	h"Møu5Óo|á(ÉQF)Â9ßlâðgÁM&NÏÂ^|õtôPÚ* 	hèQ1!jø»þ£~¿ÿé Ø)£ª¼è¯bb`²ºx5(ÿ	SO@Ð4M@Ã¥	Ç>sä[×À©2þ|qÐäHõLµÝy×=¶´!öi"R¥Óã°"ª&æ&8à@5F¥Oy×¯=Êë#Î|ïÙa¼®¢;Ð=^»g¹äK®±å#ùÈUW]åuµ©îhâ¾ûîëâO}ïÎüwÿ^ÿíQo¿Po]rÑ_vùWkóê^ó÷|ðì_ÿÈã_8ù×ªÇªØig}¸ÃåKÚ´iS½ÍO<±råÊê?ÖÝ¢»Ö½kå°7ÿC/^>³x]×©«& 	h&KÅÔ (I!1S|Ð+÷_R5¡&©Zi¢ª'Mô±·ÉBD¾óÎ;¯/BÄQ5ðVè¬´3Ï<³A´&Î;ïü{ê»$D(#EL"8q×EvÝõ6êi«ü5:éÿ\ÞÒsNhì0z#_ûºê?6"é¸7¯´çò^×@Ð4M@ÐÄ`hB¤ÍÂf)[1Yo?&NY|Zè/¬§¯Aql°IÅvýÐÄ°h"f»dðy0ÙÞ&Hô«¿ºÌ\,Í4ORýQð%¢ÑIùòº¦QöGmðº®& 	h:MØ«µ!=Ã:ôJfLöûjc'[± O»®-	M&Ly"Á 	?S¥yÚKÌséB&ÖÛxr«hBQ;& 	h& 	hb 4á½-uâèucDT"µsB»dU¡H&F¼·±zâëJL1M@Ð4M@Ð4Ña°3hbbhXØI»÷¤b& 	h& 	h¢mKß¾cWþM@ÐÄhö6O>õÓ%×>ô-?& 	h& 	h»ñ&æ'Mh9{f6414±yë#;M@Ð4M@ÐD©í& ¹[Î&F&ÂÁR5pg'éÎ»îm
M@Ð4M@ãNáÇÉî¡ Ñ¡ìø×®·f+¨@Ð4Ñ!MdçÛî;ì6[ô& 	h&&&"tEó¸¡ïvFEàBh&úHElÏDSeh2ëì.é;ëì;x½VbW5 (4M@Ð4M&"LË£Æ5®ËõèsÈìÚqÌø®ç®RBhFÙ[¬£«Xh&fE	´6ßd¡èÿG=¤18õÖM¸*bMBÐ4M@ÐÄÐi"0Øs!p:vzú5äC"Úuÿ:t*ï#üø.	DÏóòsÑÂRJm& iÂjZh½ê´Ù¡ZúLgMA¢pmÍÐ4M@ÐÄ\/·ÝvÛÚµk¡ÚñÝÃ0ï1ËùÝÁ«&/ÞA!¾Z&Eñý¤ô|#§x¸= 	hè&Üâ²+'cBAî*Ü$
~5
CÐ4M@±ìÜ¹sãÆÛ¶mÛÍ2$ð4S5S«VÇ°µ}Ç®Ly¤ë&#ZÉ¥ÐÄ Æw?Ü0`ÅÒ2O+Ûoh&:¤	7+Jª)é7w1/;Ì¢ÂÉê	Óõ¹µbéM@Ð4¹ö,K,é>Ö¬Y;ô&ò$O³%kÎQÏøÚkkÞV4vM=ÑjR641ñÝÏ±øjê'.(YÚi`@h&Úzõ)ù¯P[ËA÷nê$ü19ÂmÐw\¸­§Yh& ÓÄúwMÿÓSÃ¢mÛ¶-\¸0ÅÔÔTÛ£6nÜ¸bÅ
Ø¡s¸âª6ë&bß_Æóp] ¸Câë5ÂÀÞ~G%jo|Òäø^5á¶ïJÓÅÏ£÷óõSò»M@Ð±°¡	h4!¸èÖ.õ(E;wîMè÷æôô´"TK,;,Y-Z´|ùrgê(]±©Ã#'ò­J"'#EµªÁÚKºlÏç­=×ÐiB¨(1é¨·_8ÜXØö&ØaÑÈ®+áÈt¸ÞlíÍîøBÐ4M@Ð41Ù4á4DÐ²víZ	áì%[2W°To¡]4¡_¶J"t¯CI¡¶mÛ¦Ön(ßGP²úÃG©f×£2&ÒõDµÊôUeX{¢½¦«ÍêM#$fè·­nbN«7DI&&`|& 	h& 	hb>ÐDÁN·ßÿ½?þÅû<¤2e%Æ-ä[n÷¦~	ðÖbM,J
¨¼éÃR}âPÉP7dð ¨8ÈÂZ¾ZI¾B5ÁÿN-:ß+7ßó×g\÷®6sÉpuD¯& 	h& 	h x`ãcwF&Dùc~öÊ4XVß=3ÃB9V@dP÷,ÓÓÓÐ)ÀTiÂ
 	mZg	ßSZW~TW¸~Ã¡ÓÄÕ¿¿eñUyýúÏ~u;4M@ÐÄhÒ$*ÙÙQµ@+×ÙfoV!QK*?î& 	hbNi¢)>oÂNZ#çÛ¾Èó&L©UØ+æ4vMVOdeD2¹ZezZ
Äléd3ªêëÈÍíG?yR¨}ïC;®þè5ý¥ÁÛõÐ4M@®Æ">»UC.¶õ0ÐÖÇÑèÐDö}M@Ð41Ö4Q0ÅpçMxí²"&8<Í9Ogð`m"Ð¦#Ó)ÓÂüÔÌâÃÇ³Q[LÞ1Z+Î1eÄî¸BÏõóW8
4¢ï³°ÃhÛ±;'N]D5ÐË_¨bÄ×ÐÄèÐD®ídÌs¬¬ªÄô«\¦aNÖPhB×£««Êþ2M¨@áè p}PÜrí!Ð4M@Ã¥`
	£ÛºÝ,=ÓË¯¸zV4a?áA&
/@øòð§ÏÁ q¡ Äæx»cAêÜ_õ`F3¯_ÿäS?&F&ôëäp69`M29<ÊÐ£K8/xéÙç[4áß!¼4Ûvøm¶3çê!Ð4M@£CßÛ.kÖ¬	ó'¾ÐD'±°½°¡m:Bè FpõyÐt±°dP°ÐÄÑþjºà z
×"¼uÄ«*Ì¬Èê'¯Gy4qK§B=QUL@Ã¥	ËÞY(È"B´,æ2£I¾ÚÜF ¦ÿEwáÈqËQ2,¸ìÌ¹8& 	h`qÈzy¦YÕzAyÐôXé½±MÌMø[eÄ%÷GNÉ!þz1z9ðG]§Ã÷\G?\è«Zò~îµ±íF&²z¢V1M&ÜdüíÝÎ¥s7ú0ÒºñÙ+£@"¹;UÒ5«¼+0ßøÖ"¶ZYí!Ð4M@ÐÄÛn»Ís ¶4ìà:1g¨jÞýµMõ´ú|Mô&Bò£èeÕ±ÐRZÐDT¢_­[æi³µ`Gmv¨'jÐÄpi¢:+¹ b
· 	¿ÕJ±«ì&âö}µAÜ£)åÉ#ÖD¸©@Ð4M@_<¾5M<i­D8%¬ú»w+Ð!ÐUÌfQÌÂ MÄµY<?¬,ä¨¤~3t´¥,¿ÅÔøÊZû)xÔhÂêV	hbôiÂSü¡ÃïgA£féMt&5¢hnV£h¦	mÚÔP¿6_ô±a Î& 	h&F&<Ù¦%Lv5¨YµgøL1hZ!µCÏÐD4ÿs¯l,ØP-
[zÃ­}Ð¯E8Öásyå×êFÐCìí÷¯b"M¨Ç¨ÈBr°#S½F7ùH}£?ÈxúX7áÆ-È7è×e´nú©gÕC 	hè]x¾ì²Ë=öXâ5¯yÍYgµuëÖq¡/~ñ'tÒf­h&F&ü,ô\A¦jãMhÐ,¾rg-?41§43X-ðûfÞk{l=Dó çPÛ??üúpc73Äoº+©õ%;4ñW\}ÕG¯&F&M¼	h"Mè_zÕ«^µdÉK/½ôÓþôW^yî¹çªÿä'?9â4!_øpÜqÇ-[¶ìE+ÚT¦vAÐÄÐD±íÚz&úH5ÖÑëÎ=ï¼Ë~ëj%­@Ð4M@Ð­[·ª¯þé]n½õVåýìgG&=öØ÷¿ÿý®,ÊÔ.h:MÌ6¶lm/ÑÖ#:4M`yâ'D·ýîg|1ZÑ¦2½wÃ_ÿ½9bù¼®Lh& 	hb²iBÁë_ÿú+¯¼òÓuâCièKÿøÇO=õÔO·X´K 	hb¸41¦ãû¼¥	;w&jÓN;=P"Bïÿ`º)[Ð4M@ÐÄdÓþ#<òÓ­O>yåÊ£I/ùËÅ­®ük®Y°`4M@ÐÄØï£FêßñÎw~ñËk«§Lí²eéuÿNF	mæJ ¹£ÙÎîÂÞ²c}¤	»Sö\³ÙïQÛ8`YuáÕ hi24¡?í~éhâýïÿ)§24¡Ák¿ýöûtã¢]Ï& 	h&ÜpÂ[Þó§¥¬Þ¢bz"+& 9¢	OÞïÝ¢²9µÿ50të®sa»GAn4a¾M­t`¨rXhM\sÍ5/nÈ-[vÒI' M¨×:øàiâ zì±Ç 	h& ®{ZÂ×üVóEª©p¨'
Å414a!ßrµuÎ)«ý¯Cò®\CQÆ³·KùVÞxKÈÌ·>ãÓiÅ9á6-»S+JvÀn`4QüÉ&K«§éßo~%=41t¸ó®{ìÊ/´~v<nÿá³U5&î»ï¾£>ºA ÷»ßý¡}hiBËþûïóÍ7·ºríR^>ÇAÐ4MÌgÐ¹ï %(TøëùÝZÅ414á ìÂæÖþ¬-iÄ_ï0ÅQT
åÊØ­qD?±§bËíÎñz¸MñÌ#}þo§Í./­Z2bü§ó6hvFáeºÐÉ|¡GaO\ñJøÀ\09z_ÔÈ±ñÙç&$3¿ô¥/mÉ<òHý£IK.=ï¼óZ]¹v© 4M@Ð4ÑÅ²iÓ¦£ñM;L*¬C>pý=UÅ414f-%RÖ±RÅ6VL!~A,Ù)A+'ÕC§0yÒuF¯9>õùQ2ÿKÝøÀh¢6y~.ñ0è¹Þ¯_jahbth"kä4Rl~^#ë!ö®»îzóß\+uÖYsÑ÷&$ð¿êU¯ªú¶Õ¢Líê%ä4M4Ð­{`õQg¾÷l¯H:òµG|Ê»¼~ÀB­Æ÷#_ûºê?6©ùÎQo#Xtü[¶üõßÎvÔÖ!Ç¾ùøûÿl=41,ÈjeJEË0ñÝ»ÀWE ÚïÛ£@9T#çûNýxsæMTu6^çâÉ#|ñÖËøAg¨-MMèY;ø¥Í9]8*èu_|ñÞð,ß|óÍ§zê'¾ÄG&ü|=ôÐeË3Ç©Ñ°GT& Ú|×îYô²];bË?øÁ«®ºÊëµ½"4±{ÆßéÊ+ý/]rÉ%_~ùµ£ºäZèç¢·ùÊW¾zô/¾iÛ#ÿ³»[êpUM&òi¢qHa?/ñÆ»²n¢MÿÐ-Ì!Í9YÃR´ÕWôÙ¬kè47~´l¼i".Uù¶kÊäXÐDQÈN+ÚÔÓÏr\hâüäYgåáéöÛo×¿ô;¿ó;/xÁ:è #<òàÞÿýëfpÉ3Î8ã3ùÌpiBpÒI'ùz$èòþðÿP(¤FW~ÄGhåmo{2µë¾ûîsÉ}èCK.AÐÄÁûè,ó&&fé{osï½÷ºø´G{¼±[«UÕ>ùÔO\ûÐ~ò$4Ñ_rç]÷´bFðÜ[£¶PÒºwe2cQ§J[¡L­O'_â
%;(S91¿Õwgï%ön0">ta¾HiÅ|?E~ÜJµ)YT73G´«Z.Mäþ»<Y)ÞFoj×l-¨Bªç{î©3Ë'xäÌòÊW¾òiY°`óUÀ%uÈ^ô¢áï"S÷,'|ò{|åf"-G}´K¾ûÝïþùÿù¯~õ«Ð4M@ÐD«eõê§¿öªJþ3¤<´ã¯»ýþïAý¥		°"2DhOy°v!3GaåûC¨jÐat¡LWUë­tðñ&
w7V.D¦jËv#ù^òá­<ß1Þ¿QëBþÏÏÅÑ(´7ÞßR3}ûµ¡^ÏP9Û *C¡/~ñÇwÜ§»Z8âo~óÃßÍA·ÞzkWþÞ÷¾÷}ï{4M@Ð4Q»<ÝOunHU¨j|ê§ÑEúíB=M{.û[/Ó6¦±°¡ÐD¸ç²Îb,âMqÆ\pAw4±xñâk®¹fXã{/ôñüå/94M@Ð4Q]®¹æÚó/øµ¹ÇUíÒ÷}äöû¿'¸÷¡zB>ûÕíÐ4Ñ/è<vU £4Ñy|¡^>ïkJ,X°`Xã{/4[Å
4M@ÐÄ<¡K.¹ô²ßºzîò^ú[¸øC¢	+)¬PþM_Új4Mô&ú 	hb`41F±°óç}1Å{ßûÞNäð_ù_	 9øàz¹ß:÷ÜsÂdÄòáøÊ+¯ìB±M@Ð41hâÜóÎûø'>9×Nñ¯^¼{fÅÍ_þks4M@Ð41^4?ïK ñ_Ü	Mè¼áõSNY±bÅàÇ÷öÞ{ïK/½´íüñqÔ¬+Ð4M@MO<ñÄi§~Ûï~¦ÁhÄ^Gì	?¤hØ¾tìi³y¼ÓüoO}×w};8ÂiñU^vÇ¦tÂ«Nû»Ëô1ézÆ&ôÚ>jò$ß.0MÄdäÉ f_RsgâMÌ5Mt>ygLiBò_øÂø¼ÿ7¼áàî&${]2ü±Ç;øñ=sVtIÒ¸£Å
4M@ÐÄÓÄÓ(qÚéû/5S«VÛ×.(-ÿD,;±tN¬ÐuºÞvÊÒëÌ4qæõë7o¼!½öØSÏþÀÍeúþêÑø!ö&º{¥gçCº8v4×914Ñ¹ü¯okNßµM@³]ôÜ|óÍ³;§!tÐc=Ö|¢_þå_î°Å©ª#8¢YÈ/8è¸ãë&óçt®X& 	hTPÿvÂ	oùâ×¶O²cDxþ/mu(é¤:õ®Ûf/O#hé4ø¥kÐ¦½Ø p©jÒö»ìå5r"9þËÛÕªVÍ!×3tëÌWUh+ªHäø|wÁFª-G'/.,ûïÕ=êÆuûùfùÙámH°~ÊqËÚ´àVè&ôàôüôÄ9Eçø\zöù~²9|¡süXã¨ð<æC¢&N:é¤0X:÷Üs%iwNùXØð¾i×ë_ÿú·¾õ­¶8õ?z|*ßÐeSì¿ÿþo|ã;¤O>9:W¬@Ð4ML$M%þäÏìÄÙfè&"üÖMÑºûV¬Sëtl|L(MtMarfÍQÐÃ@;òµé§&ÅÏ1":Öª91×Áï3Üèuù:ãª"b]óbÇþOtcLtnÓ5G4¡°tqa#þµIªðdë0g9KñìrI¢ÐDßiÂ¡õ@ýLõø" C½øé½¨#G¼Bmúp[:Çj¬Ðè¡]9äýi¢jætûí·wN*|â'zSX!¸h%öþùúÛgE¯zÕ«ôÛ e.¸à3Î8CPÐ!MèÅb& 	hbRiB}ìQG½îk~«C×ý¡ø,r´îw].ÃþúwA]ÓD<ÇÏ/öþ2XÃ´YÚl¶trár}xÕÎj(N9fw0¢ÕRª³¸>"N¾°°'tïG[Y:å?!ûÇßU8ou×ÐD4QÕûÈëÖ>øiÆ³°±hF{Eõ.]~Nì­[·vNÀ%gíÀO<QþÛgK^©ªÓ¿øÅÎiBWÕ¹b&bÑÓìüý?4¡>ÿøÞâQµCð°eÉ¤ øì¿w>¾ë2t1º$z^h"ä[r£gÐKñCÌÒK!¶¢	Sõ{þPh"¥\«?$BfçwÛºln4,l·!L\Lñµ4µ~Xþ[üAÛÖ2M´²E&æ&ÌÕÿÿöÎHê:÷	õ
Ç)TqLbðÃ½Clb¿XWR8BµÄe,d$¶1ØoÆVÚ`þ,B	Z@*Cû$KÁÌe61¶-¡·QThí¨b¶bJEíûïé¼Ã½===3;3==ß­®©îÛ·oÿ¹ç_sïåKÐÿz.¶÷ÖhÂBÚ"ÅW¥U49-Z´?;M oÀÓ¤ODi¢PÄaN ªhÂâXM&ðúõMÃÃÃ£££årLLLd/qÈT2.ªÎ¡ÒRRµ)($MìÚµkúÙQ"è7ác]¼Ýâ½jû¢2¨*V§´	Zµúýû÷§·Ùzppâ·q­¬0F£ÙÁöÚhÂâÀiÇC*µÊ7aµò.³ø&W·µ¾	úÌiû-vv±o" {c;V4Ñl4_È&Ï`"MøBèöõ[ø×÷¬	mÓhb||üï|§sÚºukµ4áÈ#(QM$Eæ MEðÞrÑDahª¿««Ë¢»»»¡KHazzzðÌSuÕVKFBtCp@U¢N¦;vtÏ;:öóªTpÐÛ:"Ã_*>~­Ê7ÁUBÅÒç­(mÖ|¸nùÑö{{{SEÓ@)×H±E±ÒêieõÐ#,$Æ3ÑÝ<}gr4Á.1MÐÐåómy¿	«§õ_æÕe¹!öÓó&wkiõ£á×*ÆFÄÑÒ¸Åzø§Ï¯ÓöùÚZ¥E×ºyMÔI¼í6vàà=§Ã"ÝXì¬=²ñ­àÍd±Öw±jt;è5&<0Ì	ætµ4áPlòDàG°ß¨&}èCò{ Hsª&$>}úÆ§&^}íðêM»ñ+h9Mxó *Þ[Þ[áQb¸3hopÝó]!þo¿f ø[ÎbÕ³½N¼ØÎÁ°_HÅùùÛP:&^Øs+[¶l­%¨
·øíPp° Ëj<@J¢ª¼¾ó¥_Ö mðó}ðÀ^þrÖÓDðJô½Ûbhh9íØr­,hA¾¹¥èw\øÏïÃ¨&hØaWP~ñÆFd[ÊÍÚ]X,§ÏpÒrÃzÛøäOýéÈËé4ùò+µÑÕµòWåØÌÛRÛNÓÏìN6mþîº§Ç&~}$Mø¦Ä>×¾bÁ²Çnà ñÅEq»|{®÷D4Q?MLÉ¯vù!ÖÛÞæV¨&|9 N8Ô£Ä$Ä0§hÂóO|âê«¯®@Ø°aCFÿÕ7QÇ£Mä&`ðûÿàà ýøË¸ ´°ý²R²oÜÒÛÛ`êã×+ÊÈbéÕá+Cx¿Pt£¤@
k]¬ ~{K	+4ïËmÁÁ7U{ï	¿Äád··WÍË}ÔM´&¶ÿäÀ«v®xô§0M}týyóì?7ýîTDUaÝ¼îETÞwÍÎ"m/0ÞR¾´´ÞÙèâÛ}4Y£fKôwXÂÎ<q+³Èöâ[º~jx³ox¦ÈÞ»åsaô®Sz®{"¶¥=MpX`<bÏS8v#n¯Þ~pfðrÒæá'¿¼àæçý}hÄ\ØÞã ¹°@ô;$zÜrE'|òôéÓ/½ôRäsª&èã¸üòËO=õÔ|°A(áf?*±|ë­·ZS4AÇ²eËpù]tþ¦ýÉ'$M¤Çôzà"ÈMàí:h]%ÀO´hK!¸¶7Ìà²-ü4K°:8 `WXQ>Ò%0N;.Á,yÂ,Zþé[ßÿÜúqhñTÏÐëìb%7.:K4QM#ÌZ[»víõé£ª
£Ú¨¼g,Òo&óðÝ&Å³-'6XdãÍæ`0eôÁcãV-VUìb×­ÐíiÂfô#STo¢â|vM£SN}Ã7+È3§	.öN!M4âNÁËH\)AÝXDíK©|Î^·qãFâÓ¦M;é¤øy¿Çú¼yó°²~ýúÏ|æ3U¨ágk_ºt)ª}ÜqÇYRµ4Á`'BJOGéïï'MãÈù#¸\sï¿.üÚ¦^ü÷KïßUàeÎ¥÷-øÊVlÅ£?5ßã¼éëµ<ývÇ<ø'o0³ÙÕXºiÐYÀ¢46 i"Ññwy¿Üö1¾H¡àÄ<&Ó,ÙmÙ9úË<¿¨3.ºû·=WàhÒæËßø!M5¢Üõ½®ç¯>ðKÏ¾àÛX\ç¶sÙýéÒæÛÃãlhÆä¶¸Äkm¿PjtßlËù&ü±q+£oÑÊ°æÒRðâE½ìöÚä;ðV5viâ¿¿ë/®ø.6*ßsÓó_º{§]ãÙWüXcÂ2Bhô\Ø]¼ÿó¾7IÅ}Ï¦øÂÒ¯O9MLá"ÈM´Ë\ØHì.a¶zµ4Á£`¤ÆÑDàûðc	Ö@  ¯6oÞLX³fMJ6~£DÇs?úÅ×þîSNï~aÏÁ/üèyýÒ9¬ØÈÞ_ùH'~cI°£x»ó($öMÛ)4ÁOøUC/ª"Mø¿°a§ÀöMÙ¿)4á·ãJé@UÃÉIxõµÃy~Qÿ=úðß-pKôÒæágþF¿âïæïì¬j<Ø/3vë¶Py:Yp9üË¿U68-¨n3wòÖÓñ~ÐµÁ|ÿß8gÓ[÷Üí/%kn)-¯(^Ô5[÷xUÃ{õ¦Ý-nÁÆgÇïlPÐvÿË%XhÛÂwµhbÆG»36w¬qéöoà&DÕ.ìúÌy¾ü×@½)=A2ÒDÆ´{÷î¦}ûöUÌ0"rØoÞÌho°s%Wçc[,'û2økeÑÑ)4ÁÎF4öíÔêÀ¢åhÂú2°VÜb}¬äxí¥¡RJì7a¤ãï	2×	G×ä­ G°M(Ò)WN¼þÄóû,ÔÂyÆçª«-.ãØ`&5/¨$ª
£Ú±î¥ÝjÞhïyÜ` ï3}t:ðý'\øÝA+³-UC¤9ôQ±ßDÅ!¹éôøS?ôv)N>R¨*ÈÞAµÜXõÐD÷ì¹ÁËé çÖéÄ1¬¥ªM4&p·3üU-ÊCeyáÛ&=öØr_õW®\ySæd_2¢DvøøÇ?¾zõêì÷d×®]ã×*S&Zðà F;XÔí5« Jû8-Á¬û¡éÙ?ÂþZNäßÛk5±¢Ø}	Aý¹µ¢ïÕ³sÛÂ£üHøAùÁ=±Ù:¬»¼9ÏÝÑD®hâÿ=â£9VÆÇÇçÌ;U@Ð§vµ1ãÙÍ²£*ª¢ÂqÔ}FiÞ¿Ø¬M4ê`Î¼ó£À-neÜ6Åfe£	ÏLmDï<éäkï|*æ&âUÑDöÞÇöfÖÙ[ÙWïÝ4½\7sOÆfÏÔã¨vÒùÄI%D¢x*}·É3MlÜ¸qúôéYhâýïÊxà1Pà¶¿ûÝï.ÇÇsÌç>÷9û(ðóMdA	¤iÓ¦ÝqÇk¾páÂÏþóYîÆ6lØ`^5kÖ9r¤Ú[
A
9#hdã¾æ9ñk'¸¯¨h¢¢´9xðà3×?>TRãhç4LÇqf%?Ôd<5vÆCõRFÆè¹°ÿý?þËsD ¾qj	~ µíàN32-§YæyÙf.ðÏ=ÝRªv¾	µ¸ZÀú:ãÌ~¶«À
?íò=ð2båìÃþ>Ô?ßÄæo?ï9¢4aiÓ»Øuá>øM4&pÃ99£l2 ²Zsr	NÌ|\·6hÓ å&-[6þü,4qöÙg'ÞÞr@QÏìuYP"»Wån8ýôÓÓÚ¼yóÝwß}³K?üpÆ5ëwÑDËSOOOú´VùICCC=¥Ô¸ù²E¦É¿xÁó«
WhA°Álr´ ®	3Ô¨Xº¼íHÜUqX³ÍÆ MøIaÐggÄ'Í±ùÍTHËÜ;G­Ly¬Í½SW£|©½y,ÖÙ,j»4¿íª-<÷'eLÎÆÍ^WMØeòðLQy>nìâåÈ7ÑßµD¾¥~èWk_Ì:ÎÉ)&}#µï6Ìl_77oÞå_ßwÜqMgÉÍ(j¦CÎóªô÷÷W¦å»H0-_¾<}VVÑDèw%ÑDh@qÎ¹çÞsïU1Ó%óãX0Rz¢«¸ 2¨RÅO7¢óMÐ,á_ÎKnV´mç<ÑD<Ve3\ó³'Ìlî¥m¤LqÞðQ¨X"MÄ!Mø/v<ItþiÂ&¿æ
îA2Ëµ&DäîÄx<ÿ®¡9ãW1 rç&fÍÊ6.[¶ì´ÓN«X Em4}ö«¯¾úSúTPÉ«®º
¯AUaZ6E¥»ï¾;KÏkÑD'ÐDÊ;\tM)&:&/Y(üwi³HaÀAMµMj 26SN¶1¦	,{ö° &ûJo¡kÈÌ¯£|Ä\R:k4&lªëªh"£	×^4ß«éNâ`mGt9ÙâçïNÿ@QÕtMðMÄ¸Hª¶1MXy£Ä`¡U«Vüñ'|rlwÜqg|3 ÀÛX-MT5^bìüãoyË[.]ZUÖÎ;×¬Y0EUý¯EEMSï9L)ú]4QT P,½þÆÝ9­c5Õ×qõd
dD	ÑDðÖ²E¼Xmr7{H¶Ý:¿øõÖ+¡4á#ëx9ÞB£_Ìça7üÒà4ªâ} +-°ÊÚ&üe<ÄtUei·&èÿ"
Ñ)¼¨ýhR\fM¦	6TU²h¥ØÀç¬H|q{Ù7ÌÒDb°Ltê'tÒ­·ÞìúÀ>ÑÆ<yÿûß_MüÖoýVUsj'zU GK,{,^¼xÑ¢Eé:tèÅ_0 Ø¼y³hB4!M&&ßè4wÓ5_^ZQÓFe×?Æfó³ZßN
HÚL!MpñKixs¡ÃÊþÚÌÃ'n·`'ÿÜÍÀk	MÐ³~¬¦îíOËc½!ø×>³Ç/ÊîC[ÐïÜÄFjÞ.4QNz¤ÐDµþÆÑß+F	ò¡°;|0Ø¯!!ÎéÝúòRl¹¥xí~ ÖÒDb°?ã'îúä'?¹råÊ¤¸wðàÁë¯¿>{ÍwíÚuÚi§%ö¶NÜ1Lk²4¶Í[¾M&D¢âÑÒ+.ZÜü f§´ÈþQÕÇêçhMädöºÐD±g¯i"öMØp^æHé5_È¹°!¼½hÈÕBH:ùä¸iøÀ]_~ù¼yóò ßñªÏ=;¨^OOÏÒ¥K±7Ñ±1LËn5i¢¿¿?{\4!M&AHk×®m¿wü`s"NÓá¤6£Î-MÔédC­Mp@ óVp j;jµ;M°oET9¡8XF8LñÉRØÏñÇ_noËõ{¢ëÄ±>ÿùÏ/\¸°æ0-¦üÇ$PlØ°A4!M&
Ióæ/hPà8Q(!M&Mï¶lÝ[lÁ[m§­v§ÜÎ^:3\pÁ^zi=_ø§ßO?ýôn¸!ÕpÄ½[·nýð?\í|AÂe._¾ÆÖ0ñhB4!M´M mÙ²õg;:öóÆi:SàD6¢	Ñh¢b¤S@÷­5Üð&ZNÁBþ~béÓ§oÜ¸±µú¶=À!Ã÷³NÌPCÖÃ?L÷ÄÈÈhB4!M&*Ê¹
Âë(O4Q&^ã ÷Sûìü\ç-¡	?jhýW«eÓDÅ§Pl°á8/áÿÚú/íBh£ÇbpôA U4ÝqÇÇ¼}?xðàqÇÐÄüùó-[ÖZýèU5kÖúõë-O<+_aZ;vì M<ùä¢	ÑhB4Q` hÍO;
D±(\Ò¦q4Áhj?ÑT-féq,&Ó¬JìòQ.5Ìè¯"î¾2jP~h¢¶ù\Ú&lð"ßG ÔÛÆ{èÇ`W56l«hÛËÁ×¡8X(í:î¦=U±ëÑïxÊg}v<GÁJt¬T¦uàÀÒÄÀÀhB4!M&³çL%P (X'J&Òi	z²¨ÁÖÊ2HiKhÂ[û¨¿«Mh.ì¦Ñû³ÔñQ²§yì3
V²ÉÖHù¼B}}}Á¤Øýýý¿÷{¿×Zý¾hÑ¢ÅÇsdø<ãããoûÛøð?¼ukQ»@[4!M&
O¥ÙfÌùÌ¶Ô¯¾QJ1/%m¦&{Ø¬~Î5ol¬ÐA Á:'¦ÙÃ]°ØÍÓav,çÈNôz4&, 3køÙ1lQÚoö);c1'M5?%·ÇîæÐÎÎû+
Õß_xðÑù¹'é&hMànà¡p` +<5óVp°&¶²`\\Î§\ñAKh"1X(þt?22O}â'Ö¯êÑï±W%±5Ø!»Ú0-ÑhB4!è4à×9sæÖ	8 (IÒD`o'NÍéw}N¬pödaX\:óGl^Ú±-ôM°XhtùY¿É>~^l£^2`ÅÓ-jèûùòÆÚ4ÙÍ§	¢Ým>;Öuãu1ïlwÉæG³	S.M4Ñ8àCÐãk8,øÒ2|+Ã®
Ãá,.¹ÐD,ÞgçnØ5ë÷ÄÞp&Å®6LK4!èdí¥{öì÷¼ç=\ÏÏrê©§ÚúwÞ)Ú2!ýÀëªMqã@>% &ÒiÂ&zÃìc&morÛ!fÒÔñyrH¼vJøÉyÌÂ`Wá­2h¿Ö;	:}7&H:~þ¬púc,¼¾	ÁG¡aÒGÅKM4&¼©OoZã÷í{Ê ¯*·4ÁÌîëësÆµÏ?ÿüë®»®U4O«WnëØÿRmhB4ÑÉ4kçè÷­Y÷wÀõü,V½[ú¾^~MT_Pà8(!¨éäC)8?ëÙj_;Û&¿÷Æ^°qÉø¡Í¸ û¶ï3f4a¶*ÒÉÓÁí
m¡»iyì¾¡,&hM=¶fOÜG ÿ28ø¶78vëýª«®:ë¬³ZE±WÅ¦ÀÎâXyûÛßÝó.Mt8MXGZÈáâ /¨:tÎ¹çÞsïÙ2ãæèMÔLìL `¨6~zä1ldT­:iÂJk9MÐ¦ÆøsÆø¾®vChy°/°|3üÏØdàwlÞméäóÄ!^4;-g¹´üÐñ×oh4¦	îÂ
= ë¸D@Î2òsói"J=5ÛÏ×|~Mä:»ª0-ÑhB4!èd`Z¼dIF @6d´i2MX=cZ,NÆÉøQ7½£sÚ>Vøµ»¬h3iH<)Ýì¶lXä/Èà3ø«`óøV°2~ãX æÐo¸ Xòõ'7ùqù\Üh[|4~¹Kk-Mxwu4f%¹=qt£'Kçàig~¾	vêáëj]cìMããC,ÐDìnðS`Ç)»#£	4¸ÒÑ&»ª0-ÑhB4!M(^cúA¡hBsak.ìâÍMVâTìNuÎOÇ%öq~¥jÇ
Ö\ØSNq°PÊç}¤õë×Ï5+eª¸¦ÑDìUñS`gq¬T¦%M&D¢	¦eËnJ
ìBIÑhB4&vÅOñÖ[ÄxåcXyÛ]æ±û¢VÑD,´jÕªiÓ¦¥¹Â¨Mî'§H÷e4&6nÜ8}úôô92Ò+Ui&D¢	ÑhÂÅÂEãgE	ÑhB4Q<ßû[4§	®¤ôâñ=ld]ÑDi"Ê2nj0)v¹ádMñ ¯§·'ÅÎ>_hB4!M&|Z»v-ØaïøAÞ|¬à/6JÚ&D¢ì4±gß:&8¤-I¡*xèÇÙö}ö¡Èâ¤ML-MÄÁB?ïOFÁQ«V­:öØcOW%ÔÄ×=LK4!M&D1P78V¢	ÑDâb£QqÄªÃß®ýgmÑDki#ô"?ÁfÍ`¿	>MÞjà`GqP6C[D:ùþõñËé{Ù·MlÜ¸±««ëZ²
ùpâ'ú£N8á]»v5&¦M°:|ìcK##v¬,\¸Ð=eÓM&D¢	ÑD¶lÙ
ÀIÑD«hÓÕÙ\Þå?µOÜå2&ZéÌ~RBÖ}v-ØÎ6³F9û<4ágÞL®è©]hbdddÖ¬Yué[nÉràW^é:ë¬³²OÜ0Uú}Ñ¢E¾óæÍË2AÒ·¾õ­¾9=òÈ#¢	éwÑhB4Q»âá'°HÚ´&üpñà°Ð8ýÏÏo¼ß¾ÒZÃ/òøéf[kiÂ_,çïh"4Q¤ÙëÐjÈAì?Î9¯ÍÝ`4asa³Mq°bÕÊ2°Xeãý·vöº§¶Ðï¢	ÑhB4!HL7¯{¤MËiÂÓdÏä
ßí9£V°`g¸§±£áÍr8?<Ï4ÁÉÚxQ~QlM&M¢
¯l~Q+ÁT~:¬pP\lÂÇqü±BHáÎ*ÂÒ©XD¢	ÑhB4!h#xùs®{V$mZNühéÏôñ?æ X«	lO6å}êOéqÐZ°ÅOôfìÃéD¢&ÐhýAlòqÒùøl»E:SÒ4HV¬A¡R4!(@úþ÷¿ÿÒK/ûEhB4Ñá4qóºIMsO&RhÂë÷Ö5¿[ÚÙ ofiBå½sèàÇ^Fgù9 y9MØÄÐ¢	ÑDhÂ<XHñÈ@ç$}4òêút	t&DH£££}¥2õaJÊÒÞ§¾£	gnÂ5ÖviH^´SÖ5MäDÚc¢î	ÑD0ëv5ûÊ0	o0¦";M¤ÌH'A)xÍz&DSKÖXø*,óMs«M ëR(SÑDhútÃ³{×==ö³½¿êêêê¢mßÝÝÝÛÛ[m	===Uå>ØzJ©Ñ¬$ÈN&ôÑ*(Mc¢î	ÑDE° k³[`KÃÀ¦ÂöÈy¾ûfçpÀF
ùË£,¸¢\¼S®za£ª¿ GQs¢H§ÓDU®¢ÓÚu8òý&¬×=¾[Q£ã²Ë}m1MXSµîQ¢bÐÄá#¯ßþÍ¯[W<úSl,<M  æ5Ïõýû÷Ãì)n69AÀ¶ø|áRJ¤	¿qºÄCPÿ²ØøìqUBH[¶léÀKûÄóûðÞN9M@`BâÑ·ëiò¦ùvñË¿ÇM´&ÇDÓÜ¢r4á½<mÍòØ2²þÖ!Â·ÉA8ýX1ÓdÞh®5´â}Ð|9§	?ÇD<ÈGóªò+5mØ`ä4s"ø]Vy¿]l|Ó22â hkX÷ôX¬[WoÚ]x K"øté8À:¡	 ·p#,y¢ytpÐÓ¸°¿¾Ú¬«ILÀ/·ÄUÅ
NÊcQ=V CúM,½ÞÛo÷LQ-MÁ¢ö1Bß[&HaÌ;2Ñh¢å4±ó¥_Bèaé½®c£h¢U4¡¹°5v»Ó½Hd½ ôÎº!Ì¿À2fÃ´Å|[41µ41ÿ«ÛbÀrÇ]«
ßo9LzóS`úÍ[a»hó³=ÁyRÀÀÀÙ´í=>àåï:¬d_©{QÉR8V9«_Â¹N:'Ò4ÁÅ¢ß$ÓÕK7®ú^~¸lìb~!qzSÑDKhÂHÁÒ´Ó&D¢NtJ¤	~hòe"@4!hø÷ÿø¯D(ü2øf+Æ<ºÞhº[ì¿ùÂpÃG(Á÷%x÷÷M ÛE¢±Äì(fK¤ ª¼
ºQ&^Øs°è¹Ñ0EýN&¼j`~Ó; 	»L2æY4!M&D¢	ÛÂl©6nM4!È-M>òz9óì¶;î)¶oÂ÷YðNoü°000À8"+!1uèÞ_J4AL çÂ\±(ß#Å7T.	òJîXßûÕ¾üÊDý4aãÆPÐÑ7m4a®jöG3mÂ¡òE¢	ÑhB4!ð4aå×ÐuB4!È-M ­xô§1JÀ6ë~°ºaÿÓDÇ
4>¶3ÞÂLÚóF²Chÿc#Í~ëèÓF+Y	f]Xü²ìRá·$VCï	+`1TBä@¿×3B,C¸Pþû~6ë.!ÁNÄÑhB4!Hïºë;gï¸-È!Mp<®x1O6ÈG<ÎÛBð.UAPÊ@ë¢âÑÄ«¯¾ìöxÀ_lìù&Ð²Ø¹mÄ:uÛva°¿æn°>  új@Eàà|~ËP)q,¬p«¹Bx
F4%VÇ2ÏpÍ5×tMx¨&*êýX§×<¾hB4!M¤Cnà&rH8#t  óºZh¡o"pÜWEU(hk,Å;=ñü¾Ö¾ lÃ³{'~}d²3f¯Ë²¸¦z©hü¢ß1¶hB4!MÔO´?ØÅ[~8M£	Ë)ÐìuM¦>{Muºã­w9½üÀÊhN¯«h¢Ýi"?ú])H£££uZ ½®A4á×M&D¢hh@Ûq/ì¨e#È(l:0?'»oB4Ñ|àtuë!ÈÒ}wBÆ¿xW³øbD¢	¥Ü&ÑDhBsa&D¢ú}~èNæGÙf£=p?ÚrÕÎV ML!MØ:ç¡ãlMñ°·äeR¢H'ÑDSáõ;uhB4!M&rHÀÁE8(í´ ¢S¡&D-§	nÇ/;£ì~4ÑhB4!èpàÇr´ÀDK@4!M&bßÄÊÛîâ´5	4Ì¼Í¶}çi¶AÂdÔF4ÑÀS¨a&ëâÑ±E:á¶p`+:Ñì·í¢	ÑhB4!Hr.ÝØM&D¢¸ßÄÀ}k9(DiÛ±»Øà`cÒlãza·&j«­iÂ;ßû\´aÒñöÚ±|+vM&D¢6¥	ènÚÿö¹É¤°O¶ÒY¼läü×´XhB4!MTÉ!L %ìð/ý£~¸Q¨ìwR41%4aOÇhëØâ?¼ûjÑþùBåJÓìu¢	ÑhB4°/*6Z#Õ=?ªØ öuAËÁ ,Ç¾Y&D¢	ÑæÂ.M@ìSòsÒRöçî²©ë3P
ðÓêÍëd¥qE4!M&DmJ$7Bv R`ìAÐÑL4!´M&
O~¦?Z¯Wæ³àâ4Á-sóÇâ/ÎN=8G¡hB4!M&Ú&èXyÛ]óæ/à÷"öN@ÿµhbÊÓ;D¢	Ñh¢-h½à)i"ä4¦	Ël4A¯xTUÑhB4!Mä&³J§¤ÙH	ï£`'ÑDJí>z{{ûúúöïßÏ]hkØÈ¿ÌÑhB4!h`·wï°ðUÁ "ª¥	+-Qq&D¢	Ñh"4ÁÕyóøÁ]m
õÜHÐ°îØ~áFÂ¢cGîêê>@@nÇ
~±NÐ`4@¬&D¢	ÑDÎi_lB?á¶P;°·.Pô3T¤	+ßza´;MT5±hB4!M´/MäD¿þ¡3±Rð[ðwttÈÁÁÁE¢	Ñh"ÿc:üHà¶ÅG%ñ³øÇøË<ìOa»âÎ*R12NZ'M&D¢)ÑïÿcÆÇ.îßqû7G¢}}hÂv@V`¾¾¾à(ÑhB4!Ð\Ø¹oþzÎAG]öæpgv!!
ñ/Ý43ÅFÆ]M&D¢	ÑDôûSÃãLÑ^4ëb¬ }±£#&KaN¢	ÑhB4!È3Mpì?Ïµuë`ÿAÎÞÎ7qYüÇZT°ïfbã®&D¢	Ñh¢úý?üÈ9×=kËü·ù¿m´@X¤Óàà Ö'&&<M°k¶LÈ6øôXKj|´iMÀ*ø6IÐzÐ5HXwír»l¢¿Ñ>	µMÔé G°÷iý9?»u95Ø ì!yM».M&D¢Æ}-ÜþW¬Úyóº_~e¢}}¾ßÄe¥äiâuVZñù[â´iMt´iDZ½i7dB!m\V õøÅzÓ®T4&¬9©Áú¡
ðK¥ãÙz°ææÆ]M&¤ßE¢aj¦ÌìNäv§	ü2,¹'ïÄ®Ù¢	Ñh"H¯¾vxþW·A,Õ¶Á¥AÜ&ðÛÌËlMÀ®¶¾ÕåÆ5J.·4a¡Ó³àl&iÉ4cpÇ]M&¤ßE¢jÇ©ÈBï?ãÌDh; Pø¿û÷ï,MEá7" ÚØ«B4!Miõ¦ÝÇk²{¢iÒî	\`3¢	ÖådÓ)Vtn}ì:M Ø`é`â;#Ü«=,8Rn<îºhB4!ý.(0Mpp>ª]sIøq*|5Å	Ö/²0I4!MøDÇi¢ÉîfJ\Zó/°~E`f6d>§±æø®´©#¼¾0­aC!1æ'(-?ý&j[Êùh4B¬hBú]4Ñ94aòQ Ázrð.àôéêD¢	Ñh"K2ÇDóÝÍ6¸®æ;_ê§	(Fò¬¼í.ÆjÂ>²1L;XÇd¸Ê/ù¥µ5Mh.lÑhB4Ñá4á#?#*Òä¦ì&M&D5'ïh¾{¢ÉÒ½°Û&Ì`ó)ØÎjmó24á{OÐ&M&¤ßEíKé¢¾M°Ô¸ML­~´MtM<5<¾ôþ]X>³|ûe·ÿë)ýªDù¡	:8CLé¬D¢	Ñô»h¢4áçý4vj°Îñ¨FÌlW&$mD¢zÒíßiæ(¢zh*Ãë0ÑcÌ7áÇJJ,M4!MH¿&Ú& á­ûSÓ=A¦`t+»ð½­­WãMHÚ&D¢¢ÒÍaö?´=Ô6rÑW]Ë]6®ÙåÛ@ür&M&¤ßEmM­½N4!i#M&rN2¶hB4!~M&D6¢	ÑhB4!M&¤ßE¢	Ñ¤hB4!M&D¢	éwÑhB4!i£$M&D¢	ÑDáõûÀÀß>::Z³Àc»»»{zzÐk;\4ÑLØ³ï qÇz¶ ÅÊ·¿ó=NljÓO°g)òE6m&&&z{{)»+æß¿O)Å»pá£¥Ôî<%M&D¢éð×±t²~ïëëëêêSðïðð0Tjm§@9PÄ(ahhëÕºUC4ÑH¥ÎÏFÁý8E+¯º{©8 Ö9çÈ¢	ÑD[$ ä$áp)*VA@Äï3eõRÑhB4!M´M "x~ßË·ãQv8M`;)Tj@PØ4À:~¿fó{ã?ÐØÅ¿¯¨y¡gÑÆ¹×'Gxà©G )ø[5:&¶ÿä@"MSEØ9&l/¶soLÞ[Adà²6ôwI`¯ÿ+Mä6¡ª/ÁÈ+ÈüRypÀv:&( ÁJhÂ¶?[Jf&ý°Å+M&D¢v¡	ã4m,¢	êôÚÄ/6òKÔÖ{{{±¿PµÄàããÓ4/?úAu¾Ñ®»»±b
ÁÆ [âSc"3j¿\MqÅª7¯{1&`ê8-)Í¹@p MØðàXA A:Mpº"<ÒbúP¤h¢]jñâ·@ÔP0BÑò§Ð³¯½¥J<J'PB¥hÔ-¸9ü¢ÂÌ°9td&D¢	Ñh"G&¼3µHg:ÎØÈÀíñ'5l¤§ì@ÇËÁ
®wa`CY¾?µim$M±¯Ó;&#^~eb²L¤¬}NWMËûÎ?ôÈc~Ó& Ì°gß&°Å·ÎÊM&Ú&¥¢÷Ö¾í21"ÈBV&E®}9M&D¢	ÑDÎi(qÃÚ<Ghé½é8ó#Pì ÐC°â½ÿ´üí/ìaå,L/3`eNuÄñÆ¾¤Ø®/4AgwRÐï@4ih8Q©ù&È7sxâù}j#ËàÓc;þv3:\Û.ú/ØÕ¢ðéonþz'?ù_Ýö³½¿M&D¢üû&ì®|±Z$[ÁLzë(AG~é§lþÁÁA¯pA%ÔÈ<6À
îò§F!äãô ãòM¼üÊÄÍë^ÄËWz²|/lvg ¬¼í®Ø§P&nÔ>ÒQ{öð`Åt+¯ºÖÎ%h9M¬{z|ßFì¯ù@³ÐI's¦Ð£§üÉÎeG{[t²o¢lÑhB4Q°^Ø)DÞD£¼¬øåÖ>ì|¼ÏüÇ¾AQ<ÐA. n¥µ~AgmÓ­¶Ë0ÅªßD ß)ÊÑ-v&MÀøÇ_nhâ¡G#°CDz¿	ÂÑý2D¢¶HY©cÓe¤	oÈ@QÐÝìUÐ¿ð¤ê7!M&DmG):&%ê83ïm('Ûä	ÿ  Gù-Á±þ¯?5ÛQr'íd0¦H!ÖS §ÍQ%o@ÁÁÈæ]<ÓIasOp YÛ(M´Eeðñ»(¬L<ZÎ@ñ(/E'K_zlÛHÚ&D¢	Ñh"?ú='4Q¤¤ù&4¶h"1Ý2ø,6J¢	ÑhB4!MH¿&D¢ªÒ«¯ÿÕmX°"i£$M&D¢	Ñô»hB4!ÈVoÚ}áòíX°"i3%é?ÿó?{î9ÑlÑhB4!M&D¢bÓÄ«¯¾¸Ç[÷`ÁJsÜ6Ôï¢	Ù6¢	ÑhB4!M&DÅ¦Õv?ñü>öÂÆJsÜ¢	ÑlÑhB4!M&D¢v§	:&y}ù}ßÂæ¸'D¢	Ù6¢	ÑhB4!M&DíNH¸ç[¶lýØì9X°¿6¢	ÑhB4!M&¤ßE¢	ÑD8oþÑ±cÁ
þJÚ&D¢	ÑhB4!~M&DÓÚµkA{Çòæc±QÒF4!M&D¢	Ñô»hB4!HGJP`c£B4!m#M&D¢	ÑhB4Ñ¾4±lÙM r»AÒF4!M&D¢	Ñô»hB4!Qbéõ7¦?dhP&D²mD¢	ÑhB4!M&Ú&/YR%(YÒF4!M&D¢	Ñô»hB4! JÜsïÙ27(D¢	Ù6¢	ÑhB4!M´M@:a¹oÍºw¼ã®çg±êÝÒ÷uÑD#¤Í¡CÎ9÷ÜªPÂâpIÑhB4!M&D¢ÕïK\íeÖÇ>vê©§r=?ËIïz­ßyç¢)~¿þñ¡ÚôÄá(DÒF4!M&D¢	ÑhBú]Ò¦£h¢oÎ¹5£
* MHÚHÚ&D¢	ÑhB4!ý.i<³íõk7¢P ¤hBÒF4!M&D¢	éwIÂÓÄØØØ3§%(P ´MHÚ&D¢	ÑhB4!ý.iS`Øµk×ì9s©p§pA(KÚ&$mD¢	ÑhB4!~´)$MÀÚï=õ(a@Âë
Ñ¤¤hB4!M&DÒï6ù¤;:öóÆi:SàD6¢	IÑhB4!M&¤ß%m
C[¶lýÄÙçC·Ýõ77þ-¨ªoç{¦¶h6Ø^¬`ï#cé@át6¢	IÑhB4!M&¤ß%m
@k×®=oþ½ãËi¨gÎ7+øüì½òªkO{ïûÌH\p"'´MHÚ&D¢	ÑhB4!ý.iÓÖ4«~á¢Å)(A^ 8Øßoç{&ü^¬_ôÙKÒUNV¢	IIÑhB4!M&¤ß%mòC+V¬U_QCUE@	ÿ7eÁ©QIÑ¤hB4!M&DÒï6mGËÝtÍfÑPàÓÞû>üÚD:a¯-~APIÑ¤hB4!M&
þìÏþ¬ØxM)I¿wM|ñò/-½þÆ
¼påU×~û;ßÃ²}ç-¢)ðM`/hâ¡G«Jý¡¨¤MÐ¤hB4!M&:&$m
F,ùú]C±Låhº@±gßª4 **IÚtMHÚ&D¢	Ñh"Ïú½««k``Àþöôô'æä÷}¥ÄÁ!ÏPgêîîFöïß²gÄue¯jÅ1çÐÐ~§ðÔ6Í§Csî¹÷Üû@U*;M°ßDUÁN\P%TÕMä³n)â´ÎTHZÁ+M&Dy¦	<Ç_M4&¼<Qýa#5ÑD)ù£££Õ_PBÊHßÓD¹£	Óøï¤MÞh¶úç¯|¨Zµò¶»âA_ý|Á^ÀEµî	,¨ª6±W4ÑTNN	MdfS+xE¢	Ñh"·4'xû7GÐº±"h>MÑkê
¨§ø]+È9888PJ¨?þ"3d»ú)¿È£â&Kßíy
þEQ8)êíí9é°sù-V¾óåhq¢ ÎÜß$ËLOäâaì.a{í±Ý´É~?|äõ'ßwÅªX(1sf(ÑÌÕC%QÕø?ëêÇ{®Y#h-M¤4ó@
Q <Dâü ¡4£xá¢¸NÁ+M&Dù§	ã.¢Ð55Õ¿kÑsa¸Ì]Îf¢[	dh%fÃ±<EPÂâ¥»Ë°Çsá[¸ò&Ye.çð}ºMPÉx½d+S¯þØâNdGÙmñ½uAÅmu ½!iÓZýóûâþ«7í~õµÃãããsæÌ}fÛò\PIT.rU4ÑrHiæ¢À#8p~MX9H)'ë¼¢	ÑhB4s8Ës?úÅ×þîSNï~aÏÁ/üèyýÒy¨ÉÄ¯Ð¦Í_ê&:ì<´REAiÅ¨a±YûØëZzæzhÂë}¿%¾>h¡ÜâÀO¬ypv;#ö¢´=û'òó¢þþ{þôá'¿[àè¥Íæ¯ÀüÆòì~¿OoqÆm¨ðØØç.çù?D¼¢xQsX1 ©§	ßÌS¤SÁ.H$ÛBYH(®Aðv´M&DÅ %°\sï¿.üÚ¦^ü÷KïßUàeÎ¥÷-øÊ<ÔäåW&Lõ0ÞÉÔõ¤0S¼*@lÇïÐÐP"M\vÙeüÈfzÐ+5Ñ¤d®&üßÀ¶ï'@&p	Þ'÷ç¾M»óó¢Î¸èî/Þö\[¢I¯|ãÞº"v8w}rÑ_/ùÜÚ%¸\réþúÆJ`ù¥[
üñâEÍaÅvþ2¦	å¤)ã^ÌR¶TKYo'HX ¢	Ñh¢N±{BN­t2õfÂÑBìû¿a##sÊÑ)5zÒí¯tò%Ðo°@÷G9HÏÓOd§NñM ^©ínÄwç,uf´bÅyxFs÷Xùñc3CÒ¦Éú_õ! &3Ïy]Î
z^¿02ÆQ°Rgá~ìÀ=¡H§<D:kæ
|µLðrà8
Dq=WÒF4!Mä&b¦M´&¨³ MøY®
j"ZÂú¥6¤â³
©Ì»ÁùìëÇ-q	ýe¶É7y+µÌ¦¦¹Wa§,?B¬ÏFø;@5íOdy¬ï9ÿÚ©í¶X$h"oú¦ø=Gy}íÚµüÕ§÷eÃÃJöÞ÷Ü·Vl»jTDU/D4ÑÂd#Ä¦ÓB^L¼<11kCsÓùë·¢¸NÁ+i#M&Ú&<S&ZERJÒïoR?úh+>ºþ¼ùj
ÎÓ6"ìo U¡ªJ»Æ}bñ§®^%´M&D§,-N4¡$=.iÓýîÓ-[»gÏûyUjûÎsº>{É¼ù<2à/PÂg·dYP%TÕëdi#´M&D¢	ÑR«R«|ú6íEH;vì¨( =ò­Ca%®¼êZ¬·ÂfÍ®a"l¢*ÖáÒ¦ÝiBRHÒF4!PM&~±/ðJIú½Chi×®]ÓgÌ¤VÍ²öÞ÷=&°`cÐEbà¾µ5 ªÊ J6íN66¢	ÑZhB4ÑÜRÒÜR~ï@=gnF yæ,óAØK4v¥ô%PTFÒ¦ChBÒF4!M&D¢	éwIÐÒØØØgüIYíVÞvC6ù~ës]-MàÔ¨ ª!i#´M&D¢	ÑhBú]Ò¦½hòmÎ¹ßúö¶Jê¡GóÓIxp¨&pR´MHÚ&D¢	ÑhB4!ý.iÓ4a@±þñ¡fª<®ZMHÚHÚ&D¢	ÑhB4!ý.i7@:tèÐçßÿàºæè;§ÃI%mD6¢	ÑhB4!MH¿KÚ´;M(.¼ðÂ{î} ÑÊ§Àj@	Ñ¤¤hB4!M&DÒï6ù¤	¦ÅKÜºâëÓt(§´MHÚ&D¢	ÑhB4!ý.iS<@ºæk^c#ÔEá6¢	IÑhB4!M&¤ß%mJHËÝtÉ¥_ZQ¬¤hBÒF4!M&D¢	éwIbÓÒ7¾ñOCQ(PÒF4!i#M&D¢	Ñô»¤M'ÐÒÚµk?qö9{ÇÖ£Úp8
AQ6¢	IÑhB4!M&¤ß%m:&¶lÙzÞü5Äá(DÒF4!i#M&D¢	Ñô»¤M§Ñbú£c?¯V©á8(!´´M&D¢	ÑhBú]Ò¦½hi×®]Ý³çþø¥Ë®Ñà@IÑ¤hB4!PM&D6Lé3fRW\§%D66¢	ÑhB4!MH¿KÚ´#M Í3÷m?H×eÈlÈ,i#´M&Djq¢	éwÑô»hÂÅT À®9C	Ñ¤¤hB4!M&DÒï6íKà³-]È i#´M&Djq¢	éwÑô»h¢H<çÜs×?>äUþbcCQB4!i#i#M&D¢	Ñô»¤M»ÓÒ¡C,8ÿ{ ÎÂ
þb£¤hBÒF4!M¨Å&¤ßEÒï¢,@±xÉp¬4%D66¢	ÑhB4!MH¿KÚ&ÀX$mD66¢	ÑZhBú]4!ý.´MHÚHÚ&Djq¢	éwÑô»ô»¤hBÒFÒF4!M&¤ßEÒïSn¹å½{÷øwìØÑßß_ìxÏ=÷&$mdÛ&D¢	ÑhB4ÑFú}¸¦ê\SXTÓèèhÅ-S{+òë¼¥Tí5f)6®X;>ñýû÷£Ú5ÜÑhB4!M¨ÅÕI¿>òêkE¢bè÷ÁÁÁ®®®îRÂ
þÖ|¾¾>® Ü1Üo$c[w+ò±^g£ë+¥ª®1c±h,þ=éííÍùG-¸·ÝGSOOOFú¨§u&D¢	ÑhB4ô³½¿º¸Ç9×=åÂåÛw¾ôKÑh¢­õ;d&ì@IfÐú¿Õ¦VY'ÐÝÚh+uÖ¿q4ÑSJ¾ÓDðfú
C¸e¹Û¸Qï§hB4Q0ã?&DjquÒÄ{#ü²ý'D¢öÕïx¬Ô[J0Ì Ã
Nlç·\¾~×Åï`)ÁBãQ4Õh33Â±ø5'Ë¬SÚ{v,Oz"³ß244dy½ü,å³Vr¶X!vOÌSÐ9qX,rÚÇj»KGÝ=v+xv¬0¨&>c@VO³ÕQîÂ&ü×è¿Õó¨à¦yðÎ73ñ©ÅOÜ.ß¶Ø{ÂÁÃêYrs²{E|?;Æêy	Û-|''K±[O3x9}ã_NVwR4!hw¸ý#ó¿ºmõ¦Ý)D¢	µ¸iÂ¼~¹pùvÑh¢}õ{üi\ða5ÁÏo¹´ hñÓnðAÞ
§>é>¹¶¶û n]qy,¶ð%D6+y-%T!CPmOL4/­´*y^^ ó[æ&üÀIyÉ«ÄáVïX|ÆàÎÇcqvE¾å.4?¸øýÒD|Óü£aãA<{FÁS8$ûxzâÂ¸¦>o¿	ØÅ·&ÞÏàM&yÍx8Y?Íàå4ßD|sìåäKÂ£Êù}D¢ö¢	Z;`
¬Ã|M&Ôâj¦	Py\>ÿ·ýñiÝÓc^¦/øÊ§®^Uìk|o÷%Å¾À³ÝÅoyâï3³Í¿ôÆ4{Éw¯ÝÅp´½	ØV¦ÙWöyßãtÚÃö½ÚÇíðXsÐ^åy~¦i¿Ìñ{ýYè£ñÖ¾Üfyò$r4aówpF_>û#áàÍx3ÈË]xßÑ<¸øq ½Üß´&ìxoTüÔâ'NãÜÜ%Á{bì`gÇ=ñIþÙq=¾Á,gÎ)ffðrZiñÍ±[4'·~7nËÜÖ5çÒN6Å[ðñ(|WÞº¶Íwïl0LYÑhB4!M&H0¼l¯i'}¬f@í·Àö¦²#Å¶¥YtÞd½¬Ù<1MXµKcßÕQ?JûÀ!«9
-RKé4açµùÈL<	:$ÒG*Kq¤]~"M'"øÂ&_£/ÓJnZ@æ¢§ZüÄYUk.&[Bñý¬HDøÎÇOÓ¿&#M&D¢	ÑDÍNÜü¼"éÔÖ±fÆ
hñk0Ì$FÀFzCºvw[¹tMGûËºö±=Ñ¶¤åæZÅä£hÀ¯åñüi×åC¤b¨±u»ÛezèðNæá©yâOßÁ­HìáiÂß½À6æÍä°(rN'Bðàâkänà¦Å4Aÿw±göÔâ'n@<ÛYaëa×eÑeåh"ñ~Æ4awÀÁz@`Ý"§¼æoN9P¤"
éDP¤hB-®NØþ1M<5<.M´»~·¸\1[]Mñ×º³{©Yõt
iÍoÚÖ÷XÏÑÄßìRëIÍÁÆ¯î<;(%,OäË·oõ´Hí³u§e=}5èqð=yþÂh4Ú®Øì÷)¸G{+'1Èàï ìU_ï Íf_Ä·;?¸øù ØÛwº·fÉõWÇø©ÅOÜîaÐ¡#ØÂ
Ûõ9¹%å~ÆwÌ¼WÁíõ½Îã§¼|\n¿'¾WKâd¢	ÑDÛÑqhB4¡W3M í|é.ßn^	 Ä¤FMN¿7>¯öMü:ÝîWØ,êÀÑDht>¦b?MÑh¢hâÙýÂshB4¡W?M0ýûü×Ë¯L-N4!~ï´ÄnàS2£YËyOôÖÛèGú-üÓM&Ú&w&DjqõÓDö'MH¿+))&D¢	ÑhB4!MH¿ç?ÝrË-{÷î-ðîØ±£¿¿¿Øñ{î	zj&$mdÛ&D¢	ÑhB4!ý.iÓPý.i#´´M&D¢	éwÑô»ô»¤hBÒFÒF4!M&¤ßEÒï6¢	IÑ¤hB4!MH¿&¤ß%mD6¢	IIÑhB-N4!ý.~MHÚ&$m$mD¢	µ8Ñô»hBú½õ{'é$´´M&D¢	éwÑô»¤MÅ4<<<©$´´M&D¢	ÑhBú]Ò¦Ê400ÐÕÕµÿ~áhBÒFÒF4!Mt&M>òúÏï{õµÃ¢	Ñô»¤Mµ©»»»·¢	IIö¢	²¢	ÑZ\4A¸pùös®{R4!~´©*AUõôô`¥««[úúú@ØÊ`[Â:·âì%`#é)%d´¢P2þÚ®6ÂÑ¤¤MniâåW&n^÷â{ÿxhB4¡W3Mxà"MH¿KÚTÐhùÃÔ7` b  ÔkHÀnGâ!8GaÅâ@ 5<<ÌÌ,i#´MÔLä+VíÜþtM¨ÅÕF1GpY½i÷·®ÿã?ÿÒº§Ç
¼L_ðO]½ªØ×øÞîK}g-º	K±¯±kÎ¥ËÜç>5<N³t ¾ZûfðsHÙ°N '¿°´é§°_KÈÌ¾(nÄ¹ ¡w$mò°àÅ*i#ióÅl5[ö|eõað %¸ë?%M&jóMÇÑD¢	éwé÷zhá£É
MRCfnÐA¡ßNVÚÄÄ/ÂßÛwþXÒF4!i#¨&þá©ÿÓ¿ágó¿ºíÂåÛÜº[þä#¢	Ñh¢öH§)é¤H'ÅHÚT`ÿCUÙ_ £À/#ðË-ÈÆa ÂDb+
ÙL¸KÒFN6tª-ÒéÕ×¯Þ´ûâþO<¿oöE:&Ôâê¢)D¢	éwIì	6¿w=La(%na[ãv&õÝ&kØè²àö×&}ø¢,Jý&D6¢zhÂ3Å{þhºhB4¡W?MSLüúhB4!ý.i£$i#´)<M0É7!PB¨Øâ¤ßEÒï6J6¢	I"ÑÆtM¨Å&¤ßEÒïJ6¢	IIÑhB-N4!ý.~ï(ýþØcÍ?_ÒF4!i#i#M&DÒï¢	éwéwIÑ¤¤hB4!MH¿&¤ß%mD6¢	IÑhB4ÑÉ-îÐ¡C¤þþ~éwÑô»¤hBÒF4!i#i#M¨ÅUî»ï>ÅØØô»hBú]ÒF4!i#´´M&Ôâ²'¼<¤	?M­ô»hBú]ÒF4!i#´´M&Ôâ*¦±±1ë:qäÈéwÑô»¤hBÒF4!i#i#M¨ÅeOàÅæÍ¥ßEÒï6¢	IÑ¤¤hB4¡=íÛ·ïæ£iddDú]4!ý.i#´MHÚHÚ&DjqÙõ@zæg¤ßEÒï6¢	IÑ¤¤hB4¡=­Y³Æë/¾øâ¡C¤ßEÒï6¢	IÑ¤¤hB4¡W19räÿùo~sV}~MH¿KÚ&$mD6¢	ÑhB-Î§Ý»wß~ûíS<xPú]4!ý.i#´MHÚt¬´ÁÃýà{Ë1ÇÃü,oýíßþÈôXùÈôµÑÄ;~çwÞÆÒºþàO|ç;su<ãßýÝ·sýSNMä<:thçÎ6lX¾|9§É~MH¿KÚ&$mD6+mÆÆÆ=þéþéÙ%_¥ôuÊÑ%<õÔS6mÊó5&~èMä3¡í{^Òï¢	éwIÑ¤hBÒFÒ¦½R
MIÚ&Ôâ¤ßEÒï66¢	IIIÑhB-Nú]4!ý.i#i#i#´´M&Ôâ¤ßEÒï666¢	IIÑhB-N-Nú]4!ý.i#i#´´M&ÔâÔâ¤ßEÒï66¢	IIIÑhB-Nú]4!ý.i#i#´´´M&Ôâ¤ßEÒï666¢	IIÑhB-Nú]4!ý.i#i#i#´´M&ÔâÔâ¤ßEÒï66¢	IIÑhB-N-Nú]4!ý.i#i#´´´M&Ôâ¤ßEÒï66¢	IIIÑhB-Nú]4!ý.i#i#i#´´M&ÔâÔâDÒï666¢	IIÑhB-N-Nú]4!ý.i#i#´´´M¨Å©ÅI¿&¤ß%m$mD666¢	ÑZô»hBú]ÒFÒF4!i#i#i#h(M¼­ý®bÚ´io+nzë[ßú¿ùo+t:æcÞò·ûÑÜRÒ+¥Â?DII'¼¢666yH¸@\f/ð¸ã;öØcûûûïjÿT«HO+W®,ö®X±¢ð±ð/ê×KIQÒFÒF/ª¤¢¤M'\ R±=hJJJJJJJJJJJMÿ¦Û~
endstream
endobj
156 0 obj
<<
/Type /XObject
/Subtype /Image
/Width 1050
/Height 552
/BitsPerComponent 8
/ColorSpace /DeviceGray
/Length 584       
/Filter /FlateDecode
>>
stream
xÚíÁ1   Â þ©g                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  àon¼
endstream
endobj
166 0 obj
<<
/Length 1242      
/Filter /FlateDecode
>>
stream
xÚVÛÛ6}÷WèÔ4/"%í[o	6hdc (6ÁB¶h[°$z%ªÆöë;I[Úî%Û"3gnCÐô~öëj¶|RáL2V[$Áä8E«ÝFñüûêÃìÕì~FáA	eÆA`Bc´©g·ß	*àìûYNdâ,ÅDªÐÙçyÖrB±ä	JÀ<é¯û²Ró$:Í)t{(Ý Ñ>ow¤÷¿iUnü9­Þ¨®sÂu~ì7í¹ÅÍ{#Á<aÜÂ )Ç$ÉØC!ù#Ø1¦i#ñýÝ;ÛkµÑµ÷bÛöis£<ôÜøÿªrÂfï%Í<éÂÚo~#ë9Ñiîï2{]èJï|ò¦ÑÆFFf$AJq&CXh¸6è?ãh½¥KtnÕ±Uj÷¯ë7{©»DQcq°I}}clGt»D«yB"UUç¼í;åñYo&X¶ÎÛ«ÍÜeà.}Ùô:&÷:7¦·ÞhÞºÈFµ&/}Õ5}½@ÏWÊZuÿÓ§9¨U=Î¹Q5F»pó,aæ¾)ÐèF7EiJÝ<½ùc_òú´P²³º(ßåæpÆ®52 ªtÛ2íîó½½ªª©¤¢ÌkpÌG£U
P×ÇY<-Ï/¦¬ªiç¥`_ÛK³<ßä¿Íx¾×8Ù¹!¦uÊÿmó¯ ÿ;³ÒúàWåÁrá'~Ù¸8MØÙäÛmÚæá^ð.P.pÆ(bicÆìÃp?ÃP$,$FËáH¦døRÍåuÍÑïÏgµ w1RüìÂ$;þùÅÇ6§6\@v·çjµnÈMO}úa»Ê×Cò`9d.»äÃ%¯eëäMî{óÆí:g$ZìZW^ò¢I@b;ó©)&B©ÎÑäµT
J/çNDôu¨4{eWÞÜÇJÿ£¼#ÀýGèêr]VÀÝ@#L êñóx&!ìv®!Bq¹Äû<Ûé4|ÿ;åÅr÷½.[ Ëu¶©¬G©þS;(ôîT þè®CøûãE{8>±+¼¥¢8výz$2§u~7°æ(y¦×®¼ÔÛ)Í¹ =ù:ÐLýÆô­Â|?5¥C·½4Ñ,ÃqÌÏÃYh)h¶$
G&X ÿ'¦\¦!_YBèP8NaÆ`8»Ô§ËôEéËsÖ6üBu_>
OøHcà§moÌñj¹T>ò¨Û±nwKûµô¦î>oÒ_bÎ3´@ûrD¯:s£î{Õù$½ë+`~VUõeÊýKz½ºþs2}¾ÑkÊ`ZãòÛ§Ó	fÛæµ:A1t×Ir§Û+ðÀmËøHÙåA¡0o[V¨¤¸äÕ¨¬æ©}ÔÏ¯RPxðsF5{þÆhÈ ñªØ¹³&~Z¢»3>~«x»þuK'
endstream
endobj
161 0 obj
<<
/Type /XObject
/Subtype /Image
/Width 680
/Height 666
/BitsPerComponent 8
/ColorSpace /DeviceRGB
/SMask 171 0 R
/Length 35720     
/Filter /FlateDecode
>>
stream
xÚì½ÕþÝLFg¾$æ?/¹~(bL¼$#â ·ÑD`(0b¤$Ñ
x¡¡	7ô4¨Ü±í øqÛ`K@@âgWVß#ÏÊûß³ëÓçRçªsw½ë¬ª]»vÕ©Ûo¿ïÞûÝG©©©ùêIÿ°eÄ)R©T*JKUÁzÿÈ#<òHD"H$RÜ_¸páß~òºqÏó7ºD"I&úä'xà#Gýüýû¿+¤«áùä]Ë%D}zèþáS£ë J¥ÒdzæñÇüä'?÷Å}©T*ûâ¾¸/J¥Rq_Ü÷¥R©T*îûâ¾T*JÅ}q_ÜJ¥R©¸/îûR©T*÷¥â¾T*JÅ}©¸/J¥Rq_*îK¥R©TÜ÷¥R©T*>÷wíò^Ó¢w¾ô?o¿_,#%ôà!Z&ö«À¶¬D¦(ïâñaÎyûÒìÞWñ¼òÜæIñ)Ø6ê¬`:^ïPÓù/Èc9Y.m}gÍ,| Hô¶âZAL[§öÓ3,-îãÍÂ+Sâ»vä¨`!tôã%EÉ!¾8v¶®à(¡ÎyûÒìÞ|<·ùÐ}Óð:$|ð`tµ,Çþ>8n¼­üF)XÍ.Æûxq>¨Eô;k|n<E#ÜÚ2Ïs÷*Å)fûÒhr&-Z(ùÅ'9jgâ] Y+p5¡s }îsûñAs¾ûöõKKûö!rßJÏgÊ ½ßÈæú7þ7dÃª»#^XæaM=w_°XLhað£Ì³Â0ðÓswGfþ)ï(n±vþ	Ýþâ¾4;î{´
&¦xþ¹>p÷â²=äH´W/õ[ì¾îkBc ;=5ûV¤à>òãYugfþ+'÷-½ïLÇ%rWÓü yå#'ÿ¯{¥ÒrßÌs¬yS>óüµÇ¯!¿ZL÷>|Y©ðüü¶klõ6%³ß#Lä¼&{ýí-f¯·æcÅÚîÉ\â¾4wîÛcftKñü[3·º¯W²Çåo±Î
cæ¼v´`3Djîó«âîåj2î{ |ÓñóÛÉ¸¸nîª½àé|ÐÜï*^£F!¤â~úõÎ&¬Ó½Ìç¾2îkÈU¼4LøæÂ×5jûlÅC
7Y[·j¶W`Üçù»®~]íd¸Ì6±æïOwOÑÞ!îK³ã>áâòÅÞ©Ï?ßã5·Ëýo±Vl²ÎrV!AbÐße(4ÚB­÷qVÈÙ<½ÔÜ·º]®2g»ÂN¯¼åd!æKL³-C*þ8>|IØkÅ«{ïrÏNqnËö)p¹´zÜ&<{+¶÷¥É}¾¶P{IÝO¨UæQ2R\_mj··¸/ÍûnZ÷JñüäÒ´÷S¼Åxïì4P²çÁn·}?\î[í3µ÷ú"Ò¼vã1á!¤Ò¸sß­Ì³Ìpkð|h|ïgª§æ~»îò7µ?ø]r}t8+×É^Âa)ÚòÄ}i.~~s8»ÕÚÏð­IñN¹JýsÜû.¸þºvûõèç/ ÷Ûý ¹ÿHÜ*÷Í­¬É³ãyò]MñY`µÁá¦óI`õÃë¥OMØ­.xtv0àÓIÝßùqÖªèVfØÛ!µÉ/îKslß7¹]×=ÿAî§°÷ÝÎ6©ßb¾8"=~.ÝJûí~ÐÄ}i9pû©Æ³÷]zòcâÑHøY°]<¤Ë}û,¸ý{ùvó|ììÐèö¾fÂ³Ñm°A¬c°uÕk:1Rø%Ä}i(ýúÌóOWsçßeø=³Ý}øÓ|màÛ'wî[­#á©ûí~ÐÄ}i9pßâöxÍæë³H®ïÉ1Ývs¯?0XÛ4í|æAÅí±ÌæGµ3·×½*Sr?_â¾4tîÛOú¤~þí­q»¾óYõvÏrOö[ï5ëg¬9»÷irßuî·ûAKÆ}÷©?¿´4Ú÷­SßqÏ¾¦QÀ7Å}æ´.½Ø[qzéX°3Öçccp°,d®§7a¼Sýt7ÑÃoìÓêý©ãÅ}ivÊÇÉ{Pù~Ñùúù·MÈl.«KsÄ=gRqyì-v_o|w¶ü5¾nYöê!NÆ}­RÄéõ¢ï¦§×;Ô«©?hn6ïfYÛeã*KÅýôûóK³Pq_Z\M?¶¤T*÷¥â¾TÜJ¥â¾TÜÆûÉæÍJ¥â¾¸/îK¥R©TÜûR©T*÷¥â¾T*JÅ}©¸/J¥Rq_ÜJ¥R©TÜ÷¥R©T*îûâ¾T*JÅ}q_ÜJ¥R©¸/îûR©T*÷Å}q_*J¥â~Bî÷?óÓ8QNýÖçÁ}]©T*&ÓûT±¸ú?~êÿôÙ]¿!KÏýÊéÿ©¿ÑuJ¥Ri2ýÌ±?~|Q¸þéÕ«×Ix²~ýú¿ýÛ¿ÕuH$I2ùÜç>âûâ¾D"HÄ}q_ÜH$¸/îûD"÷Å}q_"H$â¾¸/îK$DÜ÷Å}D"ûq_"H$â¾DÜH$¸/÷%D"îûD"ûâ¾D"HÄ}q_ÜH$¸/îûD"÷Å}q_"H$â¾¸/îK$DÜ÷Å}D"û!ÊÁã#7o÷%D"îg*+V¬8pÐ±Ç{ÜqëÞ£g\ôìsÎ­¨¨èÜùÌ1cÆ Æ"îK$DÜo×Àÿ·k]òÍKg>Z·{ÿÁï¾°aË¸	ÎèÜµq_"H$â~2ill.ïðá8âÞÓm¯½Úê0÷%D"î{²ÿ~@¸,èÂð>üq_"H$â¾'}úôY°¤!DæN9{ìmwLVS\ôwïÑ³±±QÜH$¸o2{víÕ×¶]/ì6xÈ0pÄÈª§¾µ¥}ûõowGÔV¯}1Ä3Ù¸åµ3:wÎÎÛ/îK$¤$¹Ê)§a¡à÷mè'ÍØ´qå²> Ýµç]lÂ*2O9;\ÿ¦ªï¾{¸/H$qÒÜÜ|~®á¢6>}£<y$âpGÀu°J EJß~ýñj@'óÔêutí*îK$DÜÔÖÖ<4\îæÖ¡X`"ýü¨Ì¿Ähø õpýüÐÖ¶Ç÷9q_"H$â>dÂ	Õ£Çå©[+ D¿µïîXëQ+( ÷¡â¾D"HÄ}êð"d§L«1ßmî'÷Ý­±÷Å}D"û&.¬üÞU¡·ïî øô³Át:ör_ûØnûþ¶tî|¦¸/H$qÿÈÑØ¼'xRèQyÉ÷#«.[åèç&,`  ¼óßÚÒM¶K(zÿô¯½v¸/H$q2`ÀÚyR¤>WÏïÒµ¹¹YÜH$¸OaÞÖ¶¥ýi÷=u¨^q_"H$%Éý#yÙÍ%X¸/H$æþ£ÞþFÝÓéwë9ûs³Î/îK$¤´¹¹ûî»ÁJ3ÖÄGÕºvmiiÉåjûD")mîCÀJó3:ßTU}çä_²Ë}(ºpéª%ÿññÂüß®f-¢µó¯=®ò{WxâI¨Àä~)rá~sss£$²yóæ÷HWFRÒÖÖ&øû¡ÐÊ)UUU={õ
Kÿõòáüèß±ð­k{}÷^ßüî·ªêC,À&LX¸páÁC¹Ys¯á±ÇÛ]Á½Ø¿¿wðtâ	=»wJc­çýÕÞ½z
¾â~dåÆû7î|ëÐÍ³6oÝupÆò×®ßå³Íû:txGÁ½DµµµÿvõÿóöRi¬uuý^=Å}q?ºÒôÊ»ë¶û[Þ:µù£?ÿEÜûR©¸/î*÷iò¼«	:@ÄOUÜ÷¥Rq_"îçnò_:ºôþ©ûÅ5kÖtüßDþöíÛ[±PWW'îKÓ×W/;½ã©Ðn]Ï|Ujæx¸;n­bGLàîâ¾¸_2Ü\=¹©qóÛâ¾$÷»víLÄ/Ò¹
¸/Íû\~sÛïÀý}û$ËyCá¾ôo¼÷Åýãþ/f~Ü¯OÜdÄ}Ü¿æk`þã)·Þzkß£ÂúÀÔ©Szè!d3¸/õ¸OÅêöÅë Ýº_ûà}XÅ26qÙÛä*7ßà·ucúë)w$ä>ó»·;(vg	87æ5âz®¢@îÂq_Ü÷Ù_Ü¤öóßúW©¯¯7?¿gïc+é¿}ûvlÂ/R,¸/MÁ}Ð`(ýæ¶ß1ÞÁM¦ÆwüÅ/J£©Ô<î[~lB`	vPÛ§ÇêÎç_â¾¸/îûeÈ}¬ûÌ°ô¹,?¿4MîëÄ®Çýà&×Wà®Ë8A¦{ÜÇ/SXT°"áq¸CVx8q_Ü÷ÅýÐeÑ¢EßéÛ¿ñó'ãþ#Ü¸/ÍÈÏÈ§ø%îq?¸)÷a[C ûPÚì)¸ÒÜ÷AÜ÷Å}q?DyåW@ü/ùVí¼Çñe¤DûÌ cêÔ©Ìåææfq_÷aÓ v­~ã>Ð¾zøé«·: V=î[~ß;.K°rGTHì¨`q_Ü#÷_ÝýÀ=tÄýë_ØÃå÷ÿô¸Ù³gÏm·Ývr ¾Íse¤ [Æý`w}o¸o&?hø³Å_Ü¦ÇG5LÓ¨g:òÌEà&·4nr[á9BX÷¸ÏüTz¼ÜºÞfÀVä1Ï¿¸/îÇû3¿~éèFWû['îGÊ±ÿµ¯ýÓªêà\ÌHA:¶Åí¯¸=ÒÒÐèi¸_Üâzû¨	ÈÏ)Çþ¶¤à[âö÷¥Rq_Üiû¾kòGÜØ/î'tì§ÖÂ»ýÅ}©TÜ÷cÊ}×ä¸±_ÜOáØO­ñrûûRq_"îÝä¾±_ÚÜOÓ±Zãâö÷¥â¾DÜ/ºÉ}c¿T¹c?înq_*îKÄ}W<8¡°òqso½}r!X__/îçâØµÛ?kî?>gæmÕ?&Ô¿ß¤Z7=¯KL³PÜ5÷wÏ©Ú×0ÍÓm£ÎÊ7÷ÅnÝ{VWÂZQQQæÜÅ±S·ÖÜÇcSÚïEÖ/8¤ºò;ß½L0¨?¾qdO÷ËûlY½p?Üù«-{ûxêòÄh9s?c¿ëÝ.[å¦t<íô­-mÞ¥[½öÅ¾ýúc¿XöòÇÂí÷Kû½ÈZñÅÈû÷O8ý½í<fî:eZMÂ¡Å½2|Mì­I_7nyMÜ/+îîØö~Qüü¡pzÖûûwìO9{ða¶OkÂ/îjXhÚ¸ÍÛìó5·¿¸kîãñsT¬Fû8=~ùÖûâ~2mÚ·¯Xíû9røÀk¤C»ì-÷óíØw¯< O«jîü%X¦ºÜÇ·7wÄÈ*lÂjê·¿¸kîãy³'mkK=[ÅCU<ø
¹Ü·:­=ÌÌ`'éV£°Jïi5PÎG%3¿g¤X9Ä½¸/îgäçÇíÛ1¶K¹ï:ñ¾dêÝ?f}|Ùì{hßR,ìÚó.ùÏ}ÁøAC
?¬ï¥ßÛ_Ü÷³ã>ËJ)¾0öàñùde)ÌlÐÇ.xhù0£ÔÜZ.Wß}þ­òd·gBn[5¡÷5÷Åýttïâñî|i÷*Øþ®Fûx¼Y=¶
¹n5Ø,D{¹/^+{ã¬æÌ7ï5}®OÜO-õõõ:uJ³Ç¾ùöqqµ]ß>n6¹o7)é÷öÇYáÜÄ}q?îÊñLã®ùÏº¨qßm`ÁjîgßbÝ«÷ºÜ·çû2A×Þ#(îûÚû	LýÅâ>=]tõ[ÀªÁV·­ÆVíýâ¼×ôËë Üª¸Ì±yee·î=2ê±OûÅµbøcM 5÷3òíà¬pn8ÃÂ»ýÅý¸sßl²Û¥<~a¹[
óÜÅå>ÔûÖØ5ÞÔÜgT·!MÖLÄ}q?Sî{f~ì}Ïx$Ü|<ñÂº¼07ßD«¸mg¬Z³z	ÄýÔýNÎùh]¦WJ»¼î÷51ûVsÍ®ôgó,°Û_Ü/îó)%s½/çç·JÛsÕüùöl»I·yË·Õ¬ç%÷Åý#ÙÆíÙ1¶qþð½ârßjàÞ_>üÖÏßÅ:o¯IBî³MÙ¬,º	÷Í±ßÚv +Ão¦ûIdãø,C¦_6*Î³Ànq¿¸â»]PÌÞw»ÕYæ¹óXgTËãËÜýÖªhî·ZkÝæ0¾Üd5OÜÏÜï5-r½ýÞ/nû¾±~}ÖÏëd½®ÎvqûäÈÏ¢c?"ZH·¿¸_îûeÈ}Bßúõí¬È¸=Ñç> ÎJµ×ÏjÂ4Õ=ÿV­Ì* 40Í®d¿[¯÷swìGJãö÷Å}q_5îïÛåãÈÕÿ»5Û¨³
âõi_ý¨iÜþâ¾¸/îK¢Æýdq{`ïïk&îû%àØ/¢Û_Ü÷Å}I4íý`ÜÙûâ~ÑûlÙµç]öµ£Û¿XÜÇs{·&ëÝµ±¨òä~]Å}IîíûlY	ëÞ(ß2±7[üc4OÜÏ÷ëØ÷zJg¤^ççb¹ýÅý)Ójl(kT][^ÒdÝÅÓ)*RzÜÏb¸/	û0öÁý#G§äc¯þ`Ô¸o,¦Ï]¹urÑcþ÷_oÛ÷ÛÆßGß±ïÅUÈtn²Ýþ¸bùã~ýê­Ü½3O~~kmw¨Zî4¢B¤ýóÑãÇTW§æÑ¿Ûñêö×Ä}q_Üo·¡_Ã4húîý"r¡®ø©iwP&¸Ìzßsú¿yÖæ­»Fû¯î|ëÒÑ'¿þ9öÃÜ©FÆ=6ÑváØ
µd4Éµ÷m44Òé)e(à(i><ìB.{nÿkZS\®¹?dòú+&¬«ýÍ.ýóÄ}»/¼ÔnhÞ^Ò`»¤fï[N>Æ+Ê»òîMÉEGvÙè§¼Ëå)¶â	¿ý.ýÃâ>ã{¤~à)ì^|^à ÿàe3¡¨d7HÜ÷³à~¼æåñ¾fîël|t[!ÝlÞ^ÈU7¬VÖMrøú@Fô/ ÷©Î²pì3Z©!uÜcÆæåÕ¶vCÝ@g÷-«|lÙª
Áª[Z¦¡<·?.Ú]u3¥Üç½péî3<l°ÅæHbt¾ î]s/)_7' ¯¨Á®C±÷ñÅ½ëþä>Õè"÷ùPYÜH{àyÁRÌK±gM0n>¤¸]#/;;O$îû©IÝ2±÷;_Ú»x¼µï5ýÐ=Åå>ß>3ñe³),-\ðùNñäeµk¾¶¨·Óce÷N}ñìo×­iûø
ýìÁg,))ô®ÇÖuêùÃv³õ%¿ñÝÍlØBï{|}þWm4èêìûø1 y²¸Ç®Øåµe('ß=î[%M<F± ï;ë_vþUºý¿?ìÓØKôórM¿%õE¦â^àx÷èç¿¬¿âi`µòöuî½ ýÿöOçÃÞÇkbwÊ¦1ðFïÅs£¹Ü^L¯¨Á®CáÔM£ïúÁ-3p¦/~×
:¹ö%»ÔOoöpÐÐÐÃâ¾=¢üGvÅøg­sâM<í:@¼Ùv/1õ÷Åýç¾©E×ÁËeÆMBw®·dÜw'È¶Å·4³~§Jû¬/áºù{l×Ð÷¢ë{#¦Ï}eÉ¨AHÙDî¬LeË}ºqÌåB²½8Æt7Ìu:Ü·èÖVTÂ`×%Ì}v4¢â	¦¹Ï×7Å5+/Ëý7HÜ÷3jÙO31ö>gÄ¦CÞ,ªÍeokBî³ÚljÓÁ°Ü¿W%ïç·0ãÞÜdÁ¸ÇüÒÁÂº3·¯¢9÷mîEæô¸ÏBX¾UÞUYùùÉbsÓöç´Iá]w´÷ØóJz%ß+*a°kK»ßã¾ëùçL±ÇÏüü6¥[;MöBÙSÜ q_ÜÏhÞQ×ûÙÛgÖ=^(¨û¾°
û¶×ÝÁPê×ædüÖ±¦0î±}úpk¸°feQ ¶â.x­ÃL´¡äç`~~YZöë³+ì^v6cñÂºWÒé%ìÉKjóa1'çáuö
»v§_o¿>û§üGæbw;k¦¸¯	±n·#õå1Å÷ÅýtÂòÓäèD<"1.Ü'»ñ^Ð{·&	,5g¤Ó«Ä&!R1ÿé¢4§%ÒíåÕ8¾(ï}cs>©TÇñÆ}âõIÈ}'!÷Ùôåñû®Ã5·ÑLx¤
®=fÍëeë"nUzDn7ÅíÚH±P¥·Gqz§WÜ÷SÇëÝ8¾QÞ¯¬âôûâ¾¸/î§ÙÁ/£î|ñâ¾7¯¸¯yy4/¸/÷ËûÈÏr°©@ñùKûáºý·¶´±%ÅZvíy7Y½×¦cÝ5­Q&ýæææ©S§º)uGEÜ/Oî/]¶Ê#¨^üq_Üow^ÝsªhïcMüâ¾¸·?±CÅÙKTY®t÷e´RÖWÇ~×®]zè!.ãÚvìØq¿<¹ÝQuS¦¸_nÜoØ;8ï¶Qgí<¼/lØR;ïqÕ%ß¼´{gsnÅÿO<	éÐªªñyjõºrã¾¹ýÿùüY·!»ðæ^ÜdÜçÐ?Ûäv°Ìú#sÆ§éØ¯¯¯ëqU±|Í5×xæ¿¸_&Üg÷KÜWåÍºË_7úw²Àànf[pC'E.îûé·é'4í¸¯aZpÛkoÞsï@>¶;9`À Ø+7oÞìóþýûÊ)S®½vØ]»b/TðG¶}$÷)¸D_ûÚÙ?¾qdFnð ¸ë¨OÈ}è[ô¯f}-Îgþß1b_WW×·o_µï!÷9Ä#-`ã[$"7Å5½íÁ¶HbÍË0à6¥p/7³*<E(òÔs/ûâ¾¢Ç3íiïG9No(

Ü9ù°ÜaÂ~,»¬/>ªø/¨3qFçá7þïQ9p2iÒ]:qÿôY¡±ÇíCûf98IqKp8Omÿ±k×®°ú·oß.î÷iG'þíE'¶FöÜ·	nV¼¢tÃWÚ=1ÍPäâ¾¸î]<wð½¦E ?gãeû>§åMgfÞØqÏ9èÜáSªªª`¹xZZZpýO9åT3QKûtûtunFse$ó ÷ml>Ã&Àe/}Ç>Î0ëû·Þz+¬~õç/Cî»O&]ýn>n69%ä~ÂMøÅ½vC'Im!IÛE.îûiÚû©µ]¸<\¾ï¾æïvÔ××÷ìÕÝJû¹ý=ÿ<?\Aî{SíØ¬îu«ÎÎ±ûq¿Ì¹Ïî%.jYuSP%pÚÓá¾û?÷ÛE.îûÑ¬¹[ûÄO0*|Áî=z{î¹øêì¦lÞ¼yÌ1eÂý4ÝþÖE9;	gð±*ýîÈ>×&÷sqìûâ¾ñ9gÝù$Ûü¤Ia±ûnùV¹rGL'¹¸/îg·gÛ¨³
É}ûvî|&Þ) 9ô¯Äîýñ²ÃîîÓ§O¸.ý¼J|¹Ûv
¿¢ôÞïÚó®AÜ÷í»ùÛå~îý`¯þì÷û¥Ñß¼R|ðlvi78S¬×½íBïYå6ÊÞYACÞü`yxÉ09_ _ã÷Åýôõ5³·­ùî|©0óðzq ù¸ã>Wù½«f>Zcd<É÷ÜûÀ%ß¼ôØc½öÚaÁnùâ~4{ûçÞW3Ç¾âõû×'î0÷¬ázÀý½?Ø²2áä¼yå>åàÁ.8p* Ý{ô~ãOïtºøà#Û¸Û'<Öý)§:|øøøÇôn ÷³îíµèØ÷Å}q_Ü/UîïÛ·Ö½;f¿0q{ÚmýÇ¾{öêÅ9ã)ûÎ¡lcÆÁG5vÖ}	s?Þþì±Aî_tQwiPqI³åþ÷Q-,úùwý»]ÔýÂn/à·[±Oéüó»ûeÅ}ßL{ûÛEM (%@ùÒæ~^ÝþQsìÅýÏ>ª4¡øý, µ{û(|ÿÓçÌ®zßcÃÇÎ´Õ¢ÕÖÖûåfï3N¯±¾`qz%åÃý|¸ý#èØûÒRÕç^¹ýO­ÝvOÝF.Ç÷¿ûñmßç¼<ìÎî3ro±Ú÷%¥Íý°ÜþuìûÒvõ{¦/~ÜÇÂ«Û_÷%ç>ÑÏBØ«¿(ýù%eÂýÝþwìûÒtLþ~·>wÕÏÇÚØ÷ãÎ}NÌ·{NÕÞÅã3"¾¸/îÒí}Ç¾¸/MÓä¿ttc¬}q?îÜî}Ö~>q_Ü/Û?.}q_.Y¹èû¿÷ãË}íú¹
ècõ-+Å}q?
nÿx9öÅ}i:Ê~}â¾¤(Ügþóðª?¿¸_t·ìûâ¾TÜDûîø}W£9~_Ü/mîC6oÝN·ÿ£uKèØGJ|ÿ¸/÷%Ñ´÷9~ßWö¾¸_x¹«nó3ÞX±bÅ¥¿x¿+^ÜuÏ-â¾TÜ÷%!¶ïÛø}ó 0b¿Ú÷ÅýÂËÆWþpý½ÍX¸tt#~±q_*îû¹oã÷y+hü¾¸_TûÈ&ùà>~±ëÿ"îKÅ}I4¹Ïñû`=¬~ß÷£`òûq7öÅ}©¸/2÷Aü}Óð»mÔYÁæ~q_Ü/°Éî{Æ~ß¾}¯¹æ[½õ¨ûRq_Ü÷3å>,}äÇ¾@ÿî9UÏ]õ×0>â¾¸_Ü÷ý®]»vìØ±®®NÜûâ¾$îúPØø6v|Ò·úÅ}q?ta¿>û=ôÐÿ(îKÅ}q_÷aìãömu7fËéüâ¾¸_î¯Y³¬§·_Üûâ¾¸cÜûÛ#îGû\¨««÷¥â¾¸/îgçç·=ÆzVÒïØ/îûä~sssÇGSî/\¸ð¤OèÙ½´lõ_¯yÉîû¿8÷ì¯öî%îÇûlÍç/'ãÃê ê×'îGûtòý1å>¤QRÞrÿo«(?ðñDû6»ôþÇ'îGû}ûö5î³_îKÊ\VmÚÿ«Ç[t$Åâ~ËÄÞ«ßÅ}q?jÜ/¸=¸/)"÷9/Ï3îÅ}q?\ykÿÛë^n£û¶tq_RràýÃ[w>¶b×¸Ç¶ryç[te$ä>|ìþÔ{â¾¸Wa^W9M¸/)â½Çºtý]I!¹Ï~}­ß:µ«â¾¸_xá<®"EÜL¬Ûî>ÞïjúèÏÑeûìÎã÷nòÇÚØ÷%íü2ö%Eá¾gæËÞ÷£còÇÚØ÷%©M~ûbq?w÷Åý|üq7öÅ}Ij_Æ¾DÜû®Éwc_Ü¤0ùeìKÄ}IÑ¹?iÒ¤##nÁ÷K[jkk'PnúùØ?5!2eÊÃë	÷ÅýÒã~}}ýÉN©=NT\\q¿T7÷ü.]õ'Ôc=vóæÍzHJû	»ð©__r¿[÷Þ?µöí×¿ãi§»]9ÉvlÚ¸m×wSï;wþ\þB2Å÷KXÎ=÷ÜgÖmÈÇw­÷øô÷m^/QãøÄý´ëÝÆÞvGîdÜGá«×¾ØnÝCÜdjìçé±)=ûseì÷ßkZôáÎ Ø®Ñø}q?îÃ ÇGj,¶¹­Ú·ÜuÏDÜcéXÆ¶2ÌÝ:}æläa¢í>bd¸/±/c_Üî¬û{_ÜÏûä;uÊ´BÎy,^ºl²!­-mfÝÜÇVd&Í±ìÚû8
Gö>k<nîè÷eìËØÿ-+Õ¯OÜÏ÷vñdwÐ' @#ùÌÏÏz¨íqì(XfÉ.÷±û1Ïº§A©rÓ¦Mîjkk«}©ý²â¾§Ô/îûaµïé0º_çAîc/lE%Á³÷­u hï»Üºý{QÜO&:urÑß½{w¯& c_*c¿´¹ÐÿÏÛo´Lìåw¾Äpýï5-÷Åý¹"ÛwXwMtûsé.÷Ö.÷Ù%À|ønùV&ÙÀvÏýÛ.îËØO¨¨¯kËzfW[·û¼r 'åY±¿³f ÕÄ}q?ëq| 3½ôìG<øeùÖÀx´ÙûÜt¦à«pÅ²(VÝs`áà>>¿v\v÷Ssß¾}X¨¬¬Äï¼yó_K±û¨âidm(³,Ê´¨®JÆ¾$Üåm{øs9£®}â¾¸_xmw,¿ÆñeÄýÉ'WWWcéÓ§ãÙ:Ä
 èÜ±}Vk]ÃÝGèn²e,¢²Ë:ûtÖ½½°Õ6ÉØäÎ},¼³f¸/îKËû­­­HÇ2* >R¸JÁ2w,÷+Gc°N}Â¼[øeNü¢b`N-·Â]ðker,*û¬²ñËZÐ°j)íÆ²±/î§öó¿1óG»çTaß59ÄO~~q_ZªÜ÷ôÝU,ÀêgÅé&¥Äý}ËK­².¦Æ}3ÿÙú5¾õ_õüü.÷éËÂ*[üÍ'`½V#Xeìûq_Ã4À}¬ ¨_¸/-UîÃ¢¯¬¬QåéÓ§ææç?tèS¬><æç±OÖ{Ü·^(üuÍ|,Óx7vFõ¸ïÅ à&üVTTä[Æ¾¸Oioc÷¶:V¿¸/î'°¥2êÖPÂvÒüõ(½¸= <½÷ ºß¿îºë*JCCmvêC:3þenì'lßÇ²7a+ÈtVj×:>÷]?/ ý²â¾µõúÛ#î·;^!sÙ?@¸EìÇWÛß¬­LûQ§Ù?JñúJFÂ³Ï ÐxðÀß)Ójl|=K­âð3ÿçÎ_Bv{³G1´E»Ü7Ï?VCB)c¿Ì¹ÿÎY¶¿¯aã÷j>>q?qú·ë¦+ ÷½àü¬d7~ª´¹è¿ÿ¼¼ù-½P÷ÿôÑPôÑÏ>x)íßw9¶°¶ná§Øo{a.)wh?ÉÇ'c¿¬¸ÿ^Ó"@÷*àÜoØû-+NÒ'îûÁø<W2O#³çÐbOf«ksî33&SÜw||NÈ}|ciq" Ã=*Ò·âÈ}¿nMÛ×Ú,âÏXþ:®CÝ¢è±/îïÛÅ¦Ü%÷­ú­üâ~9sNHw6kZ§y2­33£î»ÎL73S¼×m9u¹EZ=(ATRø
èe~Ö+è¡-Iîñ/Ý-gîñ®ßóÑÿ¢hü2öÅ}oü¾Ë}wYÜ÷Ûå>élaôØëÉº!m¸{AÓ@î[fÆáwG({CXM¾ãFùKèÌç¼lì¾¸pß#>µrÂz$¡Þ9ï~ãÖ¼«é±»°zë¿¯øNÿ+xûâ>í}üº¬ß6ê,Ùûâ~Üá©]MÆ}¶ ÁtægÇ}¦ÃÒ§ë ÷q,Æ
fW¢_Ü/CîwûÞè'ù/c_Üç<¼ >»óû­SûqvµïûÉ¸O'9çÏµ&{#õi5ôó'ã¾kbë @ä>=ù)üü¬rXS·¹ßë|Å¸góæ@?î~þ;zºoÿ+PO`óD&µý2ä>ÑÏBØ«_ýùÅýjëÐ|¶¡p ´õâóæ1ã±Ë°ûõ1è(RÜÌ\%ÖÇ¯ðVrÉMÂÞEÍ=mõë+úw4ñÊÏmÞù~¡Ï¬Û9?}eìKòÁ}îÙ=§jïâñ_Ü/Cî+^ÆñÅK8f¿uÏö¼û_¡?gî#ÛË%ë®H$÷¡Xæ.¨£rp_p_ëË}ÝM2ö%!r?÷Å}q_q{"+ùëÆo[¸`ýUl	»°o[èm_¶p!ê ÌÃ?Xµ}Íjáå±_¶Üÿ·ßH¨éþâ¾¸/îûQ6öóQ½StNãÕ1_}°ÿªu¡!¾sÕ* î¾ÓÇÝdìûYÌËãé;_²	yÅ}q_*îËØOÆ}ëëÂ.¦°Í9:Õ¢î§à¾ÛO^Ø=Æ·Ú¾®fÔ%UÆ¾¸¦r÷ûâ~fKîÂTÜÒØwçÌ%¾É}/ UÜwçîñöÅ_°b³è(c_ÜOSaòï]<^Ü÷ó§9öSJÑ_ÜÀØ·ØÔsÊç£\b¨Ù ß.÷Ý¢Ì±Ï}éùgÅ ¬ö}ûâ~B{÷*q_ÜÏh|©l²EÝyD)î¾.÷nû²­)îh;æa
¿Ìo{1ê¾íÂt·Xq_Æ~èJß}Æ¼YªÙoß}J/ß{ÝæG";¨e_
÷·ÇUöëSû¾¸áÃ¸´ÇégO$Z@ìöLÅ»GÉSù°ï»IÛt<XEÉ4Ì¢ÁÅBØ|À6V+VÜ±/±/î'ãþ{MZ&ö÷Åý:iÀN¡òH^DÏ\ôl»t§µëeÎ`³©ùùÍð·] }ÇFÊÏqà³¸/c_Ñø%¥íç×ø}q?î»J4»³åzsÚü}ÍÇã>W¹`yÜ·@|nË©:÷¸gâ¾}ûq_Ü÷ÓÝºUâÚûf×3
¹Ï!Ïî@æ ÷±£uÞKhï»»°Q@Ü±/ÄËØ÷3ÛcÚî¼â¾¸oËØu9Yû>ºíûä>Ã±Y?÷m öp;¸±M¬¦!îËØÊØ÷ÅíÜßY3«uj?èÞÅãÙÊoa|ÚWÜ÷mÖ²ÞmµgÄQ¶ï»¡Ëmü¾E8GNOv#»môÈéíe±`ã¡¬Î`ý¥s îËØ±/)1{ßÉËq|éwí÷Åý|ÖW¼>}ûP¸â'²G{_Ü÷ÃR<WÜÈØ±/)"÷wíÌÞo×½/î÷OîpJõèqÅÕá·Ü÷óÑã±ðãÑ¿Æï¨Ñný«¢®¸cÿò+®,úB½û'£§Þ4ú®÷Ú\/c_ÜwÇïò{÷Ú÷Õ¿¬¸¿gÏÛn»íæbËnyhð-³±péèFüb)E?«I&½ûÚÚÚ	ÑÊ±Ë«ÇÿòÆÛf¹u¡­æÐÔ"î¾×´èg9XÀªÆñ÷#"oí{ðä^oÛîãËHïß÷%4½òîÄºí«6íÿÕã-\Ö5ûÖÖï9üÅ}q¿ðR·¢å¾Ç·ûøÅr¬ÿ¸/	Ê÷o±üup;ß:¤")
÷wíòÎY¯ebïôgä÷Åý<üà~Ü}q_Ìäï7nÝÀ»dìKÅý7fþÈÑè£\ýâ¾¸ºÉîÇÝØ÷%)L~<á2ö%Åâ¾5èÛØ=ÔPÆïûE4ù/¿}]Ü}q_Lê_Øsãu$Eá¾;~ß³O¿¸/îK`À¿÷%	ýút$â¾DÜ÷%â¾DWîÓÏOÄ÷ÙÄ/?¿¸/îûq_RzÜ'å}T >Ø²GÔ¯OÜ÷Å}¸/)QîCwÖdÔ>(¸¯q|±æþ'X÷Kà_à^ûq_Aîç¨â~t¸øðáô¿û%ð/p/pGô<KÄ}It¸ß2±÷±]¼Äm£Îz¯iQú±ûÄýèp¿dÜ×cÙùÖ¡º5mÒubÝvq_RxîëlÊg³¾Æéâ¾¸/îK 7ÏÚH	ÖáêÖ]%GRhî³#ß¾iï¬e¡{ð{äh¿ô'á÷Å}q¿ä¹/HI$qçþ±]ÀzöÖ¥èÇî¨¨}_Ü÷%â¾DRJÜwÃõpõÈQFf¾¸/îûâ¾D"/÷3¾'îûâ¾¸/HâËýô;òûâ¾¸/îK$q_"îûâ¾D",÷÷5L£¾³fÖ£=ú,ºmÔYâ¾¸/îKÄ}¤d¸Z5~_Ü÷%â¾DRÜW^q_Üû¸/îûâ¾DÜHÄ}q_Ü÷Å}DMî}öÙøDÅÍýÂ@Þ÷OúDÅÿóÎ;Ï& [±bÅI'dªªªìl±léÈLß¿ÿgi.¼ðB+­¶¶ÿéÇ{ì)S¬´Ë/¿Ü-móæÍLokk;õÔSmÓ·¿ýmÛeÆ(ÄJCá¶©wïÞ¶vÇ)1½¹¹Ùý;8¨í±ÒpVNÁvÁ_³ÒÒ¼8(Í.Js/{©ëëëíâ@Ü3lØ°L/N»[iXpKËââxÜ·M7Üp6aÂ/N=îÅÉÓsØåêÓÏ»¸ðÏ¡wqò&»ÔqyÝS°çÐ»8!~S\ò|É}üÿÝÚå¸|CñU_øO¹ØÿXWWÌþ ýqïà"x¥á/?>3v¿¼]ðÔ%+Í&C÷JÃj²Òì¾¸3Åî{ÝgÂÛeáÂ^äLVZ²KóIVZ'Å¥¶W ã^jûøöF{¥eqqJì9LqqÂzÁýìp]²zÓ¼ÔQ~íâÄý9l÷âáshö~·nÝ
~@ÿ3ÇüôÉO~²gÏ¸>n=­¥¥eÐ A½ÿ*v!X¶täAN»/¸­¶iÌ1¶xÔkeµ>6m¸¥Ù>xð  ÛäÖÓpQfo/²íÝí
ã.»WÛ*«VNÒ-ÁvÁ_³ÒR_¯ýëøÄ'X]{qÜKê¥]{qPYÍôâ¤y©±»·´,.w©Á}ÛäZ¨É[zv§ÄC÷âþ2ñ[7Ö~ØÏÿz§(Ïa²KçÐ½8{½Ösúâçsè¶ïêoô»ÐÉÑE©©EíûjßWû¾D")|û>ûõõ?óÓùC¿ýÎÿ»ó¾ ~}â¾¸/îK$brtÎú=è¯¿îdõç÷Å}q_"ûPà>\ô¡¯q|â¾¸/îK$pßCÿ¿úë¾wRúâ¾¸/îû$:Ü÷ÐßÿÌOgýûpÌ'?¾¸/îûâ¾D"÷sG
èûâ¾¸/îK$¨q?ô§¾¸/îûâ¾D" ÷³C¿ýsN<&}q_Ü÷Å}DMîg~úuøûÃ;h^q_Ü÷%I¸½ù¢ÿúÓ¾¸/îû%)3¿»àéÎ·éÊH$±ã>ôÎÿ)5úÓ¾¸/îû%)ïÿé£~ãÖ¹ÐX·]E")÷=ôÿëÿû.Ù±)}èûâ¾¸_&&¿}$ÖÜ÷Ðo|O(îûâ~ü2ö%à~òãzýc¦Ð÷Å}q¿L~ûIipßCÐ÷Å}q¿äM~ûI)q?þ /îûâ~iË=ó_~µí=](ÈÁ÷ïß¯ë Éû.ú3¾¸/îû¥*.ìÓ§Ï)O?ñÄ¿¡¥¥E×¤XÒÜÜ|íµÃp# Z±b®$GîCú¥ïÅâ¾¸/î´µµ3|©üÞU4xÿpkÛ{î}à3:_ÐµkmmíáÃu
fàÏ1£sç3ÏïÒõþéïÞ·cæ£u|óÒSN9õî»§Èü÷sá~Ö*îûâ~)øN9eÜIÛ^{ñô©Õë*ó¿þµ?¼þ[÷bã×nªºYæ¿¸/îûâ¾$w?µÊü/°Zeþûâ¾¸/îKÂ2ðS«ÌÿBø©Uæ¿¸/îûâ¾$,_æ¤|ÿq_Ü÷%1ðeþGÇÀù/÷Å}q_LÖ®]ôÓþL½s1ðwíywÊ´4Íÿ½z8P?ìmwP§Ï½zí¾tÙ*$âË[[Úp/lUæ¿¸/îûâ¾þ×¿þu<N½/þæM£nîza·#«¦ÛL¹¡43Gþô§ar3¦­­M÷"}¿ãi§ã6ýÃª¥#ÄG}ËÐ¾ýú#Ìq_Ü÷Åýr·¿ógÍ¿ÄvBà Y°Ê: nv%Vx×Òd Ü¸Ü<â¾X@:~q¬m¯½9nÂ¤§Ò§OTBdà§Óëæ^|\sþ\^7»*ó_Ü÷Å}q¿¬|¯&!¸ày}ØHÄ¬Et 3¹S¸Ì_r?¸HÄQ&MQ,¡
]°¤²2ÿ³nÁw¹Ïª=ü¼°¨¤ïuù/îûâ¾¸_ò~°¤ iû+ôó[{½ùð-w¦`GzÎà^¸çîæ[pµÌÿÜ»èãº²ÆeéV¥ûÌq_Ü÷ÅýØ	ìµô»è³]~xÒ$HMCÞ¸oÆ&6nÜà^'¸{B-Ió¿¥¥%.úfïÛýr¹´÷Ótò·kþãäõNûâ¾¸/îGP`ÁF¥{-uý`[0ÛåÉ}ú={?÷QQÞÛ+!÷Û5KKÃü?|øpmmí]»qFçPÆà»~~¶¸ÜgÇ	zWÜ ¹ÿ8ùó»tíÜùÌ3f<xPo¸/îûâ~DüÁ:K­Ý9ÝÂì6bdYL^7mÜÌ¿«Öo<È}¶æ»»÷2î³- ¦L«	úùKÌü?|ø8íA>µz]X£ïýúØ°b×Óúlðåö§¾°aËµ?¼^æ¿¸/îûâ~tüÖeô%g¯0@Ü}e(7qtµø-iV¤gJp/wT ÐÏîg¡Å5ÿ_Ýýýù/ø÷Üû@kÛp£îàê¹æ¼ºt/²õÉl7¢Bvº{ÿAÿâ¾¸/îûù÷ÿôÑå¯ÿìÁs1ðK@ÿM¯¼{ãýñÿ«Ç[ÞÕ´týôÏeMfþã*á^¤¾\q_"îû©?tj³}Hs1ðKCÿ;ß:4±n{>èîãÁéo?úÐü>´q_#îoÝu0:ZÜÿÃ;ÿÎýÝ«Þðû~ãÖg_{)õ+_,7?Mó¿zôm[ÞÆ%h@gÐÿéûÂzêÆ=¶Üwéÿ½ûÊÍÀOßüríF\·Æ-oãFàrýæ7CüàõÄ}q?¯Ð¿bâúgmÂ(û;èg¾ÜîqÿÆïßù@sÝ¯60åêÑ¿©¨¨ô½æ06¿ÒåÛ?©iâUBM	íG÷në©tWË}(pVóÈÇ÷¹¾ßí/è»èG-èØcýÎÑ¼t^:<ð£úÿÂº¸¿b¸/îçûxÑtåCç>>éäüèÏiü¨ð¼ÿ§BwòomicW|ªzp}îÝÒP8c÷åc^9¶òO¬Û¾ó­CùðóøÖ)'ÓÆmíFãgMfæÈb.4]ýùkvQç^q_Ü÷Kûý[±ËsïÔÇáÞ Ø'úÓd)ô	&ìÍ:¤LÂPr L>ïr?Â¢Ð©/©8ÔÂ³;ÂpÊ!víÃãz÷ùëf)îûâ¾¸_òÜ·ÏéÆ×Þós1ÿHßÿePÀ&ÆAy²kÏ»¸ópL2 Å&å^õn(PBÇ#C>OA¥+åhþã¢áBq\$¯ÇKº7"a
wqõyyp¿x#8;irF)¦?ßü½>â¾¸/îûeÂýÔùïqÓÇÆõ[4¦p8"qîÎÖÈ\F.ØÅÏÎügÈ\1käE¢«$_¦xS#¹yÞ7Ësì{u¿Xî÷Å}q_Ü/mî·¶¶îÛ·ÏK9t(±mùûÀfÑ¥ÁèDk]%ôê3ð¯ëL&ôÓ1öÓÎ»JDîr¦æ¿9á-1/¼ü0bþ{¹7wJv»«gÓ¦Mí¦ûâ¾DÜ÷):u²UÔ°êÕ²3ÿÎvÑ32ñÕz¹(áªÛUüâä°6AñÅí@»ßý¨Øêä£Sóßå¾M`Ð'S¼©¼<îÍ²ÉÜzB|Ü#÷¾\wÝuÕÕÕâ¾¸/÷Åýdâ~'+++çÍæ©ÍëhgÆ 7Ûá#hïsûEÏº*Õ
\î¿ûÆhr?Mó?!÷-*¯õÇKy\¾{ö~{n0ÞÖÖV«¬666ºU5q_Üûâ~P:Ï&>Ó§OG #&3ÿÍ§EOxÜgK={1ûô°­ÙæÃë	nû>2qu>Ë²DûíÿAî³«ïkh)R8ýqÂ<\`×ÞOèäÏS>îª¬¼e¼Yâ¾¸/÷ÅýBo?¾¹´_ùß½GO}È]¿»l-ûHä²ûË¾âüeü²Yßòê»ÐÏÂÀrÓ¦M¸84!cÁý ù?nÂ¤m¯½khvº]%,Ì¿Ä½h	SxÁSìÅæ~»_Á{ÑÚvà{ÀÉäo¶Ï9#îûq_Üo÷³¾?µÀF5÷±M÷Ãëaßå>xöAw4YºèûG6Lþ«Äëaù?fÌÜÊï]µ`ICáþ?µzÝ ÁCqÃßÉß?¥g&÷rÄ}q_Ü÷Ëû¹ô
l:Xv°ïÎïÒÕÌÿ\Ðo3ðØæ5aSéÓ§báÂ}úôépÊ)4ÿó{3ð/èÚµ¶¶öðáÃùþ¸S9¶ìûâ¾¸/îû¡Hsss¸æÁÆà»×¤¡¡¡¢¢"¾Ü§´µµåÛü//îûq_÷aÌæØ!ªæüÔ×¤ººzúôé¥ñnþÞÀ÷w*»^©â¾¸/îûåÉýI(æìì°ù_,?O"îûâ¾¸/îGÇüÏ·_¶ù_t_Ü÷%â¾$FÜÏÔüó¿Ä|q_Ü÷Å}q?:æ¿üèÿ¥jàûâ¾¸/îû1ÿeàÝü¿iôdÜË¯zÕ¿Ý¸eÛ+¯ö¿÷Å}q_Ü÷eþËÀ/®|ôç¿àYzÿOÝR³üç¿¬ÿÏCÿÅUq_Ü÷Å}q_Ü¤,]¿gÆò×ëÖ´A¹\òYÜ÷Å}q_Ü¹Éÿ@}ëc+v}/ÐSâ>ûâ¾¸/îKÄ}I!Mþ~ãÖ¼«É3öAùK	%<¾¸/îûâ¾DÜ×äôþ ±ßé¨Øâ¾¸/îûâ¾¸/)¹iëmµÛ¼DÆÃ<y²EÇ÷Å}q_Ü÷Å}I	ûõ%äþ£³ÑÛ/îûâ¾¸/îûç~kk+½ýâ¾¸/îûâ¾¸/)yîC&O\YY)îûâ¾¸/îûrè¿ÿ|ÅÄõ@L\tÕ¦ý)¸ä¨·_Ü÷Å}q_Ü÷%	7·)ÖÁï«0ùÅ}q_Ü÷Å}q_RÜ/U÷Å}q_Ü÷%â¾¸/÷Å}q_Üûâ¾¸/îûâ¾¸/÷Å}q_Ü÷Å}q_"îûâ¾¸/îûâ¾¸/÷Å}q_Üûâ¾DÜ÷Å}q?ßrøðá)S¦L³\6fÅÛãý<XÂ7ÛßóÇ-ÀHñµµµÅô¯û¥úîûq?Ù÷êsÇw[õÏâ«~êæê±ñ=ÿs¿öÕÚÚÚd7¨±±±Ã¾0úúA±ÖQÃ¯ïwó²ø?nnD÷ :ïün×ÞP;÷ãxÚÔ/~¹Cêû"îKÄýÜ?¥ÃÉÿóöñÕ!×ÿáõßÇ÷üÿíê+Ss¿Ç_?¸±!ÖúûuË¯¹ãÙø?nA»Ü·¼;÷ãxÚÔó»v÷%â¾¸/îûâ¾¸/îKÄý|pÿÅÕË 9Rïo¼Íè YsûnñY[uãËýOÌØ»n±­bÙ]MSQHt¸i¬»ï³÷g-XM-÷ûÌ¶L>¯áEw§_|*îûâ~Ir¿öÁûNïxj·®çS	ÐßÖ=Iï¸µ~~7îq½-u .ÄûwÔVÇÍj ¬[BÑ¹9íä/òQ_[1'çÎåÊ7÷AÏ³¿ÞÚãâ¾_îÐqàµ#òK þÖÉºÜG
C§Â<[(vdi?y+TÜ÷Åýä>àûæ¶ßqù×SîÐ·	ù_ î£Â3´#|UqßàUÜwÿÂOTBównýz_î®áì®®8Ü'ÇÓ/'ÿºÎ=[ÔÄ}q_Ü/aîÀ½­¢ K ,³X jeæÇ*Sè |Íú&÷i[ptÆ2~Q>7á7îc¯ÕõÜòQË´
 OÒõ	àè^¤xgn{ñÏûËgNL¯¸qÖ£°	PKh/#ÜÇî\µ
e`
òð-/ÝÁ+6DîãÐÞ?²JÏy°s0c§MÌÃBp)¬å ÷AR,Ã³´©H ÎvüÒ`'Ä^;Âöâ.f¤ûó^¤ÙÞ·r°{DBËH·óÖ<ZïUPí};.bÉn
òàdÜ;[UÂó÷%â~Ñ¹.ÐnÀì}Úõ¥#'7îÈFFòÇ7^1 rMÿÈÃ£01SîÛÑ½¶~+
Æ*ê8=«*°÷åa
È±ºÌ_aµs[pï8ÒÜ'Ýá·÷¸¬{×-&Á>¨HÍòÝ<LA!($%÷­X¨ÕCÂòóó(ìº Xã<ÝÿÈC»$sZ0²ñ¯awDì}óóSéçÍQ¤ülì·ª`p4¿@³yï¹/[Þ±/RØûV>Ë!¸-J¾ÿÒr)æ°æ1?ê!â¿¸/÷#Ò¯
VÒÚõüüÀ´5©»Îyd`6ã>J 7Q FÙËCæÚrXÜ·¢p8Ö+x2¬Òûnÿæ:`ýÄí6½\7H!¹oì£w4oÂ@97aÁv	úù4d~0L÷òxM,Ð%5öb9ÙqhF(Áê¬x¸å»çÀ³r¶ízÆÖ"åçg¿>>	è6£¿®	l÷¸¶ª¬-Ð§ûø5»~û ÑÍÓHÈ}+uÒfË»yH÷`µïüÅ}¸_\îÃ¤5×ms7îÓv¹Ù.÷}6
 p³÷Ãâ>8îzàqè2Êæ	Ý	¹Ê¾º÷ÑØp¹[D#ýÁAg)¸ÏÎó.ÓYm`ómêdÜ7Þ¸ÏVª;¬ k??Ðov&¦épUo NFÛ÷­õî}ëê9MîÛ.}ùh¼§æ¾qÕ¯¦a^}ÏÁqÂ÷±jPyBîë=îÏ_ÜûEoß7ç¶Û¯L4ÿ<Mþ ÷]ÓOî¥aG¹¬idççgßÚédºwDrJ??+!Èä>bÝ¸ÏÙ6ûÐ÷}DKÖÚÜ­}ÜíÁÎÑAî»ÎpÖÜ·BÀzÔMñÝZAíû¶jÿÔZ.<_myÝþ>+9¬x~~V¼î¡ôÌ»^qÙRlÐ~x6â3ÅìzóÓ'ÊIäÜGn¢öx¾ºÿA¦s/«Àð%ä¾?	Ï_ÜûEç>ÀgÝÛÌö'aüÒUN+Uk»­¥y°Êö ã^Xö¼
 26!Ås5¤9ín·|þOU¤xyl¸"ó°râöHÄ¦Â÷ëÎ\Âjæ¨g/;ú[i[ì7m_zþ½<ÖyøkÅ²×j Y÷ë³æ@À4»íY=Ö[ÂÓpÿ«ÖÀ­K°¢$;¦oîèÞ:ð|´.yÖPÎ£¤õ=Åì_ïØç¬aËä>Û¬|fæÐÓÎ& 
õà^5Ö³(VWâå±²Þ.wþâ¾DÜNû~¹ÅëÙÍÑu_2ñú@XT-\Ã¹ñú²½XñúBëWôx};û²r¢q|â¾¸/îG-N¯Ú³ÎÿåÉ}Èî8q_ÜÏNÙë~jë^Üûâ¾âó+>¿âó+>¿¸/÷Å}q_Ü÷Å}q_"îûâ¾¸/îûâ¾¸/îûâ¾¸/îûâ¾¸/îûâ¾¸/îûâ¾¸/îûâ¾¸kî¯yù@åÄõ ¾«HAº¸/îûâ¾¸/îû¥gïO[Üâq)²÷Å}q_Ü÷Å}q¿$¹ïüq4öÅ}¸/îûâ¾¸ÉGc_Üûâ¾¸/îûYü15öÅ}¸/îûâ¾¸ÉSc_Üûâ¾¸/îûüC§6ÇÔØ÷%â¾¸/îûÑçþ#­$¿;æ¹õ/ûâ¾¸/îûâ~Ép¿æÑú»õ8ðþaiPqep}Ä}q_Ü÷Å}q_Ü÷Å}¸/îûâ¾¸/îûq_Ü÷Åýrìmwt<ít*e;I¸ÀíÛ¯ÿêµ/fgl¯¥ËVûâ¾¸/îûâ¾¸ÔÁCA¹¼kÏ»]/ì6eZM2Ë}«]î§ÈûÈ¢ö"îûâ¾¸/îûeËý­-m=bv=ê`=q?}æläôÐ ¬å6mÜÆÕ#«¥ ^Ác:È%YStÚÎçÜËØÄeo¸/îûâ¾¸/î3÷AC01uOÃPf ½ïâ&6RiÐ ÷R.[ÒvíyÜd)<Ìã6IÐ;Ázå¡­cö~p¸/îûâ¾¸/î3÷Avã¾ÛÊO^#e 3!÷­=ÙiîæÙ^
ÍN'£Q2ÓiÈó$tûÛãÜXÇýà&q_Ü÷Å}q_Ü/gî7mÜæ¤ö¸õûd«Kyj0Åe:3¸Ü¢*Ìû<d@"~çÎ_âq?¸IÜ÷Å}q_Ü÷Ë¼_Ml×@Daøø¥7>÷a\¾tÙ*L>s¶pSPVyÜl}ÀxçéúùÙÄÜ$îûâ¾¸/îûÇÇ>r ${î5mÜFz"jøXæÖÜ·T27ÂrØm/b§äåqM~ëògF½Û	N¶xÄ}q_Ü÷Å}q_Ü70Ñ3ðÓÔà^Ù£¸=â¾¸/îûâ¾¸'î+^¸/îûâ¾¸/îûâ¾¸/÷Å}q_Ü÷Å}q_"îûâ¾¸/î««×¾HöFpÙOÜ÷Å}q_Ü÷Åýì¸?wþ¬I¦ZäÞÐ¯¨¨àX Fßå.ÖÇ±~H±ñÉbûâ¾¸/îûâ¾¸Z½9ùÐv'ú± B6(«Ø ·â+îûâ¾¸/îûâ~ú(äxÖç@~÷æ·åØ|woÁx{Çö2Ês)àÙìµrÆ>§´µ¥MÜ÷Å}q_Ü÷Åý¬í}xãQAð80±pÍÜv7Ñ$Í«oÚLn¸w`×ÏOe!fï{³ö¨}_Ü÷Å}q_Ü÷sá¾h×K?·qÌÁµÎÝÃfzû4Çrº~{Ç²¸/îûâ¾¸/îûy²÷]ßÓëqé.÷YC05<+÷tËév&ô<Øqîü%.÷QcÛ9dÑµOÜ÷Å}q_Ü÷Å}NGÚ­`®GU7ä¾7mB:§Û£µÎ& 6Ê#Ï®=ïb	ýü.÷9­rÚØ¥±Fa' îûâ¾¸/îûâ~úJøà)»äÙ=.N¦ÙFmn²®zV§Ëa6,»MüAjãp^»Ûpl;ÀînAÜ÷Å}q_Ü÷Å}©¸/îûâ¾¸/îûâ¾¸/îûâ¾¸/îûâ¾¸/÷Å}q_Ü÷Å}q_"îûâ¾¸/îûâ¾DÜ÷Å}q¿èÜdñ³äë#îûâ¾¸/îû%Ãýè¬'wü÷MX¸tt#~±¿¸/÷Ëû^~:ðÎç×<¿ËÜ½SÜîmZÖôôSÐ§ê¾jÂZ.CÅý(èÐ©ÍwûøÅrì /îKÄýrãþílÀ'ËÕ«î|þOûvûÑÑw64\9a­wÆ=°FÜÉ;Sc_ÜûåÆýW·¿æåñ[äçÎ_°Â»M×<)îGÇäÇ©±/îKÄý2lßwMþû%Ï}Ïä£±_ÂÜSc_ÜûeÈ}×ä©±_ýú\?Æ~	súí1ÏÅúâ¾DÜ/CîÉ_c¿¸o&LýÒæ>ûóûâ¾¸/îÇËä¯±_&ãøhòÇÔØ÷Å}q_Ü÷¹ÚmÕ?öùÞÇþâ¦Ì¤q·|ð(pÿ@Ó	?ù·Ñ×Þüãk®©z0"'}pÂMâ¾¸/îûâ~Úºéùã;®zô8iP¿vö9¨Eû@Û×¾v¶îHB=î³Ýºìq_Ü÷Å}q?MîwèÐA±Äê «DûÖI¨'ùËâ¾¸/îûâ¾¸/îûåÀý5/¸áþ×ß»Úgt#tq_Ü÷Å}q_Ü÷KÏÞ7{«GqöVÙûâ¾¸/îûâ¾¸_Ü²ù­¾·>gÐÇ2RÄ}q_Ü÷Å}q_Ü/Õö}×ä£±/îKÄ}q_Ü÷Åý,Lþûâ¾DÜ ÷ÇÞvÇà!Ã2ú #ÓÆm©óYÕõÂnÐé3g3ekK[ÿ)Ój ifÆY¥ó_Ä}q?v&L}q_"îGû@sÇÓNÏÊØeõÚSdèÛ¯?¸<PdFÕY|ü±/wOGy8q_Ü/%îÃÌï?þùûâ¾DÜ÷.[»lE
¬f¦°2 <ÅªÙÝä>Ò­¶0wþ×Ä®=ï: E"½X¾¢ÁMÁîÌ}¹3@q,f@
òsØrÄ}q?wîÏ­áï9¦"2òNÐÉ|ö¸Oo÷Å}q?¦ÜôAOØp	zb0CAjRÙ z 6;¹Ô"ÅjA'?2· 0m^ò±Òz¤2Ö:S¸l¬- òÀÝYÀ*±!öµÝÅ}q?wî×<Za·º	W×GÜ÷Åýrd'gTÏ¯"ÑõêªLAm»Óiô$þÈÃ&~ËCÏ v7[ÞN9Y[0|ÓGµ¾« ¸ylwn÷Å}q_Ü÷Å}q?a98Ò¨'÷ò¬¸L's­&@w«^ÿ:·@.[9ÈÏÃ±Á7\¦3ÐçIb_dNÆý4{ûâ¾¸/îûâ~rÜôåÙòîzïWÃºyþÉ}Bß3±é°ö},¸Üwy´÷Iy×l§½<+û<\Üí}¶_¸ê¦»â¾¸/îûâ¾¸÷A×L¦N³Ý«ÖÏÆz3Ï]Ï?3ñ1®~óó£LÖ
ÈqüAîód vPvØãC6ý»Ü·­ô	Äûlá7;ZàÛB»ÙO9|Ä}q_Ü÷Åý¹ÙÏ×®±I{«ßÝÑs¸4Á^nb¬4þº6¬9
ìÌg§¬Zg){qä~pÐ¢õ¸HH£UBÏ?6ÐÄûì"Ë\v5+Ui·ÕêçÞø\¼¸¶ÌÝXZq_Ü÷K©__:ãåÖgÏ½P¾$×û´ñÙ7Òèë s·ÆM±ï<;IZtª°)Ä:K¸Éu¡ÌìIÄçN¦°¶fOGp% {Â,ÜseÄûô>±Êñ2^ìêB	¹o7Î4ÖÝV0«?LVû+îûâ~q_'ïoÙàE;±Ä¸ïúùÉÁ ½o±!ÂÊðAî[ K±ÌÁbÝãøJPÛíD¤¯].Y`åaÝ§aÏ[Ùû^,,Å ?Q­x­©u!®ºí;\f]ÎvLÆ}»S|x¼ÚTúÑ/Å}q_Ü/î+>q¹oq­)$È}·nPQQìªû6Xf¾9XlÐçÃîÌC*¹p4z]CM±kÜÝ0TJÜgpdéà;Ç§ð¿ÓõávOµþ®vMîì3ãqùÙgÆî©¹½r.îûâ¾¸/î¸}ßÌjëáRÉ¸o1lËýàP ÷½IÜg;ÕÜGBº	÷]÷;/«Rt0¦u µ!0ÙÈä¾u÷Å}q_Ü]møMÐæ8â~Fö¾¡Ö8>ïl%7¾X
péZç*ù ÝR,s°Ø ÷Çà¦ÙRX`e¦+ÛX¯à!¶^k;6â5'ûÿÑ´·zæfüîç÷zèy)\î32_(ÁLÆý`÷×ÏoÍ1v w ¬µÎ$l¶÷Å}q_ÜOÑÇØíÒ[Ëþùé ÷Ssß:È6#¡;5¡Z2o¼Û4;{âY:fZpEZ¬¶y½b30Ò uI£dÃ¹£í(Ü½÷Ö`mÇ2Ã¿ðÜçìö.ýsç¾]p«íXÏI¯*Åëïn²îìèÑf;÷#Ë}­êåÞ)Ùûâ¾¸/îg¤^Ïdö3_®Ûm,áL:^ÚAH´Þ¶Wr?îÚîDÛcÜwéÊ8>«ÅÙTîH·ÛÝ,ÄÒÉ°ÔÈkªw½~}Ü×=û¸5Iq_Ü÷Åýô5ØÌ>bôú²Ãv²tl¶¤ðÄ°;,%ÃDÜ/üüÂpÇÚå£~µÆÓoäú{ñò&Ó+ÇÖ_öß^ïW0íw.÷©?¼*¬¸=©9Ë=ÿ|Fmûâ¾¸/îgÔa³î¦IÇ¦Ï³¯"ÍÅçÅ÷ßÕúß>}sÍ¦§rµ÷¥WÎ}¢ïo25¾æêSæ®nsõ¡e¯{ÐÉ÷Åë÷Å}q_ÜOØa	àf4?w&ßvgÒa'·¨à/ë¤$îûAîßýÐêÐýüÖÄ¯8½â¾¸/îû®/×Å1û ¹z&îb½¼¬+¸¥¤$îû¡sßëÒ/îûâ¾¸/î»´âû%8Ë¡z&rM ìd±Ä¹»«}_ÜÏ7÷W¼´ÏÄ'îûâ¾¸/î'lÐ'ÊýÜysÍ¤c«X` £<'ôÉël³â¾¸¯ùøÄ}q_Ü÷¯ô0®K!ç÷÷Å}q_Ü÷Å}q¿(Êáüyê¿'îûeÈý§V¯[ºlÕýÓ®=Îtè°áAûW^é¦ßsïÁ©¸Ä}q_Ü÷_Ü÷#¨Û^{sÁà»Ïw.ûÊWÏ©8*_;÷üo\pQßËáÏ7
:~ê,7ýò«®Ef(÷íxúøã(°vÞã/lØ"îûâ¾¸/îûâ~qõuÆÝ>©×ÅßúÌgû§ãO¸°û%øSjæ<²øÙôYLçÖ¿ÿ{^Ò÷ÔPÀuøiU5jâ¾¸/îûâ¾¸/îF7nyí{è_y%XÆWÎüÃîypáòõ¿Ïôé\ëoÚê ¨l ÊqÖWÏ)%îïkLwÖ÷Å}q_Ü÷ËûÞÂ~ý/©§ íjkÛÜóôÀßÞñô3zÿdÉåW]{Ó¤ßübÆK`}2EeUo\p®OÉpÿÃ/a/¼ãXb«\~°e¥¸/îûâ¾¸_òÜ§>X÷4L]`îc©[=zÜ%0½óêÃùh*¨r âÑ«ß°þc[ÿÂ¥£q>C§6/jÜ]Dîg§ç>Èþ^Ó"7«Ä}ëÔ~x÷wÏ©÷Å}q_Ü÷Ëû¦«6ü¦.ö½°û%_üRT.ìÖãúF¢&ÀÎð»÷Ì¢Kv¬÷8
¹rÐ¾¢¢â¯ýÍïT¢²*=òß7Ízr'¸_,Çúç~ËÄÞx»éHÄ&Öö5L÷Åý¸pÿØc¹è¢îÅÕ}ö¸¤z]~ãE=zC?^(öYpÂ	Ñáþ	ÇQ·)®ö0ü¢î= /tû÷íùk~VÇsLD¸¬Ô<Zÿ'¡4vÇ©ZgøvõóÇÌÿtü	Ø±ç%}QÈè;ï7Ð{
f>¸Sc?âÜ§EûØd­ÿâ¾¸îCúÕõ«=¶tÄ=+°ðýÛùí¢ÅSjûë'~VÐþÐîhZ²|æä¢ë-wÏtOíé¿úÞ¸¶Zô³Z3{Z²ëV\î§îß®>ñÌöîÇÔØ¾owÐÏÏÊÀ¶Qg}¸ó¥½Çûâ~\¸½áÞ¦W·¿6dòú-­ø=ðÆëqüyâ~DôÍõË®¹ãÙkãËïlô	GûyRùà~Lýès÷*¾ãÖ¯ÏÚô¹¬~}â¾¸©>×ôÊíl ñ§/~ÓQÚÜþúÑUP¿ó¬øÙ÷¡ì×'îçûÐc»ìkFî¿³fVÞ®¥/îûâ~
¿ß­Ï]1a]Lýrà>ÌüÊñk¡Ñ7öÅ}q?\î+n¸/îçÃäÇ+¾Æ~9p&?nSô}q_Üû°îßkZDcßUöç÷Å}q?k½êçwµ´ûQÖW]þ½Û×FßØ÷Åý¹Ï6ý¶¬ôõmu¸/îû¹èÉëÿðúïÅý(ëï×}Ü¯/§*îû¡pãø8dO~~q_Ü÷Å}q_Ü/Ïñûâ¾¸/îûâ¾¸/îª?ÍùwÄ}q_Ü÷Å}q_Ü;÷÷.ÏÐ=jß÷Å}q_Ü÷Åýr×8ÔyÚþâ¾¸/îûâ¾¸»®yùÀ¿y
îÛ2ÒÅý¹¯ñûâ¾¸/îûâ~Dù]c~q_"îûâ¾¸/î§ßÕ8Fé ÷[&ö¶	w>Ø²2´Gq{Ä}q_Ü÷Åý¢ü1OÜûâ¾¸/îûYü1ÏãþäÉ»wïÞ©S'üÎ7)6mÂjuuµåimmE
Òåç÷Å}q_Ü÷Ë­??Mþû÷ýÊÊÊCayß¾}@?6ûX¶;:@EEE^¹ß:µ_j÷Å}q_Ü÷Åý"ü15ö=îïÀ½ûâÀ´ß»,3«ùã>°ÞnÇ'îûâ¾¸_æÜ¿}ê¬o\pQQô_ü´XN¡}/÷i×ï¹?}útºúAÿë®».¯Ü½/îûâ¾¸/î§ÖUþðÅ/wX°¤aé²URèO«ª{^Ò7DîÓíO'?òçûjß÷Å}q¿l¹¿·iYÓÓOAªúª	k¹ò¼çþÈ'ýèÞ?,¥~å«ç<²øÙ,üüîihh<y2¹ÕÊÊJ,ã®þüqýùS«úóûâ¾¸_ªÜß¯°Ö'þã)ÏÈÞ÷ým¯½)ÜSkç=¦±ïq¶üu×]ÇåC±K¿qË>½ýä>öÂ/Ãò°e%Ãõ+>¿¸/îû%ìç¿`ÇýÕÿñ¸/c?wc?8m÷Êc~~Úøt°wmÿøùm ¿79ï±]Ä}q_Ü÷KûÉqc¿ÀÜÏÝØ1²ªãi§C»^Ømîü%Y}ÝÕ¾ýú³@(Æô±·Ý®bãA§Ï],c?YÜëºdÇ}">Ê¸/îûâ~õësMþûæ~Æ>4syõÚâ­-m9r(Öm 2­é8¡îÚó.q8¤/]¶ª(Æ~.ñúý÷q¸¼r¿ebo¼ÝA>wÏ©÷Å}q_Ü/aîÉ}c¿ÜÏÝØÍg5Àls JR#k®y>bdÍùÔÜgQÌMM·yµ@¹Æò×8ye¯~Ã
§GÄù«Ç[Ò¡.~~·ÞkZÐ	 îûâ¾¸_JÜ7?úÆ~!¹JË>Ýòà²}VhãnyXèô	¸y°Wû(¨ØJsö¾ýÆ%C®ºããàéÇÊûÔvé5÷[§öc×>¾éìã§ñûâ¾¸/î÷aòÿäîå¿nü0·aÑ³@ÖéFmËu×io)Aî£øWîÏ¨ýmïËÏ]Ý6nöÖ¾·>úÏzr'VSë¿ô:÷F|W3Õç¶¼íu7MAÿÇïôìÏñÅ}q_Ü÷cª­+çLym/}á3ÎìÔñÔûÆÜøæÚâ~(Æ>pïºÜG¬¢iÏ*¬uûìàrßzýü@¿µ#Ø.÷çÎ_â¶d­ççÆ!Ö^ï(¸º««)ôâá³¯¿§ÕLõg¾ìqèÏ÷·GÜ÷Åý2áþopÅ·ÿõã¿ég?ß¸å5|Û_Ø°åÚa?<áøÏîéÙÓÊûaûæ®7LÃº·xLÁä¾åÙµçÝÔíûØÊaÆ}T*ì Ø=.ýÖ6þÐ©Íé»úCñó·ëêÏû;Ævy¯iâöûâ¾¸_ÚÜ7ÿâ½xæ£uÁüîýïþð?ãÑ4ÿÀýÇì[;üÈ®¯?«÷-³y\îú¬X/A{ñ ¡û_ùê9w?¶6#âÅýtºöåÒ¯/ø[VÒÏoª¸=â¾¸/î÷~j¦ùoîç#@_(=êuPûsW·e1-`.ÜO³3ÿÜÆïgÑ¦/îûâ¾¸qî·kà§Ö¨ÿùæ¾ôå8f?îg$áÆí÷Å}q_Ü/÷35ðcaþçûÆc¾q~þ5Å}q_Ü÷ãÎýüÿyå¾ýýèsïâñGíûâ¾¸/îÇûocÄl4Y½¼víy×ú»)Å2ÿóÇ}ûáûÑç~²W>ýFq_Ü÷Åýèøôjña8Ú+ .«×¾èu)wS
oþçû2öÃ5ö£Ï}ß÷Å}q?vÜOÑï"Ðç 1$2¬ÛÙËH1CNf6Ê3çÒe«¼@![ÿóÇý/|©ÃY_=çÂn=¢ =¯¼¥ÛÅa¡÷»ñÛí=®øy!OàëÿÜå[}+s¾¸/÷Å}q¿-ø®Å n:ÌÀon¤w«0ÐW`Üg¬9þ¹_0ó?Ü[ÿBÍ£õÑ1¿~rè¤ÕX¸tt#~±Ãª(mî·LìýÁ^ÐùùÅ}q_Ü÷3ê¢oó°õ4ðiïsÂlE¢Ü¬ødÜ·}QaHÆýÿ·¸:tjó¢ÆÝà>~±¯K~¼àÇ ÿ^Ó"Ùûâ¾¸/îû9vÑgÀe:i>eZ³­)¸ï:Õù¿|¸?ëÉ#ÿ}¸ÏIpÄýp¹co÷±]Ü}øÅ²¸/îûâ~¹Ý|×OÈtÒÜm»çTqépßreìùp&?¸Sc?Fq{8/Aýâ¾¸/îûÑÏèîK­2v½Ç}ÆÕUüÎºý]îsÂ¬b!Sîhþ÷aæû15öcaïsÐ73V÷Å}q_Ü/ ÷C²7}ælÂÚfd³ñû6*´ë-ÍÐß¿Não¹ÿeÅ}è·Ç<SèÇ¢}þ±]`àãMÇ¯-ûâ¾¸/îçûy²MMaþìãX³yÍâ>ì}q?OÜoÚèß»x<ë ,Míûâ¾¸/îçûáFÑ£&4ÿWÿÇS?òLþâ¾¸÷=Ý=§
ªñûâ¾¸/îçûþñÕeeà§oþß9þÎç®ý ßØû×<8{SP÷Åý|p_q{Ä}q_ÜÏ+÷·.{äüs¿zò¿|Ï½´¶÷¡Û^{sÜø;O8þøË1û)Pþ¯úîØÆïß¾vÒ«É}hÓÓOûâ~îÜu¯øüâ¾¸/îØÏÿÒðýïpüçüÔêuYsðanèÝvuÊ´ÝK8SÏÖ6vÚïÛ¯?Ãú%³Ïð¿Ð»ùA,i¸üòÊ>ÿOUÃ®DWæÍõË~ýèªkîxvþïlhç2ûâþ¬æåùpçK ?@ïªì}q_Ü÷óÝ¯ï@Ó'Üó¿Ói§egþs0~úa| kä¢Â@ sÈ¡ßñ´Ó9¸£ùÎéÃMÈÌáüV=ÈÂÀ?ùË_¾ä¢\mdÎ¼i¿$¹¿æå7Ü¿ñú{7@ûnäR.îÅ}ßOÊ]q_Ü÷Åý¹»ùò2ô®;gn0Å2»÷wíy¿°ñ±Àpý.ßmì?'öeàFøÉÑÀwuÇÚåi¿Tíýq³·ÂÒw)²÷Cä¾;~_Ü÷Å}q¿¸q{²0ÿé´wíw7Ì<ÿ< t7óÓ]M	]Hg(ß­KÐÞwÊÂÀÏQKûO6¿Õ÷ÖçúXF¸®ÿ-+9OÜ÷Å}q?"qzÓ7ÿ]?¿äéÌ÷\ôµÍÚCsÞüü)¸ïy ,=öýÔ>uïºÅá¦¼¶bR>íû®ÉGc?!÷÷íÛ·iÓ&üZ
V:äæAJþ¸3ß}{±ßUä÷Å}q_Ü/
÷Ó7ÿÝNw¬ ÇtPÝ^.ÖÙÏ}Lv0?ãýÝ:@>(ÚÉ_\>s²¥\xÞYîWÜ7?¦Æ~ûÝÿ*×]w_QQÁe{¡úsá~B÷Å}q_ÜÈ<¼)Ì×Ónö>§ÍuÃó3sÕå>ÜvÜÇ!ì(YøAýå-ÃÁz.1dèo§ß5ùcjì{ÜÜ«««Ý:À¼yóÀwÔ:uêdéÈÕüq_ã÷Å}q_Ü÷SÿsÇú¤<tÓÄ¶ï³ÿòp+Yàè<îk¾dö¾×o0÷ü~½/ñ7>1Ã* eË}ùýÇ?Scßã¾w}ûä>ê Þ q_Ü÷Å}q?µùÿðìßÈ®?Ë@|²qýÈd{þ3ÞÎ¡|	[l/×ÞÏÎÀOæíô]¹Ï+¢!9áôÈËåW]ûà¸Ç}kÊåaøÓÕÌÕÕÕâ¾¸/îûâ~^Çþd/Ü.ú?R¦?OÜ?ã+g?³n"(¦£}¾sÙ¤9©¹ßÚÚûæ ý÷íÛ'îûâ¾¸/î2ô_XcðsÑñ#@Å}P,ÐÓQÔPGJÓÏïvã>}:L{ã>ßÐÐPYYIW¿¸/îûâ¾¸ó?Ocð£Ã}û¡û÷z èG"ªø5îcÈSHîïk01ý ~â¾¸/îûÑÑ|ÿù3ð½ú¡Eá~ý­-m¥?§[Qc?8oÞ¼y°èA|Ýüÿ6X+@
ÒÀý`¼>_óòûâ¾¸SîhþÀÀN¼¾|ûaþ):a¦9íB¦ÑójìG6^ß{Møj9´ÇS$jü¾¸/îûñå~æÁüp?Æ¾'ã+;@¹ïûk^>ð`Ãëyåþ¡ÿþs(Üß1¶Ë¾iP¼Ý\p5}èûâ¾¸/îG_Ó4ÿ£oàçûù0ö;vúÖ67F=Ã ôí× $2Ä¢kòc+ê,3#[¼ÎÅÀQzU3¦L«É_MÀ}ÚâÊë¯¼ó<q¿éwo¼ãÒõ{
Ð¾¯~}â¾¸/î÷Û5ÿãbàçûù0öIs7µò[$JNhï#Ã"æXgh+)fï[:'JÎ±oÄç$ùà>?±nûÎ·Þ¾Ï°½¶ð^Ó¢Lkâ¾¸/îûñRÿwOóÿúQw|là÷èV3ibìþH(ÜÏ±oLgæyEE7RÜPÉÁé°Éòcu ÚûV`|Eré¨' @wÖýïVÞp×R#>õ²ñÏßùW\í1ðö;i¬[Ó>Øðú¿Þb}¦àû.÷ßY3ëã¾SûíÛÅÞ÷w¾$îûâ¾¸_ªÜþúÑUó¬X=ÿáËn^«eÈýüÙNRÌùëz RsÄÈ*Ë¦»Ü§oß¸Ãø6±r>ý¯wÑ¸Ù[ÝCçþÔ¯^5©©ß¸uÔ·2¶¸ÜÇÛÍyxñåm£ÎR~q_Ü÷Kûo®_vÍÏîX»¿\~gCCr?cö9Ìé9"ÐÌDóØc7Ùq(Ç2é¹~~ºñQâöë£g ß-ûO6¿åÒ?t?ÿGþËÒõ{Nm±üõ÷ÿôQ¸~~ÀÝÆñ}°e¥ùXHßÛ/îûâ¾¸S
â»ÆþÆ'fì]·Øò`Ù]-1îç;@pëgmîLÄ/ûòî®ÌÖÍMükÉíh31¹s$yò:fßè§~}Fÿpûõ¹ÜgÇ~ãþî9Uâ¾¸/îû%Ì}ùã×B]cÿÂóÎr§ÃË4^¼¸Ç }î¬AEeÀk\È÷}Ðÿî;ò7ôÇÑC÷ó¿³fÖ{M³¿mÔYÜ·clq_Ü÷Åýæ>MþKG7º-ûä¾±¾¹ÓhüìË¬'aÁýôçáÍdÍý5ùþ¶¾±/îûâ¾¸_}õÙåW_ë¶ìsÜÓNþâÆ'þÿöÎ¸ªêÎã PUÑV`«®gã"ÅqRv+heeF»D×?a7du1Ll±t»Òª¨3dB×¥J·o)¦¡;AV&Ð¤.6aeðuv³ãd¿æ¬Çã}y{ß»ïÞÏgÎ¼¹OîûÝóò¹¿óÎ½oS´½ÏÓø}|@_qyßåÁûxïÇÖû¿Ûûñ¸>w¼xáû/oµéíª÷ùé½àý¢ðþáJ%ûg»÷¿»cm×ºêa%ûxïã}¼=ïkbé·éGÒû$ûÁ%ûá÷þñÍØyo[³¤¯JN·oÇûxïãý8{ÿÝ½;®¼ârcÿyd?Ðd?üÞ×§ÛXÞÞ»§+~ïã}¼oï«¼ü½Õ%%%Ñóþ­ó²[ÿzÂ¤«4Qyw^/2óÊÙË
x<cÇmùQk¼ïÞÇçÞ³oúüñ>ÞÇûx?nÞWoFôòÈ½ùåÿ]ð-ÿØýðßýVsëz]º¡c{â":~¼xïãýâò~Ï¶b\/ïÛk ¼ï{?¿Q¼õ¾ù~~¼÷ñ>ÞÇûJùåý"MöÃï}cyI_só¨^Æõá}¼÷ñ>Þ/lÊ/ïi²_÷ñu·,ñí/ñqÞÇûxïãýÂ¦üò~&û<·ð>ÞÇûxï·q}x?ïÝP3dÁûxïã}¼÷ñ~$Çõ¥Ö¦Ù«ïã}¼÷ñ>ÞÇûÅïnßÎ¸>¼ï_8qâoùZý«¯l(Þã¯ø³k3{Ê/«ÿö¢.+»æñ]Å{ü:çôþÌ¯Ìú®ÈûÅxØ¦\þ¥)E÷ý¾.õ¹ï5æÆbæk«v¯úNSñSSSOÐ	Òi*Þã7ÿö3L&ô­ÉûþìÐûî3|ð>ÞÜXº¡ãäûýÄ!Ìèé4"ï¼y¿»e±ò}½â}¼xïÞ÷Só>Æï÷ñ>à}¼x?zÞïmköÛ÷ïã}ÀûQõ>ÏíÁûxïã}Àûññ~ºçöØrhÅ5xïÞÇû÷£á}ûÜûå¾sìÇûxð>Þ¼_,ÞÖÏvï·£÷»ÖUnß®%äûxð>Þ¼1ïn¨TjvîãÃû÷ñ>àýèy_é¼Ïs{ð>ÞÇûxð~¼oR{Ï{æbçôâ}Àûxð~ô¼ÿÞ-ÚëanÞ×¤Ïïòà}Àûxð~$½¯¢|ÿl÷~3_<·ïÞÇû÷#ì}Û÷ñ>ÞÇû÷ããýã0ù~o[óÑ5ÃêäÇûxð>Þ¼_DÞëµ\o¼¯k ÓÛ÷ñ>à}¼x?zÞ·ãùí½{æ¦~%þxïÞÇû÷£ä}÷þ}÷}îß¡÷¿¾nÔR³zïÿ2¯>±è;û¾ÞH	oYÔøkµ·´|çÿ .Âû]ëªô~êMýx?ÚÞ7êIÑuþsm¿@ùûW»[ß8A	yÙó¯'ÃÓø)¶üÇ{ÿêçîÍ@>ë}ó]ÿáJ¼+ïÓ¿ ï®~óK|fbXÉ>ÞÇûx  ¼oÊ»;Ö*Í7OíË>ÓÇûxï £÷S§ï?¿÷ñ>Þ ("ï¿óã:%øJó=?¹«ûøð>Þ ÷ÍÏñØoöo~Àï?Û½`ðgzÈ÷ñ>Þ ÷ÝÝÓtoÔ§òîµ|¿÷ñ> @d¼oÆðÛñ{vH¿ÒüáêÃûxï ÷ÝÙÁGôó{|xï ÄÄûÙäÃûxï à}Àûx  ïÞÇû  õþóT^ÏCzMáþ}¼÷ ¢áýC+®émkÎ\¸ïã} hxßß÷ñ>Þ Àû÷ñ> @ÐÞ_»víçÎOï_yÑy&Mj¤³³Ó=ªmÛ¶å:¶¾¾>»\ÓZbViwÆOèêê²Ëûûû·nÝjoÚ´)LÚU===MMMfUkk«[["°µi3·6UbkÓ¬[ÝE»»µ©r³\Î­MckÓAºµé-ØÚôÖ²Î#<2zôèÔà(¼¶6O¨mpTÕCp²	õîÝ»ÝÚ4;à¸¡÷ÝP»ÁQm¶å¨¶vè	NpíÐÛaºàä­ºÁÉ;ÌjÚaÁÛ¡µCOpÒÚx_L0¡¤¤¤ìó÷ÝE¤ÿ×/ù,6þ:wùÌ3íÑjÚ]e®XÌGÆ]>nÜ8ûëêêÜU.´'eòäÉCÖ¦X¥«M»Y6Ðfî*Û6<oGÔ2Om:Ôtµå['8nmàØÚrNö¡¶ÁñÔ[plmò~ºÚ|íÐipí0]pòÖ3ºÚaºà×Óvè{;´Þ3fYõ×VN,IÁ_W&îòòòr{*5í®ÒöúÍS~mm­»|þüù6øzïùÿ«?j¯qWéPmm·c¯â²Nþ½}¨íå·&Füx?bíÐN íÐ§Pÿoóßõ~ÞÚ¡N¡¼P;LNÛ¡íç_¾|¹Ý Põ»Ò?~|jGÛåéëp»G<}¶{ÄÓ×ávx:ÜîOíñt¹Ýt ·ÎÓdß§ÏÍíòt¹=QnGPæàè$~~OpÜ(O¨mp<An7]öÁÉ&Ô>7ÛM[pÜPËûn¨Ýà¸ÝtÉ,vè	NpíÐÛaºàä­ºÁÉ;ÌjÚaÁÛ¡µCÏ·éBíë»àü1cKGª~Wú_PÊ¸>Æõ1®   ãúÌxþçj&§~WúÊÇ3ïã} Âz_vHý®ô¿yíîãÃûx  ÞBý®ô5Íýûxï ÇûþªHéã}¼÷ Âã}¾1yÂØÑ#T:éã}¼÷ Bå}w]fÕÿ§_8ï~qXÒÿæµÒIïã}¼ 6ï{Ôù1Ù«AùøÒÇûxï Ðû¹©ÿÒÇûxï ÓûÃU6ÒÇûxßN&ûç5$æ×\æÕ2ÑÐrÚ @ÎÞÏ^ý®ôWß|¿Ã÷¦fí^eúnÑ À½oÔ/ãgP¿+ý'o¹8smxïûÂoòx_Kh  #÷¾\NýÃ>ÞÇû¥ü$û  >z?ú+}¼÷JùIö üõ~ªúçOÿüp¥÷ñ~)?É> @Þ÷¨?éã}¼ïÊ¿d  (ï§ªXÒÇûñô~OOÏÄ/,	i7Ü]2¦NL&i ïõÏ¸tì%n¸ýáî÷cèýÇ«{êégN¾ßòË½oVTTÐ, JÞIÁûqó~__ß©SßéKÆÄûwÔ,hmm¥Y ÞÇûñô>É>  ÞçÄÄû$û  xïÇÇû$û  x?ÌÞß¸qc"°³Að>É>É> àýHzöìÙë×¯·³ëÁû$û$û ÷ãæýßbWõööjöèÑ£fÖL¸ÄÜû$û  x¿x½o¯\¹R}ñÅÍEiÚl`Ðõ Þ'Ù ÀûÅë}eñÓ§O7B7½fMæÌMÛÚÚ
rÌ!ô>É>  Þ/
ï+2ßW¦/¿Û«éEZUNþpzd  ï÷Mg¾½ÿþû7nÜ¨¤Þ$ûÊñåMo0ºÇû$û  Ñóþ;?®¶÷åw9Ýôí¿wi=H¼^³Z¥KÍêªÀ|ã÷Iö ¢çýÿýÏã*§Û·w·,ês{¤u3`O¯v¤oúüííü2¾ì¯W;{æÌ¼ïc²¯<zç®×ìì=÷.k?phÈ-ßêêÑ«ÖjMh¯ªg=ôpÉ> À½oRþ?ü¹ xoÏÃ<¯¯°Êû>&û_¾ò*éÛÎjúõ_ý&|õzìÄ©¦æ³åÆÍÏkd `äÞ7EºwÇÚ³Ýûe½fßÿï¿u,ùøN½â}¿xÿ¿>Øôó?tä÷>~³/ï+·i»õ¾²û5O¨ô_®×z5Þ7³ÚKY¿í.Ð?ùé+$û ÷G2®OêW¾oSzÛCîýGNËøsë*xßGã/ÝÐ±sß	¿Ù¾¥réÞèÛx_Ò×$®¢$t-ÔwÂäûfÂ~Gà~e@² x?·Lß¸Þtõßüfµ*ÞoûÔÏ0ÆÇû¾ÿ?ò}¿´n¿¬·Þ7¾Ù@r7_è~~ã}·gÀ\ØªHö ï×ûöý!öébà)A¼ÿÝu¹Æ§øRî\ûkwvúßõäz?ñ[Y?ôp±¹lk{ì­èÓy¿©¹E;êòÀ÷1~$û ïgþ*_WV\C¾·|ÿçâ}7IÊ5kò}+q;ÎûfZkÓÝ@² x?ÚÏíqí÷ý²ÿZVTßýäúfÝêzç®×JJJdsó¿éÐæ>3oHïKÐîM$û ÷Ïéý®uÕJó3mSDãùýñ¾_(Ù¿bÿèóÜµçæìZå®ýÍ¬ÙÆÝR×ææ>} Àû±õ¾á?Âû¾Îô;qªaÍ$û  <?ZÖûa~¿½Çd ðþH¼ßÝ²¸·­Y%§õâýy§ñ DØûG7ÔØ;÷mÑB¼OïóÓ{  Ñö¾¤º}»}&¿&4+õãýxzd  ÂÞW^?¤âµ°¸Ï÷IöIö ïçìý³ÝûÏùx^¼=ïì DÛûC*Þ\dÿk¼x?Þ'Ù ÷íði¢·­Ùñ³7òöwyð>É>É> àý~'ó|ð~¼O² ïóÜ¼O² +ïn¨|oÏÚw­«Î~$?Þ÷Iö âãýã°ëémkôUÉéöíx?>Þ'Ù ÷¥{cyåûò¾¹P=Åø»<xdd ð~÷ï[ïsÿ~¬¼O² ÷ñ~|¼_VV^ÆH$h` [ï~~£xë}ó?ýü1ñ~xèþÃ= ¹õ«yÝÿÖþö) ¿Þ77ë1÷ò0®ïãzyß^  ¿ÞWénY,ãÛÇôqÞ/lÊ/ïì ç}Û÷CòËû$û  Ax¿k]uêïïZqÍéöíG7Ôà}¼__Þ'Ù ð×ûÒºù*ß|­ïyã}¼_(Ì¸>  ðÑûf _o[³ù=>3O¯cüº[ÓÏ÷ñ> @4¼¸¡R®Wjoôõkw]ðý>ÞÇû  Qò¾û¸3;0Øá?¬4ïã}¼ P¼Þîí{xïã} âõ~öùð>ÞÇû  xð>Þ ­÷{ÛMyoÏÁ}vÊ¡×à}¼÷ "ãýÌû÷ñ>Þ ÷yN/ÞÇû  xïã}¼ ÷ÏéýD"ÑÑÑá9ªd2¤««Ë³JKÌ*mãYe§ÖÖ××gVõôôxVuvvUýýýîrÍåÚÀ³*1«T­gþ´Yîíø[[jp^zé¥ÒÒÒ§°¡÷j9k©oÇßÚÂÚßàÐi9Çz¿¼¼¼¤¤äÑ/Ìô_8yTÉ§L6ÍÝ»w7Î®Z¶l=ZMÛåÚF[Ú5yòd»JïÅsëÖ­Îß)ill´µUWWÛåBäÖ6sæL»båÖfBgÐfv¹v·qVµªÜ®Òµ»è`ÜÚt¨öÔÓak³':ûàlÛ¶ÍzwÈPk·¶ºº:[ÛÂìCm´&rNºPËûnmz¶6½µ'bíÐN íÐ'oíÐàÚ¡'8Ùzäí°¶¶6?íÐ'oíÐNpíÐx¶Cã}]H|Ú®*'-ýw]vÁy®ö?ÆFÒsöuîÑº«ìyimmõÔf#é/÷¼è\{v±çÅóÑöjÍ=_îyqè9/ó%l3s?îyÑÁ{vÑnpìG@Mj÷£a>¶-¹í?ËàdjûÿÁóÑÈ-86Ôò¾»\oÁþ»sÿ©æµC78¶C¼µCOpòß3ºÚ¡NÞÚ¡'8µÃÔàÄ°Ú|Ö¬YùQ¿¤?aìhóJKKçÌ£ø¸×Bâ_=Èüùóí)6§LKÌ*mc#¬·³jÕªêOhjjr»S,Yb+VnOâcwQm6ÂªMÄ®Ú´i[*±µ¹]1ÚÌî¢ÝmU­};Âóa·µé ÝÚôì.zk¶¶ÌÁ©ªª5j'8¦ØÚ<¡¶ÁQmnpT[ÁÉ&ÔJXlmÐìHãZÞwCíGµÙ£ÚrN~Ú¡@Û¡'8þ¶Ã!Ïvè'ÿí0s¨imàD¬ºÁÉj÷ûýóJG­~WúJùoºé&X0®q}  ×· |¼U¿¦ýþs5Æþ÷~Ù%çÏ¼ñüxï Òû²ó·*þ$õ{¤¿ïþ+¸ïã} {_¥¶r¢¿êO>÷ïã}¼ ïû«þ!¥÷ñ>Þ ÷ýR:éã}¼÷ Båý«ßþKÇºÒÇûxï Íû#Q¿+ý¦|îÍåSx>?ÞÇû  !÷¾Ê£7~úà£ùÓ?jðÔ²áöK2Kïã}¼ Nï«<yËÅVýé<>Üñ>Þ9|øÑ[Ç¦ÈûvúÌÿ|H{  ÈÙûÙÛ<û+¼÷}áÁgÈønYü·íº =  ÄûÙ8}XÝxïûBûÛ§<Þß¹ï `äÞÏlöaIïãýR~}  ½ÎïÃ>ÞÇû¥ü$û  þzßXÞ®¿úæÜ{ý²>ÞÇûA¤ü$û  Axßs{~n7øã}¼ï{ÊO² ÷SÕ?Üúáýxz¿³³3µßMìùç@jÖ1Óº  ï»êÏá)¾x?VÞïïïoll:uÚu3*fuN åæ[ªYÇ|é¥{¬.LÒÌ  ÎÞWùå²/í¸ë²vÄûññ~GGÇÇë×8xääûýÅXùýSO?suYÙîÝ»ii gïç\ð~L¼ÿôÓO¥²ê7©ñ=ö¿õ¶¹µ¼Æ xïãýT^~yÛ5"`|·,ð]ÌÐÞ  ïã}¼ïÒ××7cFrdÛÔÜÒ°æ	·dÞþØSÚÅ_ï¿Ó¼nFEWWM ð>ÞÇûÅoùüunÕ³î¨Y½÷_ÿÕo´ï)ÿ«¯ï½¡ª& xïã}Òá«¯.ó]¸xªëÛ2Wqjvç®×ð¾Ê­·Íe à}¼÷+ëWçÇû¶@=\§%fÚ¼äýg7þð¾ûÑê  ïã}¼/äD1ïùÊ«l1µð'?}ÅäøÆòZuìÄ)Mhy@Þß¹ëµ94` Àûxï"'ÊyË÷m¿¹÷íÚn(8pðÈÔ©Óhu ÷ñ>ÞøxPßÍ?z¡àÞ««' |¡} ÷ñ>Þ·ÔÕÕ=¹þ ¼ïÏìÄ©Tï?ôpÝ=÷.ÓBMäý­/þìÎ;ï¤Õ ÞÇûx_$Ù_ã»mSïß7wèoóU6n~ÞÝrç®×ìË{nÝºV xïãýÁâ¹º¬¬xÈ¹í9©w×××G« ¼÷ñ~ )ÊÝßZúüó$û ÷ñ>ÞÿË×6ÿþË¯´Í7ö xïã}ýýý7TU­i|*2Òö¹Î¨¨  ð>ÞÇûéÔ__¿*?Å{àà[oû÷-K&46 Àûxïg £££¬¬üºÖ­\Y¿ºè|êÔi< ð>ÞÇûÙÓÙÙÙÔÔÔXèÈi` ÷ñ>Þ  ¼÷ñ>  à}¼÷  ïÞ  ¼x  ð>à}  Àûxï  ÞÇû   xï  ÞÇûx  ð>ÞÇû  ÷ñ>Þ  ¼÷ñ>  à}¼÷  ïÞ  ¼x  ð>à}  ÈÙûcFóV&?Zýfðë¯¿~Ô¨QÄ  Ò¡ôÐx?LÎ7/ºjNïê'  ¹^Æ§ß   >ü4vJO
endstream
endobj
171 0 obj
<<
/Type /XObject
/Subtype /Image
/Width 680
/Height 666
/BitsPerComponent 8
/ColorSpace /DeviceGray
/Length 462       
/Filter /FlateDecode
>>
stream
xÚíÁ1   Â þ©g
?                                                                                                                                                                                                                                                                                                                                                                                                                                                       [/
endstream
endobj
2 0 obj
<<
/Type /ObjStm
/N 100
/First 819
/Length 2354      
/Filter /FlateDecode
>>
stream
xÚµZ[SÛH~÷¯èÇäaZ}¿LQSEÈPÙd­ÝÚ2 /`¹d{ÿ~¿Ó2²e[aÄÕÕúÎ§sésNË	fÌ1)$LjoLy¯¸Á0íé!0SY¥J1ë"S9arÌiËTdÎõÒ1­·B1íY0¸XHTq`Á2c!YifD°Æ EÁBÏ¬E1`ô907ÒÂèsÀ³x<«ÁxÖnÒ)°ÃÍøI:ÈóÀó(¤dxÁ¸A ^wP×cJØ'ÀCº¤w,j¦ÀM(z&¨ByË"ækD¨Í5 E+#=-M3ä	ÊR
"0­` ($ÍàA´ñ¤	{Ð%Iê4;¸ÓÛ%´)I0Ñà$a>cFa@éRdÆÃ\ª0t+ð³$³JGê&­7 µévÚ¦Ûal»¼,@:S04üJÊ¾ÀS,àlô©1×Èø@öv>ÀH¬ñBYáL	ñ
Áa?EátCf áG>tªÆ@.ùAÁ%<)(2¯µ,h<aí95&ÁëàR.XvÆ²ÅyÁ²÷ìÍ,ÍÇÅË·ì·ßo¾iïðñß'tÐaN¾ÓaAQ}u\_¼Ý*Dm
yGauKë¦¸EÍ#	þ&¨oÚü9ät¸ªyMêoÝ¹êM®éðHi-$ÑüT£Îj!gÛ¡Í_~þ¼'õÏé¦û4µEöâ²ßfì³fXË^¡{ [{¾öD{ZÔ}´2SÍò´°Ùö £Ã]S_;Q§Ãrx]§7KÄ6ÌÏ-Ö-\nQâ?jÿÖ´ÇMßÎ;¢ë-6OèM[Ê¢[Ð¬kñð/Í ^ÓVñ¸Øn¿¯fõ2RÖ§£~ÃuZ¬qX¯/ß[?·¸yóTÿ6×¬ZV9ê¾-ÿ\ï¿gÞ¿$bT7¬»XÅö~$»ÝM3!\×VÉß+Ûm-~ºg]2[Â&¯kø!ÿk·8×ÝY-â®ö_ög·ÕÃ7Ñ½\÷¶säþ¾f©ðIÎjnH×âï¶%J¨ßâ·E}¸kÏl_Q
vÊ²ãñüã²óÇiÎ²/Ãë|y>ÏP
:ÈNóY±(Gùj×ôËïù÷ñð]ñ}¥)Õêb ·âN¿w8@úJe1IEULÃÅ !7Ídïò{^&Dq}ÌN²# Ú» 
£9ûªç5­SXÚÐdhc¸CIç´çÆÌ;[\Î}On³Ã$!;LJËÎ²ÐçÍÍ|>ý5ËÆ³|óQqÿ|^HÉKPQFËªd#©§Á¹·/dT×Ù¦wãÙ<{Fîýþø÷PsFÄ{¬õ¨Z'»»mSÝrª¶\Ã:©Ç°8#?9¦.]àÒA¨eB£·<	éNP3¥Eýñùò¤8¹GçëK_ÊbtCOð®÷Ç,;ÏÌi<íhÝÖÝOu÷£¶áeþG=q¢+RT£¬FUºM5ÚjtÕè«±ÂªðT§*<Uá©
OUxªÂSªðT§+<-wDLå[,9W»·Êtòä­Éa<õWðÒÔ×qIø¬tÈv÷;}r@×Ç©1ÁqÏr!r¡äNªº`èÀ:jJ¡³îF¾Ô×z®¨YÆæz'Ó/85åN¡3Ñ´ßªK+ZVÚIl¶G½2G*Úá+D­÷JØýTTÿT° kE»#0	Ò«Lzt¨¹E±!ðåniÍl³ÄíTÚZ»^ø`ãF0íw	,,A¹EÇVBí]a¿tâAÅ%(iÃë`:ÑQ¯@Ç¢þF.UÒqc`.>OuÓ~:: drÀ
¹ÜXULûÙW`Äc½r÷`úÍÊnº±ý,ä(ÁBªIëLÇÀz×Ë²VÀf%<ZêQ¯X&
îQ7É xDiQ=V':¯ @Çvà4Þã<"Þ»içË 'TG@3ã=÷¦v^!²5<ÃVÞ6g¹Ý´c{ÏÆ`Môr@sØXÍÖûÓ§é½Æ2¨!$mõszb4*à`wVX¶w:F.¯HºÁup»ë<×?XV¢Iá¬QWHwð=:*ÂË?ST÷Ó-tÎ)OÆÀm×ÅÇ«¢C\Þ\ÞÐâÒK´®ípsnÕ8¾÷»ç¢Å:2oSoiezãå:äç45RÍNzk¼§3¶r£36?¹3ó¡,ÓôÖm­Q6UãiªÆÕT«©[S5¶¦jh{Þ .w7àÙYv^'³)=²ìè,{ÿ9å§Þ±ìÍËEÞO)~mQ¤[M/\8=½Å¤âÝìñ©sFIB¦&¢«\´ô´DXþôvY§P7Ðzíkïþí0ÄH ×þ5oz«M},CjT©¼û¹Í°>ï~)®®Æ£ñðn6§íºìð²XÌOÎO>eÿºÎÇ3úÊ³éoä!mKtWÂT£@H§(y¼µ/d~Uïó¢¼¥½ñí8;Îóë¢|üõ,/)þûyCBy9uÄdÚ|D8çehïÑcmã0økrOá=þäCÁBU7Ö3ÚâXsJ`ûó.O8QÒ*¸"~|W<nå¼¹Jè<swl¦®Ï­DMï±ìw °c©ÎqúÓBíÜ­Y¨±Ó»¹þ`ÓË®siËÒ­öQmµêª4e«}UW¥5§ûÜOU¨g=Ö{O[fÇF´a¶«¶ÇÓPC­9J<þµ ·£Ä³/ïÔ%æÿ°
endstream
endobj
177 0 obj
<<
/Length 2354      
/Filter /FlateDecode
>>
stream
xÚÕYëoÛFÿî¿®m¸|ýrHÓ&uÐâ\[¸âàæÃ\II®ÂG|º¿þfvgù²»npÀ¹ÏÙÙß¼V®³w\çýÅ×ïÖÜIXy³Ù9aè2qä³µ³ÉÛE¸ü¸ùpñÓæâó]®Ã0bQâÃ"¹<pÒòâö£ëd0÷ÁýÉÚ¹×+K'HÖ,%®S87¿]¸sù±{!óÀ}Y-W^è.Nª«Mk·äîB,=wñÿ©:o¥/ÿnMOfy«êeà.^±k%ÑDJ.½pqo:e^u­lìâ*£aQ!ÕÓdélåNÕtvÞ~·ÃÍ¤ª<²Ù+;k¾Rw´¤Èïð"õCÞ|¯¥lÅãp$³ò\ µ0þð¼pºèvºîâWQbm^í§<Î¾vV<d1¿Næm-%I(åQä{R\×4YxñN{ª8Õ6/¤]^ÉS9»ÀÂÆ|{OÜï­ªZ{ ìjFÖmÞÈRV4/ö²JG*¢iý¨ª.
Ì$ÚÝÑ¢ôZåm.
C-òªÌ½hJiTr3æî@¡µÍ¤ì¹Ü[¹ðçÃ2þ"ÎVE6Óåiª%`zÏÒÆïË5ÝUG;AÌ±V¤ÕÕ± I½ï·ª,­ÑÔ²§`u«0fÁ:$hG_§wÕm<5ô®e!Ú\UÍ_°1 ¯äàWhè×ø¯ÿæÅÐÇÝ=´{èO,­Öão&êÓ3ðêx#ÐÜµC^ÎåQ5M¾-èdx#f?Û(ò¦mz(ÖS7³«¥uuoOj7CîÙ¬Á3õöC×äªCÓËäp«BµyO ìZþáº^%g<ßÏ
ªnwªÈÝ§­YûÓ7òKr#Ü ¹æÎöbð4¢ÜÏÕf£ÝËÔ÷lE>xøÞÆMìÍµ¿ßUZtÉçGY+e9õÃE-Æ®¼ÇÚu |eñLîp«¿`:IðÅÈx#úÿ3GÂQEÑËóÁÁSÅ\nµ÷#uClE½äëÅÞ(oÎÀõGàÌxÊ©ø'«HOUãÒ÷^BÚ Ä ð0¶'ÐH|mO3
 ,ãEiAýtB Ñ?Éïp'Ã^aæ(è¸Çæ!Ï7<ë£¹äC/öLgß²ü&´ÞDµßÔµüÜIÛw] (!ÝCÖTgó7é ÜÑÑ°[o¡íÀhô÷Ç3¬'ý~!ECÿfýØ±P¨öSyN;=ßùØùýsÉ9øä¶¹	Aãµ!´þ®¥ìtæ+?bëÑÞ3½«UùKgþ£Êk§ÒÎº()ð(p¿sê*îÞ)[YM[ëiûÈ5Ì=,úDQáfÇc/8¤Â+ö_Î|(ó2/å@õÞ8­ómOÈo1ï¤dßp
^ÿA)Ì0¯9pLèJj×4ÚhmË$M¸ÜÂÚ[æSÊö Ò,Ôþ4'p<Ü£ØÔÑ)|'wEê¦QW{¸D7}Yl8²2Ê8t4xÀ(î'r Áßç¨!£[mg8QªL4³S*3£µLó£¤áOª5æ3@óåÊôðøM±Þd¶8
UXVûyõ@²y>;D;´j»«çF"3#²hä9ù®y&ð]>V£ªðÛ5r×f	¢ÇHS´ÝÎ6K`¤#jâ´Bcq;\níJÑá¥hu=÷iòø1wh/Øæ£oç¾ã[ÈkõgÀmûF	ÈÇxù( bGË¹©V.	{Á¡"$)ó5zñdxó8\l6ãªáþvGhwÀDïÞPÓþNo%µ ÌÀô}sóc$ ícDÃ+ÖøòÐÐ~}_øÌ7'ÓJUQ­29 ï}%¬¸§o#í@ÞLëw|)ËïÀ²\èÍ%|>½_ù`</Áü5°ùkªÁ£&$øèh¡ï³GË9¢Ús¯%¢J%÷[¬¤Q·çPð@¬¸ækùDU´%ã´à¼º¥¦uJþ,ðg0¾7t)i­´wOØ¸ÛÆ<=ÂZ([*É`«æ´Þ;¦qýÞ¼tÆÌ×)ÝÎñ"yQìø,²ÕÃzç/£ûóa9)3.eÀO·¤A¸÷FêÄD»r7dáÚóHR«ÈÃz
ÄOº}Ýo8ñ ¯c»ç3d#æ¯´àRºÑÿ7ýbÐÓkA@ZÂa`t±3 ¬ÉíáJéí²à¹ïìe·'J7üX¿Î<-å;e:Õ¼räÇæhGHu^õïÏ¶h7ÒùÈ&^¬Ä*æYp¾»í²ééÊÞ#6­Ás]¯÷ÂÿBùã
ýÓú¦--59f"XâA¡DïÓ<«8>ÒCX®töéMR?nÒý¼ïEó¬MïÖAH63t6BÜÀ÷¦º=kõåqÛÕ¨J°Û<PC%âY£ä	óþÿhgÞÞüZ4¢2å'ëiYÚTóîÚUì{ äæwgë án¸¡ãY+NQÛwiíû4{DÑ A§=_¥ëMè>Æ7ÿíGEÊ§nþpùÓ[(°*ÑEb¸ZÛºn¦=ewÖm%Æ²ÙLJbDh1Ðä, nz+
Á¼Ìè²(áS¸ÍR- æ£éX­Í#ù­gæAKwàníòm¯Ç6L¨CÒ£°ÝËúÁÎ±µ¥ObKäÜQÄÐûW~ßäIÂÀïß´¿k`|±i³h	Ûq´Ù¨Ï5J­íï}\ãÜ»¸èÀ{Ö¤]þÿCú1t®IÏ£X1ý£¬>èÐ¶Çï_¿f1s Ì¿ ®ÿÚ£\
endstream
endobj
182 0 obj
<<
/Length 1984      
/Filter /FlateDecode
>>
stream
xÚXÝs£F×_Á#ª[>RW¹J;ëäRë³ÛJy÷ac3bØ¬ÓþõéîA#'w/béïþu÷ ßÙ:¾óÓäõäeà¬¼U&ÎúÉcß`¹H"oé¬3çÑM¦×?O®×/ ¸|'pâÄKVùÌt?yüì;ýì ÿjéåÞ¯^$¾S8MüDgÆ^4êõNNgaì»©*Y6ôôlìiý¥×-Òçià»²©i'¥jd=à{ÕZJÓ³l÷ÉkõÄÊ¹g^ÕéÌXä¥ô0<àÓ,¼Uá¿O0AµH¶rµEþÕ(^º¼ÙÑv³ËkZÕù¾*ø\Î}÷eÄ.¸«ò${´âRQÒ"uªó3¸r[[ÑdâÊ=L!EF¯x'4ï4ÊYiYsäûÉ÷#5c÷OS{ÓY%}ìa4fÁÜ[A{1AûûÁ5Æ£ÍâiÎ{REA}$zlýÖ ×"Î>¿¹YDg°bràÌÂÐ#ÝGYÎb$²±ô>FéøN+õé%*+Ë&Dz¥´iCäRk¥k¤$Þ<ZÀ,õ&×5fc9wdQ¸9°'2Æ*ÂÎªÎC7EKfjò½)Ø­å&âÈZvyÁt)M^vØr`	ùú/kËZÍlsWt70Î¼p¸n9£ï» -¼ÕÂLª^aâ%¡{¿{mÖ÷#´úËåùçÔÄ<[[#èÁü®;b°sDÆÈ`#ÆIzQ{ðå¶sÕÃ"E}ì£¿Ç!Q­öÒT7¿îl=û\ÏP3ª½ZH¥n­±ÆfÀ¦ÄAã]ïýQ%´ØjQí:ªª³§Èëæêm'é/è<aPZ$î-· hE¾{¤Ýx´ªdU#óqN¤¢Ìèã«º)ÀÎ«üëWÁû¢M%¶,eèn¦¡ï¶Ç!;KÑE­hËtVCÓ,óR×ð:Eüï$´Ï´|s¹`ÏfÑ»·z¤)åfÛÊöÀU åå)ê*Oùôç)òÐðc6ÀÓuðÜÃ"Z¸Eµy#6+`Ã ÚÒÅmlúsHñØ7ô £`e
<ªÅ`E>CÉÑä/¬Ã6Òm3ÈfÆ`<tEq¯«bÃúM))q	°ñ{Êj|c¬G°ïþ§ÍO8Á"íâ±­yë êSAVêÙò¢Ôã¦¨ì^£² sSMó±Ë¨_`o ÜýÇF¦Ðê¿4Û|o1_ôGÛCW¹8B?g~0V¯çÿÃý'?öïîo?Üß®uðíÅYwgªÓT¦
\tõ/\fßÔã%Í7VÜØå
+oìàJpää½ØsÑ(²EE¦¢Âe
À~@_òö1þßNåo/rËesYåLjÿ^À,âqM7+Þ±Ç5!WñQ÷÷t$% Äëz»­Çö?ZØLìGÈîûHDØÿÓ+Cþ#Võ¬Ð^0`ÑÆ&4¼ÎOpt D¡¨ÞõN3hâe.µ¥| Jsó1«K
ìÝÉ¤y3»åÏgBì£ú3Ô6á9êÃêCzkqçÂ{-%	Aú­é'fÓ(Æ
DJ0t>(¤´ÑF±Üá.{lèÈ·|n¬üote°ÛÆÉP+KÐãJí÷æ³_LÐcQ²àdÍ»>R¹
Ïí×~Úë½ ¡> Î×£Jç
.Ýv8Ô§«ÌèÖ4§îÒ¤0Úrl+S¥²fQ{QFÕíR¿`]-_õ`¾ô¨ÖÓ(vµ(ëI­çfRØO£Ø·_ $Ë$yAl¢åño¢íÎ®Ýÿ½ÁÐÙ/çÞô:^j}æi47n¨c=­Çþ£¬i^¿©ÿ©-SëèÅFÿc^W¢ÁÓ²®m§âdßF6)ùå·Ú¶¾Î¹.ïf*òÉð¦¹ëSJHü«(ÅVÒºD}ÝuÝØ
,s³¯±QÒjÏ°(ï@ø²%'ÙËÏÍ=´ÂFénLÔÇÚÔçó÷\óÿhöG¥V­u7Çük ÿà)~.¾ë¡ö=Þ~NAÏÁüBCïñ<ùîi ñ\ÿ·ÔÐÜ¸gZ¾aãÂ§ÆÏz¸ÄC)²öò=l7{ÿaøõßª*ºrM[Ý©¾SÞFx~Jn.ë?×6{r¨oÚâ)/ñøØlö8rÖ÷Ð@Þºl]íD¹õ÷pb¯CÂhÛì À_È&ÆÑ\ÿ 5¾ýzqË,YTÃ~Îs®Û¾ ¶.ãçæb'¼ºïs]ë±àÊ°Ç]ÿnÌ÷_¤|e:ÍOUhg[ÝÂî©|äìX^£ëõä
endstream
endobj
186 0 obj
<<
/Length 1317      
/Filter /FlateDecode
>>
stream
xÚÅXMoã6½ûWèTØÀZ,K¶EÄÉ»´il´'F¢62©%¥¸Þ_ß¡HêËT(z%gß¼Òöã9¿.×?Í}gá.¢Iä¬·Nzn ÃY¸sg8álô°þ2¸^¾|Xå9¾Fn´ÀÈs=êÄûÁæÁsûâÀúÅÜ9{gº»xNê¬¿¼fäYÐì{; ²¸Á|¡bßröâýhNÂá¢h÷æã ÂwÆ¾ï.ÂPÙ_1ezÇX®FKT¬¥GAzcT=ó'=5cq1ãD½mÛø+(^Åck¯H;Ç|¨^¾
9© °(ßUk)Çß
Â±h[å&kðË'DwøA½\ÿãÂ`³ÙýÛÑ±èÛ¤än»<M`¤B­Ç=Ék»?5Ä~*½§3×Eµ¯0!±^±æ
RïX±°>9ÙãõßáÎ.»\^¿ ´@5
qMÓ'ÆÕ¶»Kº[ï¸Â1Ip[å¯q¾¹È;Þ?V£ßxy`ÙÛQJèN½ý ÕVd²¦¬7¿zEm,+L£º¿p\8ü©JcfÊD·ªD)©LJMÜ@Ð¬á-AÛp¦»ÀÇ?PJFrôn×XäÝÙ0ln?ßR:ÇEE| |³÷U¯iWàf+fkNm9© up@®ÈöØÊ8©;C<'¦7°­ÑøAç¢Y¤®Ã¤¨aI[£ý%ð¶j=2Ò! w¼¼Uç©óüJ+èð¦¡â+d1!´wý9eRÀ`£AØ|75Øÿ¶.icê=åû6º­íâ]dFæ@hß«<*ÁÛN]¶¯8XÁcÝÚ­Þ¬+=À~sÐÄþ9åñ¸¡I»}úázÞS©ý'Rã}åùÔllëÿïë`½Ðj>ÏP¿E$ÿO»¦¢à¸e©^Ò]ÓªZ÷¯RX¬l"7wÅ{/ôV_oVðôí½¶WPj§o4³ÅßfF¶öÞKSÿ¾ún©Èáò¹½\<!.et&ÕÝWÒd9 Tô4uëíÄ0§GËÉÒ´>­:gUñ¢ä;²Ý9Î±6v.àÞi"k]/Ý]ÁßwÊ59D·}bìu·ª¢P.«2Z]Þ\]h5:²Ý®êAD5çq©EÑV¨Ïg¨ÑND_üÇiO±*Ë&Òù¹,ëG^U&Ñ×¿×2Òdæï'`óó<¦£q0W;ÉET>ý!Ë¤oYÓò«¤âFÃÃIÖ#S.Û|ð!§ò/ÍâJíÞó&*.0US¹¥Âüòw|­@ÊÉY:0¤¸ØUø%D!ÛN\Te0uÓi;p[æÙUÚ¶*&hZÂ&`²q4OùÉé]ÀVÖ.ýVýV³	êlR>H+{¨`?©I©1ùE1 õ©7|!QYeBà+ì½(\ªüì¾7MÕòY/é7×äÐ35(8e#YÚh 2A	Ç´,Pë©R=årõLÅen«?}Ìóz=øUB.Ý
endstream
endobj
191 0 obj
<<
/Length 1580      
/Filter /FlateDecode
>>
stream
xÚÍW[oÛ6~÷¯Ð£Öª.lÅ6MÚíæÙ!Z:ÙP¢KJNóïGìHn·½0,Ãs¾sûä9wç¼¼Y^\Í|gîÎã vÖ['<7TÃiº3g:7ÃÙèvýap¹|øêçøN»ñ<T<×ó'Nnn='Uku~>sª3ÏÜXmñæ¬¿¼Þ§¾SgDn8«×;CßÊ=$ô³ç~÷{ÁÒ,n¹0³KøZ,ÌìUÉôÆ2Èq0ÉÍÎ$<<OÌÜ{mg¥ÔÔO=_+Dwh³+}þã`¸Pÿþð²/ëC%Aàz³ØùØ!6vCe*n¸®­*¡ëzóÄÏüPoöC×9¡qj¬:î\õ·6¹£ñdîß± ±¼4ùC àºYîa»~ü¦ßÃ ~AÐÿAà%zo
(uÎO¢¹gìûî<Ìvªç£qyCZgJF~4|È¥yå¹yV@êÁµn^ÈÇããÏßó)¦´ <'Ì.ª`ÎÂÊJÀ¡n6¡ìóÅÕ4lAâG*S}g¬üUuDJo&[I¢±Ú¸¼º¯´êÛóÌë]M|ö"oy¥þ}ó¾#yÊtêÂX%]y1´Âcô£HAà¶­à²TrÌ ¾ARVäªPDàÚºîN-UÐ¾Mø½G3Hx^Õ_^§v¥~¦T&¥Ä#{.%Ý00o¨quU\×ù¾ìü×3öö\,YLÄðr»¥	­]£h¦ÎQû&²WñU,h0²ÐÑ]=÷#aâÆHö¶ç¹Ä^Øú\BÊn@Gä6 ë 0£%¨Á®ë¼Jû#í÷_8
=F $
jßÔêãëÛ^Õ/eBXU¯ÛG^½¬þO$'w óí§~Öä¾2¹¢òË\¼¬9@jóÍ.¦<)õ}Ê³bÞÕP7q 0¦Ù3*;$Üt¥pSLVºÜ×û={ìOüNç,·hõ¶R©¢¬ÕÅ0íõÑÍQQy"`´¯.Pþ+TåeUñÏøìB@­V¹©Ø(¨mªc¤ÛixgD¤¬ÌQ=4Á4¤£<°ui~ÅÅCí£öÖéþqWéjÔ{Qk[ZõSD¾9yT©ZÐñdêÎÕCÕmþ¬ÅLu3þá3õ7Á~}Ú¬eAÎé«ÖÕÈè!£9X
p²Qi({Àò½î». 3£{K\49è?]Ñ*#Íp'3. ÑÉ°Ó ©­/xÊOo·jáâþ	¢5Y¢éRQR%KhÚaTÕ!ëL=¹øÿBRã!©qÍÔ5E½F¿o5lr°PÆ¹u$aOâdSâ¶¨d?ÂÇÁtâFÓé1O\WÎ­z7=WóþºµE¨v¢Z©·¶ëvÕd{Bï0M«o:=ÀXÓ'mÅÉáßPË¹$¶ã®6òÍ^Üæs¼ÄKHª¨PA%4TUÕÈ<y<+k¸·Üw+RoKÐFËBÕ½Ú¼0ÏÆú/ÍÄ{ÎÒÚrÎzæ*ÉÅêê[âX<öägºPýuUø%O¾ê"ÙéîE¹a4±<UåX~_í#g- °LàÔ§óÂÒ¾>åõÚ½µëëHpà¬¬>Æ,+þÑà²74-hG³#·,áudÔy×qG'0??¹jª_MªñQÍ¢­\ÿQó~}SJÝ#¤ý¤8 ãû³õÑ%l«×O¨\[Î(Ö Y¨Öwg=ð4%­ï[a¾&³a$kÈäb½n>Më´!´)@uúlÛ³DçÃïÚ~÷\Uç¨ ÉãÉwì¾Ãb²°5å+¥mgi¿\þvú2È
endstream
endobj
200 0 obj
<<
/Length 2055      
/Filter /FlateDecode
>>
stream
xÚÍX[Û6~÷¯ÐKZ9¨köa¤éMÒÎ],Ò  %ÚVGURÇ}Ù¿¾7Y¶¥I²X,öÅæå\x?\gë¸ÎÍìÕjvuxNÒÈÕÆ	CaÆF³ÊótñqõÓìÍjöçÌ.×ñ0BQÈE®8Y5ûðÑurØûÉþ4qö²r4A¸NéÜÏ~¹CÍ1hNäÆ¡{á$Õª?|ú¸X~8ÿ³
¡'9Å¶§r¼â9KÏCi1]5)¿¨µ;3`²ÔfD°o×ÛÒäN*á¢5ßR3.È{ÊÌh~ßæ¶`µÙ$u>Bµâ¤$UüÙ(¾±ªzÃ6ÒÞÞ¬	;#Ì©Q¶>ñêÿ-©Éò'ÍíµjVCï­zqlEqy_Ñì;úgG­3¯»rSeEëvú¦ÿn8oë¬ìrcÎËì¨XÔY>RätuÊ!ÌuI«oây½#õ~Ë-)ç;ý÷mJv¨¦N<êëQýÏ$WÀ<¿Ë(ê­´Ù¤¢ý¥j§b^¬ÿ%Àl8«¾ ¼ÓÝ~¶¬,ëìáH­gak}äù©³ôá	\ÿ\x;gÝbéc_Ê­åÏ<ÔV/vB(?öbcÆ®gbR&p)FÞ2òç¿À¯7£Æw#Gñ}ä&±åùyDj0,Á­t¯®zâ ¥%1C°C5ÃýÎùÜôJ=Hi©^8?hËUÀQ«2þi¯´«ð|¿ ¿Úø¨eú¢cÆ5Õ³Â8èiÆàñjuæz³áô¸
GªÐbÝ`þæQJß¯EàyÉ¶EÅ<TQt
ª5\þCÎ½äã9ÛèÿýÂs=Q®.$±ÖÆYÍXWæz¸6K9m)¯º ÄgzéwßôlZ+üöFIpÔÑì	òðFAÑ¦§G¼æÔ°üc¸sn*±êÊ·ÜÝÌ\pì+8FA1 S²Í¥g`P
ÔC0èû Å¿vp«]¥]2áÝ&§.~K3NE&Ïºò¹éA«0ÁôDYÿ ®Gï¯áñ¢5;¶^T|©^hReªXû­1Jb|CÿâüÈvRk,½(2GÆ8Ð¬/ûÌ%TÑfKÚf¤#FªÉøjDlº²<s)d©z-­þf²Õ»^L&¸Y«Ô}æ]ImFíì±Ö&\è(H$ß&©jJ8ötÊ¼Q[u0{^hü÷/«x°ÆrZ~/úc$×}^í(ã´/ôôºÈÔk3g¤>=òµ»³ÃVXgÞYª³Ø4¦úBÏäÅ¸|eD¡G}aÍêåó´æE(ÀÉiZSråÓ« ã@¯BÃZjÞo»#­.Ñ­·`¡¡Ð×/GÚêÍBq§³|ë|nmï(sÁ 'Qw°Ï»°:wcÅIðw£¯Ê»
â%ämW."$ÆfAù^Õ	&AËr¦×J ÐCgaÓES±vZ¥ü³ÑGó¢%a8¬xñÙmtN_ v=È9áÿèüÿæì§NpR÷,B+`c Õ7¤é]®íwv÷ÖêÚWRK¹=z]ðíá6z>¢×Ä5YÕÝÂ8¿7ì¬kË¢î)HmØ9DêEUa]í5ðé5Y¢YíÔ9ö ×1òñ© ¬ÂA-©ía)¬`@Åyýï¨òÀëÎ)áßKp9
Vvª¹iõ²±aÓMÇ×ØéxpRTdÄ¢wDÜtÅ±a,·Â³¢¡_UØ,7¬^ïXÆJbsÉë]ÑØ¥fäNfîÛzËáB¾4¯ c¶'Ê¸¯mo¨ºF¾jËÉôÌ${°ýHªÖb´ìw
èXEÃàª°mÿy kÛ ÞUÐÃpnKøt¡pU®¼ÙÉÞ_öBË5úhM ½iÊÕ'§±>	5ÝnÇÍõ¯ðôq/l;÷áxj¸,Qõ^KÖ>%à¨ë)Jz°µô(ë¾J U!öÔ¶ÐÙ) 3 ¤öýÊDIP]¨ÛÀ¦¯³/³88ð¬ý±Ís6lO ÊBäpuC »I\=Ý¬ã¥8	c3ÅÐ<ñ5ÓKSH¸ÿi¿ábÝ|Å(}'NPáA³v_Q ré£$5To¶ãRAÿù±Ä{o*1Û5ÊRÏÄ4$3´üê8¹3ÑmPOA§çaxwmÛ¼¸ºÆ¼¦êå+VïA.jòÍe¯u4mÈªz&h0O»³, ÇÐ¸k_lÈ×Í"ÉöÁ5ÑöwØÓî¢(
å;l"¹æ¼k¶0~<ÔâàÌG´FûâH^ÄøöJÎ®n½ÆÏ^Epªg~,>'ÇùÔ\úò¨Í_bht¶ç¦`ñ#ä@Y{÷aÊì+ySPùÐ7PlðÚZ]õ²ÿ¹K ñKÖ%Û¢¦ý¤OEÚÝÕM^.¡ÃóûJvH¤F»¶*Gïù?¼Äem[é
endstream
endobj
206 0 obj
<<
/Length 1374      
/Filter /FlateDecode
>>
stream
xÚÍWKÛ6¾ûWè(±ÔËVoÝ4i´AÚøR$9Ðm+.IíÆÿ¾C)?¢EÒK­!9ïùf(èè×Åývq÷zC£*©Ê´¶û¨È$Ëóh]fÉ&Ú6ÑÇåçíÛÅ«íâ1Ñ¨(²Ê$æQÝ/>~&Qgo#dÕ&zr}W¤uÑÅriz]Þl².¢5ÍlS¡í_âµrÐÖ`F+Jª(å½â-gf¹*Ò"|@ÊH|fiDÃs×N¹ÖôR5ÕJu´>*1öRõ¸>2oèIÏ2FÔ¸zänØ®ã<;Í[íwbð\µû÷ô.÷§ãÑ¹÷JÇSHwË'_x.#cêyg¸7³ájÎEH±öNõâêBwÒÙßú¸Bûy-PÒ¥ÿ	R÷ìÁïAúXoÑp}ås>¿®J¹Ò{uT²p¤òÙÙMà©g>º¨pÏÁÐ*½ËnJqQ)p~8ÜÖò6Ùû¯jóÈÑuìFÑ=?é9e,DàZÖÝ¦´ne-;f¦¥8ê©oÔ-³µ7#åðÏ·¨ì!èo»}n§I©â=~>¹Ü~ÈV·%KÉ7õRÊÎ4×²?vÜðn¶µï'h=Çsh/ýÈË§\]óé°³DÛÜë¯7Fxß=è)ìþsÖÌébsáíäno+v[Qu.7wÌ*KVÑ*§¨¿eþ^RJb9.WiYYâ·I~TkB­|NM¹¨¼àªLã÷ðOãWþkÆf&d3Éü>£µL²¬o¢î;1çIµ¡e;ÂFWÛÚ'uÆhÀsuÁdûÆFÅð¨0|'jìº-ZÜþÒ¦B=àÊ¡×é2B;¶Ù«ÑË¸*XÊrv¹ù¥eüNâA/*ëQ#ò%ø¬s¤ÎÕ°8ZQÁÀ}'ÇæÕ¶ô©²|IccN¸<(vlE­ÑÅÏV.-|%héÙãJ|¥ÖÂÝ¥iègd´OËcçQÝU*­åÁ¶M³Þël³ª\Ú#fLÍm"	à:åÝ­@Ô)Ùi¯DÎõ·¿m¬ì:wËÄ£U_nâ<ÚNK¬PÌo`AªíK% 
¢;!ÝfÅj/³WövÌ¶¬`ÈÁðÁØÊ"þyo/ýKss-eë$/+¿§å<ÐÙà/ðÙ
§¾µ\²=;ªQmò$Kóë¢JWÀ|ké o,èñ°ëF¥% ¥Ú²èßxìïXØýDH½P·LèçÀ*°
·.Z	·Ös/Y±½]ì¯YNîÒ³Ç;h&¤·®à|vÒ*Éÿ·ºÓçëþ=e§WuÇ&ú*ïìæûaà8øHü)M3Yª9®kÙpØËq5p7[æ×8C¬TÁes6Á J½ÆÓg~:ñ0å¥ÃP&ç¶»à»6v;Èã$N3ºÖFÖ}*Aóüúæó¸æù>OHú£Ôû¿Ü¬ö­C-sû|áX½L4|)SñZ¶ì}
7áÖØ.3xÃíC®e(®í­GG"oÉÜèn8?úÒºi ÄOHAÝçtøOø¼þ%:
endstream
endobj
242 0 obj
<<
/Length 3779      
/Filter /FlateDecode
>>
stream
xÚÕZ[oã6~Ï¯ð[e f$ê>E1³í´)&n'm±h@±[YòHò¸Ù_¿çBÊ¢ì$²»X´/¶x?çð\¾CÒ,'îäë77oo4Ñäæ~¡ð`G¾H&7É/çM»ùöâ«s'Þ$DúÐË®Læë_~s'hûvâ
?M&;ê¹i""èâNÉ^¸ý¥=/x,IZ\Ï*Z]NgëºÎlþ°¬§^âTÛr1ÉÐu2ó±P¿º®,ó6¯J$vÀ;I)dñßdSé:òr	£×ÙM=×©êüS8câ9jêÎï­*|*CçUñ¨äí»Á²~vóUV·ÍçX8µ*2¤¥áþ<[ÖÙº!9²ëå?~ø· ~,}¤VRÄ±?ñAnµFvöbÄÞdÖë¯ÉøiêyÀJY2±©ç¤$
ZtÈ³èøy
BÈê2W5J~ö¾®ÏLê 
,züçèñ\Aÿ>A¬1 ª1¬TÍ%ÒìèÌ?1èáÌóD<²ºÎü0­ÝÔªQeKê5º«¦Q¸ù~9Mµ]!/¶ÞÎItôg¦i4Qä³ÈÚ«ÖÕB¦÷×=ÔK-P®øIox¦Z«vÕQ¶Î
b:üØ¹j{#ªm± n]ÍÛ©;t÷#çN©¿µÊZþl+þ?ìñ(Hvð?÷8ôÑÐ}~2Ò3qH¨z¶Z·T£òòi:Ú¡/Í#ÿ¯«ZÍ«r±÷l¿ã»/4­Uóª(²»ª&Ô¼Z
.ÌíuÕ´¨o¾³QÕ¦PüýPVzg±Ól©Spà[`7uÞlõ$Z	h ÖZ§ý½NS	· ÿí-ÀÔ;´ÓTî5W¦¯®'ítýÈ#¯ß³Ý öï¦d¼±6Þà%gÂ¦_ÂÆFÂãüì½µÆÈÈ;Ñ·DðÒÔò-áé¾.ò/Õ<oH/¶Vj,Ào{·hl¾Wmóêß©väî¸"õìÅý{ÐË)Zvþ²¬`bXGzzWqlÑ#ëü=¬¾Î6#×¿ÈÄZ;=Kß³­ðúoÎÊ£ã^,@ëûI÷i¼eó(×Y©m	 WÛ¦ti>L ¥EÚPÜýð«'©ðTI%!cÙgóª«MËñº6»bþÉ;+¾3àøúÃ7W#íÖµíWç¬{C@­yàR7mÃ¿º¡K1 H¹Sµ¨z ÙÓSô°Þ%ã¼þ.Ú°ýntVçÕV#/	
Ñ yéÖB¡îþÂ56@d/ùk§kæ¦	ä/zäÍªØ`¡!eT±e|w´*íjÈ^³ªêv^­!Ô6GPAÔG¾¸ØäZTË\5\uO`GÀN¨á`Íß¦×2èãDßu ºóV¯G°gÚ@ÌÂjÎåR©Ïèt?¶V¹Y©?	Âÿ^¤¥Çezgá¡¥*UÏQXùÄ6:Ê\¦"oU|îHªixh¯c:ê â»´À¼ð 6ä÷üo0Uäji4ÿuP:V-r¸@;D¾ â!Ü&XFúJ¢,ëÒ6½ÞbE¥¡­3ÈN©ë¬ÕWóójfñ1fÃ2zrtÞdESWÎ¶Öb{«p*ÀèãBoExy"ÞúÂ$kÙÇÍúªlÑeønä|ÓÄ"]¢n«PßAv$ïá×s¾¢ï!HtcÞ4 W4Ñô¦ë6xÄ¿çÏÂ¬
øï³¬³³økV­ù]{eAB|ÌâÄyÝ%UvýÐU4E¬6-ËlÏuJÝ+6±Ã¿6vWg8P5ó:7íYI²W¼uÏ'ñ ~ccB×ÕÔxdA\qßëCi²ç;LPfª¸fnBy2ÌØÉ{sêÎfVÕ÷°Wzy·Y~1ÓCÊ*®éËÁëËÁÝ'¯Ð`ÚYùù1/Aû»Îxöð¿÷èÔ ?¼ÒîÉ]Í[t#`ªdËPÍq*öÄaõÀB+öÜåS6ªRèJë¬~Øn¸ìÑ7¾DÄKÿæ§E8,´Ð1Âã'1#$(v¤7pÓT¥Aª®òÅÀÉkPÜ.í ølÙ¹^ãÈUóÑ$"²È×,µÓçÐCøpñôÅë{ö~ÛÕss0kÿbNVâÞþcÉì?}w8æÑAêhrð U` h:°Mó7cü0'VOÒ{TLs´÷J­ZßOCIx¶Ben^Ô	j¹ZóiqÈh aHe3íâ#d°-Æ~©\ó]¨ºâ?_jÑ[j-¡bEwð>®ÞÈtÄ£Ì³MvGè(À¿ö¬W©?ô	iÀËÁ¿ÊX¯Î`«¿¡ëdf ¶Vë
gap½àJ|t7«|NG8ôhòì.Yêl÷§ÖFq÷f{ÚáPd: ê0	ØÅÒi·uI<ð¼$_µ?£¸ß_]s=æCÒ.¯ æªËkZRú¡ð£`â
74±;tY]øÿLS¥ ÕCñä¬ø°f±1BÝ²2Ô!X£Ï*¡÷mÓÚ§Ð¥d;.ß æC`±LþÙÆ¢&8ÄË¼`×§·$1R,Ü }zKLïÉÈ	¾Þ>u^¸ð#i1²RÅÆxê¼`wðÃÎTk¾èÏS¶á>MíPóF5ùk x_{UC7Im9èQ#Bþ1¥ñb_ÿ7¥O+×?R~>Ç´u7Ì±ÆrP£1ÔíVtíuµºWu½¡îi¥ 6U}l '¶é±Ò6äæÄô'¼Oé£MÛ°8QþYöëØäs­Ò+Ë¸@4w&AF^Òí²PN~nï\ÈÊÜÝ~æîÛ&iÀn,kT¹]ßu¨NoE¡z×ÇMÆ%	»ê=Oñ³öÁdòùÉZ}±=»Ëãp0T?oùLCìÂÉ væm8@Á£A«Rs/¦§a£¢&¼KìX:ÒPþ9½¤±ñéaé$ÜVQ0z¸rÜÓ	¥ô>eÀÀíreÐtJÝ3ø¾ëÌf¡ÎwotF)[mÁq5Ûõf¯ò]WÒ÷ýëâñÛzÝ£ÙÝcÙf¿ës¯ÕìÝðÂTwQ0[ncöThL`Úg1ð+)IHt	ÖÇd½£tªß½hÜPõC¶þ]_Tågx¦g4í$¸ËâCÁÎtôôvÈÿc<æâæ«*îxÉÌÃî6T³¾Êêí%s¡ëï³ÕìÐ-uWUµ1Z°-Ûæ,±Nß¬úXYÛBN÷ÛÖ©ÙÎMüÐ5m¾Ä¨­ýÜP:§ÔQ7ªnªn·l;f^º­ÎÔ¦jIðèëlcWô.g:½Éön£wªÏÛ?pA[f7Êl3P,4°c:mÃÎ)K|}~M)6T#Ô¢ãötÚÅ4qðg	+§à ³0ï¿·Ì°Ï\_dÐp©/>ó¢ÞÔS? Òcµ­¹GÍk[dµ¾®XU»Þý©´Jáfö!Øª Ûh@jXé±À×v8î^ïu0 ` ÏøÓ.5jmí»3XäugÇbÊðd¤(ÛZýVÊ5Ý¢« ÄwT°üBe¶i{	¾²ð¹G^ ð»GæfúÓîG#ËÌ6Iû¯ /3)XºýÐ{|Ø»3Õ¨YHüBB»/PRû½yg Ñ81·am»yuy5EU//ÈKË¾-ãWK3ÒúÛ¬ÈÛÇËRí¸Î*)aåxÊ]jqk[UEsY}Rõ§\í.»ÜWÓ.Víº8Ì¨÷ÒÌÝCSû¡â¢ê?<_T!Þ@uÞAKI14dõyFâÂÒåO°Ö­yùCa"b=Oþ(?¶<;HS9»÷§aI@zÈ§óërÇ«º~yks_Á(IüXÒ­¶q×ø¬²Kï²r¹ÅÜ¦¯ßaô9Q<®ËGÉºÏÕâÖPrÛñ <	×èw8Jïâþ§Âä(6qUõ8JÍ£PD~b³bíKYÒ;»S9r;N¯ÍZ·¸Ìóf2D6?ñ(~Ì³=`æ;ÕÈïIáäe^hÛRµ{ËÜívbÕPÛ¼¼¯.eÒOEì¥6É(&zHYþêpî`ßïëeoÍ[ZîY.ã Íd:IýèP?;£Àq<Îà:·Èã"mßÁ_VÈîùâòNÝ­DrozñÛû¢Úr$	D)wÀç8¸ÔùG¸Wãä[EËb,æüÇbl¸yéIå©ü¥tÇ2Ê_ÂÊã·.`ó7è¼Ñ<Çÿ'£ÒK½hmèþñ°¾ÏÌ8¬²ñyºëÇºÀ7ÝÒ'Ý/£,úÇ!§©K°âSÝ9`<ä¨© oX6{nnh5Î"èY,ß·5®!Á)^%úG®#Èf½6¾JülNÓ?¿1o§î\?/¥ÄA2/µZ¬ª%ÉÈÅSÿ¾þ!ñ%C
endstream
endobj
262 0 obj
<<
/Length 1008      
/Filter /FlateDecode
>>
stream
xÚ½VËrÛ6Ýë+0ÙF0@ðé]ìØ©3IXz:ª	KQ
@õ÷P¶dRm7ÝÜÇ¹ 9@àóàj2¸¸Í0Èa	<8!"&f`RiÃáãäËàf2økÍ10äÄ D8Åj0}D 4ÿ¾ I]\(Ï`b T`<ø9@½ªS4t4º?ÖÃQ£q<ÓÕºbnC<¹±dª|Æë¹[S7(M5»lìn¶ãÅmJ^iE0R0
C¯ôÊá(ãàO#Öjµb¶åb£ª½[ÖB»I!,F3s [¥ ÇFÃ<ØgÍ$²ðòZ7Ññë+oBÉ
/¢%ôÀëRìT¯ôûÍlÆ¼c¯c;êO£G|X0VÞÕÿàÔQÝa7zz=·Rtû>%qE¥³`H²ðöZó¢ßÿoB1sx5×{CNÉ¤ê4&lyùV[ÖÅwìJÒ¥ûå#Bæ&ã§>Í]ÖjIkÅ5}YoRSµt«+m3î?ç¹÷æVKç^´Ù%æ½]/Xqßè.ØZïMN{Ê>~ÿtñÛýe/ö3óÕ$Í¶®hgR ÕL²ª¢ýø$Rü$äù­ÖLR½¬?ÅÊLÃºêVU'È³þVùâi!JÕY÷o£¸QÚ$eÓ¥ÓÄäò¥×¢.6R²ºØïdµ²½õ¸,¨jwjÿk¿õÎf¯z×EÍy¡Ü`ÏL\±Ò`¦\üËã»Ot+$×~¥4oÙ	ã¦òBíÂößbÆ	Hæ9kï¬ÒÔgnÊya­¶³ÖnÒ$ÌGvÆ=¤&gÂd¥ë9D{Ú;¾äp8
ÆöóJ¨leº;#P°¢0Eð·¢ëõ¨2½ÇR8l«yuÜåSssO1fKgÁÆ@Qp§ßcC´ëXÒu×Ü¨Ú8øà/îF©üzà9y°åã¦È>"-GIü0_Ü4óûàV²´=óµCl	IZÀ]#hÜÀÆÇÆMyÌøÂwè¡G¯@.òÖ¿Â<V¢¤µÛî¾÷­Mmí«_8îmÑÜ\7Á¶LBrÜ¾²#ÂçÂß,mOqoÂÖ*¥Ò>iÜÆJ­Õw#`fÿS8Âþpà&é¿ÒÌU¢ðÖãµPÊ¼$+s3;ïTóþDVÒ
endstream
endobj
266 0 obj
<<
/Length 2553      
/Filter /FlateDecode
>>
stream
xÚÝÉrÛFö®¯@ùEhì­/¥±j8h@ÁbY?ok@ÙÃT<±Ñýö~[?¹Ö­åZß}»9{ñ&ñ¬ÔI#Y+BÇ+|'±6¹õíù«_7ß½Þý~ækyV9Qêë¸^`m÷g¿üêZ9}o¹&Ö=Aî­ M@\«´®Î~:sÇ¬=/¶¼ FU¥0ñ»¿Z{®ëÚ8èæmÑv(`ºNê¦b&$:Ê©¯n¢ÜZÀÖ*v8`ÀÕZ@4vª;`ºø¯Õ:Rö;øëÙ¯iýóÝM·T#Ç÷cpI®èf 4ñ|Áw¼ÄòÁÑi½@íÈZ¶uÕ©ZV­¾ßJË¢áß}Ýè'´wØ×ÿ/Ô?¥~ôX}uZ}ïõ¿ìô¾uFrô±µqð Ä	/õ²x"Í x¡µÁ@KNä£G*Ð!>zdòH7ú_]É§<2þÕ*Ð+ßÎø³,È+ñ ,©'NÆ_úÞDgµöÝÌÀÊm3Qv­kXy¡-fx¯¿ÝeÞè
Ö`¾-Ê(pÑIÂØþ(aû¥NÒgÈuÕéµìjÞívb¤¦¸ÝQ~
ñìµ=ÏIÃ)]ë²^©Ð¾çôÆx°@0\S¨s,¼ød)ðúZs!ë5ª
QÊUvÉá·>tE]e%¡^uYÓéðw'`7«Äµ!yqûeXu¸k¸å²ñÑ¬Éºº0®FÝ.ëxÕêß{]m5ßÞ:N°ÊôöÊrvÛÐ²¦¨{©Àg^³§
 ¤HýAÒMôYéfzé¨)ñ¹n·MqM!³á{Y~lDcøã6äªÁ:tÖL³êjç²elÞwîÓN7új-MOh~_¼ýqôüªdHU2ôMÉv¼Õ:ÄMÉ/\qÈÀ(ÙkN Bà38*§ÚPï á÷ºÔûOà¡@×>Á EÂú¬,n
Ñcí{¨¹6/_õ×mWt="¡L0&Æx×Ô L÷pZ_§ÊëSZèy^tÅý¤E±ÈÏú.êj¸´ìvùRf¸·ýp´cÞº{£hþrU·×?dÍ]X¸QHék©¿s8±étRO^&oëú#@Ù7+c_EÖüÊ¼C>ÔÖ-EoCRÓ¿ÀxÅùK8]zz¶e§\Ê¤¸°k
åÛ¢ªêvNÕpÅ¶ #ÞÖ;¸m©J69øä,\9.eÚ ÚPE_G¦$Z¯íò%Hç¬0=Ô=Ö0Or1,ålóx°5lçõ¶'ofhÙÍøçÝ«7¼xïºªÔTdã#í}öÀ¾&|ÏÈ@<ö¸è{cÏ@Èë÷FÉJ¹íÊ¡! Ý%ýÃxãîÀÓ¨r¾s¦°w»'«Û²ØÞ§vñ¡p7yÓAzoy8¡	0ªôÙE¢D%ÿ¿3cÀ®A5_?ïn7ifMù¶k3;;2ÕþZnIMÝL;Ä¼Äv¾@×£AÄÿ}ÙkybQåÅÖ4Òü©ãá¬ûCfIjñEü"$±ûªFqþ+Ö×	Q¦Ó`k8·Óà·Æ:P1Pª~­(ív¬ûíNÄqÿé@-P©íüû±H\^0(&f(°µs8¼"ÎMÛñø¬H#ðÀ?£ÀK8L¿Æ÷Ï=Ùº/sÖîZláq6Æ8­4³%¶9­»­Ð¹àz¹3òÈ;ÿÈÁ;ÅAo7HùÓÖ¨I»>jÓ8F¥1J¦JB~ÄlµÅ1hòiËÍ4ñ÷Ø¯íí+çif
{Á§áPQÛ]M©>û¦nö¼-¥c¾)üî²gÂ¬å¶,JÝu²H0áqÙÖ¼"ñàÈòMPÂf&Ô¼Oä»©E66ì£û¦Û­ËQT2üe¥2
Ýïd4W¯?R>Q§H&¾q&8{)û[ÿØQÃ}+hhA`sêÒ-SÇû|®ìª_­¶­ìÂK£¨óóKÌ<;SKé+o£.^QYXèN¸<K¶µÜ6¡kÖÇbm·rñ±à¹F
Ü¤çumSÊvÐÅoÑEðMªhÁP[¡ëìöU-/Í\	%4Ã÷aà`}+¸³) ìdüc £Oá$¯µp«êY<¦Â¶Äf2¿AùÇ×p¤L-âqÛHG	`"Ô¬L?v_ÓK7Îí°Ô´ô¾â)Þol Ø?4¥ùÈ_2æ²$¬¤W	¸à%TÒP6Úâ¶âÕ{7Äö#CøðÎÇãCsyL¸òk®r&äù
ajÉ0ÉÆ:ä_9g))=Ô6/x¶Q/õhx+ºª @#Ñ 2À÷8É/a(iX²ECö
ÏsÃ,±$ËöMoÔ:òñ¹Cgüú»Òàã·Y}±_4e[4MöhgÃUÖÞØmS÷iAaÖ¦[â	;bÿ,qêjÃ«Y¬=ì$bOåKÃOÍÍ@2£DíôÚñÓÑx.
ísv&ÃÑ=+0!Ißò\1ð»óüK'9ÔOö¹g³ISÛCdäárGÐ`Ô¿.sRÓ¡KÛ¶v¤Þx¸Km8xép½°¼çâµ<C¦çµ0ëW³ëÃL²a=öfåÚGI¤×@¨^86X¦rÆ³Ü9O
SÛ~Æ|ÔÜh:*TÆ×Cª#Uúüÿ<{þìäÐNÆuoê²¬ï©Xâ'RlyIÓ\`á/YlU\0Â5{#a
wÊ2ÏøãZß Qháý0éNÿû,@=]EzPò,oM$Øê¦Ë
Ù+õQàô¢é~0æ¹ cv2ÛSBfvyÌAu4VY4W=¢ª+¬zpXïDI¹ä?s´ãPù¯K³Iè¢('7&1feÒqA_tM6#júTÇ²Q§í¶o[ó´(³N7óD^´æß4n\öû×³ÿ ;%¤Ã
endstream
endobj
273 0 obj
<<
/Length 3138      
/Filter /FlateDecode
>>
stream
xÚÕkÛFîûþ
÷¡2.Õûkï¶fm6í:¸+Ò ÐÊãµYrõèfï×_£WN"8 _¬Ã!9$¤l/îöâ³/×gçÏ'\$*	Ýp±Þ.P·BOÅõfñÆò»\9¶m[ëel[½|»þöüyìùq¬ÂÀª´Æñçìb}öëí3P¶íølöæ­½ØÀÜ·[yI¼¸'ÌýÂO Øbqsöý=e7Z8JÀóëÊóýÇGþ	íÅÊm¢×\n+Ï­¼Ågbå¿UËêvéÖoyÕ5QÕ<±5¬Hë¼}Î6mgm©æ	 \Ï:Ôú'ÛvßótZòó²Õ{^x·;ýäºÞÍSøõµ-c´;=]·MÓ6ÏïúÑ>Þó';°s¥ÕråÇÕT{ÝîòòµFzBu¬§û]®XJÃ¶®o³¤a¨yfm^@ÚQ¸Kd½nd[/Ûáiñ£­Ó²ÉÏ3³´MèÒ±öü<Áñy­®K¿xXõ9ÖCÕñú}úÀ»1£l:?6v0áØõ±ÿ2c]®Ä @0/V§RìÊbWô0nìjÃÂ´Ü3çB2°{ô2^=hÅwÀÐnp¶÷c!@j#ýÃk§ßÈ[Ð[³¶: RÓßnÚ´F °	åø*7ôÕ./6µ.§,¦²®Û4/çÃÖà1]"bØê­ÙÈ+Ðï\p)ðÐ~¼6sÛue^*ôq×û¼©æ ³½VoöQZ¹ÝXkÂ'aè«ªlaïÓQHBí3ÞîE©$²Dt"åÀ±¨«Ðµ^Á¯c]Ðø9#t÷k®f¨Êó"pInèºGÁbÇ#<åÄB³Ä=ÏÕIÄÚwÊ.]º¶õT£a°:3ªÛ©¥ö­Ø(Í(ºÕÆ]O¸(ô0_:7&4FD{x¶ÙA-Ý@øcê}tîÄ	y¨áÈ#.»þþ¡#×ãÓt|öö¸Ì)ÀÓë®Ñg%@x¶O%³ßwiÁö: xVÓÝ6mÞvâ.v>óxñ«ºâí¨ ¤*x¾ÖM·Î)Hñ!Â]éÁÅ ·­u*"é.¤·ÉnôäUe¦m3«w[¹>j´ïÖ+8@E¿ÞhìLÇÈl]$7ðe'½£LÝ
-=\båû°þ·­ç 	ö¼ÑáF±eÎßèt£OLì/[iw¤.U´B1¾	²X)^ñýN3üh´Y¿a:VîðÊÓì00 x/%ìÃ k:ù0,ª;¸/
^U\å{êÕwüðÍÄ/r)ø¾«bÈìFñÁh©Éñ©8Sb¤ESÉµØà[GwIéÇØqôGÒ<á©¦#û´aÅÿ<ûîÕÕÅÓB÷±'oæg¿zq}}sbåõË_?gàúÅÅ)ÜKØãòä&×/×/Ws^ôúú5-J«¶¥Û\ÕH
³#ãLìÕ#<Ú§ïÉ0	 Län["ØÝ9kTw%ÃÀÓ!aë ©æLX{VÎqËê{¸Þ[-(;Ì¤©YzÈ[¥Ðëæ(Òå¦1Ã4%©ª<BNM"fút¦ÃLsÄ·$ò/¿úüñÕúòúåSF­ÂH0ÒªÝhIÞ+Ô`¹I,©p+øºÌêC«7<Í¼D)cS^x÷HQeï3a©§Çâ¯NË%×xó(èÉÁ8¬/qÇzcHñÀ ¸yÏÏÖÐË\×VNýÔ(ú½Ô(|¹§S#ç£s#ôãX<ß±Q	©?hDW)åFZm43Ñ¸Ï'ò´»Ï¢×=¡FÊöé!z+IÕ/°õi¯$_¹ñæ¸0(é{ñ±ÐScjZÌó6HÞê u)úi÷£ÞI¸¢ó(Þ5n ÜyÝFótUjR}U¤ÈKôE^ÒäfEÊ Y3tlÒåÿÇ?eÎ§ôH;sB±²Ãà/(£Æäæý¡
¬©9²MU~¶§¨á/¸´l{Ó!gñ¢PEaø8¯ð 9Ì!hÕ@CàsNQ¬Ü ükhÑù1¥(,-uNH|~àÍWä ¼@qIÊ H$ å©í¤ú´ áäÁBXm«zÂ½¾¢0{­99õwWre¹ÑÓDoxézá(äã¯jÃý¸'bnâÜ5¨x²w¢À	$R&d®½Xâ5<)®`\N|«É÷ºOkÁäèäZöH1gÒìÐêµÐÑÆÜN1ÕÀ%_ÌV]·iö®)Òf7´_N5Àbö¶VÎõÑÒÆý¯¡?SM³-Ô¤a¶7eêâ}
ZÒO'EÂP,LØ²UäCµ ®Øî·È;*¿GÀ&µgÊÑ"QÝøìµ/­~ß*¥æTùo¨24cwøU]Ù]äùâò«{#øÐæ®w,Y	iÓ n@§<|ó¯·fo\¿¸¼ÉÏ×ºiÿ9¡^<fî47 9È.î¨açÑEcÇG7%>gR+s¼c9»+s>jÚ¨ÁqÌ"!"Ò¶+xOqÊ7@}¨÷%Kð{üÔ¥5Í`ðÉ23ðt´-ÑL*Ä»:ÝïéÜq"«6§ráû|³)ôx=öÀO¦Ø³÷ºú¯xÌ÷Õ_ÙA$hñ¸ÒâùþTÇîåy±»­ Ô	Å>çÇNõxÜÀôxÜQ×6´FM7È÷½	!y+2åv'ãîî²ù¾&«Ã_{b²Û!%×»ÑÉ}|ßo$¹t(ß4¹9æÆÜT	0°¬ç#0ØqÚÎ/û¡Y{ä{¼ÓfªpÊþCH¨¤«e3.û&,;ÈôkÆÜ¦ÜPo¿áâ8ì{_a"uðN5%<9 ömÖAð&C¤Ìî¤9U;aQ¼4¼2ÆÑÖ!1[KèØ0¢àI^wh4óíS¹	Ï8±×-5qÌ± èÐµTÈj>ñ$8"bZÉ®`]µ`ÝÖpëSC§<N69¨7ùÓÝËÃç~RVäT{%O~P ]ÐäÑöLc¼íøÈf]ÓWJuzñCNpÓÒ´üèEèDgÈáÞª7BN·<ÑwèuÂdö<"À®ò¼ÚP³Õ76 wMz'C6X^?§n²:¿5õñíÃ$[ÚêÞmÑåGÍ4AZ8¡ò½xzYBL±Þ@Ø´­¯«ãº=}Fì«ñ}æó©æëzô¥d3|`ùbXÿfýÇ	¼%
Q;.hÇùX<i&äýçÌ1SÞ¶r?v+gúQ»ØÜùû§Ô6Rüní*å¿Î	süþá0¤buÙ®ªÌGP÷ÉD±FÚñ~äºÄ¸ßåDÙVÕmÝéy£3Ì¬O©ðm]Ù ¿ÇómZ±¥³hN0î)ïìOi¯Ãwîvg>>6¡¡w$ÅA§ö<÷ÙO2M;QÛ§§ÏdU$ö}±hþï@»ÌH!-DÒû³§÷GõHà/«ÛióPa!8¯çï"ÀUEûTñörÒ~¯ÿý9
Ô@ÊZC_ § ôO>¶=Êô}X°rUÈWË«þ})K?ËFa'ë»ÅðB_ý àmC-Ñwwm{xz~®Ku¿Ëz§ªªïÎñí\vþÙlúþÛË´í 7ú¹HË»¯Ñ¹NÀñtú?ÿ¾3
endstream
endobj
172 0 obj
<<
/Type /ObjStm
/N 100
/First 891
/Length 2580      
/Filter /FlateDecode
>>
stream
xÚÅZmoÛ8þî_AàP`û!9|_´)ÒØ¢E½Ý½^a¨èbK®¬4ýõ÷¢z:{cá
4¥l=&óÂ¡ö$Ð.
mÐ^	£¸5Â)6	m<Ú$þtP"jþÞè^$&:¡ÿ X¡I3{L|°
ðÖi¡#þ8âW0lT<$¿â>¿âomà?<$¼JÀ`,üGë¾ÆCBÏ	Úf26d-­ ù,÷%&¤´0ZkôAxÀlH<tFaÈò+'Q<NÆ*t?cmüÚ8^17SPÂ*í'	Y¤­°Ä|³xÂCÖAºD Hpä±àÄý@àNsÏ#îÇ(áLÒÔã~ÎcÊd LÌ ,Ë&	¯:>Zx$âmÀ Ú	0oÒ¼¾_aa4Hc¥1ÁÝaÍñÂ
*ÀÉw2`@2FD£yt'¢e´)z_$bÔjBä¼")¥x]ðÿ¨¤°Ðd¡E}õ àÄÜkºJNdhAqèjL·¾F$Ël ªd#Ñ³#³~BiÉ¡g9@ðàøzö¬9=³fGÏÌ0Å°Rmî¡J±x°vZiÈÒÅo
~GÖñF"Ö{ Ñg ~bÁ0R9å'ûûìøfQìYUÕí$;ºúÔv.«ËIö¼nNæÂþT³WÙëìàî>L²÷ÅI+>X­¥g=vIB¡lAFì<&ÕÀ=ûû";ÙËú¸ÙñÃ«³ºn1\!ÃSñÓOü[#òÐÈØuB¯FÖ<6²7K­Ú}\M¥Iöl¿ë?{vÒue¿¼Í?\´íâÇ,+*y]^â´ÌeÝgü){×Ô'År9}/OÏ4$ìOÒa;[05X`¥Ýçõõµ,Û³&×us¹üëAÞçusóãûâóU±l§W³³r6/ªü«ü¼àÇfaV[ÐÀ:Y7±Å¤ôHò>®Oëé¬\¶ÿ8ÎÝÓÂ/@Ú¯Ä{ýöû¿`~ z0ÁHVþêj6ûøwØ ¥b3àdê5¬Wï%»{ÐÃºj;Í?dëÚýè°óN¶û `öÛÛOÿaé2ðõ}^½cå;* y½{q(²ãâQXÉññþ*¾Ãì cbp\»á¥[ÖWt¸óyÝWoXäÏë?D·Ø"$Âú½Ëüìúv±Äè<5æÄÛ*ÐÖÃ#asÙBÊG&\,ù(½¢#îb9Öv5M$9,±&{·½å(EUÈzþ¦b«ÖÔ»Ø;:rCtc
åV°hòDZS¨¶R;Sz6ï{}ôÜüúÜì°¹Å¸677ÖÜ;¤×§;¤¾ótH©µé¤¸Õtî­Ô­äúÖö­ïÛ0¦9³	B$lVqPB<ÐÖY¤Û`ÍÒßZ³­y RÑ²V2YÊ#\^1#ÝÀC«]ÌªµkºLÛE?ÂÊÿx«ÕÕu9ÉÅéÙãcDÒÀz#-l+G`Y"0Ma¤Øååóä¹?-fO(,§eòYÍæ²½(ê¦ïEF/9c¯(Á/âLISÜzfõ¹\Ìê/EÓIy·ÙËÓÙÞÑ[ý&¯äE;}ãÒRîÒîbÿ
¾,cÁGbóÿ2;kNÔc©ïíÈ®ùoN,gEùH¹ðÂmK}kûÖ÷m£G=zõ8êq¦Çgzéq¦Ç©Ô÷¯ûÖô­ëÛÐ·=zõ8êqÔã¨Çgzéq¦Ç4j°«¢´A É	ñ/´¨¸É*ëñÜH5¬tÉ¨ÊÆcb#´â+,Ù#xÈÄÇÄYø(8XVÞzÎù
	ALØñhÂÈO<R!ÍGì³]ê%k61q#2A4V<Hé¼ÊÃÍXú	ÞHÃ7DC+&Æ)ì2#2ÁQfEÄÂ´Ä4xqF5BÀwG]¶«+©ñðæ¶(9Ì×$ XaÍ+RBéáWLb2Ñ¼ò±ÊwR93ÈÖÕ@K¯ôL´Ä7ÉæÕb1ø´ßElËK¹r4NÝüF&cWåáÿ½°ÈÔCk/9¶P·ß!ICºà¹nÀN71[Øm¦åËÏ]4+ò¦ÚË?ÕWíÞç«|V¶7YU\ïÍWÏ{Y^Ueu¾×Öõlqæñ¥,®³¦åÜùr¡éyÏ¿Í<¶Í.BsåSâV=qíHiè[)ÛûgQUÓðÓRæÄÕN##411w"a¬*Æ¯X²h²·Móò¿UyuÊMÿÓ/y·Åe^ßþ n]×"&è3\ÔU"sØÏxÿRgeq:}S#÷MÎ«ó+¨Ý.:$uÅg%çÚ,³ Ìb¬ZÇQ^]7#èAÏ	$9lå¨p¡¶ÅÑHl_'åøiÛ»$ñ1®D¹lÍþËî«a²]Ñ6å´*Úu5çúÙ_ãíRÕYí²}Áï,$QUåÉ>i2oó¼*ÿìld>\äÍ.U<úÈÖt·É,ÀmªaÈÄùMYNçùbÑ"aöà©ù¨QÂS$§ýÈõÝ³Y}=ÂN4öøÚ{¾®s¤£5)5¹;,n*¸Õ1è&{|Ör=ÎwìMöb7ò6K¼lè´ðÄ~¾Å'E¬?«<¨«bÑî¨» Yà	!v9«ÝÅ±¤úöù³£W¯wÙ]o#x¸dÃÁî6Bxo[ÖëÎïÜC8¾j8Êûzú½É®[¦åK2ð]ÚÚÛ{µ¦8½¨Ï;÷µùòÔÐCíûXÅ¦çûjÿÛjBS Ð!uË5>ÄaØÝ½ij_±Ð	5®öúëaXU³4k9Y4Ã°ÆÊHv
êXíº`pV¹îHdy¸Â|meàcÓ¤ëËWü ¢æè·?¥Dá×K^=¶ââõ÷®¸øõV@"¿>áWîc7¤°NÉ)=k,ßùNúr{éÞJÀwJZ¾/5îÈÞJKë<Rù/À2Ú´éLguRý_ëj
endstream
endobj
283 0 obj
<<
/Length 2775      
/Filter /FlateDecode
>>
stream
xÚÍZmsÛ8þ_¡ö´V(Q¯{×ÛéöíºÓ^»o¶læ¶XYr%¹iþý(K²ºÛÞÍæÅWx  á\;ÂyuòËüäô¥çENê¦9ó+'Ü(NI7qæ+çb¸r:ógeÑè¢^Î=}xYA¸QèQ3ÅqÌÉùÉ§l·',\áÎrsrq)ôýêW¦skFn b0D8¹s~òÛ`nEëÞò±t=é9±º2?|¸°ÓYB</§3?×Þ`É(jØdE¶ÙqOmªXq7ê#'1µWTm²®©x»ÎrM½YCMÊ×³D­®T³«45dSoÂ$r]s©Y«&Ô°ÒS/\WZ3Ág:¯³B_^ø®?FÄ¢Ôy!teÅõc/&ói,&~eä$u}?°*þûÄn´62 eìKc&n
$h7f%	/3'×KBgÖøì
úúi7ByGh=õ¬ÖSPLA-ÍZSaÖÈ~i¨Á(F"j» fÀî²RÅu§ßô_WjKÝÔödOùâ©!íNgwDÈÔÉ+3ÍÎ-¿O6µ¶¼g5îÊ\±Ü£ðJïjMÚVôÙVåR¯ØüAßÐ î¨ÖÁøBÚ3Ôtf¾p½ %â§'&ÈÃ`ß¬VÔ¢¨þi§ë&+jÜ¨êÚúªD6°Õh«<ûC_WÔS7
ô.Èô7¥%s3ÅyzÆ½Ë\«ÊÎMÄÍÔÃjæyA]d ñ0°³]ào2_ëQ´I b°jp:uDhèO»lêÏø£r ðSÏ*í÷ôe,;vïà#=l±Ö.~
o×KªýRA»bQé<WÑWùÅQ³»o«q_½óiÚµf²ÊÕYcTl>Ö³
1~Ë-ê\åìkZ34öÿ³µo	:|ñEm`;ÖÍ8bÜÏôRg5¸Ty^SYÄoý»ØûlyÃmékÌÛuYpÑ¸p, nãp]°»1u<£.3lUjæ®(ªymØv¡;*Ô[½Ì®²%³¢«º,.¥`ZB·ër;êUEÃ<4e»ºiÈÀG`­Ñ v¥vJ«7xO\©µ=»V£òAËÚj$ñ=u>U«E®9øÏúÊÊ²þ/þõü«ÄözPm4¾ÆÝÒ
<µ;EÈju­ïµ´¹ºÑèºSkkr£ê!Ãí-}×óÓÁþ6Q0ÈÎTN[t«eéJÝ
	
 ÉÚ(¡MK@o²e#¦XÍ^?ÌXL>ãO¡èb6>¯åÌÁ¢7d;Ó¼b.¨Âp^%àÑV¨wìBNÏ4.Ú2YfIs½U³û=8¤AeÅñ]U¥½:òßM£pB±G5öoãåbÊcÊÈLØ¤)
bøíxÕXZ¯Êñ	¿ìUqdÝ¹à9+ã|MMoå¥®1deÖMpï0*Õ[Uð¥±¹¬xòUC°,w-#cY Xu³¼Á§ÒÄ4ª®Éy¬IA0µ1"§¤Úðé7½};{þ§­7z¡%×àDãÌ2%-YX³X)cýP{}þnDÂ35ÕµC³Wt"Ùgº2n&×eò^P;ÈØ£ÇcÆ¹ea8]ì6 "rÃdî×ä§	ÙÊ³.+8¿ýÍy	ä¸U¹­²v	¶èüµØåªÊcôÁtRïkZ?~bÐo±Ogä,Úì`JF|ã»ó¥MALÚÙIt»&Õßº%6°$8¡î¤&ó©¿aêOèãÏ3ÇÌ°	u/¾d1Ó±3ðfwR÷Ì1þÈf\´¶a»æZÞG2p7õRrgÛè\*¬M^Ï-´¥N´ãÒ¢ÑÏÄÏÒ :î;r½ÑÅu³¾IbTÖXÆØÁ@yUÒÖ4rëajù¤í£)ÅqÇÄ7|êí©»5¡½wJþ lÖ%6ðfå®~Hó¶/c7ÄöØ÷(õn bÃ·­*þ`ÂMööá?ÄýðXËøaÖ\ìoî`ö3é®(Çð?¦Bb8þiv
eèAøÿ´çô ÷6æãHÜ$òÿwÆÜÙÇ[®l½ú=IºB~ÕÛ¥vÀ;	Yíú ú¼ÐÂ	éW¹i,ÇÎFhªf0ú's'ÒTåj·ÔuÏ®
ãðnÛ4¼}x<i¾
iÛ$:á{ÕË]][ì:/i¹ö\2L4VûÂÂö®¸äÉÂú¦!|ØÉ2<Në?ïãÈeúDê­ªÌîï;­ªº£àüå¼´¿­ð*?Pòw¤A¿ãÍY»JªnÊÂîÀïNz÷]ây9\'·®Ô]ýÃ¡ÊozSè;B:B»?:2$Ü£´Xóæjè.dBÇ+î¥þ0¢-!@KBÌOvãÉähç÷aFìÆçùQàJßï[ók¼%÷=º%¯Êk¼l÷au-Ðïa»¹ïZM¡Ï^ê`K¥»î±è0-³øýgËdNWxdÂõ£Vá§³È¼_oòÂÏF$ó}W$±ófläÊ}lym¢óv°y2gwOº^Ò=¹¬ÃãzèK
SÝTÙQ´]DGÀ>P×s¼Õz
ö" Hl½v7G©o­üÄ¾?8TË  ÙS³$0õMèÃSpa+t» i^fjj¤çÀ<TtÛÐÁ%Jö£Æ(j$¤GÎ·ºÉø¥ê_uÅ¯)£¡ë£ü#éÛ´}Ò8A"s5¶Ã¼I±Û,Ìë¤@Jû[ºUP³V±yO¨zÌ@aûð°mW5GýzÞ`0¤çã×,ÖÇq±Fàè	é³¾¥îCùÛf{ÐÓÝKÚJÍî2³NÃéî¢ðT(»Ð»<òY3¬/ÒÁ¢oÌ[ÈyÐ¯GA×'ù#±Çr	øê*CÙyÊÄ.z¬ð)Å\¾@Óí+4¥DQ2!ÂéøF]7¤[_Z>öÚ1¤³fmN]ÆF¸½ìMRïdkæV)â~Ùµ¬S Úå+·µú&ÛnõSÍ}
tÎ3öÏQäbø_Òú íÿrØÿÝÁ5ÇÆBô	#é©&½ÒÀï&°p?/7Î¡PôÆÈêþîjWöZ7Y=ìørbûúüð¦åwC~«kg_9ãçÈNèJà,*CeÖM³ýéôTîm`ëU¦Ü²º>ÅÚ)¬óö2yøÌ9üòÿ¸æ
endstream
endobj
288 0 obj
<<
/Length 2719      
/Filter /FlateDecode
>>
stream
xÚ­YYsÛ8~÷¯`ÍÃU±·25Jb;ã©É1±R[)'[P¤Â#ýûíF7xHt®h4úB÷Èµn-×z~òtyòðBÈZ8È¬åFN´ð­8òÄZ¦Öµ8þl.\×µE£föaùçÃDVIâD¡ ¦zæä|yòé]Kô]ÇµÞ\p­æþ´\Ç_$Ö¦ÜZÁkåÖÕÉß'.Kë¥mûð{¡ãÉðÞóB-Yf]ÏCPÆýkÏÞÜç®xÏæ^èÚÂw\÷Lôý;5@(ÉvÛSêUj§d£RúR3/´?ÏDh«jOCÌ8ûz,kÍç,À\ß%¨wêzÇwõX¼f£
êùG#^/ÏeE¯T5YYüë¼³%O|UZ­Ë"íÄ¤ÎMYQ§,uöJVÓzß%è ²­~)ÛE^ÉæÐªç·XSç?Ôt¬û!Dâ	U}FõdÒN° £ºàDñn&8§¥%kÉke^ÔkkerêìÊºÎV¹êviaÓÞ4LûVDyj[±J¹3H²â·UU#>;Y5¼ ¼9P±É¶ªnävÇ²õN­³÷®ë©Ô{d¨ëâÜöþÀÂ¿x1wý¯ú¥ÙdU:s"¶}7?K½PSgg_ª;vÆ"©µÚ®Ôÿw¶Rx,ÐÒ¸
rºFTÈÿÇm¶¡ÝªÓîàÀÊ©*ñ²,ï73©;JÙ-ÞwþP9Äc¼ÜîàÌÀ&ÿÒÀß­Ì)t+#NJ${4ÒÎ´/bP@]'bØ}áø"¤Ý¯`Ä oÎÎfóÔr=ÇwO©ÿ´mÔûë2ÇÌÝß©y£R¦¸}üÚ×m½¡Þ8c¹f`

¾'l¹*Q5|8ûpµE\¢)*%ÓºèCÞ`q °XñXgjÈ_5qÕNÂqß¥vm£³¼iÐÔH¸«f~Lÿ-\H ºï'vvCCÑíËÃ¹f3¶-dÌ6I%rßi{I>À)?0goùb$h0 ½Éàw²àúÐ~B3ÆQhÌÂa	\×I<ÁD4ª
fïCÒÕ GþèÇÎ"v¡Â	ãÄð~7Gýþû\÷ßLäÁáLb³æ¯	®&2Ñfºìg_ë 2±|¢1-¸Ø3t dMJIR²)ÓrguC£[YÈ[90§@`ÿ¨õÃY3(sô:ðp¥h4	¨Ð´®Èn=ÜaË=lözSbjºÓ©0BYVp¯ZÕý$GPJ¨+ñ8%ÃÙß »í:´³'
¦4¯Óéñ¥ Ò³+tÁîB|éV 9;Ytwã;,Â Ñ¬bÁÙÝ¤jº! ÀÀJÙÛ¬(<À®0Å4ÂÎ3£4OT©è5jõF­?¢½Uj¶"»Jëÿï@æçéÎÌ<ÍÌ« vðÀ/OPxad¡!zº@Æv¥¨5NÅx6pv:^i¶f÷ÌhcPð].×jSæ©ªXp¥Àµ1Ë$}·ÉrÞ\Rs$vÖÍ×$#¹åP14;¶IQöà"Ò´»:ÁûûmY)NÁ[Nµ¯^ª¼á²ÕÇn5åLG¸DÿÚaÏª¼­T]ÿJÎàA0³Ì~° îxdHjH§uäèq]4 CxÐº^ÇÕ	y1ÅÐÆ8@D÷nèrtÒÔ½bíÇÁÍÆÙn¡I^Å"7²/y¿bGÇ~ìèr?tÆçø=¶È¾¢Cùì`ÈÊc@3wFvÐL:ïXªrÈ_oëbI}òa4X©ÓRñ4ÅäÙ6kX
ºB÷ú&.ã:Z ]±.s±ú(Z¹2Öíngª6p¼ýÝ OËá|×]á33¢­]÷ÑíPPðÎÖÜó!Éò£0-¾¯=Ë¾$z«kéS]K¯t©ÿ_úo¹Òöã¯ôÿS2ð}°ìíîÝ­²nW5\ZÛÁ5ÑÆu[å¾Wä£Ðäg4ÐÝÆêoÍ¢8@Í7U¾a	ÞÕ ?ÊJ·Ý×
}!kÆÆçï@Æ&CdL·xÂ(»»~'ÎøM¨l<Î":?xxR$ ï¯ùïà~Þè_5*ðîoæÆ±?Xþ=bÈÙõ¥Ïhlql¹(ÒXö¿m1ëåÅ¯LÎ z·eÝ<æ·gÚD»c3a7«;õ*±òbÃaìßlÍq@±´=wÅuwÏ&VPsP¼öSLÉÀIÒ?Ú%á&Ã´Ðb¦U·ªPÌyñJ:èZñÜÁ!JÐY1W6îÈ3&¶mkSÐ_b*Äü<øËòKõ¬Ý÷,Tì3IwrºÃ ¥Y
pó
Õì*Ù­Jñ-¿þ)Wä6Ã è/àúlJ¦ßãX÷¶úM÷¬ÛJêG:üLfã6züË]øØèÝ&ÔùÔeÊ~ùÜªk«§HS7P9?çIà,£J¸÷êü<û¬-+FÜ>Ë¼eªz¡y·e¹ëY<¢îEû3çÎ=:µT½®²2-«²½Ýäû)Ë]÷q!ñxYÉO+¼Kq&xÛäò´ÊÔM¾Þ\ôÀs¬ð^0öÄ·ÀaÃëIØ;ïØð/¶Æ·û¹G°A@ÕQ"ð;ã:t<7|9#¸ÏM s1 ãtÏÈÝ31ÿæÅwKNªHF÷4w¸Í<óñT½KÒDexNÙR³øý26ÚdfÒKRw¥°´{¾¾¯üU®;ÈÑ³dd_[¥¯f¸ëÒhêgô0éóJ©âìª©TqKOªÓ*ÍZº
Ðö¬§®þeAl_§ÑGÃ¡ù<¨«·½©?E¦úw	ßÍDäÑ]?anqÇ®ýi9äÐ?ýÄ	ýîIë|ðúôÌ}_VN8ÇXLÁgC3à¾§T°C©{«2íîmIÐS c¡4ìsÑ¯JaÒÐ+Å<òý$Äi&dÑýöÔÑ7,ìlè7ó¦jTìIx¸]jùY¬º]Þ5IúÔ5PIC@üðF:kÐyL6:tÒ÷Õî4æ¨gÞ¼FÁ¡ø8"©Øó»°_ôyhÌë2à¦¥JØzÃÚ(TÖ¼>+¦larQ¶íP
>Q{PÝLýóåÉÿ ­Zê
endstream
endobj
292 0 obj
<<
/Length 2620      
/Filter /FlateDecode
>>
stream
xÚÕÙÛÆñ}¿o+"ÁMÕªi¬ã8²´ypI~ áP8¼Ù¿O_Ä²]øééééé»®uk¹Ö_/þrs±z§Td­uäEÖÍÎ
#'ZûVùNbÝdÖ';püÅR¹®k¿©ÊVíâçïVï5Ú$
Ò#ÎÅÕÍÅ×º»«k{¸øô³ke°öå:þ:±îó`k (®UX/~¼p§ÜÆ3Üz¡ãAÏ¯ã	Ç¯³,oórí_ðGÏ°îZKçÅkÞ-;¼w¶nKßìmZâÀ·7]£3¥EU
°ªùò¶:lò2móªä»¼ÝóèªÐeã,a¤ì×pz¼9}¡lÁÐ@BË9?=Ïÿ wºÖ¾Õ0^ÀR1ÞT<y²b!A(gF,Dý±«Z¢²Xz¡K×ÃoÊ"¶OË[Íó¤õîèËyª+×ñµµô|g­DSpw×vè×½ÑX¡&áûa ;ëØUlvNè'Æê®ËÈ³ßÁ¯ñú½"È4~#s;X±8A@ß÷Åàfk×$T(Oó¿ÊHQ´ä/¤ÄMn¿áµC>Ã]PnÌ?f@ÅãF½]¾aRxAAQAòõ ³d¹Äf®[0½Ëô hÕÎpÏßëV^àÐPÅ&ð¿õ\jðTäIÏùO$ã÷=_Åó7ÌïgÈFïÇá}$¢7=rà¬åd|G%#ægÎø.GHUÝß¼í¾Ýçå-9Ã2}Çu}ñÑuÑhv "rX/AÿIGÒ9 îPßUWd<Ý}&ì#å ´­F«°Wo¼Õ(÷u`7Ýv/ËÍ½7'õ¼¹oìÄàr°oÛãËÕêîîn¶7ºÔD¨Õíµë(¯Wè«§HÃrÏ®ëps²¾ë$þó9fB/WÇ´Ý¯ÚjÅs²ÙsÚ	èË¿e0 Vw8É:ª{0|ÜbæXð¾u>u¥ÞeoÈó<5xi6ÿÓqÃëo17Û:?Rö	><ûÂ$\ôk¦ÏaÁÃØ'Èd=óÄiNS.£«Ê&oZtZ®ÊâW(°ÔUS#?ÕÜév&?A"y®ç@¨¨ì-i	ck»d48ÚuûNÇÏ6Ã?sâwèÙ²Çàí Iø0ÄÊox¸ÑE¿ãÀNW.¨NÜ,©»¦fÐòA2¹?j!J:¥yI©¬@¶Wà PR÷ñéÎ'HÇ.%ÕåµÞre3®öiÍh` e×ðøï±Sj×Î³ÆÜJ$§xì·pLMVÄ$q´c§ãSÊîÃêè¦äB!T`t_#7 ·uZ¢aW'l@ß¨öÆð"-¦ÿîG!XíÚðÑ6
°Þ¤fS!¼§%U%JDÐis¶"ÚvÂ- íêJöa¼Ãç±}½ëa<0¢àM\I¹ðV=Kw-gGVâÑ4 F½aýZîÚáJ
.¶Ï6 ¼°â @¡ì4#ñz£ÐF·<¨nÍ*n n/XþÜ\6VIDFmÊåÕÛc*(bûÓ¥ f AMÙùiÞòuÚÜ3"w­ÓV®}¨( ÔÇt+«ùäÛ ò~EÍ?UóEß^óE×|>ÁÚÜM«wó¡#ÛL×3®J"© »Zí ¢xpîqÔtºBë&¹j*[ÙÌ ËlLl´R@°ÂâÒõFfÄEËj©ÍÕ´¬tûHÇÔ¥`Ð»txñ K®qIIµì½$Í]R2ï´LÓc-g¹I<{nkz§ÅYNv&+MÂ³Üä4*ð§`¡Á
gÓSy*I²	ûúg{{°_R¿Á ¾IØ~üûõû¡íiNhl»ºÆÌ¶dqâ^ðGtÏbT'eï~LKÿ®~xû¨îöU¡SDÐÀÿ?QÑ#]óÒÇþ]#tB_^Ù¨8Pæ¶îzâÙJÞH ,"È1­[É^ªÕðÖ bÎS£í)OQÜRâ·&häbîkpcå[²¿Ý§²À@ã@£¢ª¾ðG I$jÄl*±CIL?XMBgÌWÄYÆgW´¦rªx(ãiôå-¾Äá{ìZìõìþ\%@ÜØëFS]÷¯°6üÅà>×¼¯Ç¼g·MßPß<Õ5sÌF¿£w×Ã9-ýÎÏÃ¹,oNAS4?qê9Ö´­¨>PÂ{ÔØ Åì$¥À8÷È{+É¢BNÇa^¦ëão7Û®éi@ãööÃ)ò5~ »|~®v¹Ç/
.ÈCEºõ\ðI^Õ>«Àî¢×mÀÉ¸A-iÙïÁ|lôdNñèA §æµpv§7B+z¢i¦çOî0:¯sîS£BDåq.âÞ
¼rj6îiBy¯§?]5Íy<Që°]ö¦ÍIÛÔëÆáçö×Å]u·û0¥×J¿ ¼Ó"@ä2M92o§ÇÜb¹6ß%Áí«Þ~áRü¶«:c¯÷U'^±^0@ÅúÄÁvU!/½ãlt#nx~ªÍ·úÄ5Ò¢ðåfé{oâõØàCíÝt8Úç·b¡Xp$V+ç;8r?ü#NäEkö"èXs~ûàHÜòF$±qÐo¥È.µÎt½
äBbHQüZç'ø3iQ§:1 ë¢dáÀ T¡¦GÉu+&_ Ü÷÷'Þêþ9UBù¿Û4æ»zûÓ~;¢G'o(è57ßå5:¯å¸ßp­¥ç£ßB÷ñ3Lìå<åW³tÅNâM_Ï®Ûq;<TÊ# ]6zªÎ Ìæ¹g?+ÇóÝÃ*æf	uD%;KÄsj!ÃÙ¬¥ª YxÒ]¨BbÑyø+u®ç÷W½`^ª'µ¨· 
)"À)|% x½ëjÉ± 6¹_6QøÁ>×uZC]y¢`tÐÈ®pJfC§ÉUÍZ¬¡)ÒfÏCóéÊüÛ9å·ÑPÒRÀN·²mÚEöÜX´áÿÁzÅo(îòrÀþõá{äìÛãHøûÆá5/ÏÌg%Mº¹Ebüí7"9{ó«ÿ¬
endstream
endobj
298 0 obj
<<
/Length 2203      
/Filter /FlateDecode
>>
stream
xÚÕYÝÛ6÷_!`_d`ÍEQE KÚM¦Éº(¶²D[ºØ#É·Ùÿþ¡>¼Z¬ô»Ãß|öã9ß/þ±^Ü¼æ<t~è¬·Y'
uîüîL,WÜó<÷e]uªê®ßÜ¼ùhVÇ,)<Ö<WëÅç&z{Ìã¿ÿé99|{ãxL$±so8N0`ñ½s·ø°ðÆÚN8EäD¾d"píÛíråGÜ}¨O8¸_rÏMAmóÖÕølÔV5c<ø~Û©M-T£ÎÄýáy~Ó´J©|*÷ßÙ¾<l\Ðü®Q
¾v©¼ÿN«îH@^/}éÞ5­j`iÙ&­²BKºÖÄÐ*æ» ð7¾éÁÎ,Û¬8gh£cÚÀ&=÷¾´#ÔE¹+Ù ¼dõáPW8Þ+­Ù¿\ºj$Ü9U©3aÃJÛ¦>ôõAu­}Þ¼ÄÈ¿\f¸³ò}&ùw­EKPd[7è¡ñÞ­0ÞìwÈå>¿}vÎq1£àLÄ>±Äj£' c»WéöIoÚÛÍünéúb&6WÂgÜOÀ°§ ~ß,Ï½FÛ3¯õÞ$ïRDhp¤-y§ªü|¢Y·9$RÇKoËÃqÿ@ìm´»èoB ¹#Ï%@ÿ% ðùÛCzÓ9@ø¡{Hp`-`ÞÉOzÕUB"O»R¶&ÕÛ	7F­é´¦mQ7ª«ìÀµ"n{Ê`acýØc2ðmUøvfO¸7±wõÁ¤J»Z®IF.{:Þ¼¯N¹Ae4M7ÕöüÃcåx0?víÏ)¢¤øH2?J¦ë
HóùTSÖ9EKYå¥¶¹Mª#nGÔûv´ GSåÍ~àWÆþtÌ=x®K"1»@aä~?2àÆ7L¢çöäÆø;|)[|¦øÐµé6t±UUº q·uC|ÍÐu@"©Kwíc&KÉQ]ãè_§ìK\ß GÈ²)å®8I©-&`Ê«/)d'(ªý)Wë%Ý÷ÿ|Ó®>ª:lT³.Jq°àÄåW¯1iÇ^ÝºMúV/ðPíhjJÇ4S6}6t¿ÇosmYM,läY|DAäå,DbH²± ôÝw£ßWæ÷'ó»ÅNÌ¢8"ìø67êá¡+Ê
#Dlz½K!È4Pg w¶Ú0úcIÏ¿¿þ´ò´oÅ$a¸¢ô_L§:mZý9¥?ôº{"øíæ3ü~9mûãÌ¡*y°_óvFlÈ@°e¸5îÎìýYÌIITàîJÑÝÌ¢vB¨îÑ w´9½·[2EvCkQu¸´²Ô[*j±`ÁêX[b°M@{=t
Ú«g`6ö7LÏ#¬wÿq;ç/ÌÁûÃ,¼æy½3~1nÐQ®ðtÂ|)ÏÒáÒã ý|ª»t0N¶Lû¦À¨(?¼²×À@P¿~<k*¯7ùcÈÓeg/%#ÿùÑ%È&ÈÐ*ð|èlô§ÈÌ¾ëÓ":BÒT!=ÒÔwsÒÙhc|ýû£ùýÅ,ñóL|È§0ýÏææ\7¯ñÓ"â4þ&@ð§q	ø:\]Ì*+¡´>àvk²Ã1=GãI?ÎYófº	5¤	tÆIdúó-W{EáÙÔ<M¦¤ñÔX÷Ñ¦Ú_õ¡óÁã:Ô!/§=¿tÇ]Ô§}cOÀ=Ô:êñ\NºÚ´XÔõÔHL3sÏ±Õ\6UÒìÑØ$t_iµ#Éï`£§#²XÖ²ê:?e:o%	ÒXf:!À4GÐÊGalOê-fî,Ì½M£yu5wÚLñs> ©EJÁ>yi3>éD­èÑW3Wø®]ctMëT^»O;+Û`XÄhãùÑà)ÇØ0K£Ó¥pÔ£@
6Ai;zÆh?£!,_\n5«]Ñ	:MÙû¡m}Þçn&éãôÉÚ¢¯°¶¸/Ê¬8¿(»~Ùeè6Î£Ã|"]¡tF\ï8Ð8e®cþ ­¸.@Ø«­)ÝO>OúC$áÅÈ]i' ~ÎÝ[£ZéÕ·5mÄ Hý¹-GºqM¯ñj.Ö¼Nò«`c5>[üX·m¹Ù«©º©6e¥lw³XFÓöüÚ¤¿,G&1ô-ö¾ÙÖë±shõbé§¡Ýë&Ø¥%=¬·v¹¢3å®êù¬û!H¸¿PEqxñuÆ¼_¡ìúñWz]à¢'H@Ý»ªÜÛ)A¹MÓ
)hpM17z°Q>f¦ÂäHÆ{dMNplð.¨¬O4½iézKÐõ3ÄlÏã'1¢ÿ¦ç¼çÐËôÕëÜ©	w=°ÔóiÂq½ì©¡»ºûR&,æçåÎ¹I©öOèi÷¶8Ä?$`-Ê*Ûr{p© úCwÓM}êÎg¶§úJ]ãP1¼S´7uAB|'+O¬|[!y5i7ª¬¼¯¬£õúûà³Ëüï¨µaN0)_jºÔ¡Élí0¦]9üB]yPlö*üÕzñUzÈº
endstream
endobj
302 0 obj
<<
/Length 1558      
/Filter /FlateDecode
>>
stream
xÚ¥WßÛ6~Ï_áGh|&7ôáºÞuíµë(Þ=8¶sÎ¶2ÛivÿýH²Ôºí%)"¿á<9Ây7{³]ÝI;+oû±³Þ:QìÅ«ÀIâÀ[:ëÜùê^8_H!{_ìÓ&ít3\¸º[Ê]¸\zq$Á­1+ÔÝ®gÍP(9¸¡U³¯ÂÉaí#¼`µtF³rÂ8áÎýì87q¤ôVQäö#/Ã²pöIVdt3_ø"YÏ>>u]Ðä}WT4Û6ÚÌB7­u·+y¹HV¡õY*k¦jS~éÃJ¼U"$åÂ¥EòÏù"öÝOð+Ý[3ÿ<ï{bXß&ÜÆ^ÄVá½qto®{åÐ[-eÊ2ðäÒ	î'ö<#%Å ÚCZ/½©ìë|±QÚ°@XOø±Dä³ðÄ ³)`ct%¡+Üß`w?rÈ |´þ "±S]§ê'Ò=yLnë®he]é<Ï¥p¹ÜN¼IæûÍ¡#eÕ.A"Ü½n[µ)ÙC§il»¦¡5~C·E¤ÐãÛë§ÂT×((iÑ}É7@ÄCTà
«6îQu;µE¥2]êºõ#ub÷æÅêöÞ~¸JIÎç$ÖLia-rZaÂa¦ê¼¨DTÐôM QO»îÍ_ôV³¦ò8Ù3Û©2§UH
ºïÓ<om[ÝT®û½M½Ma¡:¶( îË ÁArrµIènîX`êøÑ±ª4)2í('vPh²GQV¬§²h[$U,«Á«t¹t+:N¸`å4KYK©ÀÊ¤â%ßRÒ¤4iN<ãb¦ë.U5ÇNÀÅ§3/Ú¬Q{Ä¸LNc¨àÓÔJ ã!?bYÑz1eAzxÂSñ²$Þ²døÒYÇE»®@^­j»W 
¸×¸2à`lä¬DÌr]°èSçÑðÒðö( RÂ\ÐÀà\p$£¨Çì-. ãZV¦Â@ç-Û é~_ª¢µ Z»=p(rh
¤é/>T9Í,1Ô9s0:Ê[*ú07óßiµ/¶kwúP²¯ö°EÝ!ü¬¸6ûº°ãÕ]ÚàZlýÀË³ê2¼¼Ì¹gµqb÷þv1u½àÙ§Ò<8&úµVß¦WîtóÜN4éEà{Ò_Aø ,ùI·ÞYéÖéÑAÌ¯	Z{¾ì!¶©·(6iÛ³Õßë)5¼½ÉïîçZM¯=3ßbFÄõ°$¼$LNIZ+¼'§×4@W×ß£Î|,_ª½ÊHõÜ±8ßë,Ã&JGÝ p8ÍvPpp^ÛÚO± c/7Ýba=àxVåk(£ÓMêW,íÓA)¥s¯Íd ±³ù?|IËgÂÇÜE8ÉõÓÅºÿyWdçúGhêøê¹dóõ3Ü¤{óûÛ«¯/ê¾+:RlÌkxÓi7u@{ÕCµi²´mmÂëÛÆt_TÞêæ,|h{xÎu¦¸ì¡ßpWõÏéÃfTGþiùCÑþ³aÄûò#f24<üÂ#B±%eÒw|¿¥}ëW´fù1£ªõé¾¸æâëHôá[Ä!AéÃCï}ø ?áBb_ ÂÄ¡CN(EÄ±ëÁ7ÄmGaà~lH¡Ò»Ùª´._0À?g!öýL'|bY~Ço1P¸Ø}8Ô;íhqô±qÒB¡ÅiÕ ~Â´PÎ>c¤É¨ß¨W·G@®µr­¶´ÉÈ÷ødv3Ð£-âËÐ'æ'/©ÛõìQd|
endstream
endobj
307 0 obj
<<
/Length 1135      
/Filter /FlateDecode
>>
stream
xÚ­WKoÛ8¾ûWð(ÃDÙíaÑîö°Øn,Ð4Y¢m¡²JÔzóï;|Yqôb3ÃoFßfh6 OËÉÍ-¥-ðB0k,%ã9Zæè>p4)!$¸iªº>,?ßÜÎéà\4cS5Ñ6ß-$öÐ¡l7¹ (ÝgD0_ÌÑÞXîP´ 00!¨Dw/2wä6¡Xð%,Æ<¬ï¿ê)ý4d1	²ºj\6v§¶²v¹®;'Sÿ§»ÇR¶ïLØÞÞÜ&|àà$JPÈ¹óùwSç]¦ºÒ ÆðªâE[;}Ctô¢Ù¶»U)­®Z»ü~2Â«àì\\ÿ#üçàüõß_ÏÒBN13x2-7RùÞñs8òe×@<AdLèk ðoùJ"îÇL<üâªÃ³7À?[Wcxþðú²ýåuBèJë·×ÕÖ%z^T\G2¤G|Ý
©kéË­nßaM«`CAZåVÚJè¹£Ó¦OváT*¬­ò°mº^TT`5U§¬µ36êÄVY8»ºqÐr­»;+då#wfÛw­¶Iî¬.]êCáÌß$HõC¦U«dÛM½¶6]¯78eQI»Z52ýnÍ³$ ñ4Ø,h©¥K¯6µlíµ÷«¼PÙäGx¥fjkµãií7 ¿? Ú'3°z¦ðä®Ð,ÿ§ÒÒFÌ)	>ìÁÈÜGlºª½ÜÒ¼0yZËFV­¤ÚKYYö%¨¥û)¸©Oç²ód
exºLþf?íaz]ùw«}óOug¾èEj_º´,t@ú¾ÀfK;yD-HÔ¶Ädæj ê>"whYVïvu*éâ$*m¿;äTÊVlòºãPÒÊ'6Ù¶nå3¥ÝBJu"\ÿ<$¡ö×¡ÌÏ5Qè6ÃÛ#]³Ã-0«»2?ÓX{«M=óW²ÓSAóC;Ô
¨­º`Æ_fÆ´¶ü1"0#ñ@Û1¹+]=ôÐÄ@xT¶ F¿æ	7V<¤ÒØ»j«Z«­×îL)ØPçÙMçÁ­4³B÷¾ !0ûè.VGô*-Mïíug;RWN³J3~ú­èÜ7=&"çYðC¯ÓÂ#²AëÉæÉl°v²agÉ3Ð·¹)EPì-Ú¿²þMAH5×¢gÓùro
Ö. ´ÈÜ!Gùò0Rgxe³1±'¼BfGy2náé¿­ýá+8ë_sq1u»µ3]ÏüKt+eÿ%6¹ð­ÝÙt+åö÷3PZè:7^ðÙ; ü÷ü	sá
endstream
endobj
311 0 obj
<<
/Length 2165      
/Filter /FlateDecode
>>
stream
xÚÕYKÛ6¾Ï¯à-TEàÛ9¤¼½ã$]R¶I¨¤ÌGýû4Ð¨Pkk¹Ð Ý¯dÞÖcÞoþ³¸yþ&ã^äH¼ÅÆ£8£ÈK0È¼ÅÚûè>û¼x{ózqóåÃ2æq/N$GÞª¼ùøyk{ë± Ì3ï`)K/Ê³ æiïîævz4ç©Ç#80öpÚU öôx6ç1ÿål.bæ·Roækù1Q©jKÇ¶¥áòì6Ì$Á½Þ×3ûÙ<ßí{í®	æÿ>ã±oGbU?8ÒÈ5Z»há¾n[µTZuJ¶8¤*"Ææ¹4ÈSÆs§)0iûu6Oÿ3ürÿµí¸\eÃwÛ&A&àÖntg7]ÄQg<4Ä<xæ !ÑÝÄ1H{óªgp«(ô	°ÝÕ½&é,I&õÒNÕ}{.ï)a%a,0F²XÝß]+ÿÑÉjí «ÍÞ<YÀ,ä<ÈãWÛàXZÑáðÔ/¦8âD½Áv-ÛU£öª«6Íc.üÛ§T­4{ V¸Ú¤8|ØöÐ¨NÒA8²/V6t`S«ºÜ+íF7nxJoaiýô&þF\X5ÁûD¢HªIµ Q6õ¶)ÊÒàÕf ÙXº¨¶}±¥TËÂ¼5Û¦	íàU´FøÅHbÒxd8U,OÀ6®Ü&6°¿
v¿ÓXúø^óÒè;Ø/Ëcp¾l"J«ÖR®[ìäåçÀ ÿ¼©òGß*ôo=!¡K|lh/K0Ù	{$)¥A§èV ¡u@¦]×í¡/6#%Àc9Ò¼ÚÐÜc¯:$<eùÅ±EOB$ØÛ4u=UFzóÚÌhÛ5jÕaß¢Êé"+Ôv7g.óZÁMh¤pË)¾p|É® ð52-la@e«ó$D<Ö§ñ&² a;u­±×ÈV­MlbþT·;£ìcÿ²±,fóÃ)<9­{¸sa\p(e& ,Ñ	b8tÄaËØGÉ!Ø"þD£ 6|4·<(ÄCh¤ãÂVâcÁt;óªÍH)»]½®u½=â"Òn×HÚ°`ßâ,Ù(¹¥Ö±©Áª¬¹ð,DuzbÍ`h¹ÐìÕy"8ñAÏÑRlÊº!{^ô&ªî;7RzàºÓÉönz­s÷BW#©Â{SædOÒÜûD ãÐâjÚ²Nª©§Uå^ÓV­ÓëMl ~I<1ýì_"ÀÇ8ÑAÎ !ê»6¹uY©k¿IÃ½æ å3ë Ñ÷²ygo­6=©»»XÌÌ6ýV~éeµ{ùÚÞ3Ï}×Áj{»åµ}q6Ë.®º]SåÖÔþØëNÍµ2¾Ð2Y­Õªèjò"£­Èp­G<wr|0¸ªÅGù×hÙ«ºê¬óuY'nþ,i7÷ÿµå@	@õÜã^®×pØïòA6Ý.çÁ1Ê³y=Ã¿¿ô¶b¦ÿ?75tÇgãÛíx¾l>H°¬$¸(¶Ô{Uæru'ÏzµûcÑüÖï)á âL£x°)æÞËÃ½Y¹#ZYªx¯jâABJpa\Pdâ¬$Ä¾ó) ?ßXd^'AÒMXçá,'°¢Ðwr$²øÍÄ¦òÌ¶E)Âöùè¾óïw¤LÃôWuµRf¯ÃH§g9adxF^2®ß}F2BÃoé1~xq6}ó` ñ
OÏvz=Ò1/ßÿü¡£È®¤v6%Ï¦&¸M]êaÇw%£¸M1H75L°7Å¢ÅÀÉ5_WXÄ#ïÂbÊJÛê)ä1HþkSy×Á_#b¦©écª¾C¢d@	X_´J±o
ÅRÓbFhÛ"Uo£K2¤PÄô{àÌÛ±RÓV}WEìCPO64x®I÷c>²ß.«ÝCbÚ/^.¼ý0¤c9E}&sË	õrÌ+hÖ
,göZÚò4É0ÅoÁuµÒý4wQ%ª²Øª$3Êç[ücS Ú8Êù´7(àÑ¬\Qu%
/[aºg¥Óz$bÐÕXëË{¿Õ¯º¾ÁzÒ#«%{ÇºoÜ§!·,¥î¨d`ûZëÜÇáãS1¤E-Ntn¶õíÐ82°±¬lÆ``ßò¡-f².g¤ïÿºì#C$ðÜqôÑÄßÌàæ .9ûØ#ðÎIr£Ò6íþ°üÁ´`pë3­n>L­¼âÿXg/òÂcúÊq«Ú¿ÐÂrr©{S·ÄyRG²ï½>'¢N£¯';.÷3`;_úZµ']vtfÛÓb zëäìg¡LØÊ>ËKt!6Y~Uü64ú·e¿±Â%)LQ(Ù$ôñS-Y×Cßçà¯ý6Q´Ûh')k4}î­¤Ý;¥þ(bà¢!|Lã NÎË±F§¾ue+k.¦c«Å¶\êú@ûõâæOððÅ
endstream
endobj
315 0 obj
<<
/Length 1794      
/Filter /FlateDecode
>>
stream
xÚÍXÛrÛ6}×Wpô-I¶Ü4ÇDø6£ú"!	5I( iY3ýø$  (QIÚi<ñ.gÏîÀÐ¡½ï¼s:'7g¦6ÒGCk¨9mÐèv¿¯mýLs|möÊ²^?:;×Nç[Ç¤©úpdÓQn}Í;³GCóé»¡Û£3mµþèLÒ!hÓÎçÁ¦3WNí+§nQOLþr_>l× $Î\¢3P'§&òËÉûf¨s¦Ö3M}4äÎÌ£GöM>6ë¬AÉ`v;Ax°éß§±cwY½ú¥ò¥ÁÞæÃ²Ë°w?9¯N£òeì(Xwýg3ç7Ñ?qsÉyÀÂ¡ËÐøµ®©gÝãü³[ø|¥96üÂ¼èî5úfÊð´	s%	bØ`ø*£å¬øÁìÞõb_ðùàu°.£öï_|÷è{¢ Áæ`Ô@|è¹1ÂEYxÄ¢ »lÆ
ññ"cÃ1ìóàØìÒ ±k~(ÈèAaTà7{`è--,%¼ ña´äD(Gê1Ïyå!i¹È/70^U øßÑ,±"ßÂ7EN½­Ú1ªpº/Å/±uüòO1O]1r1¹K;èÉÚõÀ®Þ³i+4íV-Á¡ÍÛRzUîì.û,Ãi¯ÁaÙ<=ï¾æQÌüÝÝ»1äqh;Sè¤»«h±é.W0ð1Y¿² e0æÅµ( ?_®P|Àã"/ùÒeÓÏ9åàz-Ì­LÉ¢ñÒæÏ%$ØVYUÄ£ð¦¨1AQ\.T?*).î®NZñë: á;1g?UgY§J1Q¸¶ñJ_/nyjWãÐ¢Ü7ö	AK-:¦JkÊPêOÀåjÆY6ÚH4« ÒS¹Rc®m«>	c	I\^mÑ
 %ÂDcæô&e\$)ë×îÆnÀ¨hPjì((Bä7×ÝÆZiI4ýãâöáÓõô¼&w(JG&W¹í¦ì¬>á­>½»wäGcêÃ8u"¿UÕº¦hy4Á]	¤K¢RÅÃ<¸ØîàE+ÜÜí~Éø~2v¾¦*A½fUÞNyOE~¾@Î[oÌ/±^}Þë9­×"ÊI^nt'iBeébt;)à Þ-j¿¨8)E	FIVÖyíðòþÎß}¹ÿ2mV½­øB5Sg¼½¬hrK"÷DI¹Ì²Æ©Ñe±TB<Î©zòRC@ûZ¸ÎopZ@h Ô;ßÉÅ¬_é¿ÞímÏ8=ïª*/Û^¡Æxo x
¶ûICVEæ[ÝzÇ¢zx»å£Í_ËüÃ&ÚõÝåäë3¾¿SíG$¨eè#K$X$-p ï©Q¸^ÌÅh|ÓÆ|^<IÙ[èUÑa8ÔX°hýE·éö$ÙêæÀsµAIàsÕÀ+¢û$*­=,xóDÚ¸Ò}ÚðÂ4´ôÓa_7ûAÌ÷Oô Ý'ñ^X%XôÒ©Y*²u£FûB@¥R¨ÎÜÊ,é·`_Û³ÊtØÉÝ/+ZÃ¡~ÚÑñsQ>¤ròØ×Gg& Ä%FÅÊKÈ*vv¼5ê=jQò$¯U¸ª\7x+(Wco5Fèº®JÅßéVE#B%ñí¡$âge¼ñ6¥ßü£ÇLÚ`<äçéÖÍÍ^:Æ¼è¿qhz[±#ÍÖ¨ê\³7tåt-0à@(ÙÂiCdI±3öMü©0g¹Ê}ÙOÈlCYÈD®È·D¬]ï	ð ­ê(:i¦<Åð$l#LÒ<ö³­,Ù×kíîxIÑíÀ¥QwÊgê¶²ULÁsÁc!i($¦ºnÉ½YtÇ1kÑj¶B.iÞSG[W½Hþzp£(?(4ã§È«Ù×SWWùÄ¥Ûê]Ç(*öt¸rÞ?áì³_Â	YÎH-´9&Ïà_0-Yùä§v¹*Ó»³õ: Dgm»ÑRÜ½ÇîÇ;	.wK(oªÒ&LÿrÂÍ¼{å«ca¼å±uå+û	*­T¯Rß«OZÂj6EÎìGÙçêïµÓùõSå
endstream
endobj
319 0 obj
<<
/Length 1649      
/Filter /FlateDecode
>>
stream
xÚÍY[oÛ6~÷¯ò0¤°­P7_Ò4E8Ydigk-Q1IÔ()©÷ëGI¤î¶ä8Ú ,ç|ç;R@ºtÙû¸è]Li*OGêHZØ¡²¦ëÒx¤ÉiaI·ªöænñ¹7[ôþé)lÉÉ£©ÆF(ºdº½Û; YìÝg	ÈÚt"=%#]INä$G÷¾ö@QõX+¨VF#ÙÐi¬¦åçäÍÐPÃO!rÓ;l'ptÙHþÓX øñûeOºMÆ+Îp!vÒ»ÒH)~DÖBâßu»hWpWÑ ¤¡¢ÈSÃØd^Bì".éiÔMÈ»Fh?»ÔAªYHÛÙ~§qsøc/ë¾³¡ìi&Ë·0¸³Jz!G ¡¨f[gDJÿUôïÂíG²äéÅ'ûÄÁáL+}Îóé;[ùåxÒk6ÏYïný¿,ÒÁ~¶èÜÖDVÕ²¡b°©pûF©}7~ªu¾o!póB³ö5¶1¢;ªùÎþ¯¯çç¼È­d× ª½d#0_"ûILPe_f/¡ïSâSCþàB/r Åá:VX!³`k:"ÆÄÉà¦±WÈ»W<`ì<Ê æÈÎòË"Ø»¯ ~ëú9©-N¼BA ôAN$L/&¢!Äü³Õ(hÂï>EDÁ³±t ÏCü:¯K?	øÓ]ï&
0À¦8ñÐðÙxÿs mØøIwä/%/ütø*!RäBPd#<Y/QONâé§-yÃBÊÁcÏÂ&	D»<óÅ8`x¼	SÀÁÅ·	´Ã·%¿M%·¹³o®¿\ÍæÇÕ)oªëÞ=!ôPa`,P3ämø5¤!¹Fu¡M65®PÍ&6òg0Ä{â@{µå(í_oÊºÃ3®W++@oñcòLôx²O¤
¶¥9Âo»R
 ã!PO¾ÕÒq¨)²6Q7÷0>
qÜÅllbnÒ´=Â^±37h÷øÜ93÷hw:êämÃ¦V¹¢GD×Å°o¡4bPÔh.aåz,QÝÄZSÀpLä.YDt10T (	F7*llW¥·±ÉYDhpA1ßGª2 [ÑýFH&#È(ËRI&=zS|ÏCM&ñ·5Â/
»&_åú<ÏdWÒÿþVÆülkV%À`Õ·?æNÑÚÏá3|wç?Û9Y5Un×)@TÚ@íUâ$-M<´Ú5Ç5(§`½íyp)"Ø5}ÑÕ ±Pµ*UÂ/ååù¼ßW^Úõ+í%÷`.ÒqXÀ¢ØÌ
Ï/é%(^l@Ù*ü´ècµ2È³2²þØv¾foÞüÿáñ´=zí¿[úÂYµ'v­äfmRgE7-½ØÙühhb·ïï^9qúBÏ6pëb[Õ	Û_l;ãÛRÆàøS*US Ì£eÀ*I´u¹ùàY¹lq*;Ñ¨8[\RÈò¡&ß²e?ÓZcÓWTèû¬ãdèÝg¿ÐcwÂe*Ó}t¡é6*ÊªÂÔ¦ìtHé».O'J6 Ð g$+*FÝ·©vÓª:GÚ¤3Q[J6æ+OÙÚü9·»-R7yìüÙäíY-ËêT Ú=?  ²w[²ôyËÍ£uQmÔðLw]®È]kã\ÝÄ¹ÆV+MÕËögße0dÝà2
Qý8Ñ3ýÈ3âäõÃ,IO+uèûyVF9®*Gô´Yï*×&Úþm³D²[.ßc/=ÔÆÄ+±P`Rìç/jÞIåÞ²Y¾ünM4JWÄ,@æ%aN\ä;ã:·Ý3Æ0-	½¤yÏÈ¶£6.óY8r[Ø±ÝDòÄF>ÁõqúyÁ§b¥øuXb­+gbÐ¯k6W8(*	ÑjËº¿F.jÚì¡JÜ¤×Ù¢÷}Ô³µ
endstream
endobj
323 0 obj
<<
/Length 1577      
/Filter /FlateDecode
>>
stream
xÚÍX[s8~÷¯`ÜM§1ØØq6õL¶uÛt4MÜéöAÙÐäÍ¿_ !¹´³ºËw¾stLm«ÚûÁ_«ñîÐÒæú|z0ÕVÍØúx2ÑfÓ±~¨­\íëÞÁäå·ÕÇÁr5ø1°è2S³4{ªOçc:ËÔMk¢9áàë7SséØGÍÔÇóC-ÍgÚd~¨OéS´ëÁçY=z6®mYs}bÏ´5ÖÇóâð×õsèT(S²-Ç«÷:ëO6\lm²ÑbZþOÙöÞÉÅ[ãÓÕQmfÙTKY>·íâä+¸D;:?­8=f{õ5¯êÛ²ÑËüÿÀ°xB ÅØñ7>ö¶É ÝÏGÛâq.¢fëcI*~cè3}Ä×o¶å:Î$±0¯ÿÒvÿ¶9<^é¿%[üÉYþsr~y¶¼\s0Õ-û Í5ùJ^Å_
×±OØØë~=BvG¦©îÇAÝÁ¡±Öáîöcã"[rdì ñì-ó~Ì'Å!@)ù[hÄcbxKç1`d®aSiªDt'ò@U^Íd±Gª([yTLf6þ@R.íÝÆûI¯øÙ¡'¸~âcÔ?V<¹ØÐQÖ¤£Rz»ºeÒñ~\êj('xy!ôì|$Ôëâïcîê0¸®¼ ö	þNB:Éµ&Ü´aO7d¹upé¾y×ý\£ªd¥9«ÖíS9E¡eopKøÉçx~àÒùº·/4ä$îºÜ¢~ra%f!0òæ?>¾R(¼X4³A;M}2µºfüp¤ÀSÇ
K9eàÄÉ:Â{9³ Ò=£!w§élùhL+"k\«I1</5è¦êÄ «!¦&ÓÇÐ8ê²SÖêÇò×^ï§³%rã®¤òò|t&*æ¦à¤åòâíãL=ÌÃ­T±@EK\©ª¹Æ"sx£ÕýD£ýã÷øcÚG\1w«»·<c\¬¤ àV YS$4Íê@Ï,J< å*1a¥¬»ïpÜFnÎÆ=® %4DJv©¨¸rByý:øá.¸¿ÐS§¯ìè?¸^6C|®)¡ü#Bí¼P)%J h³.Ðn§+v¥ø¥¶4ð	ðQIî9"Th	ââÕL(QN&¨¨ú±!q¢PÀ\*VÁü8^E@qß»;?»%·°ûË}^ý3|¹:SêÛCYéÜïÕ®¸X±CPjßj6êú|Rqú-nÞo9e¶QÎ&Â¡4Ãó·zaòÚ¸H]YÚj©J+Áj	 ¢*³uÅtÕ¢ªJUuUX­6)ïoT¦~¤;¥lpd¢×`dErÔû (8À-*`#´Ý<ãÐ F ¼9Ê×Lý$.Nk¹æ¶î&Üb+äÿH`§ûTö7¹·ä7øÔ[Æ	ëGéº.%
e\m{ÊfRØã©nxá8åø^ß^<Bñ×;e(	×ôã~ÅCÅªú­8ÑMqêÇ¡MdêÓ
6ó¢ñ*»å°Mï5)Xê9òÔIí"­ÖLJsUetÓZ¬1vTÕÖcCTªóPÝY"À_«ÒçØS!®Ìº¦¡j­ÊÍ¯<zgq{NKv¿·öÒpëê!]Á7Jù²èÑK©¤è³ô(x^¼8ª¸Èù»ýºÞ}}>ÇµöÞ-y¹:ýtqÝÃç¿ÀV²[³èº½NyâÈÎ·Jó½¬­âµ+:ÕÆ6J*ÏèÙðc>Q'©2Z<*ÏUa&hÞq%¶Ëû}Æ¯ø¦äÿåjð2¹@b
endstream
endobj
338 0 obj
<<
/Length 3177      
/Filter /FlateDecode
>>
stream
xÚåÛrã¶õÝ_¡Ù}¨Ô±`¼{d6É®ãìÆµ´M¦CK°Ä¤Vë~}Ï EåN§ÍNlÀÎýÊ-GÎèâäëÙÉÙHb*ÍîF¾ç×óFaàh4[>?ùeööäõìä'¶9#9òÄ.@9ÂÞh|øÅ-`ííÈn¶¼88£ltsòçguèî ¾#"À¬ÂýÍ*)z1úÊ_6:GR °ËÑTJû>C^Uú.ýÄI±³FÛ´Y@ðé¯B:ìËõÅÉèA¾xùr¦?5/_¾0ðL®YmJ>¯NEzwÏ/Í*ib~Ìj¯·Z²òd¡åãÕÂpwe'MZv¢NÚ¢ì_u$Te²^WåºJF[æÛÈ°NCd|×}õîêû×çCBY!¬Ê­ïªÜåÜr`¥R,,ÁG+ãm¹2{#ÕÔq§J>PÎ4öôÂ>7zTISVÏåýë=¶{@==OçeÊi5©ö4i¤Ô²Pn6µSkSL¯ÕðÖLw¿ÖÕ÷iÝt6m°G¶ÆP'¹eiÁ&6¢ì½Þ¶ Cë?> -±V% «öýë)ú£ÎÓÇrY,tÑ<î¼}ÜUß¹ºÑUZÿv%ýìøÎã|ñ4%ûöáôMãø¬¤Ùâ)ÎÈî¯
EÚ0"+Vç©s­1ö´Zéå&K× ç­ ÚN®0Ï/÷3P"ü>-ßB´.Rbã	ÿéÜ¸LLÍÂdºnÅE6Fãe÷Ëdz\TÅy?äpqì^?´_1²+Ö	¿,bùòýV×ó*]£¤¾lÉÀüaüË eD:³2{L¨Uº\5E÷aaª=L]$~âQeÃÜÝq²q8ýßûfçEû§C(²T×6Âì«Ó9ÆQou³mKÖY)øTvúY4=:öJ×iå¸#(D,Mñz&Så;,TzZµ³D¾Ã£éÄPÄ¡#ñÄXÀSúÛ"Ùø
þËñk_·{:*NÚ=ß×,À%tCÎZ`OÄt©(v°âB	më¾çt(¹-'ÒÄzýûrÃme<ºµ0B:ðÝè3ENað®!=j1ºÒÜõùÄ Xé`fª¦TìØ	<Ry²²Âí7hÁwè83¤þì8jnÒ7®²ZpÀð±HÏæ5ÚÙkëF¥ÁÄ¯?]¾ãw5<Õ>W:[ó*«'h<)¥Á?dë	WÈ2I`Â/T¬2mg0JÇqÆïËFs Á³nî3=b"ð©O^(¼ßM4	*¬Té¼IX&XhSmæÍ½cêÉÈ8.Ü×Ôà´æ'¼És®«Ìæ©5§öÆ1°¯<1û['1¹T¾U4<Ó@Z!V7ÃJÚÁsx ÄÅ{öhlaß¡	UZ,HY,¡OXÌämE4NÞM [2×üF¤Àvdé¼6ûJ~ê|{úOÍ0ìê!×Ú")ïø0P( |ÖÁYm@@ÁfÁî6Ã`i¡1ðÖ2*Ù	Ï^² pFD,ò	?5nûäë6îÖYüOëÒÄÜ*mtÿî$q´èj%HÍs¬Q¦üé"¹qM°H·æ`^{^ß»[>+¢qÊ½q>ãÔ	/XÛ$·Yâ+»&ðÃûÌ I|"­/¦ÛtAnëhîµðö«Ì^Î0×ifWÉD9%Å6ÁÀd3 "TØD'¹Nëêx¨ÁrS8  Ûëo(­÷°æ%öLÜ©YóMªñ×!X& ÀVJ{!rQqË,)MøoÓÊ
M31TØÐ ITYúÆmÑÝe¡÷Ð±æ`Ê@ÃËE9ÁK²IàOÙ­À¿.ù³Rnÿ<ã,Æ%r)Uy[ò4+ënmÕÛSÜúpÀzuiî/ïq`,É5w2îN¿ÆÌE[z!Ý£Þ=Ö6Îe%
À5÷¸õ¾Ãdoõ¦Ò@ôãÔ?«ÈwòþK­÷hyL¦í%ÚÔÄú0Ø«ïzã7(ArÈû×ârS,sì?®çxÿZ¥ÕÑ6É-ÝhÁDÈJfUiÍSõr[ÍÓDÌmêß¤0¬¼Õu(È6ÅgÔ/?Ë²È\Sÿî
/ïLÞ +]³ÚÈ-ö°/ØºÒwÚÈÜ	ÅÝªç$ÖÂ½¥Ù¢ôjFc3w.Â06=·!k7.ê Ë.×ÐN¿xMñ<Äj\Y} Z6ñå$'c q@ØÕ`ÏÏªå×¦ûAtèÃá¿DU|è¶ aàöÓiÍ(QúøÔ/3<¢±£:êæ¤%3¿ïÈ¥Á:Û,9=MºôÁnZ\çy´iØÕE2+|LÉ
·íÊc=>üÏ²¹ÃÖÊHæn.W^Õs(áû¿,ñû1×HøÑ^d£j»WIüVGPðR¯æÇ,e6ÀbnkÀÔÀ)G¶Z8¿æe¾s»M³´¹ç}ÜÎáâëw¯Ðy¾¹9Î QÔ÷yÈg'ì»A¹ièÃQmèG7À)#9~Î óÛô·ôH/u!`õ#«¤ÏëÑ7¸Üõ«b15¡Ü¨_n½ÓÅæ8¢+çî¦.×=H#¤
{Yëgh?k¨k¹P*0%ª
m	#î³T`òÄ¬§!0r_
&ê$,,K¸7µ:Å×À2³d]så«8sâ|Æ·þ4ep­ªÚÂìbt17üºÉ×¦qÅdi+!DÖwØTÝSy¶ÐvxÚÅkà2é:Q4¨®Ôn/T»Z;/íEáPï93Å¼ùîOÓÛ¯¼U²^ñûÔ àÃÃ$ñDcà5ü8ç:§ÝîÁBdàEîÿ>àý[ÑÍÌÊ-·ÞÞä9kÄ~ý¦Q{±¯J¡U-Ì	æy½¹5â£_qK^ aÿ³ßãý³ëÄXT<9x±àÒ>ÃC¤Krd³nè¦gúm®GA!OÖ¶¹_¦J ´° ]p\ÓÓû|®oÎ|DÄìÔÓU²«ºnÃ7þD^3<â»zqj~¡ðK{º}{uïãË7Oùüæ'Äb×®nøÉ÷ùþøÍåwÍ4ÛöhøðÃTÑ¹Óóììô´LÁ§æ¥´áçºâuwmH¨60@­&°¢ÆDF­ïÃÒt1Jp±sçöîÇÛ@sçß=È_ÑÑ:pãÀq¾c¤ö:nÈú]:¥õ¯¥>âÓîÞo×@àAÐ¾jõùÙY
ùC\­PÂhgs³Ýº=Cô@~|'þÑÄßÉ8ç¶?¾³¿÷DaHHOøÐK@©^ßô@î6JDyç«ozjM)a.c©}:J;h"TÞ·Û­øæ¢¬å×±2}áùåê¦vú¨ãyéºlN Ó£úN*sÚqw¨/àI;aA5±CðÍÐ·9A?¾ËV[í^º©'_í)RCúk8y©E¡3Î¶µyõjýÿ.¾ð'8¨>)#áJÕ×|þ.ÞÿÈ®ùøO&¸R4hËb¦yVwÍÊæ3'óúì0¯Â¾­ª£x¥Öå/È´.§{÷6D}ªÌ)ßw-Àn^ãIÏôáKw@9í	gLªí°¯ÀÒã¾,ÜãôÞõSØ3ö>í÷ÅSìÏeYÆBÆê8_ÛNê|ÖÑµ÷ë¥á'øÂ»3ì
endstream
endobj
348 0 obj
<<
/Length 162       
/Filter /FlateDecode
>>
stream
xÚU=Â@DûýS&Íeï#»VHäºÊ¨ADÁ¿ï%ÔjaöÍð0¶´T4Z
bñRJ¬ò#úl·Ïg±îò!¶Eãõí¼WRê4¶ FfêHwCþ²bíp¨cúµ`eÇk!'¸ÆÂ¸¢£ñ¿eíub~5M"÷½=OE`m®7	½£ï3Í
endstream
endobj
360 0 obj
<<
/Length1 1416
/Length2 6052
/Length3 0
/Length 7019      
/Filter /FlateDecode
>>
stream
xÚwTÛÒ6Ò RE:QCHè½÷*¥ $$ ½IïU©*½H* H¥)*J/_PÏ½÷Üÿ_ëûVÖJÞyföÌÞÏ³×Îwøív05$Ë Iuu5Á  $, 	89áXWØß~ §)#RÿPFÃ X¼OÅu ÖW XK@@!Hòo -TxÀíº@-$p*#QÞh¸£¿Îß@n(,))~çW:PÑC! .ësÃ¯¸P8ëýÜ2NX,JJPÐÓÓS â@¢åxî =áX' !C{Àì#õ n°?£	 8ÆNpÌïÒë	AÃx+
C`ð)ö04¿:ÐHS¨!~u~î ÿl, þW¹?Ùà_É(é ¼áG ÜÔWÓÀzaï !û ÄÄçC< pWð«uPMÑ ÁOøg>Ga1¸ëÅeðÛ¬°WFº¹ÁXà¢?8Åï»·àÃuA =>[p½ÃÅöP&¸û¦ÊÞø·Ï$Ä%D0w Ìê$x±±7
ö+¾pãgðóA!Q@ü0?¸ÿðÁ@<`@,úÌÏç?ÿ´ `0ÐÅí`pàßÕñnÃoþh¸Ð§ºøüëÉ
Ï0{$ÂÕûßð_G,htOí®)ßÿTRBz}øüB¢  $"Ç?øý³Î]üOÿ«p@/]ôß¨¿{öøCî?
áþ³O]ûßL· ø/ðÿï¿Rþ4¿¨ò¿2ý¿;R{àêú+ÎýðÿÄ!npWï?<u`ñ2ÐEâÅøo¨ì·vuaöðnÿÕÄBðrPD8â)Í üöÃ1jp/ý]8êô6¿ý&s#`wøÅÏþ+WÔ`ðÜü`ðÃþ:ÈÕ?ûPE@öêBÐh7 øxKèÆËÔæõÝ@AOâgö: Ñ
:^ÜeømÀ~û@@A×&.ÿXú Æ·ó&øVþ¶	óAH¨t°supËa¥"³'ÿÊÉVÚ¡¹ÿP5¶[uÔf1Á(;kJû¹ÚdXÍÚ¹MOÉý0gîÃÏr{­·È>?»Ú#»]ÜÄùþ¥ñD[OÌRØ¤ÑÝwY£¨ÚÉåí»8)}ÿªîüèÉEW¢&®Ò¢×Ú^Y¥CÏ"iúå!¶É®ÏxEtá¯ÜOn±AKÑ©z·´eZ 	T½ý}3Ô]¬QZV¾sb©U¥ûXTD.WÎ<½ö3·Øc3ÆÇNVaÓ¾ûÅ<OÊaµÞ¶Óòö¦ÕMî¤vq'Û$hðÜ+5jN)¿i?ÆNÔÐ+x1íLk¼+ûÄê¢¢í=5Þ9²ðóvª¦ÅpO0÷ÝÙ³Òå/~u¯b<B	ÿªL¡^Vå£ÏâÙðszÚÃá=³Ï2n&d!æÔb,W4#Ü`N-,|ÕVnrM°îsïåÂ{û>8³§;­­J\SîQhÜBÍoFÁã-°àZhzU´2ÎÓmqß·ÂkÑJ§×YèWkqýºðúq4R
Èól£-28A 9âVÙôRWø[)a=A^ÞãÝ@ú·=ÈaGI`ôñ&ît0¨@ÕâHß½.m:Úæ(Öû´PnòÎù¹æTý -7EÐà©¡pýD/]O+ßSúæeIêÅøaÝ¤e}J'?~ÚiîÇWÑô­'ÄF·(.ì6åFñU1½ÒR"H& ùìsÖæ®°#3ÓNì5vVös»s¤ÍõïJ,¦óÇ=.×oÝbÿÊH¸\ùz²½¼¯Ñç	N*àÜ²ÚnòÖ{Y6¦!·§â·÷l:;¾û^òµ¯µU`çûåA%×HÛÀv­MYZÏ!¾¶­N1Åvy:<ïmA-¸@ÎIß«Í	Ä½´iNF!O¹HúÑ ÎøG7&¬	@7³«Ît}ga¸³ÐÆjS¨¨á%Äù¦Ä'Á$y÷¦g*=ÇÇÆºäÝ±¶KÈøh"PØ(.mÐÐÌô·øF¦¨Ç.Q~1««êG!³TN²^DµzÉõ;|Ð¨9¶`·2VÝïpÎ0ìôä;¡X^¦ß f¤QÍºJ,ãÌgPÕ»¹Ù7MfíëoÖHÛ<Í7.¤º³tìAwªË;3!Í¾~Ù<ºwÕx£À`lÞ³[âÞc'¶Ñ<nÒ¦â
½{/¾áÐT/óÝYûçã1F×ý9N]7+ªtÉ%þ® ¼.L3GiÆÃwÁ>ïièyßç¨MùØ¿lq ýô5¯Ì'Bgt+¼½Ðo-¹Ô_´p|ð­n^N>vj¹Ö8ïcò¡gÆØ¢ -Ö´Ü&h^ceé` ÷>ùÚxÍ/8/»:eþ4¨ùxÀ¶;6xÁáØ¯fu$§2TØÈpÌ<ÙûL¦VÈ9Yßºe1¨³ýJ¬IvsÈÜx`^iÅ3e7äü
h³Ôï	júýg'z¹HÈËÖ*Eß`»ö×º6 pû{#Ö
muòd¨+paiê@¥î&EVØÉ	[ïîÞ¢[eÚÐõU `WîçÆÈÙ^ÚÆ7ÇÞ·Q´¤é&C,¢êlQ¡ûÂRÙÌ}2÷ÔG|ÀçPSMÆJ"1n´î­Ãl}@@Ðìs½ÍP!+(²¸/²s.»ÅúþÒÃ{ºÂÉ·CC{²Ê×r÷ã½OÚ:&ÝÍ|á;¼u]¢~Ï%nTæÞ´ÔR_Ý[Ïð#{&ä§úfcZI?ô2úòô `±X»ÿ@hÛE)!¼çÌõgÂùÌ'{1=Ä^4¯hýÕø92oeÚÑÝä®Ã¹¨Úa¥kz¯­;4ve»P,ë1î¥ïÎ×Ì;+òfÚ:<¯ª&ç.ú,=XipÕ=Xe·öVAú°S@¶Î¥fÁxú3ä(î¨H~!Mù5­¥Ùf·<ä2õ¨>ÙÜ;Â¥ÜG ÙøÁr®
Ñ½+oFKêÞ$¬â×¹gzÿ¹ÝóAÐAgz9ÕqêêæÝí:q­õOzãMR+÷3ºa®ÇÆ,}Ñ3ïÌ.IOÏùOL"ñLV$2D}È×Xa¾¼Êk
Õ+çJfJRoV¨$îÑ¼´1¬Kâ(j0ù(¨MHäúÁAÌË}!ÜPíéWõHCC°óxÚ.Ù%±âç½*o¤×»zçòo©^ùÕF¯Ò,½ëx7äsL×iÕ3²ò±÷1»@Bò,èq3iU4©4yg-e	uièÇx8[~<+§Jt^^¯ÏMÒfÉÿf4#[Î¦V'@m°WÇj ºÿÐÁNÇOPnHÔæÃ¬çSý3qzÑá·¥?ÜyjbC¯sW>¾®·ÿrùªîþ{øÖû«SrÉ×¨{ÂW®¬üæýà|Û¬3[eCb-c{Ìw;çfZä|ÿ`dãÓúN¢´ÍC½A&G}sJç½>îônîk´ùZ	þTDwR^Õ|ºa>Îó÷R¼Ü|ÆbtD+DF±3¡8Þ=ïíÊýhIçRÓ0öe;ÑIÍ·/käí/ÜFyéOâé$ã¦UÍôù§R&:¢)+5ÖQ«× ¤l·È,q§¯©GÇØUMI|²Á;àÁ ãªdSÓQQo3m_\ÀèÎRêwß©zìåg%ûõSÙrÜ¤ðT»ñËªEukÝÙ{aÛS¼3drE×Ôìyæ¾ÀgÚ{üØµô´õÊ²j!\öûñÁa #1,¸ÎµkÖö¥]Æj$An3æ&ý«Oöýôqê5#ìÕB¨è·Ê
QÝ¢T½^:*oÛÓ"ëvë±¾3$êD}ÍrèñZRáNy4È«ÈÏÄ<y¹Ú9ÙôéX =GVIÄ¶£jñ¨ô´áËÞµµ @Ü«Xt9	åÆÂ(G¡Òs
BÁÈ¸ÏRJô{À¹\êÌ9£Càb +m  a7Ù7£9»^$w¾{ý»Rõ)?µKËË¦ÂÅÝÚlånQ³
s6­~h¿ß<ÖNCvÃFî6®bATÓòø^þ=Ô|&QñTÂM7¹÷9Ø¾UOúÖrº?éHBI+j¾e?õz#£²zÑµD½w¹»æ}¥Ú¿Qµ+Î÷ÚÚ.·:K	RÞ ¸_p~fRÄÉ{,Ælùq§^iu1q*^¦cån4È¹, ½gÝ³Â/h=Ïiø9|eRØ=ð³v¯9Û9Äï)Àò5VCyãòVÿ[º @eqø²ÜëZºNT*ó¤¹ucøÔ÷µO*´2Ìõô8?»~ê¡2Yß··,,÷ÏP@®TbÊZÕç	j1n<ó7æ
IJ±ó+ðLW§ËÍSåt© ÉõÏ6Cü/ý\üuF>-}}u@]¶ËúÓÇÌ&8¹ÝXü¡ÆúÆ¡ú¹@|(å&þAhÆý¨oÎKjtÆ3-ï®Þál1NWcjó>Zº@]ÀÈ*¾Õda«óÄªav[QwËÝw:¹BOÍi75ó3{ÆÓÑ¯,§ë_?zsþéÄ´õHXlFÛß@É/¯Èrx¯<t´êÙDÉ>*t|ÇôiÐPb;÷¤î2ãjJr*ºý8ëÀ²÷úÉU®³Ãï¼eYvK¬q¢ªÑ8³GÐ¯s £HTì+ÅïNÅhEÈ«p[­·g.Q-MêªNã\kò×Bù´åÌ¶ÉÙK
Q7Ó
:ãT+C,ÅJ\[Å_L¼&Ò¡üª#L+!ÈÆvfÛD+Ú~¾Jj{ñEÛË]¸³pá¶µ,s=îïÙÎpPþ ìªj¼BEsÀõº¦P*UC®¶6uwp¶f\ºâàcï'Á~nfYëü?êtp[_\Nôäi'¦QÎ&Ó"H³¤ÞL© úúEªë·¨9'Ku[»Kû6î¹í>kaÚ
÷Úñ½­¥e[/Î=Ú¢÷Ï¨	bäÓrgYÇVEJ0R­V½ÌÒBå!¯ªå]Ûj«¡t4ËgwvoÂÈò§7ø±àÇ{ãídBgN]NW|æI×GCy´Á±o{¾J¨sRG ZÞlö4èþK>F¾æl2Þ|ÓJü4¥r3¥ÞY|ì¶ôO¶kÏw0Ä¬¹Ö²ÊßÆ×ÎÊ­m~À]±±JlAûãÿj$VDbRtî¬)?Ww|ÜvôYòHIVcïòÞMLÞ±ø½ã>'4åÞÍ rvX©ôÚÀµQ³n{ÿõ3jÚâ9AÁx¹¾0Æ^iúÜýJü`cÅ¤2ª	ÔgÇ½KÞVóY3!w·ogò9µë÷¥}ööDQ¶ç¾-Ö{º5Nµ@Úê²¹Ðe¿àÕ¡é¤*ÛT^h`'´û]mþ¦ùèäk¦Ð,cùí«aÄégÝä©÷	Ð§ÞM&.Dqø7ºþæoÛB}[Ìïç¾êæ^ÇÍl¸ùx¼zÜ©åÍü¥"PI¯dJ °ÆºÏñgfo°r×¨m¥3^9ýZÍtHQ?»<óÆ¡{æ5¤2­qK$I¡½å_a·´+|SöêÁzR*÷¦tseWÃñü¤æÊõiýüb­c¨zâ[=£ÞHhÐøÏæhÐÙ%ñ÷Ê­ò£Ö*édgÑq#¶)ÛtY®îeÜBV³méz0ælíµ$PëùâQ8åàuLÚö5ºëÔ¶wýÎÙeµgÏåUVµ33¹jøv"òÑBä¢½&PÂ­î<)u"©ã%´ÍC(R%Hôôv#ãxQ+,GWU÷]]í|;ÒñÑ!ïáÐ
úàÉz?¶kÚëµMn¿`ZÎIF©JµzögçÐ«Bi(s;K;e5÷Ö#µzm¿¿I2ç1ôÚKX#êò"r*¹MÖ¬¢Á¸;	ê#Öùw4Ñk^Y
mÜ
,r'¦ïésòÖ­=S¹wû.ä§§ïöyòqjÚ]cAtÛi{ÅbÝFKo~íÉ²k)§+nñÇ|NT¹«¬'¢mY?»½*¯zû!bô ùÖÆ¢ËíÙÜÝ£¼c_-
ó]KbfR:¿;I£&ò*2<)[V§ß_~O(ý4·®þ®º# !ÃcMSwÑ; C^DPÕ·²¡ív®¬­S	!I<ö*íK?üé©ÝQrVnÓ%ÀR.C8´ìÕLbõéqTâFhWh5GËÞò[%²º¢´(n@øët·û«a¾'i»vØÒ)®`uÂ$Fª@©ýá¾Ãc­úl<óîïV¨Ô±ä)ú¹ù²^ÕÍÝ$QSW?Ù¬vË'Rò¥VêK®*ú2<±¤Xô¶¦¼#ëeÝñÂäelûü1}²0g¥©%	ùùàÏ+*$/câY,ïz«$M¶]v3+²¹`9Oñõä¡Ö´] ,ëC ¾Ì+~­lcÔ-á>E®UoW_é?=$%!lOA
îÇbG(¼(wöøéyÅë·4mdvÀý¦ ãK5Ó.ïESíÍ1Ç)«ì]ÌPâ+îÞ£2½l^²»üYáÄ?Õéü*ï5}ÃAÓÇw+ùyà?ÜL'æ¹Ku2RÌ£]:CÉ
VQ¶qÕýT­~´?/6âdáÒmôÉ¿§\Dnw´ÔXÃG®èy];pð
ÈRE¯*¶Ìêj!9;Ôí·a²2O÷ÿ+Í£õDÞÀà¼ò.§`1éaE/%T8x·Ö:÷Î¿0ëYç)T|¼°Lï~û@®RtÕ|dÛl#/×` ±ø	ÿaq·ÓFzÚ\_K°_¯g¯î~Õè¤uÒPÔÇòÛ9æÜn^ÖÍ|:¢é¹6lUÖ¾ÅÈ6{öG°ó²Çª1m§òtN×Q?Ä!Eú
g^ÔØQ©>L<éçê¤{ô´§¸àð¡N<¨vÿýÒ­òGâî0ãúb»B

[Ý07Z56Ó·eý." ïÅáàõúÇãCóFÆ¼ÒG	mu:o È]\YÐ÷Á¸T/©Yß6qªvMKÛÏ	cbÏÏÏ0îaÆ¥­NÄÐSÛ:\Rf÷"»ZÒãKÏêtìå¢#Âµ/g^U8~oùÍHOJâI>ý_ÄëEód&òs<Ëãv#'SÈè´5¹H±«K]½þ<iäú	ÏzÍ=Eß
ÞXôuI/á1r2Ìi½hU§h\HdëÝëÈaéî!o;¡F×9»¶W.ñæqËò|éwjYÛjöÕ}Ðakp7ÿ`âíg©½õëÜ?/$2$×XÍ?¢Ó¯@³ªóÚÊ¿5TÓ-¹ºÐpö~ÐqéñªÝajAtFÐ*Ú¦´/-hÿªÝµIc¡ðnt'¯Uj¯çèTø1¼_lý¦Ùæ`(îXõz}fÓØáMã°³!ïÌÉ°o4RPð¦ÕsS¨S+×ôüµÎY©¦×Túë·û"ÉnªHDQpò^¦0,eêz%öõÞ²ÑI=gymOÃ{,6Ú²÷âþÒ,¢(¿+ÑÂË"@ì!Ê°Ù{\c¥c
Úâ=¬×þü¯AA&À?|>»v¦ÌXÎHIò¤'Àµj«gÄÒÑï:G'2E¥0}Ê1tìÌ;ðh#oÂ~å³½Æ»5¸_Ë+w:<´ä*êæ
k?_ÿé.PÕÈÚ6û®0ìF×Páf¯k©ðqöó+û:v8&R;#ÜX­R*î½Ñ+ð¸§ï]Ý÷'Q× e\oáuF«Ã<.ëùølrNñ[D/åð§ñå6Ñ X¦KaªQ¹®_]ÞÈpëq@@äu£U¬¤²kØ#$Õ`§X÷¼ø©cKptzyéåø	AIBûÎ¶t36â ¸|²Eé[ý³ðîÏ>¡vîå±ý5GD- ?\TÊu¶¼
Z$É"ÝqrÚç,ú8jLÄË­ò®ÅK;J´2prÝ·»©¸\s~­¥ØË©a~ÅÑ²$:©cNLJÃj³uxL>¦µ	Í³âyíÍÏ->j©èÅynþ¤À¤c>áyRìX PHiød{ëäG%Åºø¬ÍíQxz õqKÊ½ø®ý¥wûÇÖ;V>|³FàúÙz`G¤®ÿa¯¸¸\³èx®¨æÂmè®ñËI6.ðrûÂø vèõ	kzÃ7ÙãÝ(IÉùþÚ(^
endstream
endobj
362 0 obj
<<
/Length1 1472
/Length2 6602
/Length3 0
/Length 7602      
/Filter /FlateDecode
>>
stream
xÚ¸TÓï?tJ:ÎÑ%ÝÒH#àc6¤SºA:¤SB@@BRZ@BQºKßÏ·þÿs~¿³s¶÷óº¯{{ûºÏvÆÂ¨óGÎaQFÀQ<ü¼@	æ~  äðYXô¡(äÅâ"àÿÁPpPhLB5pÀcW_À/"Á/*@ñ	"ÈjÐä<FÀ!H|§ÔÖÞçG ;À/..ÊýÛ çqAp&eqDïÁ O`(åù_!ØÙ¡PN||îîî¼ G$/ÂÅVàEÙô HÄð«dÈò·4^|¾ùÇðar¹@ h CàH´+Üâ@ïx¢¦ÐvÀÿ5þ¸ÀÏËÿ¯p½Â;À`£î	Ûl 0@[YåâàÖ¿ ö¹ 0ð;u@YN BWø·>$ØêBò"¡°_5òý
>f%¸µÂÑG!ñå§uÑçîÉ÷·¹p;Üûnmó«kW'>8ÔÙ¢¦øðÿÙBP a ¸0? âxíø~m ïéùmü£kðõvB8lÐe@|¡6ô¾7ä \\!¾Þÿiøï>??À
F¬ ¶P8þ¿££aÍ5ºÿ.P-?~ ð×ë_OæhY#à0ÏÓ·Oëº¼×ßÿeGx ¼yÄ<â"@ ??¿@TTàûßqt@Ð¿yü¯Üÿ.úþIÙí¯Øÿà¿ci!ÐÊ Øÿ-ô§@a ýÆÿÿ,÷ß.ÿ*ÿåÿ*ôÿÍHÙûmgÿCøÿØAPç_Z¹®(ôh"Ð³ ÿ_ªäÏèjB¬¡®ÿkUCÐÓ ·E+_(ô"¡k(
l÷G5p_óÂ!:$ô×öÿÇ2°úA¢¥ùÛAÏÐï«#¬° äâòÄG÷½xó£§Òâñ[Ì >^8v kôØ \ð5­>+Ø	!í~ÙþÀ@_°Ë hÀÀ 6¨ÿÿÂÚý/\À@ß!Vèãüÿ+m°«zë]Ó?ëßâãÏM#ÀÁöµÁmçÕr´î<_>à,¯tDÄô£Xg^zÛiàf¨L8Ë?³®¼?ª3[:>íCË¹{>âñ´++`)E5¡Ô»&¿Ï7pqÔea°FÐØ¦F¬íÅëÒ<3Ã6cK4¾
íÜxýµàº¹a*¾p2¦Ð¢¢år:¶0_02¯ MÆ»¥¹ê«^c¾ÆÉ·EQ_x®Å¤..¾ÏêëM<ÌWï©©¥ ¾ëõ1g(¡2>ëqU^øT¡49ºÐ1u	ëèÒÉü¾7ñý®¶Z
ÚÏ]ëÂÓR9ÝKtëú|D÷"ì¸«SåYª¬1NÓöªa¹=ØT ºÍIDqÉæ|cîó A¯c÷ÏEgÄó'KÁÄú?¿Ñ18ÙÍ_=JPÐ°Pè¨ai1Ú¯¸=äæ=yÕ-7~?þÖü¾m°;lÁ¼KO9gÜ±õn3¾IMøô#!§ªF}ÑiÉ;é§­ó¦CEÒTV|v)ÖP$OlF_c#MëDÿ$)1Ãn)ýëù
áRÍRÉbþÀçcû·u·cIkÖt»/n[ÄY¹ìó	àY¨çvÚ=+Öb{6nÅ]}7Ø^ÊÿiàgIQòüi®Môã½\c¹ºpSXDRçßå«aúvÓ¾º´·cÛ=ílÉª§ØûV*ýLÁ°òÆXáVÅ>Ê³>FÛq3K÷°Mãñ!¿Ù¤ÐzÅ·­=§eÎò r¶ÙqÁµJMVqolÂpC?E¢1r"ÐXC À4ÃÎ¦&£>O¿eÆü¢9¬îRÅiÿ´n¢µïq¿ø«0PYìà§Ï|ÆÚ"ï=å5»Ï·6Ìi5[pÂMBÉòMb§óuö5®Ö,Z*[JªÉÞøü÷<&¨ïl²u¶¹Rû¼A^i= ×ËPJ:,ÚIoÄ<þÁ´{ |CõÔOSÏÿ5rÕAQå¨/WHáÜPT¸ÐÍLçf3â²½¥¹µó Î÷&Cæ\
gÚ­´ðÓ«øj^æºNúZ¬^¦=0Ã¨FU;YûcãþÙOKÔ¤dzçðAZ¿«,ûÃ2çp1Å$ÁË,oµ]_àåVrÇv-nÁ*AÕH®¤»rU²qÞpiì'BëàÝ CD]ê[kÎvLw]ÒÉ¤¬©¡OÒÜÁ}kÅåOÊ/3îëíÜvÓSH-ÄÎÒU´Ã§&µäÎé§Ê"iw §¶²mÈ©ëX`Õ¥»ÏePY«¨z9°Ï<~Ä1Dl?4ÐQ«³ñV)ý¤	!Üý`RÕ·Ã·íÖ;j×òc¡YE;Ov+]5(4üÑ[ÌãWC~nñSÜ}ÌõLvÅ2Çu[2+NÓÁ¢nÄ3÷¤tø¾k*$²Z	ÂûÉú_êÄlZC4ºEaA-ÚÁõD@ÑÉ¯,Ä!wU.ô¼^QÙ|÷³ S´ûtüh=ß;=}U>yhsÚ÷òmß\RÀMáÈsiµÚ²ÿõäkYs0XbFÔ-úë-õð+!m©{;?Ëe§ 	%`Ü:¥K÷¾:`~Lç$ÅsÆ2gÄÙ>»lý6ùñ&Ðb¹5êËÑ¡9,9v½	ÙÂÜÅ·ºjÁÁ¨ÿå?ès¥bwn¬n* ý	Sdì·ä+W'ørÂé"òRdùnðtý5¼ÊôØÑ6¦ñ³R
s><~¾Þáã}²¹)\/è2 Ä·®KÁ 'øÀÂZýäç)ï2"­Ò@=;äEÙ÷ý FËÌVUàú
Ãùõþ NPiùñ7)nBÌC+T,1ÍT$þF;Ü­Û²GïûpxÜÎ£®ÓÙ®8Ú³³¶.ÉÂ:Óo}ën³âd1Tª	N43kD{êþ¬1}½`óÅL+/&@Èb¡;ã·"ÑCz:ß¿6µHÜ´ähQz8û­Ð­¢çK'-OK#á{>Ú^ ËAoØ\'mÔì§{C!U¦W4ïò5ÅFßÏEFwç0+"35T?¶ª:>jÌáH;ÁuÎáY x&÷~xSyÂRs8êúl.Üçí8k´fì´õ¤d ÄZf±Æ=È$(äÝQÉÛåÙGßä}ëR¾;Ô-ôà.ëí°ÏOZÌ²1å®®·ß`D|ù8!&ßo
Që~i¥¬ÎóÌ¦ðIw{@¾Çõ<® á]R8æcíVfßÖ_å)=Õj6ëJ:§£PÿÝMkwIEÄ°hh77Ç¼?Oî^ÜÛ¨$.jöõÃ©åH
h º­Ñ]¯%\Ë©*LÞleBC¡Æ"öÎû=É5¡{Ô^|êç¼&4zL}Z"o1ô	ñ\¬ v#iL\6Éõ¯Uà×½_¡m[OjéjGÁ:jFT¯óÌ0ô<#ùô!:õ/!ÒØ"¢wù°ûçªü¢x%±P¦è±½@f ýìÏúòCh'9y×ÑX_¯Og¡´õ½§~Ft@O¡cÿ×Ôjçâa[Aêø£ø½Ù·­·Ä½n¿ù¢®°äÇ÷õ¼5¾7-ôv1s'U<ªÏetJíEÂ¾Ê`GýÂÃ>¯÷7Îs.+þêéÚÂµL¢Æ®)`ÀY£qÜvØÎöhÌ¤}Â³ÍÏwN+Å©$ü0Õ:ì  âm®P&ÍüKù-ãX8ç+D+ÆämûÈ<Z?v>~¨DÅöª»ëÚ.F;eqò[PòNGgtoÕjF<?~suîHt!2g¹»ÍËTô,îM©åkÝ&(ÍºÓÛÓÞA\\d¦°'¯qP,ÝÄ×_éòõóv0N­ùÕsóÊË#íýÊóñhá@¯{e*¯éW8G4ÅnJt¿³xOÞ\Û2k\@ß-Ró¾ëxÅ=ù0¢×,ña}âC¥	NNUÊå%'5Kin{.ÚÖ#pQ8AÙxgí¶±ÄIÇt[ç%zÌÑ=â	¬ {I.zoÊ7À°;cór	¶=ÕêÆêÝl^s¦GÃrôówà»§£uSúmId=éq#ËÄ·ö¿[(BK®Íö%²?5t3Ü]2»ôÉÄHys!l¼e3n¹é¬à{v5á#uþ=Ó-¬í£Óó!~PÌã»þ%ËÖIÎ»»KÊÇ¾\@La P4ód0a/¥ª!uÔ÷;r	-í@Ë0?¥µÒÉËDç!´£¡î$Öñ	Yvt:Ü}¨­®YM	¸±Üßð,^Õ¥üÞ)Ï`xüy_\)¿*Î^
ÿ¹ ü[¶·ûí*KaÁ³Bå]ÛÉÎ:¡lùôoëÛr%åä+íÎµ£ûC$ß.5àF2Äíò¿Ö±¹ÿñNÅ÷ôÞ\ãµ¶Ût/]
Íâ»Ü}&lk¨ù}ï¸ÓÏãLù&6¸ps×7¯e`8©©äÞ§ÑåéIàêø@©û]6÷n=àj/ãÅáÛpÇy¡'ÖÊ.;7÷"ÃÜÜ.Û£Åªæ³øJÚñ½c2ä`PvFEltÃ4a¨ úí<[ì£Ã½©øÛ<Ï³´\@I¸%í½¼E}{(­úÂwá0ZÒf95ó0{ç$~Oò¿Þ¤ÌÁh£qpÒc§XK8-bèûãÙ®À²$«÷¯X|-ô¤u0ÓìTßlÎq%+ýå=÷dsÜF>J7ø îÄhÙY¬Û6²ÎV¤©R¿·r;M³·äÃ[{ózrø ±ôã</9Å)­ó[íVp"úhoç{V&ìÒLsbß^t|p(ñ<G¬Fc|øE¨®uÅ*º¯¶ø¶ÓÆQnY¿ôVJ ,ìyá0G½NÆËLi¸²aGÊ:õr`vp`6Úª¢ÄÞÛ4ç]V¾QÀ6J=:ú!}êô ¦[õ2Q÷kz¶ÕJ	%ÓÑ­£túÎÊãbØ?§äÈ:á[ºqoòÕc¼Y½$Muæà8®AEG©ê·²^°qR];ûëß¢ÑNE9òáÉ
8RsäÚ·Tí$¯¬æ{>d_«zÆ2ï]FKZÌØ¦ËÅdE.{´ÛlÈsUL¹¼ØSZÞ3CÏÛj«ÓEë¾b¾d®ºKó9p&KfÓZVÌAj.XFB¼9E7ÁÂ©é«J×Cþ½0GRÁúÕJÚí§vêjþ»ö×¹Êd4¤áà$=*yGílUáiJ«v%Ç)ÎÏ,Ëdù5Sì-­øuÁDÎ}n¬Ug
Ë_µ05Luîú:®ÞñTÈ¶ÖÑês\<Ù¥y/RkOÎuÞ¨r·Mt@D)dåìÉ§xPkZÚzI[\ñ.rv5¸(Ø³×'»Ï¦(7¾Êá©JÔ¿~¹b¢JoÅØ°úFµß»Ù=¨_ÏÂd<ÿ%³rÉÇUÅ¹CC§C\ÏñÔ»:K,ÊRo»ûûäÃpNçNóTÔguìêkÕ5c«Znû+àíëSy-MØÜÙ¸óh2%)ê*àÖ3!ô·²ÿôc¶¶ëEæg¾zwpHqçýø­j	8Øä®E³ýH7ëÝV6;ýÔ¼³4'efb£K5Í/$¨%ï¹=!M»m¼*y;XþAÂbcX^5I\Fýp /AjëÔÀ|ýuPÔ¸qäOëáú·þ.þ(iO©ªPÎµ +¬çDí¨^Z9<[ãyoQòÕÑ­§Çg³¹t[Ay:¬¢(	æ©«¤º­ÐüÑx4d+Ó÷:ÉËOOSºÝÚö¯N×Ét>zÃ Ì$bÀ[ÞÀÁ<æú¤®;¤f,Ú
8@~_Ú	ò@<6_)cv¿Ñ^äõ}ãÚò&ÛÏ7\*­ãª +lª¨|{E/YgÌx=]Úç¹ñeð]"®~nðíªÎ;RáaæØ°Ô(VêØÎH¼çÉ*eë³b9©DyU8n_Ùíï¡ÖD£ùðLóó^]Ìa£û!Ú³ñ4áÄ¼Q¯b*÷ïèuÜKCh=²øï'[àÆ»6þJYâ·¾HöCjúe§Ù%f!±52§!¡k¦éBêá¶aØ¥½ß
ºK7H(d£²ô+ Sl S&>ugºê¾óß¯º*f%Fû±ú_¿ç½.~³aEã&æòSêä!.
g·èHÁmï¨)oHÈt£fãphûíÍ
?kJ8]:æ¶cW±ÕîÒQePv?2(®ÑZÓ@XÛ/ gIÃ¤	ÓÒÒ¤£Ø­)Å¹DköµÖqðÒ­£Ä¼{Í£[²ùÂ¨	úHsÞÌÄPZÓ¸Q¿0ÁÅ1I9ýùÀáDqü=1]éN¶¨²âþè;{ñÕÃJ¦Ì.ÛDùÈì¨Þ9ÝcIyÝXíÒDÁNNyÁº Wø,æ¦eµ>âÍ\KmÈÏgñ¤1¿]~èË#N©Ë÷®ðfÄ?Gf¶«`s¢ºáé¶Ý:ydÕ~çëïo6Ë-7HéãÂ&ÝFÑuUfÕS?ÎûYª-[À¢¯¸ôUÔ0ë:õ¦Ïjm¼çPÓPr(|3Âå öEÀH\Ú&Å·´	@:vþ®ñXÖX~Óg_ZÔãÃT\ÿõx7n?·ÀrR#Ò.3Æ²c!,ê@¹ü3ñ!®jÂSî
cdÒc§P5ç²:ÙÚzØìí;vÅ-¦"c÷C0¹ÆíðÇc<¾ÏÖT}6(U²þÉ]ëKvV&Á|®-¼¬³ìÞc9¡dT_b²ø2~aëüSXc£ÔÇ.éÄ$õsÐ<Ãé ÜRÚ
X¼£}q°õ|¯Ø)!Í»y¹DMäBúµ{u¶ã]ÜòOO>2¿ÖýÁ0® qßLåæ~çsG}róRæmV¢çLÁëJÒB}%aôºý`90_¥o¶Æ1ß`F2©¤ÐØG/ã{Fî£Ü<¦$\­uã©\M=-ïÖê[3%½²âÚèÒ5Uy|fq?\1®U íTTgÐÆ¥î
³Éd·u7·)2Lê6Ûô{¾Å¯|ñÁDNÐ­âNÿªv¦ÛD]£À-7B|¯Ë/úÍKCÀ¹Å»VO3oezy&L1cCø+¦S­õä¶±÷ÈzÇIÝö4îÜ_¾¯ÚðýÚ{Ób°r÷û/UÉ~°wÊþ#Oy+ÑR#«GlëþmÙÒ°{Éx<ÖyØí®ëO1º?`~eJó;csÝô¡d^ü¬¾×ÓöÊbêuÒ}©tï&íØjíéKR½îz÷ß¶ðëöâ»ËÛÅ¯¶]?¹~É4SË´Ú?õl©ISózª4s»kh3ÂÉ¥ÄA°IG¶Âúö¥`r¬g0õäìë;úo|NzýçKsoËî4¸â§)AÏ¹ÞÍU#MÙhðîÖ´¤}Þ°
×­¥9Þ¯~#Ïµï=ÄQÓxáºQc.ù¯>gá¥P÷zªu7/2xãjíJi{b(0A&¥yAÁq'à1¸ßðsÄÁÀx³ô øÌûD&N]£ÖAÚ×'ãñBÚ^?ZyÁÍGöà¤rÖ«åO³³£±ÛR[¢äI&÷ÓëOÏßïorË	ÃÕ#ù²d®#ÓWÌAHÞz-¾²¬dÑÙxÖeíÏ²CÊÊs} ^ÛÖ[Gô,îº©1fYãÕØÛ_KÉº¹ôóºæ^ë²yÍøQ)íz³EàXª\dI#?}Í6ÕpîÎsa½?ù¶öSê	1:ñ+ï,i75%Fä¼'y _»pé(|îÆÙÕ½ßùÍûÇ@Ü¤¢Ý!ó¼ÙÑ)f^Â¬9vÇ«2wñÀS+O_E¾ÝÈ"`¤SÛÞ­¯}­¬¾}út?°iÁ 5Ããåî'8½¸hÞ5PÅKRÿAtàÔuË-fÆñ´1²XÂ°vX×8¿qæzðêîY¤áQáè÷`zùÐí¤÷gy¢çr\	ÊÙêïoË«C)æôvº/Ø¸õÞíp¹P¥¨CÕ¼1Ò1S{¶o¹ùôuyg/þS{ø"Kù ÈÉÀÈXløöÅÄ{~¯úm!úìÙAÂÊ±+êÌæº©UH_â[eO_­O­pâ9&tçÙ_¿îÙÜ4M9×6|fÿiÕlvÌÅ:óì¥¿­EÓZr`ÄÁZîÇP¥Ä¼z©[t<RBI8¦J>$ÜÓð/#K- Áy¬2¿ù>m>åüÉUA!Gò÷ùºÙ»->²ÜMÛë5çÎ6aEi'V7é~½ÿkZýQÓó±i©ÓgØâÐJ-L±ZøK·èÚÉé[°Åx(;"ìv{I=k¬Ol9À§Ë=ÁÙ¨µu>û½]¥Ú³öÁ¶-JñmÕnhòÑieÖ;_}ZMcIl£ál±ª|/ÿÛÕ®|Y0Kx%rÅ@*­ äB_P]h<õè"¸ósýn0àuÜjúÝKºÚÏS¡#kl@²l?×ìr>»4¯ç¯L½U\¤¹TÀ	ºÌöäì4£1½$w
ÚÀÙ+°{Ã¬Bg3Få·aE9|Þa]"
Ø{ë,bùk+UÂ\Zªúû~Öw²*ú©V)»O0#:9&íê«ãÑñ³¿ø$q½fÓ½~ÌyæºucH³ÎJ´àÎãûý åípIçyð¶ÆhW÷k©ÌuÚÚÏþ=ânß ç8+^²Ò³G;¸º`l²CD&¤õÛ?UßéÇÜN¿øÚ6ò"{ä53^ðCçÍùÚ¯lõºÙ\[Ìtrñ³ Â$ÆIrì¦ÜË²¢Â^ñoÑsÃÙîïñ_Ïs&ÍÍWÆ:Òü?ÿzÍ>
endstream
endobj
364 0 obj
<<
/Length1 2136
/Length2 9351
/Length3 0
/Length 10517     
/Filter /FlateDecode
>>
stream
xÚuwuXÔ[×6Ý
(Í -5tKwt0Ä1ttHIw Ò Ò4Òõç<çàó¼×wÍ?s¯¼×Z{¯}ýè¨Õ4YÅ- f (ÆÊÁÀÜa0 NÒ	d
C!R¦0 Lap$ÿ£¦7ÓVvq6µúmääpr ±8 °9`²C°ØXB¼Ë-\þÑ¹áI ð¤L xJ(ÄÎ`²û¹ØÙ©Ú ¿iý­©=ØÎãÿ¯×­¬a FeØÅþµò0S;°¹8ÄÊ þ-;ËÝAj`¹5 æäú[ü
br²C@jPgðï X9ÀÿÑiYÍm! gg ÏT*PØNMû?ÂëcÈª)ý/=¼sÿÄ3u6A` þ°èoç ÅÿvÞÛ¿zÀ®¬¬¤£¢Èü×ÿRICÌ¡``êädêpÀÀ SwÜáµ²³A 0¸ÀÁæ°:aý/]ü·èoÄ`x@| vÉÄ`z@ véÀ.ó8 ì²À.÷¸ ìòÀ®ðà\ÒsQ~@p.*ÎEõ_Äç¢öà\ÔÆsÑ|@p.ZÎåÕsÑ~@p.:ÎE÷Á¹èýà\^? ¸é¿îgjï ?8¦ðyÿ#å34uÀÎ¶pS³ü²:=¨á59Û`v KØë_¹Ó_·ä_¤ù¿Ýj?½ÿàþ-±· ûû.°[üA^är;ÿa'zoè¿òòþÖ;ºÚýá¯×òÁÎØìúGßj¨Óp«p½ÕïúÓNßú¡ø$­=¬A?,à2ðÎÔæ/ÎöïÏc^x#ì~¯=¼önð_c§¸Øý^VPâ÷ú@ú¼P5<©ò_óææøô¿§Í§ ?f­Myÿ¡<xcì\þ(.q|(ü7r9ÿµÿÍý[,ÌZÄ%ðáóààÿ1&x'²ñÀAöàÿ><¿m@®ÌÄìþ@^³©³õáÅ=¤åwfíúãPÁ»sþá áòp;à9]~¯|gs¨Ó#×? °Û7ÔýÏêñÏó3<'Èéoÿ½éÕLÁÃ¿ïÕïÕÿæøkÂ ¶ °ÌúOeSøw×²áøû÷Ï?ÃÿûHH@Ý½XyàO|òÀW7¯Ï»8ÁÏì¯wþý-ÁðrcÍÍ@ÍÞØÔ¼i½¨'scÝø¶²ú)<V¯'Fÿ5ÇËZ	=MvÂQÂÄ¢x(Ym¶4d|ÆìÅÁÅ»AgFÀr\6Aºg]â5wàò¤Ó
Di%µåK_ü3NÏDE!Agæ&¯k³òGÁí'çÍ×» {@Ñ>u,Z<ëÓ.R¤5í*lPÏ ?æ~ü«Ñ[¤7|4·ò;£!¼Á­PÖ_e,»['w«ù®'h§ß	´:ÜÎ ¢ÈÍ0¿Hdæ8Ê*)VOt³G6
ûÔ¾hmØIoSâWi¼1tT!ÜIºèôón??¹¬Mú²ä´¸Su¡¯àØUrÑµ*¥±Ñ¦ý%Ó§:÷õ¬|ê­xÅñãCxZvÔ6f#>Ù²¨ÂX]Ó-ïÙÛMâ!ì£aq}"Ñdå2_:¾·9Æ±éóe}>Ö¬.´ÃªPýÅ?ü"°#p]fyßáeú=áÉÅ4~wã>A( Ç Í|(?ëî®­U:T½N-¨#Ë¥©;1}CzúÝ´ACh«VÍ_T¹åÎ
gu®ÚÈ²'%:>.Ðe^åÊf¼{¯ Û!RS¹õcÖf1?¾ÙÐÌ¯(y5ªD*þÍsn<5¹Ï¦IÛdðewBÌË=gR,_¥gÕÍÐu¬>nKÞÞì(¼ÍÞ½gÿÚ»VVÙ;r£zÍUY?Îº¯£Su¨rî5®è;ö¦v¤äò)b;»}ÍÍ:Ü5£RCÒå<=*Ï ¯¾*´.ïJzØb¥<åÕNâÊ~M&5Lh>ô6*ëV×Íâ:Leúy
^2qË±gÎ¼E¨ç¤~*+ÏÀ£Îòãú¼ç^ÜªØ¼¹$}i)}*õì¸Æ1÷õ´hO.ùR=pcq9gåÔ^£`2óLE¢D¦óÒ¸üYs/¨sjz<jC÷n	y² :³{ý¨¢3=ù0FEÚ[QÚy©?:¹äÛ))íÎä w!ìDeÔf_¤ßã£-¼Xtñ¡)Ë6}²³WÚºË¤y²/÷Q|u-Áþ­<âd·ÖãÅ3Ä¹'·,5¢çÅ±ÒxãÎ°ðâ( åqËÚ?3Ú¢±í(Å~ìW5Rð'_¿	%¡_Ð"¥5y Ù'ÿ3!<µn÷åãîç"³´63à¯þX>õùmÆ3Üæ/rHDæn©}ÜyR~ Ip>+âwbDAÖF{G#hqV,4ÇS#ßJâxÂ¦ôùL3ZÌ2¹=h]	wÔnBkÅÁúð½oµýÕ+vÈësjV¥Ò<iDzëW©Ç/ÃHÕ©½7ð9åÚÖE{ëY9£)©Ê"M{ÃJÊ¶ä§è§ß[+ìÒL
ÿÊõÝ¹úÿ¤hô-+Èÿôö§ó½Çnôdã5}È¯ñô´s}§Üz>zªv¶eùéçÛv§è­ùþk­í:¯CÒñïJlLÝaÛoÚ¬~jEÃxõ¸!¦îö¬pEø]ævÜ;~Í²îèæL¨êOG2¿£}RLv
hÿEpy0¥×i(íî:OmÀG8&Ë1zqr×Fó8[Øha2ô"|ÚEß.Gþnä$õ¡ .æ®Û[ê(¯wn¼õÇ|*ETÝ¢_HL¤S' ]z<j»¸§Éj~uÈ×Za¢³^ÄDïêÄÈ+÷W£ ØðÉÆÖ²$*¼cÉµÕÜã>ýí¤ üxVUÔ([áÃ0H5xP}jÔu²òú§§¡ÑÓ60n>d¹I¯²	x[ôSEë;Ú 3@="cùLXô.AÕXz\DûùÎ×½áx.às¯ýÕ_RS©¨Ö´înû¿lmå 2¸°èæõQ´W:£òQ.âÒWÝvnn[¬N	-ÖvûWúekv0È$fÙ	>oªú§úVî¨KöÇï©¥¾V¿ÓÑoW.8ü¿Ñúk&Fªô¡¢¾*43¯Ì¬àE3SKò¶¦c,Wéxé6½ÀÑ¡ßúâð)};@±æûüOkÎLÊ¬ðocTçt¢v¦Ç·ÁCÍÉ)0¢Ò	¯|CBVÐ~ÎwI¼ 
¼½¸À.m¾©Ý+`¦07Êüæ(½YdìeöX8ÉM9O¨}Î5B¹UóGAÂ«o¾.£N9ªM/åòÎ6H5ãRQhÝË>6~ªDÌH@èÑ2±Zîq3õ~T¿L6å¯Þ·tâÈ1÷¢ÿéê#V¹JÉzÔ­ïN¬½Æ|(õ÷®xV¾ìTÉ0TV%òVKÔøÔWÞµ^ôF9ÉiUî]\>-z<*,åE1x°Ô)ùîbÿ=½¤ï¤Dÿ­^~Iæ^¬X¿~Úh:½TWtëuýËJ®úMT&Z|lïiYoÁ¯%ó-Å²7´³b#NR+hÿrs%èþôLÑ#Å{Â§Ió|â"}>´¡st8ÂlÁ^ÞY÷R2+øë~sgøÍ%¨µûl/!ä iÚY6#lFîÄ5õsT!Æk¥ÜäG_ÚD2\×E/¼½Z¥X#dØ3¬øÞR\nõ²úÜÜ·¸{O¯/"¥ä\g²©wjÐÜ³Dy×Ê&ðND!öÆaæÌÛ¡LÐèâúFÑÄ¯.$½üP5s¤Sh·Ñ£|´Ög^éùybKlVú÷ºI,ÜzO¸X2.RJMJdhóªÌ|¬ðW®PoTØi ¡¾ÁûñÜÖH\ÚZ¹²^ ö3ÕêÊ.DÓgÿânZÕNQÆèF÷gfÝjÉî-Oî{äCÁ)òWÓÐþR¬ÄoY¢¹Jã³®ø_Z¡PëZá© b'ì¨ åGîËÛaÁRèÒo?·vï]ÍÖH¶­%#ÜJowÇsøô{tDtÈVåw²étf¿®±¢*«"kBÜ%²Â²©;ÆOHý|c%æìÚ}õÐsÈ4m­ñD¯?ýIÂÏ\p¢='^éù	ª)A(ÚLìËeOÑ³å<°ÓÜ*SùsêÚü¿ãRY;r(q¸"×b!èø«ÂPó¶ãspYóOb»VoO$¼u,þìtD~Ó.²@'uë.FøÁ9ÉJÚÓþà&!dÓ*¯á+§¹mÁ¶´¬ã@*(Q¾6|<_¶ùåQî¢:{ÚhM"ÚQ´àq+}ùÓ¹T5~éóì´«!'Ûø>}71¿Ð³4NÃ©6½/¨º©¥+ §®vE7MÏ?\r«õú¡]ïw.à²´Y`ôK zúÖïÓ²xÄ?Ú¸Ò
à8MýÊrøðnÈÆÍ."úætîUO	:¸¨´KÔ`ËÌµ29/Nvbviõ*SÁ=è¦<n{rY³öýÍÒçvæ.ôÃÉÐïÅWÎm@¶av%ûÒ¸	ÒmfîÂ k|Mnÿ8|!Kì&f¬u®ØqÔÉ,i{û<É9ug+4Úæ 
EjtÓéñÐs
,r5Ç'Ø2Ï>ÊnPQMåÀjÝu/VÚÝº&ßgØ¤'&_:ý  ÅÍXOalªABÃ|C¿wÈr¾R"j2y?·~*âñ
ß6|IûÍ¨&)(ûþnQ%µ8Í*õsý4_ûð¶ùEz®4UàÏq
âõG]BI4PóÊ}2æzV¤o¯
hÈ3J yàÇAË¿ÂUVïÚßª_IKýÈ0Þ!g·1ôó}0@HÕJØWÐØî¡»|Ô|Þ}Ïm\¾I4°cáÔÎ{ú.r£ÅIN;×S²¿¥¼å§(,fÞ,w ª9¾ÜôyÙç:ÿNZz¤Þy û¾[ÄòNWbîSWÇÒ	¨=Ú³è÷þ41tÍ/ßz úï£æXQï?mÈkÐm¡$£QA:ä#µ«m¤D2/íÎÿQV!]×¸ê¹:mñMÙÀÈy£%QW<ºSm:¬¸~2mdºÎñÅGË³ÖfDþ.á$:N¹ü</ajÊ¬T¬ì	,zUæy·ÎZxLpxÅG'ÐH,éckÈìmæ£kîX´Õ*$@åÆ+ãzS}0[Ñt\^ågu¹å=+½xØ\ÊÊ×. »¾&}2huýÓ¶f8MÈEmF;móÆXIñ×êéÈÑZÓ&bVÐèâßÈÆU¯Óóér«dò*½2¿IG«_Þ¬õ:ØêG¢KI?éü[¸çgÏ\­ «û,fÐ;%¯Lþì«ÀAå-(Ó¸Å»;»TO3ï=>VXi¤Â©ÍÉ[YºÆ*ïw°·ë&¾´Òd&q	s8+ñxßðÚþ%ïÙ×$"<¿Þ2åG ñûA´&#Ä Ì¥#Õ _ ã/kÚ1o¯D.Õ³OÆ*â*gQFÉÕ9çz;Kº­ölÝÛ5hHDwt{xl'kÂ$1®¹EiAÍ­¾½dÏÎ²nÄ23m2lo^ã¥ºm ÇeZs78×¿g%%Ò¿h0¢À£±$@ÆPÎÙMÇw±âÞ>&Ø,*ë5¿²ÂyÏÚk6P î`æ{ú1·jDr]àÐlÚ´²w¶yi`%­3®3}½²j­¶V!PÊB­w(\N4Áù¦æßëÜLÂb3ðëÿÔ[0J}9ÆÒ¤3¾ê@-ÇVÿ"*j¤T,sYõ9ê°ÎyÚìÑ¥Kü«ÐC¨¦}x®«kÌ7²&yhúíæÏ7b}ÑYÄIKý3/ô×ÒE¤¨Gùó]^¥Ì½·Ù¢æ©È9#l;íFPåuÔ:a÷&`©ë1uÒ·øG3OP51	M
#qÊ ÃÉk=bóÀb´qII`¿@3zÔZL /hîíÈ²Qôãòxlnp°¡7°jùR»J®s­çÇgSsBÞW¦áx<ûgF¹ÙZÚúQ#K'uh-=®¡îUÑÎìj¥Uc>ÌLûÅ@àªK^ÍQ3oµÏÐÅ¤s;/Ü/iÛ|	Úç×Q©]>
Þ}%µykò<¶Ú±uS?) ÃÀ;ÞD'éàgµb^©Rè~]Úf7U(xîm]]+yböOfjtT#Ëþ"©ÑlèlÔÎmRÉ>>}n/ü+êñ´Gbü¤XymxürÕIIS¹{nÑI_ë¶0.OÎ!'Lü jÅS,qï¤>ÓbÌ±ZÔêrÌSXV^ùF=[Ú*PùIcLfû4³Þ& ¿¯¿<ÀÄ_Y2VÕiã±GÐG)`Á)F|¤¨{æHîîÜ¨¢/Bð]Ä/ïóÖ|´Ñ@ÐÝXv²ÕPO}îÇïMxÆ«óßæ³½ìPâ[¶XµÈÜÖi·Ó(Sâr~Ì£Q¦Ø¢Tj9}íòO
¬ÊFzÒòµlÊ'GÀÂ1K¹³÷ÒG¿Ô3j×J6eTWñÎ}hù´@b¶sCT¸¿øxSÁ_A¤ë[$û´W÷õÜw»úAn`_ê8?É¡+g Q]ÉµÏåZìª
¨oNçeòâQÞùdC&Þßé¥·é)÷ÊÔ.PÞÕw]Ø&8ÒÈè2Ç¡seSãéÊ[0§-E??yÝpÇå;¿Àÿ¶CBÜ·ÁÊ¾Ú;uÊ÷²uw¡lüu\oË6ô¤EÎ­oSX6%ãý ¡\bS¨õh ÁoZ%ÿje
qj£qáJ¦æÝ¹d¡Î«?>W¾md6L}y½§S*\£¼å²g[H·«òÆÐî­(¹C[ K ÖÈ&X*8ë*Ôy¨½ÙÅYoorO¯ù/`_øNø¾ßzyTÞ)ñ9Uózc{³èFÀ·Ëkpèòoîðä§cH£ídvS¨¶]uÄaLLBsÈûóvýêw²O³ÒÓwo$°/ù ãH?ã#àÃé7uÚ¿ÛÄ­,2
a,ó²Ù´_EuªZ¸v.{qÆúmQ,±ç<E)í×Jrß~ì/OÎYã3xìÀ½¢ î¦^Ï Þ µÇUD©VñZîÉØ»^,ûÚz%¥¹#QQ¹|-×ôÕ
NéÄNÚ|FcÞ2hèPÓè¥y¼5 È¤¢À<Uà?.S¸"qô3©ø¬¸=eÂA!i±Wn&Q8¹#È]Q±N!|)G	ÚÙ¿£#	ÝÞ75l^É¦åqï¥Ñ¥X\½Ã»Í`+4<ºr®YÁUgà¡	@=IZ«)°}è!ü÷jö ¼²àcàT],ºÏË¦X|Îób©)/ÙÒ}òìlaéQ½¨ ªPº7¾ÆmG4ÔtC³í3!JozÁÝ<æ[¢ÌgÈjáQz%hjÚÃkìõ³ÑªÏ "ZúaÈÈ¸ÝôW^U ÂÐ"Â±È]CÒ¯tm}¨GéÊ³vòÚÔzSoÕyÑà%r6w3»ÁÏ=êÒ	ý*½ÊSÞf?Q¼Ù¬KæëcF¶ÂïÐã³¾Ç£óaÇq,£¢ÇÓå)nðþ9ápÈ$ß'qI5¸Wã¶$/)Sxø´1Ql@¯ÙN¹{|^Ü«"ØÒ²rG±rÛÛ`ÑYf_Ø¶½À·âÅfTÞöÖb9j`2ë­+Ïq
ZüÌ¾Ä^ª¡ÃWgÎ;ª>ôO+n}Úh>	¬ö¼¯J2jð1ºTÊà§WáH$¶þÂ±¼5b¨,ôNÛmu¹ºì+Uèq8ýE«¿©-G'AøØ$sÄYËÀ{0Õx%zTÙ³ÎÝÖec7ÌN×-èM§ä=µÇT§Z9ÌÝÇõ>2¼ø·(¼\ª¡æwüB<A;ý"ØÖß"Ä£éæf×c&mÿù¼?^ÙrAW2>òaåÉÍáªe°·_UTyì1W,Ð»?±Ã³â!;Tµ !ävpóÙXýJpÿi¿¬x)Pk5ü"ïO)³ìÞQÞ&O¬ã\býÐ@¼×AÂV¬Ë?Í´Pè$¨	ó¤4	÷;6.)d®@÷AXØ?÷³ÞÒû½$rn&âmñgôdý¶Dkå°xªô>WFÃ¯Cák¬iHu/{½YkÂºQçOn¡´k´ZT@±¬ç#»£íü½´ñÒ£'½§bËá{uâ%Zw+ÔDL<9kðz§¶ÔoÃéùècªc$*Ö>©ö/¶¸S£ÑÖâËáf¾k7oPëRî[uZdZ2Ì;I%s£ÙZ)4³NºÄTØ½û~b</ªOtaøÉ`SÐÑgêquE- 4ù|[&-È7ª.U~K(z±KµeïþJtÖ35[çãJ ºÊäÁº£ñz&pRÿ81%-SÖ8ë¤0^ï¢Oè±éÞ±¾è(RÜ[e¢§+~Ë6°V¤Ã¦ãñæàü<l@±ðû¼»¼WÚù1¶=üF±³²è¸jå¡ÕS(Ûmð,óÖp«Aw-­¤,n»¦*Ö#EdEI<[ë.Âõaq²ò2éOã#¸÷8r(ÝYî¾¥\Ò¬ÄyÑ3K[òëR,3ÉJ7«ä|¬%´xE|WØc+Fµ¹®´D8=Å:PÆÝjãúñíÄ3*8	ÕØázÉ/éËØ:6ÒÛ|.ÓêksÞ§§¨"à×à|zM1ËÌ.Oò
)³ry±(ÞÏÈ=û²Þ,Ä¤zåªrùÖ,ÁUzßbýo±½Øø¾7à[³Á§ñ.ú²/bÕÂÍÙ>}-ß×ü± Þ:ûÔÚíÖvÇ!#4¡(
¢%>r×³|¯ûr²9[GûÈÌÜ>ó2ßÛìQgaUMóÖ¤-ëÐ£$«´(6UûNóµ\ïF%#õÙ!dÝÚuÝ¨ù²¨-Þ/aX*¼>©Jæéð£Û,õïÝr¼)û.o?×]ò£ ìÍ*s½ýÙ/µ¶¥"þÓ÷}Ú¬ö.nÕ-d>ËH95Î° Õ)hjÿÊ¢þÚ8Å´Û@B°¡uâIm¢G¶¶f½Ý=ö]j¥#¡xÒK§,	Sò¾¤ü³B&sõH×©a© ©0ÞÅîr1N¢]O#MKÕ ¶ÎË¶HL9oÖJ¿ö0ÖNMÒÍú|¬V'øR1HËo¾4n6ª¸þt¼ï|êBF%¾(âMÆ31®'1&ßIÊ3~Xs­7iªÕ¨Mm9¤b}ÕzÂã"?qüçÊ7yie^£¶Óí?î¦m&(Ï¶t|xâq«'²}Ä¾^ÑÆ]Y1ÕIc¦,ñíy}~Ý^1<kÛ°­æ¼g'¿æxPóÀ¸Zü®Xx·¨½¼ò$õù"ÞùwL-[	Lêr>zE«FkýÖ¨ÐëgÊRk+±à­ûØGRgÉ"iëÙ·ôjlûLy%-#-¦M4#ÑãKôXI	*ìn	NÜãÃæ«S>Ç8|LN$ULÑbÀÓÉÛ°«hü,Õöö©ªºDÌ¿ø¥ûzùÞÖ5WÃ^ÌÇÜ9­S&_ÆÀ&U~ÏpÛéeÈS?$1ÏUÞçþeJñ¼ùòÍKê8ôßÈVbIBDÏT¢ä9<í½¤ò9'øÖÄ$Þm~ÑFÃ½©Ê;KÂ¢î+èÅºåx'A[o8£½u*aNm%èzøKó£Ax>ß0?ïåÀøÐ[¨àV¿þÀ±âç34<ìáÜHÞåÝí*B¨C%Ót3FXyá@ZI¼ÙvÏÊKÅ»Î8F6Ä{êXä-[Ý5OÐ"P´ÐhaÁî/DÎêy[1TaO¦påöTÙÑÝ0zØÂ!yJÂÄ ¶­ôûs}ãÐ_ö²
±n²ñÏ>¹í%ºQÅOKúûQUØwT#k2ÚQyy¾nÔ[rkiµ47]=ÿÕË)ºßSléJRÆubfmw3£o_FRMH<í*=¯gã{-ßPÑxd0·ßr{JlìÎ;Â oÆ ýÚ©æ2«ûSKÞp öë-k$¾j*DÆ+¤2$ç´º³Ä&ä_´3ûØúk6Ðº½Fóý"_÷BÒ/ÏËcdÆ½òåÃ?8â}5zìöõ¡ì0vöµ» Q\$½vU%b;²
À<ÌÆq[îdJ3«Ó³K B
%M¡{ªÁê°nx @ê5½^bòÃBS=Êóm¨I­Ç/g&Ë²J«5n¶K|hÎ¾ã,¥½õ|ðTþÔJ ­ìHé5U!ÐCir9´âÔ4a`frkãBfç<·öÝpIot0åSîÚÝ5HRü§7Û,ÈOÉVÖ¯yë--'e³UÖ¶½Ö¸77
î¹c×X+|©ÂÅq; <?JÍR"K/É#Çrµ×>Úá3:Þ
»{Á-@äL¨EýÄÛ½ì\ªú%@Ô¸;wDnM³ö»F³HÁ²ê(ÏqÙ:a*Ëò/t£t§z
)0*ònÝÅ+ÊGuðvEÿþwµ8¸~Î%ÅÀÛÉº #úc¼]lõOÍæûåËtÚNÔÔ¢Km]%xÐ{¼Øê¥RbTxwU¦UyáòÂ="q¼%GÌ@iVÁtDØôIoö¯ÛÜêncêîRN·}êï`Ù¸ó¥wO.Ü$ôÜòí.ñf|ð[_ØJô<ÿaò*÷3SíJÆÖp{±¤Ì(á~épKÌë}V4Î }þ¸¯Q*Iuâ­£-uÌ#3û_ JÓ¹ê¯W",\Õ(
á"Ô[cAX+YB¤Ç7·5K")¢¬Ól^¶Þ­yÙ$+±ÇªöÝYÍÎê&*ícg?6¯ÍVpKõuSØÍÛEÔ&0æ;TÓÂñ#kÍ±u(k3Â.ý8¥ÉçÚo¤jn¬¾[
O$Dk;kz+mÌR"/ÊeicNà¼qÏ°ón¿Ô%M¼3Ë>~í²ÎÒvnö	r J"y&§ñ=Ë¯T¤rñ<nm×ºeWÜâ\º};¥:À=Cµ@íY(x{O]ÕitZ ¸%¨WÏX^F¢Ü­:­as³xå©wOå`°ÿ}:ÀfÔ<geßzëf(ßØ;ÓÒë\ó`M\Ç\ y¹¸ZêHêV¬7
F$ *4®}Å|©pgoäâ¦x®Eì/Å·
(ð¥ÝýFUCÂE¥Tél)eR  ~¬´°Ûlwd>F¢Zÿ;»læ[¨ñ¯eÍU 6ú*«:¿§æ:ÕóYÐ©TEª"a/¦0ö­0Ì,éÙ~ÁágìæÇwñaZ$åVÍ,c^KÇ=`Ë#m¯çQ\ØNo;¯È|BS©ZþÌnÃp)·íJ"»Ú?¬ÙkÉeé§ä¼¯Ô¦®á£	SÎ¯A).wâtäÍühâºlÝ_Qü¦A29Ù²}0}söã}$p ]¯XÔ§ÌÏA"BQÎdT;füêÞt_>][~C¶Qð^ÌïjbÃq-ægõóöA£ÿVÛ¦ûh)2¦\p6ÄwQvÁQ®54(beÏGÜ{B7åÈ`/W;låÝËÈ^¢À3ë[¿¬õ«b¬6âØEoÍi8× ¥\yþYÉ6Qêµ¾ÏIófLG|r½ÖG©#ÇnñÄByL©à§òoEìqüðåÿÈrÁ²uì³©%ÃnÍ~øÐ¡©l§o175Ýû¯c°e&±ú¨O=CÑ)Ë»J6óÞÃ<¹K.±¾
 ÷MÃ¾ª2§ÛCåT.ö%¢ÉÉMõ]<$Ìb[	Û55_|$ï°Ü=;k@ ó5|û§Å~õ%ý'lA^ñ«Í{<?¤*#~ZÍU¾BÎ^cÇIõ&PìÝÕñ­²i¯M¾'ÁíÄ'&FÒimðv¦~µ9\OVCÈ­ÔânSÝxõ³8öMÎ¡«­Û;þÒô8	:Bå+F&[ûb¼² îèÅc.!©ë÷ÔÜèÅMª»âÇLê4\BÐ_/.yl¥'®vº}j*ì¹£éýÙøÿ eWÕ
endstream
endobj
366 0 obj
<<
/Length1 1144
/Length2 4009
/Length3 0
/Length 4765      
/Filter /FlateDecode
>>
stream
xÚuSy<ÔÛÿ&Y[!ÛX&Y³ÍØg5K1Ùe+Ã1ÍBYD²¤-;!ûdÍ]¬S"ä;u¿÷Þßí~¯Ïsç}÷r#rÆÄ\ZwBéáq$ic<¼æ´
í¢Eý¦:Áãt$
oáê2F@r`«À!5XþÏ@<2!`<ð7A&(Åà(.ÞÙË#{yzb1(¤÷"8£0¥²géà=}	´+	$nif-!))õ7B¡ 'ß?.Aã@¢7
÷ü"¡Â¡¢?cM\ÒÏvAâ®$'LVÖÓ¢`2D$+A)ô©÷ø)@ü.r¦4å+ûûÜÜqxß¿`ù«%¤§¬%sÝe¨ûß`
øC£H E°
¡®P7]e¦´ðõDý"!?aàç÷¹ °DT ÆEùüoDðBøý_â; BbI 'r«S`Ë{c¹²ËÁøç÷×Êr¡H<ëûw8áÉiÙèHþÞû_QÚÚx¤4DY$-§¢Hq
Eª(ÿ»¢	óßÀ6Ä¹àAÐ?
§LìÏâ½Q"Å ñ_ ýS	'aQ ñ¿MbVSüAùAþ§yþÁÿOýCÏýÕ¿ø(AF ½c#<0Xßÿqà÷@kÔ>ÿtI,ÆYÆþ5&Qs4Á]ÿ0Æ¸%ùëÅ¡LðDÌÏ7(B~ã,\1Îî8Hqß/
CþòÎÄàÐ sÅò/à'íìE PÆóë(gÿÜ»`(¢P7PÎ±¼³j[YHÝnÐGúc¯|«å×#/A@4z^æXÛ=¨µ£®kÒíz¾ÈÆ:,x!ZÙÇª]/CÏÆÊvÌ wM¦\cúÌ ÞÿÜÊÅ¹¬ãÛa@>SðÕFä¼Nyþt ÿ®íÒ§ëéOO\þ4"åü~{ã²ö)n¨«Aìv;<ñbãË=±¶/×¾±Ö³9´i3+éHe6yÊ°F¹ï®õ4¨¤Ý{,¶´%ûñÇl×¹!&:îÄxþ)&nî¾`E#Õ1g`êð¶úñ.&÷ÒZ8ÇU§b¡{Ó7ó2åö2¢×Ø­~+×=Zÿï²v
éä¨«nÛKµñàtè^ôÖii¸ôaþ-U©½ )_ ¾8ñ¶·:þå¿¡ùµæ§ôc_)¸Aµ²ÕÈìÀ¢¸ôÁþ¥>sòÕÍ«¢´R&_ÛüFyç
 x£ìºiñ¬#ýQ8n¤â&b¼I[ZÐ8RÀ·ëô6Ã²d¾G®W.ûÚÀ}µãöjÍÝX·'ä«Ùuíå"%{ø¦´ÕêÀ¡f¬©X1kdDt6ÍÄcýåá¹ÈÝýóé»9ÃShPÐã¨»4LOÄàTÙÅÜ
K?Î·*a¬ïÄÞmc¼T_?Ù©QzúÒ7[¼ãÅí¹N)êð·p+±ÒÃ¯òoçÃ=¥¦ÚÌq9çÐ_Êéù]ó°¢_¹º¯U°ÒMõ=}È_ÃåVg¹7ºÊöZ¶%Þ×öjðÉâp-^·Ç¹ýþM%LçÔKZýsç·äz´¼´m`Úhåâ3v©WB«\#ªÝÕ*Lô¶	>2¯¸Áé§ËkJ§i|oVøÜn$¸±5UêK2áÉK!~À'Kë|¿s3 ÀjÎÕ®K¢ûb9
gó|wAHºçzójÉ|O-§­­¯¹L/¾+­ö$ÌÍ³Å6Y[Á"TëÕ[â@ëÞöÛå4ØÜ	±)e¼Zñãìµñ¾+7WÇ.kºóy$}1ÍK¸µD=T,«*Îã@'/Úamüam[æÔwWc±àk=Pª¢ÞôÜÄw¦×»?ÀÒLtîØlR/vÜ¹û#T1¾]É5¯ÈNãéû¶V¨Ò¹\6½ì^÷<<|sväm°x©|Ý®Ðü·ã6°±ÖÂóÄÆ¸J¡Îk9üþoÊÂÒ©&P½¼æ±ªsn=Sé{¯tò!£jgLÃræR¤©Ä:
+×ý»é2ú?Lä+ðÝ»_0HW[D/YþìæÂäÙùü-ücØ¹ QöQ[àsä¤º}Õ¥jZ4ë÷é@þûè§ûgÕ±C$µWy6ÒE¾øà:¥,)×^µ­uVÿz1õÁ¹q¢÷çØ+Ëm_Êø.DÊß¨:Ú2¦:0úôºõÆÂ*öÒúä'RÙÈ6Fn@l<Ø1pN­ üy^ÕÒ0Ò~¯Ï´Óç¢¿sÌØT¼ÇïÄ½â´aÛcüa×C³.³¿Èjwç½â¢²ºEV[ã3¤û[¯§<®@2àT2êHþ<§$Õ³ù»Ñ)ðYg÷>ýóÝøWs¢GFGôÕoÉt÷wnÊù(ÌR<º) m½Q	a¸Mfe}"ågtOÑM0d2WøoVÑpèÎûû8RË°CÇKô53ô#m³§Áü$M2ô±@7·Be]8k©¿·ÝUQ®LxÙpqC»MéþÔ]­÷ë5ô7vñÐuïíþ¡²uX²önû`±ìnä³ùBúê	vedõ;Zà~³ôæ^¬hû²+cûSúSf·åHÏ-Iþ)Ü]KBUöt.ùuÄ"©^.ã´ÔÝÇvwçn \È7
NÇª+³Y
'õø54ûlLEâeÙ,dsm48\1Þ+CÌÉ)s1AªõÓ<«IûÔ³´þþý}\È;F1<øZeoÁ@õÿì¬×¢ß«.ô[¾ýPèÖA»ýe8Øä{bÎ(ö×®·Ú,ÕO³	ÁÓ:/ÑìzA%ËC¸=x]ÕÖÕZùS_01A¦ÒZôCzZMú4§çÔ×¶¢Óü°-~.²óõmâK§îÊü¨YIP/ÊÁ®¤t»ç1s°YµÅ)èËËØL?ìT|7¹Ðó¤ÕjöÃE§ö6ÐÀ%xx44}Û³*¥µYQMy2<éFmîãnP%GßO8û¨OX8|á1·±K³à¸j'Ï²Røè±
CQi·í`¯(Øô{lÞHÐfÃþþð
ùÑùÌÈL/]¥ÑÅÝóNzgU¾)A!C/gü5;éÇ¸^ïÓÐ9®oifXf69Þ¤áN½Ü¤¶/Z®;Zóùt#SíQ9!/ ¼Ã`uÌ%÷éúÁþÈÁÎ{·èZt]Ì<!kºÍÿ¨rß®Å{õ±¯BéØLRÚí¨*©4Oï]ke>3ÝZú6{×às£[ëÉ.yjj7?:PaNByÎâ-V2­«¸d"*MVN¢rºä¯ÕËÛ½O9Æ/&0vOUÛÂåK¹oÚ	Î;«¸·îgå«d	Myf¥¥:ÁhéÚ&ð¸ÔfxjÇßÊOKCBÉéÁvá£A+2Á4B´ã¨|S|"òÏy·H	4^AGæ3Ngox¸fz#@­V2^ÇFÇ	²G¬¨û{KQw¼ÒbúõX«¼ïè+:ÍôfvÄê£ÉÅ×ÌæÁEwó3[Å¢\;½Ùú®;ºÍþ2¹O³D3@§±Ù-0uN*tea©¼FÕXn3¦qqÊÏª¿ÒÊ£>cãxêèÌ/.³c*rs`´S_¾Þ#ûGéÝ.õEçûNÝ8èâÃ!Ì¥³ft$Ë® $#Ï²õé%n3cÑUzq«ÏBPKGd~&®Ã)ôRBÅýY?±h¿úõ³+\Î;Kk«6ö°´®ìN{]n%¾EpA½}ÊòîÌÖ§J1-ÒÌ'úÛ¼Õ¹JÆ"Ê8B-''mÜ/5×^sú¶CtÎÞÌt
Za|µd/NkÈú~MF4M*z¬ekz tçùF¤¨ÊÍ×tW{çæù[B¹õç ¹£Ðí<§Ì¡ÓKnR9£°a -ÍÈOël³5Hê(à¶ÝÒ£RÖKO¤éV{7ªÀvõpæ5ºw&,5(l|+ÿîc5¯J¨ÑE~|^»TCî9Ú4.Ý/hã*4«Y¥Bü¨Wå6JøpD3\)kÓ¿RëÀ1²L#B%{«®Ýþ©èùÍö«·Þ6æÖ±þ*ó­AM÷àtK`}¢OÝzÂûó=A7Ûïg¼±~|Ðnqù¢ÃAEbÜë{_ä4°ÄÚ}rêôqÉÇ¶Òfg¼³lPÍ+»O5U¼*îOÅz¿Yzz	ý"¯Y%pÒý®Âih@U&³6È}K÷(¥ßz4à¶ÇlÀ* 2^üt¶´X¬~þ¥zêÇ6³(å;Y~U	:ü§èùÝ.>oÏ^{Ó i¡ihÃ)s\U¤Éz«¨iªõl°üàYîÃiPÒ Ú÷ñÐ=S9	\N<ÓJ¶8:FþaVý{)¡_ÌXÓ·È§¦&­Áý°ÒÐA± Vænj= {öi 05|ôÒîOÖ©NFsàRúÄ#6ÿx3ú$­ÞC3¿ÛOÇnwÙ17ö*5V!U~Èæ^õ¢éÚé=QÝtùÐÀZ&£Ç)cþfîaãÑµù¦´V:ñ)Í¦í¢¸Ã,æ[ZÑb_Ò÷DöÊ{ÑÃÚ
Z¥B¢Ât&r÷[»»ÔJGÒÈèB¾äñëÛÐªñÆD±[½â>ÄÝbf</[¸ß^Q9ÕF`OÔ15£OÔ¾^L]LLOt*Ï¯%gXÐÜàuÚøLh; @¡=z'´`ò¡ÇO3­ Q¥°¸­$ÛøÆ¡ïóF³Ôç\æ¡MôûÄÒÇ6õ¸t=ªbrÛv­Ê6¦;2f9äD²[åqò8¶OT¯×Ú]ÕaQe·êAçÝäy-0ep:_:G­lÞIÚÿ*úN ÿÓi¢½ßa¯çtlÊ¢=Hãø£ö¡Âf)Ð÷x]ÅÌlÕ Øû¢ªf½¹Ûå4pçèPéV÷Åõêk1%â»áàöÂêDÙÁûæ¯×[OÞéPþ|}¾.DïË0ßÂY½(0q^,D)N¦$Îb8Ys×õôÎ¾áûÅâ»À@ÃìøÒ
.ÐVRE/N ¤:6-õ\Jéþ ðAK¾ð5b¤a|6°JxD>HFwì²w¼O:¼¤lËdRºô6ëm%9x6âÂ7ï¼øógãn+i}ë×yÍX¤Ï0ðÔ<nïoÅûiÙ6X­¹6\jïNõÌÑò6åEÅ­ªÅõ÷æì¬Þ<Øôv©^¤5}¿"4Ç}A·©,³X.@`}aÅßgH®4^u°]µ43S¦j·ôÉ:U$[L?ÿ¾l¥; íDöÈþxù#Cýi¡ûÂ¤ÛÝ³ï«'°<U®Êù>ÝÄwv,¹kE¦ÛÇòÀ?YßN;x]÷³Ó;óªB¾´ôèëÉæg'Mù;Ã4#ì`º½	%ÄøY*Ok@ÏÉ$^®ÎýÆâÎ"qÒí"{#Lß<2¢ø>JúX÷Ñþ¦Ì(¦êÿe`á¥¬hus*üù«°§äÐ½_çârí@Xádßç M-ìõ(ý>ûägÎgBÉÛ ]åéY¾´ÍEv}*ÄsÆÃÿ Â:æ
endstream
endobj
368 0 obj
<<
/Length1 1626
/Length2 13205
/Length3 0
/Length 14055     
/Filter /FlateDecode
>>
stream
xÚ­wePÛ-BpwÝ¸»ÜÝÝm`ãîîkpwwwîîîö8çv÷íº¯ß~÷Ç®ÚkÊcÎ1×ªúÈUèLlâ¶6NôÌL< yµ³£²­µ¼-·,½Ðø°³Ã8 @¶6¢N@Ð 
4°° ¹¹¹aÉ"¶vî 3s' ²5--Ý?- ÜÿÓóé2³P|üqZÙÚYm> þ×*@ ÀÉ0Y"
ZRò *	y5Ðè`hPt6²dAÆ@G 5ÀÔÖ`õÀØÖÆôWkXB C£Ðôt3Úýå¢Ø¬Aÿ G¡ÓÇl c+g¿|ØMmÿ&dç`ûaýáû S´utr4v Ù9>ª*ÿ§¹¡Ó_µAn­éG¤­±ó_-ýíûùð:lN@7§¿j& G;+C÷Ú`v ¿i8;lÌþÉà 43t0±::~À|`ÿ5ö	øoÝÚÙY¹ÿmûwÔq 99­L`Y>j;}Ô6ÙÀ2þµ+R6¦¶ f¦ØMíþÓçtø{@Tíõ	C[+w	ÐQÞÖé£$ê§2Ã¿OäÄÿÿ-òþÿû¯ý·Küÿ{ÿZÜÙÊJÞÐúcþñÆ >CÀÇ;üõÐ8[ÿ_)Ö +÷ÿWÒ¿Fk ÿÁVØÖÊä_}RN#²1ûéF£8Èh¢r26Z}Ìëo»	ÐÁ
düÐõïèþÅ§j2¶´ùK ö¸6&ÿJÿCª¿É3ª(«KIÐþëßKà¤ên÷Áí?Z³5ù¯Ã_0ÂÂ¶n Ozf. =+óÇÝû ÄÍÁäý?üùg9C'@ç£o&æ¿»ÿß?Ozÿ#fclkò×Ú¨8Ú|lÚþr;;8|ü÷åÿèú?Ïï<è4]^°5þdò3Õ©+kp\T§·b0Ø®¨N5?×¯Ò¶Ë7%l»Ìà¥*¡~ç­Å}þÄîuOf¸Ó²+	ø'ßº'e¢v?Q¿!õ·ÆwÏó9ÙMHm&õýíq%eýÂ(6Vèó{j?R\?t²;;DãäÚhväz0Ôê¼ßñG÷wý#C]{öðh3£aÈ¿bù$'8¹8ÜÔ¿}~rá´Sq¶Ó^a5ihM3­X§ñýÉØG[¡É°=_Uywm-¨ ÷]Øú®PTÉ¹êh¦FÂ²©¿ ¬.&¸äóZL÷}TdèÈÁì';cõgiÖòêfªp³n´ðc0z"Èb7¶>öÄÉ|ÿ#vù~£´ýH`ÇMÏ18p÷¤VÇÒÿ0ÔJf)/ô%QX}Û¢3ö/JßÐLÙlîªa£¡lT(Á¯±qÔ#?*¶x°îHò^6²xè+§V,`Üa±&@+è©ûI7fåôëï|xï8càøsÓ²´gDoâH"À2o·LÏb|¥¶Jvc4Üf«ì .hÔx}{&¨)î¬¾uÌLðmEÞPrJöYrÊ1áCD-Ó³h51ûpU5ÀÝßïgþB^ýÔÌF½4AzÄé%CûWÁf/_Aòúrs?g´è®ôpÕ3|Íé	1ÌXZÁeAO$«þþzLÕÔû´¤{Suà×Ù;qQÜ¯QeêRßtgìÕo¡îzW¸r¿8Åd8´ÂÃôÚtó/ÏÙ=oÞé½iÿ¸mðJ©Ú4åóÛ*cÍ¨ýy|iNüíÍ´kÑ.¹|Ô:­ð¦îV©árý½
îýh+í3qÞlñQ²+­+·Fv/ÖF«RlæR_°aµAÒY1«k MµÃý
.`s°Ê
ã±c¦]o'ñ­·û7Ö;0h¿-dp[õô -ÉÒ`ÖW§Zø×÷Ý^ì.}ÌÍ|ïXzë	^=õd&÷ds'é¢}[¸þî/K~n;#QoCñ÷jÚªÜ$&ÀZ¾Ëñ5ÒbÐõ×µÄ@~üAÌtôÛaé]çS°;3c0Æ^ö¾xÇöE±tQ®{ÐÛCq~[Zä xñAH,6i­ù^-7
Ý¦ØM¨S~Õ³q2æ¾Ã§ãnÊÆ®G¡dÍG]î7«	ºì¾ÃË¿Ò´(kCö§  ÙlJË\AªçQxCZpú~+DyØÞøQg Á·IZvÃÙÞäR ->=3,ÊSÌð¹5¥*î;}JçF%çñ«°ý/E>mArïbÌ°8âbS@¹ÈËËznË£~oæKÆæÉE±4òµææÊïÌÅ÷snUºñÂ¼9!§Ê_Ý÷#ô×
ã¥r©`ynAe×ö>ðÝÊs;õþtþcÜ¢£´ý/Ð'!NB«Ö®ÎííÎnaXÏn·é §Òðmôgýa´Ð9é[Ë+ÌD|µißHíÙèÚÔÂQ/ãbþ`C'Ò'¥=}ý²Äãt1îý3{ÑY½}zÁÇ³!<°VÂu0a@/,LÚ$;qp'#¼á(ÙùQUtzy«Åt2UÊZüäÖBbúI&êÝhî5þ6âómpíFªJÇ°Ìò	9#5{«'·9ÆÄx¿øÌäÑëL|YÎ×½!7.yßÙÔq6O¼IånZr<çQPB½aj]&§?TìKüÇ:}/¿ìõîÁý<7LÂÅ~AÎpIÃa´ÿ.Û.·zºWô¢¹Ö{÷ðå½ãÁj¥Nêè2ÂÑ#G¯ç
üÁUXùk{¨pd½ý/?XÎ@(Â¯gÒ]åËÆYå".Laåc.okNØ«	«¾xDÂ« ì}ÆR9Öyk¯öÐ§[òË¼Õ1Ã7(Ô­\'¥ÍD¬y®bv\âf$ÌLa¸¹¨d.Uðó3RªÐÇ§÷Û¾Yä5ü]e3ñ2ôNKÓ-!µ¿+Õ Ï·ÅÆÆäez{É"¾`yÄÙñ¶rrDïz°Dlôð\ppx¸F àYV)^ÄçÛÏVÕôÅVcT¡±!o_SVÄ\YÓû°=ÇââbëVM«1±©ïcn«®}ÓîÅp«¶(ç9Eú´DtÿD!pWCx¬q-è½¿ !('àÂiãho%M:Àµ¤¬a¡O,²ÕHù>â³ºÚ¢m>A>_^tY^[2!ÑAÐF¯o}kÞL8
³Z¼Ëi<øQMè²'JNÌ¤MóÒÉÌyàµ¢UO8Ð¶_YE¶ÏL»±ÆNÂ$´'e_§S{ö×ª¿ö,L,jL' YÈ[¼~UEväÎ<*èù@µ¤;Î	.¿~ªÒâu-×RÙaÀÊ_\Þ¼ô:»ÃÅQÓäÄ22ÀOný	_êWWÊW¤ö-ýèT£ShU'Td$É^µ[ïù±|¡aÝ*ºSË(Ùë![AðÖDE¬¹]qwløhúËÜ]Û~ìëºD»e3¯ã'N»Õ
háÙO¨DÚÃCÑ¾À@øè#S é¢ÖÍ/-`YÌð"Ê´òTH³JØ8Z3Ëy×üÔÁÉSãÛß»!MÝLcRÄz³Ûn»Ó¤(õMkÉW{è¸¯¤jS«¾Ñ¡lÆ¦Ú^ðüÙâ~k×Ýú¾W_kjWØÌïÓ 3å+
¿"B%í²ZLê9©T`¡P:£Èó1¾\SØk ÅéhÉÔºö¶×éÇºOK.ãÃ¥-~lo+3ÏmIäÁÑ®bô¹òÙ8Ë¤lz9jZ#í#ÎÄØ`-W`O/p®L åØ´AòÄÍ2I-9¯÷.v ¬íÈYvJÒ@ÿnæ£Ó&ß3mõø½ôû,\©.üÕëõnW)ÌwEâ_×Îãòéûk¡Î°µ«|Ì§û§²$üÊu)±¼s¾÷N_Mt b#GÌ©Þuý)Mª4øsÉ=ð½.b»1Õù#[Gu{j¢dO? IÃ¾k(<w£FPè}æ7HÙ ÅvJ:¦2AØuJÄó±JÐÕsøÃ^tùò0R­(c
÷Ø»qt3ïyl÷*P°bÇSâZ×ÎÜê³{²5?±{É,üj×ut»ÍZhäï>é­TÄöbXUWQz(ÁJí§þàl[¨ë>í÷T_o=£Ï_ñhQ8Ñëbé"Ôn´¬òÉÎÜ¬¥×¾ssc×Ç¸BÈ×Z?¬Z@ÐÌ?&ª6×*Hò1¼¢È5¾ècü3WµOI±Þ{,ô?Ð~*çÙQEJðÀýs2BÒ<Ïk}¾5¼U¹ðWÿm¡ûÏxFF¼¯Üiääû3Å|®"ÕÑ[*QgÏ
M'2Ñ¥¨RTOÊEÌðMÏhYHd'[Êg§ãx
?2»h>^m¹C>#úÕ¡ZÎò*û+ùÂY1Ëä8åÇmJ¶WÞyèS´UèÈµ»MVwÐËtçw"s>Z¾#f5­ürÁ>ká`,Vç!º%Q¾u1*Rytæ;¥øl Ýê/â¤UA1«$i:yk/xFEó'uQþR¯ø&eqôN¯D&®¦f°¥oÎ]ßXê¦¬8-óq÷Kùð­-¡µ±ðÓ`)ñ4õ®Pc>òÕ³
rví»îÿôñâêtüáØ}raäÿÆ)´Ì¦ÏË¹:2±Õ3øÉ¨{ ÔÞèõ¸BÍìÚÙ_ãým <ÜïDl[ÿëm&'UýÇ-,©ævåC%uÅ<,ñâÐ5jn¡Íúð&ðóÙ¤u¾7t]#«ã\ëøs¢^[R¦HÎÌP3ÞiJÊgîÃ´îM´®7þæÍYù*Øfìb^vo+Ýdaz3aùÂØ½|õºÝÏÙbJ-àð	¶H? ò4Eøpçhg`ùQo$®ØK~þË½Iò<Ù@ÃÙ¸WÅ}4ýh0èÏ@U%9mìâç|òn·ªõK:¸°\¶]MPxJô|¬g5+±ÈÙëùâ`G ×¥çVðYh'|W#KFtî­qådHÍ­àKâÆÉ oJ½)¹_{ZP ýHO¡S;ÿÏTï½³ª ÍÓ«wêàMgVM{Oé84ñeK1ÏOh¹ÝÃ«´7à¯ÛJ	®tÚÈÞväü2ÔF;;r5Ê]$á®ÔÆÂþ©yOóÈôM>æ?qyÞ¼kªwsy{* °§Ø pÒ$/³§ZXÏ&ðÝ@Q¹#ÊÙé©8rrÞ.©&õ9ÆlêÆ§I¯©LT L<~#N{8dZ-}iü·3BØ2Ï¡PZúª\åx!©{W±P×Õuuü÷°?¥ÖM[äpJ±rN´ëÅèMS	Ñ`«¹k°±ª»pt(¬Ûª*ú¡íHÂSØú¾U­_ù_TJ& ü.Kã§Ècz+çûQÈ+µ±aVI¿mKÚbÊò¹CP{[sÄh#±ïÎòBUãâQ]ÜZéñOâ?y¸e@?ÄC»Ö~ÿmcDÊ`ÒMsö¢î·W='¦²^ñ?ßÿÓKÏövXN80ø]<z>D:cp_|®«ê<ø$d/ÈWÙÏªc8«Qy$lr¢V@ÛfÜLéÐvõ5xuÿg¤Õ¯w¶ôË®û1gßTÖþ;kh¥Yê÷î®+×ÜÉ?)ËºÓXwä:z-­Ýa8dåh#L/3}Ëî
K¹ï°±%?^³óöJÀ©4{KI<(âA¡Ù+Â=Q0ug3w:[â:(åMÑ8dÉeÛÿ$b/'äS@MÿKé(îû*s¡ïK¼×á¡v´¢I+É	ÊäÕ¦¢§OOs*·u$Ù '¨Ðmxþ×4g¹{©:u3ëö|{Áíé×Þ¯Å;Ð½<k¿f»§W£"
ê·'XßÄ;õé}MT{(^ÛTß`ÞïuîÝ~ã» o¦.³ôÄpíh)[®É:E¦ÿâE³ÝJêNPÖZÍâÜ3"	Â{6õÂ7·!!@¹­¸{ÀÙ4ßëd)¤Öû`ævØ.ûà¢Xßò³XµÉ'¿d°À³$À}ßâ[kÐþüº>Ü6o­[·{R)Ü¬³~N`¥VwùðÉý¬NÏ<úä¹í^Á[ÚB÷äuÀ¹`i8>@£&îÍÐ3ôí©ïÑÉ%)¸ÃÊDä¸Äó©Z*êåFä2´£rÿ*Ù²­¡·,9ÅR7&vs ÝâEMÑ°v<UNè|kÃºÄZ6 ñüü¼L£§C"ãB$Æ`5­»Â/ÊxäÛ«1¯þÍêZ¸B7p¬J<cÄ&¡µàs>$ñ&"lQb¡Äºã;.l³`6>{G¶dÃhÕc&1>ÆëVjÅ§åãwøVËWf£Ñï#íCºÒjÉ8Þ!¿àµVS%ü»&í§ª¶lpõ/éí(8Þwª[¡¶:ªG9é6cé7WüÐï9³±EQJ5«(ÃáM+Dòü
iÝº`ô½K>tËGÅJ(ÕÛWHn_%Èá
å²êF~J©ÃqÒ?5÷SöÌJw'|!~Ìëb¾Ñ?®Íp>¬áj<Ä3Øÿl·Ý"Ró{Ê¸a*ZZÕ*¶äi³Çá­_ÄO1Öãü:)[&mR §0tazl,ÙNã½r',ÂH{þ³0×ÉDFr%r¢Jñu$ÎW¯yäökê!ÉEë*Ãëù£ÿ¥¬×±øÄÊWR´~Ãtn²õ¢h_
ÉmÿTÓv2¹ryC±ØD{cÌO£°Dj¥føú±pùÌ¾àµÉþáã_/Ù §` ÅÉÙõÔI¹
àõ#uÂþºÁB¸E³i|-ÕÁ¦²/	/ÿkQñ4ÆïÅòÒ`çÜ*L¡÷Ç&´¹×­kpÐ½ëíÙÝ@ÁN9ªgÉcÎe]ÍN-×¶äßãæý²=¦O¦á`=ìV¾ÀLr}õÈ®6Â1Õ$£¤éþlXX4õì"¯ùc½~FhyñÄÐ}s4»Ã Úø`;JÑW£P8CØ=Òq6°Ø>v<%ò¥ðç3s3Ò÷ à7KæC©wehdªzâ`ÊëK8SÀÇÜ£É¥Û"¡"ä@Î×ñ(.}v`.¿Àf>ÖÏªã?:^PoÝf!¶èöC|þPóÛB(W~Jjþ~@<ª.:ål¨½¹37Ci_½;SÚ±c[jdÛ¬¤ÅRf<.~sñM¾ïW¢È>ÏüG}Up.!­f<©L,Î µ_å;¹t³>¡cKÖMs{c¾B¾àR1-M¬,3¸´¦Éa¡êr¥¥û»â;sêÃ.~§ÆëyQdß|#é¼ªzCmÙÙ¿Íå§Õëô\¶¾YnhðETC÷v¼ê2ÐM0gÞy1sÁ$ çvÍ(½®p5øE?ù]qUÞï¶ºVß«i*¬,0ÊS2 =Ò¦ªÔ%&óTÛxÄë`ÛÛ0»Z¸"jÂ.bûT dø¸¬ÙÁÖdj-^¤¢&7B²HøÝk! ðEKÂ?ÜXMÐqa áaXöú©únãÛñ*½
æ¸aògcrm/)ËQ»èx¹ñ*À=Ï¶ñ¯Î(Ñâ vÍâÆ.pDi$Ï`ýïóçÎ¶âGyc#Øh©,¡Ñ	þ ÿnsëÂjçM@W¹ÝP«ÚDâù¼ÇÌKÓ ¹¯Ie$óü8î­¸`:+X0_àªª¼ºâ»|î¶õï7jgî=~² èpE-Fe%¹Õè6C ¥~ÓoFÕFgëäÇQX¯è0åHéZ¨zg6õÅE¤¸HGI.Î4¦ÐSÓK %KÏ´Ñ,)cÃI©ogbù~Ñ|Öí):ÃæÕÊEQB>ävåÙ" ÎÒá#:ÙbbdJßÑZ>E?´è
¹'LôÂñ[VgvYAb«(­-£¾ñS·ù³$÷oA0Z×»Â¡6X£Ú«ÆÈdÂØK;»L;oJn6ù.xÃÜ°CÕú~ÀgÛÕÈÁXûÖ<Ç=ðèI.i)Ô.ÄâÏ Òìýö1K­¤rM²ÊÝ ÞÌ@SF°qdã&w9Uû-®ø6ÿòRÛ*èù¶Pá¸ÒóµòäÔÅYÿðÅÆÍ}	\D¶÷µO[aðµ¯ûÔ]hü% YSÿ	*;[lÞj#¼&0<qXUU|º,y¸;;ãsá°JGü[tgùBNb\Ø{#CefÛDÎºnâ/\Ä<ì#LRsò×¶ôU7©ñ#ðUº!Övì«T*lØÎ2¡"Î;ý!ý­åø«Ú¾ WºìÀzÎ©ÓöTÌlÝÄ¦ÇáÔûMg¹HIíç´ge"Z»´ìß4OÏJM&ßGõÝüØCù eH.Ú-<O¸(9¤ú9\CÍ`2Y¹ÉË¨7wù~%ycú¤B¸È û¿°Aü,5¤¡:<ÕhÐø4>*àÇ:ì«ahP§*´Í¼.w¦¦Óà Iâ¯NñnñVC~bªÙõ2îÍ¡Ç }áLÌ¸X¾iTÇÜÉ%!­>¾·×ß>2ô ¿¦^4LT` ²1n¨|Éb}3½c^§Ôõ5æª''øþ¤^k 9¯$<J>á«Zð `z¢¿ùäFÓj0G$ÚÞí¥cÕJò2`FÝB$rÄË 
FI]ÿþ£7~; ÉwUâÑ¨Ä)îN0@>o*É÷nXG;æÁJ}LKp 2J'ÖzaòZØH\[®Ðö
%R¹BMµ·HÿÞxÀûý=ì!ò¥u7\yOÎÌuB&`ËFÌ¿=Þ½©3üÎ¾î°MZ¨«ìî´Q¨Ôç t}no«XÜæ¼¯^HÓ-»÷ÒXÛ_mü£+ö²Ö·ê-ÄâäðOdÀµváka¶½R5â'9PWX^I:bgOç=µ¢2É[íá2^NñÅÊ!9ù£#Á¦Ê=}ÚÌü È{·XhÑ5ø¦É/èècè%]èDIO×ÏWC~ØöÖ;÷ôÂ{_¥çòÅ¸0¹¡¢l2ÞÃ"öÏßÑËáÈsèTAF6:á-*pø]þü³ÙäTéâ.¨|=ñ7L7?g <aDaÐ`ñÊ×8å¤nR^±ëWôil¿ =;sÎøë/øõàÕÃ¼`$JwiqlµÒRájö+Säqa¯¤°_$efæÒW>×ÝYvc|kug\ÐÕ%È,Ìdñ¥¦êMjÄºñ,¼þb×V&¾(,¿ÖÂyçÙEðÛD*FªMb[&«0¥n¾ºëÖ 6G³ÑÝá6¾ýyhàêªLIa?z_¾gýÜh«°XÈÅ§aLVÍöõHüxßIü>{"Þúò·]³sxýRÃøÐ³¥dêÅ%¥8Ø}=JFT37+ ðBX ó¿`6ÒKîóæG^ä³ûjzÀ«w« ]
B¾Õ:1+Ï3EEVÈøõ]l®·/Äù{îÞA[=Nþ¢,+áÕ¢èÞFþrÛé¯#Ïb~h:Â3»øSÍ2yíó}|ß:â:YÑõ}kxçÍÓÁ£¤ý8úAaX¹ó±öUka_¤X²í9°Øð#ú»eu/^úÑ ]ùÒYnÄßK7cmH"¾xÕ=¾ÜzpíÃ¯Í¹Ú:ÖëJA2>õ[;¨½5ÅOÒ ÓZõ´ýªÈwûéTÌI6Íd^	©m/C#Äºx9»ô00düýëNpLÔ«%AÑ±í©É¸+­é¹ÔúE&ñ÷ã[ædêª¼h" H/ê¼»9pÔç´°uÙmmùh·*|E 3,q²¦òl<Ç%EaMqOV/{d°6?té\I[¯ÎèµI$`0tÑ÷W3e;ç'ÛXpÚàwYÕþv¡óÕã\¢ (¬æ¹OÓ
Éô>ÄÚ a#6õ}×¥rr}V¹Nét<+óFI>(#qSñÍA,>½Ì~hÏ>ùhô3ÎòÏ´òÖ¢àò?Ë_9?eõ%®dTzôW¹ÎbÆE%@ri6·sW®&ÁwÜÐù'äYâ¨÷iÈ^SyÎæÐ7ÉA]RdÇb£D#8«äpÄ#Dá[¹îPûËmq,öñþñVÕ®6·7ö°`äòã]TËó²Tf"rÕ`pÇz1Ýxû/¡Þ,1ÐÆÆ«sl.°§Àt
Óì|qÒVOÔÛöirêóf°Ó_¿C48e­.kCW«g}¯²@9åXJ÷v(Á#ç_ës~ß)íÐfµ\~ªwÎÓÐïÁÞ=R-$ajßÆjróµ;W³6¤Z¨á
<."ÏGÑnèqíºEW:ÄäFãiGî¿OIØº¾Öl^csPËµÇÊ´¨ÌªÝÐï^`-u¥RÑí#*f!´;bxÑ5Ñ~Zú×Ä3mÊÞ4ëÉ¬cn°\7Ãj_W(Y0ôt ^+jÝìQ.L#>	§yceÀfs ïy÷§ô	pnA#´Øµå¶ÙAóqÕqÐn(uíÂ©/EÓ×æïßÇSÑÇF¦É½°ºÂJõ)ëqf/Ü{@dí¼Ð¸~%}e13ß÷>¶j'À³ëãí-È¾ë}aßsNü
!æØf _s#Ð@V§o$³:øäøF|3ì;¨{Pè4¡ÒrBUÁ	KÌPÖÛ3Á¡ëá/($­ * 2(w¥©Km± º2LTÖ-tÛ_eYyc<lIÎøËûmoï¬¬T'cÄg"-	võÉÀ2¶È	øz=~ÇMJõ2fmÃ Ê(Fñ$ä3>§Çó¯oÅXÁ²,¯(¹÷Æ³A,ßî{I·m¹»2½	O®gH!Í2üúÞLÜ¯IzÆß,5Ý|ÚGãºÓêoó¯Ð$TÓQÙ·ºÓÈ ÀèO}kÆfq¬WÑûG1èô´2müm½7sNùRÁ%ÕÙÔd¨ÕÍTåÉ­ÒÒ?K­£|Ãµ/«uhÏñHÛU¨ô@¡´Ïoð¡åÄ¥TÚ$¢ÄôåÈ®Oe*tûUò4©)üY%ð§M)Éìç½w6H7øË«üùÅ=þ¾yÂ¬ =UDõ¤zy7»ÄiíT |6ÜEÍ¯¸#ê0â$nMÇóÃ$/¡ÖBÌ( WùÆÄcî~!WnC´ñ´ë,1)³Ð
lÜz0cú11±»lO%.Qv5	Ä¢¿"?Úú¢ÁKça®°º¢á+	óÆã\iÁÙÈ®eKa×& :ïRWUVeÍá]¯xolôO½'b[7Äú)PHXÚ_Éù&~öÇÑë0ÂÀodäë8*"Cã¶¾üs0;Ôç?M&ÇSyÐÍ<¿LVQsjÚÆ'¡³2e~2¤×E¶x8ÖyùÓñ¨ÕJ>¢ÖÏs [O÷xjcJ7*âì(ëúKV°'¨±_WPhbñGQX¼-1µ;Å!yrk~Ø1sd§\»LDbçeËpIGúô³ùíµ{X2ì¾Ü¦^Ü<*£gf\ÑövçÌÆ/Ä	³ÑUÊOU5«wné¢GøèLsÚGjû±"{PR½µpEZ0"îÌqyÓË ¬®53{ ªrm.ÇKé Çq
ågV»záM;!|ÄéDîXaTôéÌáúâþo%Øp,ðßO-~ó?Y
	@µÜãÍvÂ½BUÅ®Ç§Güx²v¢Rñ¡1àìShvÞn5dÝ¿G||bÄÚ×R¾EÂâöÔxÀZvfyÁ\ºß(KÑ®Gà»V;Ñ+Àzô¤OI+µ³|ÈdÞ¾³kÈ>EZß>j°-õ×±8²ólGéÿÎ"½çQ/zç£¡ïhß÷y_49Y3»\îk§,04×M®²õô9îDQÊniUÏq~6R áå±b"³×Áµäé®¯ÕUXâ¹¯Å4EAµèeªc[éÙßÍÜ¿KÍîß'wM½üà^Fï%^^XÎ&UN>°&¹õ°ô]y4)9\gÔ­Ê¥íT:Õ."R¶H1Bíé8º×Å>!°Ü·apãã3ÞK~Ýâ1ÐàÇ¨áü|»#36V-Õ=r zÔwrnÜ](=[¢¬3_>Lp×]Ýt<Òôeìmö²Lù%¹[xk+&×³Ø¬(×=ªìw2DGy$µÍñzÄã¹E!ÁV­Èz×qÔ?{8ÆýÁ»<¼XNkL[¦ëÞìÎìñ©ç¿´¶pÑv2 ù¤¤½pÜ*7âE?Êqµ¶XIñcJÀqÝH¨C!\50mÀÞá2nÅøáSy>D÷g¯YÓÌÍ?÷y·âá[ÜþÂÐF)Ó9ôr·þ*Oée××4
F3¥#TÝ1ÛÝáyÔ'`{Ï )eü{5yú ìw+^@i	Vn®ßzjïKËæ°±Éë
¯äÒåëFR'Ê~TóÒË#éê¥2zFkW®WÅ¼	ãÆÎ2bN%ÙÁÞªUÏËìT²óOßZh§îÃÏàÞ	W0iW>9ÆÕ?(÷]»ÛrÃYÔÂPÖïQQBN)|¹wWæ²K¬ÄÉÿ¶LÈØð7é§¯NÝè¦J]ö»egûÐøð´÷WË NJ6%5ÓRÊÈé6÷BÝý®Øêmu;W&tGª]+²Å­¾¢§äkl®»@e!+¹]ÎÑ'ÙÃI2þú%0¹-×P5¡º3®*Kwçú¹äø¡+*c¬i8´¦ìñÏWÎø­! èÉêhÑÜ-	&±æ[« àWòåN·÷çê®gÕBÍ3Á¤
qUd5ÂâXæOÓ#éðÐú+äø;®BBðØ_Øé÷rÎø^¤Þk£¸(Á?b]øsðÆ¹¼Çüt·ÊLÉYøYeª­ä8ÙíGy£­£ûiÊ«hÒåñ¤Ñy`/4£äñzQ«ØÐ©±ÊÜ5¨ÍløÐ±­7"KÖÃ»¥WnÓsÇ ËëO½°½tÂX9djRîXlpcWJìSÝìBÛú	áTíózíu*9Ï9©%§szÎrû¢\!C!þÎM<L@ø§ò)ÅÙÇy<¥¨¾yZ|ÓßI2ºM!©ùüûBÐ³VÔQy9þô¥ÕÞø¶ÂÛ\¼É;¦§N>±Få²äùû9¦9ëxÞ¼E¹4{8£
£À/%Ø»ÑTbðåÊ³£× VV)ëÈ)¡7dc¦Ç­Â{xåF+¸NÏ§¸eòç[Ç[ç1_=öwý×B¬ûÚtIr¼þ¾õl½§Ð~ªi}n²ò íçÀáÚQSÝûR®_èÞ
e}ÁjØ&ã1ßÄîR|0ë=Ó\¿¨²Ë (7|ý3TBYÞÎ/KÚJ±î¢XÁÒ}píHM¹Î³ªw%äKó§ÂÙy"5ó@k·"7îm0H|ý,Vº³i÷jlnýMË7³ÕìÊÉjÉ£ûóNÂúh@Õq¼»v	H2ÿíBKNuû]±ÏÉ~ëÍÏã§¤ÚäÆ¸I÷)yvòj[^àÐÓ6Çn²î1ãß°fPýÇÚÏøEVoà¸k>úa«¿,5V6÷ñîÐ{ú¥#S2ÔÛçrùÚ+~DeÌo½Ñ×IlÏ_ü^ãÜíÍÀcô,¹Ó­ù$¾=ÛMRÝÂ«ö@_ e¸HöÓDS¤.çåC/À¯ª|tÇ«&íÒckÀª©~ý$Y&§8ì"fì0Ñà'ÅfëXèüç[uw¡bÇaÈ
gÛo+øÚ¯_"sEZÃ$M%¼Q¦®¤9Øß»úÿsqíÆ'5ØÜxÇ&tR¥îþðW>]UáÛ=78s2nm¦2oi¥GLè´»*¹ZÎiV~¶¨ã<Æ*±^N,Äa ×TÖC¹¦§°EhÕW§16%ÊWÓØ jj@Öü4ÙS|dñÉ%W0®ÆMè÷oDI7<Mª9¼ûÐ>jæã¹5£³âÓm#Á.Êp¼Ú
I'D¡Ønæòo¡a
<x7F±(û+FéY»J&¬-|ÖÞ)*ÎTIÕFùiã¦ß»9·ûIægÛþ¹²Ò{°njz¤uÑ{¢Ýa;}#ÕÑ-êÐ¿Eì¶%Öæpñ¾:T+ÔQÙ6gÕÆDù uÁVª÷Xy¬ÈðÄS|10Ã©yWÃ`E}r`¶)ñJZÊ<Ó=ñBÎ8¹ÉþdÔRxJ¡Ú>££EÀ7C{fî#×mPRÝ¾^m±êV¢7=ÝÑu§D8^1×}l³Jí<qhn·+ÖW­M«×ÛÃ>pG	¥rTHë\s|û´^·IÊ¢ÎlfÀ¼óË;4Å]wQË-è´Ö`jÿ·A¬\·7ù<´ewhìê¨÷
å;ga¿uTÝS@NÞ®1k:xÞ¹»±L*ÀjÈèÈ.±=+=+Þ@'oamÛ¾0·½5G!»Â¹¯AîU!6BBäÅ5ãÃ¶§n[ó+æò¢ßgcÍ2ÀÒ-¯PSx0q5,ê`e­)ïbÞ¶Á¢õø¦·:YÛC\J+eF?%+ÖeèJÉaÖ6Ò~=þzâJ3iß@@ÊNcLÁKÈÐD¦10Ñ1ðÌèrR0uö5§^m<}Va×±{5NÃD³á³m¤ìøÓ|60L[8öòE87¾6xÖÝÕs¸^÷vÔcØ:³åþjY+½Ü1G±Émü­¿0¸´'|ùVËyÌ}dqAD[u{=Ø|ÓdóXÁ	~#*j,µQ·Ègæ¸ßíâ³'G©6¿=ê§±k·ÿçóþ>B;Ä×¡j¼H³:J^N=ÎñIýñ²WpwûBoÇÈ¤Á÷¥X[jµª¦â:>!Ù·éyq³Áá¡<Éö¶1=Ë¢µ8«zCcØ<pÍItèçP¡­1P4æjinU1ß(HÀËÿyòÚK°?®NÔ¾¸Õk3¬Oóeãí?¾ÊÐJGø3rÀ¯UÐ³æ>ºCäfY¢}-¯ÍÐLu¹ïöðë¤Í§?X³+­ÌhTçCM9#EAÊÜý+Ê7VÞ¥ÊQ
U¤9}/AlpÙf£¢pM·nTv§`?~®ÏBp­õ³¦*Ì:ß 3pW´^?Í~Såè;¿èKZÕ×cGf®DþÔáÚÄl°+C_=c'ª nt>§£ãÌ¬ÐfÝrÇÌ(óÊ'þWõ»§\N«#+vÑë;VeèV@)Åcqø:*7ç,²ñ = \vDg6híh[¯	ehj¥¶¤´¹FV°å¤
2zgåj:ÀÂÉ½ªÊ13wòê$(bWÙTÇ âS·hª¶â÷cãb£cñÂúV_Ì£CøãØn9ã89c%ïÍNB4O²·ruFCdù(¥<4ÅËSòWn-î	y->÷-Â«xoªKa(ÏÓr£^?XM¸êº~!/£5®Ýª í^Óáã2§fY«Ê4ú­­Éd£¸à9n25»§HùçÕoî[CîÇÉ'¥ÚùØ1s¡±~Ü×¹_jÈ³)ÍÏÛSÙ©ï«Ñ±J}G²i*ô¦O!O8#¤5³!!u¹ÝáME:ü0üºk.Ýsz¾«Ù¥f,£<ÖMÓßOrÐM"ÏÐÿçû×µÁùqÅP.ªRXP$ÍÆQ¥m©Y}ê$¶êoFgºóæ­0ngqtÜò¯TixÖ[Å½Wz1@æ÷XG(Ê!ü¼ÄÍA$Å·Õô8IËÇ@lëê®Ï{º$O«}ÅÊQY¨íÄ$ä9Þëù>MàMÍ»ÑÐVAÈëóØoLb¯¾:I»ä&ÊVäøxST÷±]¶n=\ÈÖ]TDöôÅ=3ÐÃ8ñî{¥]7ø&Ë©AôÎè÷´î"9|ZùòôÐÉÈ^¨B%tÙ±PÑûv4²(#Økµ¤N@úõÄÔf áÕãÎ]ÈiÆn9_)àÄ²§ti{x²<µnì ÚÈp1ãH¡Mñ%³Î{
WLÛÿ§;qà¸-ãynÑfqîþkº#LÍÍ7ó ÖÅNkj³ÌKÇ[Ö3OïÛ£5òû¦dúÎjy«UtgFÓ)Ón^ HwlmKy½[µb:%¶Õë¢Âx$¼æÿ Áqè
endstream
endobj
370 0 obj
<<
/Length1 1630
/Length2 19279
/Length3 0
/Length 20119     
/Filter /FlateDecode
>>
stream
xÚ¬¶eT]Ý¶%{p×»»»kpdÛ¸»»àîîÁÝ=\»CpyùÎ©[·Ú}UªîÕÚCú>æX\MYÜl
Û»0³³°	 T@v¦®Îê`;0¿³:ÐÒðWÎDM-é4qí¥L\  9@
hàà °óóó#Q$ÁN K+ º=##ÓJþ1zþæ¯§3ÈÒ@ó÷Åhv°Ú»üø¿vÔ .V@ÈTUÓWÐÉªhdö@'[«©-È 2Ú;é`'í¿ 3°½9èÒYþb;L Î@3Ð_7 ÐáÀèdrvþû 9,Lì]þöÀ ÙÙºÿÀ_¹ø_	98ÿZØýÕýS;»89\ £ªIÉü;O+b;þª`¿æ`3×Júî/Ì_­	ÈÞàôpù')`rv°5ñüû/è_i¸:ì-ÿ3&ÐÒÄÉÜèìüæ/ö?ÝùÏ:ÿKõ&¶ÿòÿËêæ rqÚZ° ±süiæò7¶%ÈõY·· ØÙþ-7wuøÐé_¢ûgfèÿ&ab¶·õ-XUÀ.CèþïXfùï#ù¿âÿÿ[èý#÷¿rô¿\âÿ×ûü_¡e\mmULìþÀ¿wàï1±üÝ3 %À?ÆÖÄéÿçcb²õü?yýWkà¿Óý?É»üm¸½å_jØXØþ-9Ë<æj 3+íßýK®eot²Ùÿrû¯¶ÙÙØþNÓ
dfcÿ	ÜÿVíÍÿkéúWþ¬
ÕÔµÿ7ö_jÁEÓÓáonÿ£e°ùÿ<ü#!ö x3³óð9øØÿÞ¿¿	ñspùþoBþý?ÏÊ&.N À¿u³±ÿ«úÿñüçÉð¿ÀHÛÍÿ{ó¿Óö?ÿ¨Í\þü¯ð·êÿ8ÿkî@ ÒÊ"ØL0Ä:-3Ý¥/wxRêK/;ôp¨Ci£fQA@¸Ç?-b¿òëkm(KÓ´À{çÂÃÛÃþh/®-mO*ð"Ø¾¯ c¦q?Õ¨ôSú©N÷å/¥ß0ú<lÚûÛÕJ^áH¦;8.è(Ý
°©îPýÌ¾7Äãt¢7A`ÖÒ$=ÜÓõ\Ãöí1æÄ#Ràù};!Oqñüêt×höûìÆë\µõC§#YËÝèeÑêOÜ{ú9'©å8ä.Ø¢i¼¢ûExrGQÙ¸ä¦Q}ç¢üé2ÏêY@Mæ2ù )zQ6²{óCNLnðW¦~X¢¹6zúg=íhá^®zBQjiÔh±º±m±âX£_RánjÍ´úìS5æaa4s,û{Ô£uÃiÌ=ü³z9Wè!TêF®DÅuÕÜð
,¼hZs\F­»âÅ.5ç3A8Ü]@|.õ­Ïí7£=_ººÓ¤¹>Í~9ìoR,ÙFðlÖë>(SDSÉóãú¦úúË´v¨©éKôÁV%QV»DjfOÏN I&àþwÆMT+?uüSGê|ÜP¦ÂäcVK6Ûc]Ä`~4þÇü(i;¨xÓåm¥×©uxÉ(m¨J÷õ¼6hj]D7·Ì¼ÜjÊÝ.Ò·×Þfïoxz?ÓÖgÜà²ÖR¬LmFÍjHtRa ±4§Dº>7+{äºyhÚlÞ+e} ¨ub}{ªeÍ)+uüå²¥ª¹íÐíÃÊC=êµÑïÝ<°Ùÿ¨qC¨ZøïtÑ¥ÐnÅÏt«)°`£8AæêøÆ!9;Åà ÌóTVý`ZkÏïTóª¤ö.¸ì9í=@¸\Û1â7ñk"}Ö"gLÐÙ>¶õåKÛTÃA©æ+ÜµîKßìç.éÿRi£DÏèM3R0àcÁ­`¶ä³S­ëúo"Î/[_nÊ÷oH½qÖ)L6Î?ôfkëcV±½ÆvGCã«édBM¿ÄùPú9ÿácÑ­Á,Þ|-E-aLØ¢A«øSîå¤YÈï5M_eý»(ËÌ=U\Í¡ÅÎË#XpµÞþ&öÿì.{ÙL2IOÔëÌÃ¾¶~âÛ 5iMÌ4K@¸Í9[ÇÍÈmæ·bÂaÜ­7.*äA¾#ÎEç Àa1Äqò9ÆÎcÅÂëÚä=gäí©§o¡î>,þ4ó¦<>'l·¯llÃ%ûìPòk|Tô|ÿ¶ÛÞÝÞÈ(öK®.CÀãã§Àï°'ò8w(Táú·A}rÞ#e,_µkè¤F ëº Èåô_rK¨ò0®°ÕI¸\µkÅGìRÞZÄ_ÎªÆ×_ú¯Né]bøÄÎVÆÆC' @|PbSØ©ß²ý¥ë´e¹§)Sý7Íq8gù`ÔË9O½Û[[ GèÓý4$LåYÓ´÷õã¸°Ù±£H²÷Fó<¸ÄaVoÏ;{wCcDÇ¤uú× ¢ë-¦Ä>ùÓ>³>I©¡À§&÷~S.çmâaè#$RòvlôÊgrGIÂâ°ý*õ_Æ#C¬ê%@ÛõBjrÓºxn}ê á¦à$Ïl'¾v1E_;|ÅmsçÖâÛíN8Ô-ÿ!a'nmx.à b 9¢©rfoÂ*#õD¼zkHËà :Î1Ü 8C%¦JÎðøÅÉE+õ¾_kØZÛWºYdHá#j×h·È¾Øzµç@µ
æÛ(d´ø~ñS(¯F]4|éeà=9suûfPññ%ÎÇwá¢ãí&;ze ZXJ!S»X@j ~è²¾MÄ9Uò=SûÚ²&ìøêüÉìy¾;xñqKK00_x÷^5afu(öH½¼ö~%£!ëÖå4MÇNÍýÉC~»®Ý¬qð¨°¾~R3Ï $Ã¶¢¤þIÈðLXÔÙ*X<hìªñ Ãí[8ùçæ3>wêYt¢C£ã!6Fâ¶-ÆVWüOò:ìÜZÂQ]¸¢±HÒâ©ã(Ðß1ÉéQ xDkQP'±Â§Ôd{¾­g76yüÛµ[ÏU¼®ît³C*NÕY&!·7ù=n;¢Gè	ÕðTãûh¥0EéeÊò<dCõiXÏÐ£ÿ(¦ë¾X8}¨«ìk$CæØGÏNÉº4ö_v?Z«mr[_@·ãXêq 5Ýî©(n92Äß ;Ù6;Cý;Íç*¿wÒÛÐ÷ræÁËÄ÷?«ÛÂà¹`ëõ¬é nóKÍ!x{4jGéúr0UÔ<7°u¼ªØX0IýB:'I¡È"é¾(?Bc0x_e<áÚdójÍ~Üö¥¼!ýXÏ2	EÂ¡Yj©1sÝ}BéÕrL¤!*lyxU~èªò2ïN`67b¡d§h¦uWp©dwÁµ!'?·àÂq¨ÅÈ}Òâs`Ó ëÏ÷1Yµ·âI¦òº.;@tûì]ÉÂT%$´J7t¶BÉöj´ÌFHµk´·¥æÇ, CycÙn+W©Æ½´lÒÃâ4«áØRÞ¢±óÇîô$×â|3£å¥Ö2ç *^úöU$Àÿ¥ñ#Û7Äq×#núqª@ÒóOú­Ëêr
÷2Àfä@GtÑª«l=ñö¾)\Â_²x<ç×7ôNá±%]´O¢$«;éÈ»Z:év´·[ <!/¯Pg¥wëèiÕÓ?ùÕ%_n]f:è´ÌOáôcí>ÆqQþÎBÊÜ¿¬2Éïu<é;BMRRÀç¦à>´|k½#qa&áG}ÕGßbtìÌòûA1+õ®ýÅ«:Øä­ë£¬ÎÿTµJ$ÎvÐ©«oÔ(2õÛè¡3¯ºóX²)~Z±}?þ(îAiþ\±
ØílÒèÐ@Hkî¹<3#a$£Yõa¢çA;\&K:ÕüQÐLMû·YMøDQ¢+ó7ñûá³	T[4Þ¨?ñË;ñ3»Ó¸)iò!ÿ<Ént;ÿ©(ÒmÇÊüñS9ë?]	îÒ9½tJ¡¦<ö²7ixèAË¿ÙÇé¼aPDHÚ`%êNoÊd¸OÚÉo»>ï+ÌLeI$³¸>Ý_§~å(aÃ_ò`jX÷ÍË¢i±Þ¶fÓ'ß4µi½!1¿ÉnHÅ`å[Jì°ïë7a|W2UV~í¥§wh%Ûåÿ-/¨V Õ7YO|ê\vAô6_ýú¶ü ³1r*¾à7aT||& 	ùD¢ügX_E^à÷GA	~®%jÝÌì§Ù;
!w²cFÓçõRGªÄ	Úô½ËA¼·z|f_0÷;Ã'éh¹²»íÃD÷æ-Û3bçÈÛ1ô_ûÜ?p/ú%^£d¹èñ~4ò#_,2meäsêE!YØJs³h'êÏ |õ\5Lq©OÏ÷³yâÜ3^Î¥ÊÃÛóñÖ¼>Y,µtîByc¿
ø]Æ<EÕ!@9@yDZrbôlÿêdGT}ký6ddãóRÀÝþãÆÅ%gAo°×ðwØjnöA½¶]£ÌÂmÚ*ª)÷JÑÆPhpvßdæ$,ïuí½ë¸j¹3¤Ów$IKí=ø¥WzjU5.HÿG¹ÌMålè¼ KÒHYÉ6£w¡j½tX6¨¾Q¨®ÉÖ)ØB[ø®zy&½Lûz¿À<3×y¨¯Û>]ØAxÅ÷óñÝBqÅXÿ¼]Å'?¹Çµ&|ø¯èyáCe¸v0nq®¬^þ¸)X±Q~?N¶ÒÖÝû#åËvOÄèß¹R[côi·Ø"óOFZÿöj7ñiútô§`òäºYÎÕ <lÊpÖ4þNÝCÞ+#¨¡d©ªÎ¨d¡ßÀ´Q) ¤ªlÂ²I0ÑRI(gMS~cA°dê\Vú5a±={LáÚ)­ãâ4EÝÞM8s}}ZzÔî'ob8`ïê'hh¿·3Ü0Ýc§åøLCÏÓ .<Ø©!:+½e>Ýý³iQHr¦×2zÊÈëÂûºWÉMipÊ¯àé¼üÝW(oNáå\VX~ý=tOÏÚÊ Ur~4W}#6´ÑA¥ß$	§Qk{á·»ù¯_ï$|÷l4DÛo7ðË~âDHûYÃö]t©ÍÆCê²N_ï%Ê4¬_}-!õæïÏ*À÷!·Ó3Ûd³×:¾ô°pácÌÞW(à@z³X5ùKçþ&,{	V·¥ñÔl[ü&%ôþÖ
k>	R$ÍîEqNÕq³zZbÏQëõ¡_;fåïµé²äìü)³õaNFoÇR}P,Jq5¡^´¼PÚû*vT¹f<Ñ~¨ç/ñ(øìjíìAÈø~­G¸«á½YþïÓZb:¤@«ÐÞ^q·û¨¶ìáñê.ÿ9Ïù).¹9X­W}ºZy¿A3.íÒî²v"J&që÷¥ëÒûæóz ûwõaç
*bke½e^6ñÐÀ²Ôd±WÏ)ôËoíéãæeëÆ±'þ¶njíÄîªJ·utãD/":>rÍQ·©wì´Öü2+R3w<¨¼ÞÒYó«åÃ»ÚD¿yø@_8aTfw¸7<|~ºÀiãÊ@j¹ÁdeÝºüÃ 7¡Ëm=ÚÝOî¿kHc9éà¹âgf`Ê{5ñ¬åÊùÔ/U¾3}í/úÍ{ ±6æË4qÙ)ÏA¿TcÂªÌ7´eSrßWª²¸AõÂëêÌTkdÕ¡÷Ø²%5ã_îÜÔå&Xïív_ÏX½ ÑÜ¨l$å·Ù$ÑãíZ4.[àJÈ?#/µòbzüp¨©Ò>b'ª÷Ðs¯úÜÓSf`z­$`ónwclõ´Íb>=*#&¯E6NÖagm½wü(MÄ»{ñÈqCz&ÕkÅ3óiÓ£ç¸Î­O»Ì5Í"Í¦:_ !w×ôq£êÅ&?ÏêÃ´´Ð7ýá¬c%X±P:ûñhÀøÊ·¡À¯¾ 9Cpøq;¥Û¸{ýðËKfâÓÊj·÷rcøúâÊÎ^óK)I Y<5°Qª+fÐâmè÷Êë 'ðí^»³ùí×Äw"sâGþVæÅÒZz=ô-Ì%ÎeöÄß³}°à&Á¾î3<ÊpÍú	ÈÞNrÀ¨SÓäiÉöF>ÓYÇóûÖÿméÒ¶3¿ÎÅ/|AÑ:_ÛX`!ëeeyr }#Ø»Òx,(ì8¤T'q2W]Xh¤UæL	SoÅ£íßF½ú½^¡÷:5ú°óÓªöq'g$kÙÔ®$â'xÖô¨'èVMkÛÉ'e:8à-mRAdmí#&ÓwTÅ*¦èoXã!+¸4×L»É"ZQÞ%p<#¢$<qúÚû¨0Moµµ¤)ÝJUÚJïE+rçÍiRî±bfJ²êÙô±¦©ÜÍkCð÷c_¾=Íã®{pn?ÿ"ñÉq_ÁW°&7¿b ¯â¹V^#º±ÐT~7MPûéÕAå}aùçWUê»+BÇå$TîñûâÍ3QÖHcÓULméPðçJòÉXá°À§É¶úRî7ªDîn¦ÌÍnº®Û-2¯©Ñ¸º'{3Äâùb(Àô.Ó8óùoÏ&>ÜÚL;Á®ëM]C)Fúm¤Î ¤ão­,ìåbyKÜJ$äJøñ(u?u×SöD¿IÃNØ$jos£W%F½z¸AJ]XbâÝ©ó¥ß[y^ã(ß:òÕçµæ|`ïÍ~®þÄ67Z¡²ÞÂtøP·iÜÄk$µíÍdtªñäIÍm°Ð6Öc1s;¦|lù2A±,ÓÖèg}ÖÔ±HÙ?1<
ÚÎ¥ñe$li}ûDÎMw·Å(XáD¦MG2SÙÎMQi-ó®6U/.ÅS,Ùàð"¿¿¶jD:l~ãW¬Ù-kßlÝ×Î÷Jqèf&a¼ÒÓåÁTjy*­y4k Å|,E2å§ÆMm´EmSÿÉ
F ãÊÍb¼îbvÓèó8wcú+.©¸2æ­ýóWm=®eZZwçDqý'MäJàXYlXJ¿ôMëèÇÿêm\>[ÄöÝDëàl®JºDw£;Û
cjXÈH~C2*ê+¸ß
	ì¤Àsõ}<ï¶AþÛ­F@¿@3 mE"í¢K$ùHîíT×ôþ»ÕX4¢±?¨ÔzñËÖUËºHrmÈÒEBë[§¦û,Ñg%¼ÊnáA:*ºKI¾HX<4!9|ôIZÀíy>Y5!ØÄf¡.aÆÌ'ÿ&YOþâ1X¿ïo#ß.l|8FQC½êèF>S¦Ç2 RÑ.AµCLøëó_ÓæÃ»|üpä^s½ûkÕ«|ÆbR0#¤®xéî\[3äJY.)ÚÑùs§E/kA½ ûjH*	9üå]6«;'a!ä÷g:ÉW£Ãw${O><6á\IÕ~>Äýqó¹EÉI4=1/1$«¬IÃ/¦O40Öýªfk$Ó×(®i'Aç½¢\o³òÚîX»àÈ ûÇ>&,&;ÑIïun³K÷Ç¬ï_4­^¿_uTÃjð°h]if]âeU/("%@ermeVhåTÌ!qå.û_Yµ@ÞzÒÔ¼¼Éå|;7,=)sÏEiLÿ
%Y¥ÄY¥¦ÙÞàÅ`d!ºë¨÷$ãUñ,jÚâ0>ÀçÚ}V#W²Xm[ÓÚîÃYÅ3R@ã"Q
©î±roP¬ÛQ£Á \<3êÉ`0ëó.®.tné¾1ÞLWÇßMp×:°²þ²â^YÒ×3þ¤Ü¢ÝôÁqN#jCºyþ¾_~VùUlù·M¶bPzt7E÷6Î¦ÿ·Wû/e%þqûBÜÂ¨ÇQq½ÅYùBsÈcÇ<0Ëx¢Úw³Dn.m¦ãT¸ZbòÁè¼¯öíkiîkS_a¢ëëoôäÚUâÈ¯6©ÛðHftVpXË2hQâéb%÷÷!Xæq§JF¸')6Ùé¿xô$R"¿ò´æ=E¡BCê¢TpÓàKqÆ®`§µÂ*ÙÈg>³x!Ñý1jyÚdÞÌÊ#föFÒ¶ß¬¶Ù1|Ò Y¶æxXÌhãù0£au<^å,7ºÓ@0!ç0k]¶ùeãxâ0d/ÈFìiçè{|q6:FXî§/P+à:%Y5þ[)Õþ9ãùÁÞÂ5x(Þdö"BË(ÊVlsärÁú§¢	æ>ÉÉÊ+æZ2ÝFNuÁ U÷§CN#¦§?É'î¬Ùâìrºòe«Ç¿~û°³ºha SWyC44aãò>ÚðzU.¿]tBôðu;ªZ)áH5t%z.dzÅlz#ÌÓ²|ÙWí´¨-JIé°	/×S#º [bÏèü]T@d¸ÏÓ('ÝÈÀÜZzñ8Ø§yË^§jÐ·5¼K·tódVHSÓi)/q·áÉbøÎ÷GëRNS«&úm{t#Á©ßÖâ<féÃ"GÈdýNf¯<KÐ§ïOàg¸Iâ0oÈçüä®¦mb¢n±¯ò±3M¤}g¾{XK[ò¬,äBoÍ>Ø}ÊJ©Ðã$p|èNnvÃÅNýã­·Õ|õ´¿§IwÈÀ^Ñwg¿r°
ÇßôÂ)¯JZ9¬èúýÏí¿.­ÙEÌw·âOáÜ §½ù{ÿ ~ÒÈ/£Ñ«õÌÃ»*¶ÆµR²?I[Ï35Z'r'4ûJEVÉº\Õ»ýýD&"r:ë¬Z²åzI:pìwÝ%{hc¡Èk-£ÔÄ2öùÎõt÷qòÄÛm¢Áôf;zÈËS±³)-e»WfHnìàtIF`ñy})+eÏK6üMKñàkÍÆO+1Æ¶¡Y7´,
J@I)AÂéýøòý »¯´°­\Çuü¤¶ßz¥¼ð²ú[¾¹ë¢é¤RwMHyì(®tÝn%é`ÇÃ~¨¿DÓÌ¯¯x'Zb×øoIf81K0¾>È³[ìF Ñ6Q¯eÅl¥ÄÃ·¸Æþ[¬ô¬¦ñºzÑÇ4mÎ÷\±_:K¬X#íTø1ÓùD])w o)Nô";ºwë´é^BqYãï),hûgÅh](EX;z/\P[ÏòÖÝû²2×¤h<r:^µONß²+V&sDøzíw¥è2/sZYlfqÃ3GëO<åï¢¬¾iö%®ô6÷?mòy·?Î«?'°*òÈWMjB{4ºó£-ÔUqsc¨C/Î±-ÿzYuWùTïÙ¿¢çox<½_`^¬ù\gtÃg+áÇïSP(4áÛÌçJèxÈ¤áó&ÜÉÁàæÂÔÄÑGóÞq¢2N¦V.÷k$[¼ü¼¦Fp]í7îe;5 Üj NÉìí?ö6ðæS,å®±ê"£Î¶ 8xbÄñÂÓî_ÉÅu~V¼Á£¯SrëÊsð9éUÕzôÅÄÕÈÀÒÒ!ù¢ðÌü´.Kº(U:+!Ù#ñyUonÁLaþ«W¢¥ð=}Äæ÷ÕÔ¡A¡a!LXi>Ö<÷ªç¯ß4Múúx{4¾è(3láÞ82ïÆÐxï©7f}p,ÔÅÏkcPuü:ÆBìsä9$DßÙ¥ÉÐÈYØÎ¦LfTFpp¹
ÞD©CáÆ³°q°n1.ö­`ÆÅ­RÚCqëÛÖÄî]ÞòEw¼H
LP8}	o+iÕ/Õ%¾?V¡[´p¨wÆ(lqÚëý¥\0ç
9UzQeb¿5PÞ+öGøm¹»ÖH!-ÕÚå¨¤2Hv9b:[Ý°?g°P©)ynEåtYªjëÛ)½IÝÂ­U)kíLöÐ²§dn}ð¥=ù^²ã@BB:Ô3ç²3mºþ@:ÁÖ¦:¥Ø"×¶×5!Á<â¹¶Ï¥nR6ÔXd%DtGÁëÁphay:ý¦Hªú{aªÓ´u8ò{«°Q­ÒácKVd²ÁÛ×V}øçÆ¤#¦î×D.á	"¶ÌÛÔ¾c)ýBx¥Ò¹BHäîlþîKù§ª½W÷r¡ÕðÛÞÈ¸z
)NÙqÛÏLFSÊ>ß.ÂLÀªð¾N<
!áíçÜü¯jdüBòóåf«Á$c®ú&¬/³è#D(Òa]2gØÅ	ZzyyC¥uÛã·?Tù~U*é )}ÞÒ4Ou a°Jð~¯e;»üix¥8Ë4VýñLùÁ
ð"5p`ª¥q~<9ç{Æ¬Áv#n[÷Û¦°Gq3þRèøº±®çÅâ%ÛdPß² :c@hñ4´
¿çliÍrþKñwh³cz`mÜAñwÚ¢¬E\Üà»yðµ&Ü`ÿk'+,H!ÄóKû÷¢FÜe»eD>úRoN±è{~ÒâFd-ß`vt¦sâw-#ñP;<!KéäÊã%"vÌö
íG¯ÑµÇâÖÅ[¶÷¦@²¦wFÿ#É4É¹nûV­91¦/{DÀ×pÑ:9ò½«aÔc7½­0¥<Vj¶¯3RVÜ16[òPdmÖùëWfoÛG¦ç Ö½.U®0
Xv¸!±ÔÃ³V¬±Ryw¸ùªÛÂ/£_gü1C=´{ôá¯Ké<V1¿gÕç³"Ñ´¬õ#6b1y,ü<Z´&¶2§r¨ÚErýéÃ9.@¶Ë0¶` ¾2¶ðÕ©ç-¾Y#5]òúAü9½Ç#ýÙW+Ó(wõ(iÕ±Ï{ì!ñ=Mùþ¢¯Ü3Ó]î~à8ÅZ×m4 EîTCs|Ne<5	6ÑË÷/D72¸ÓÄ¾à2	JD0¨cÈX¿¶{Zd®XDïÚÄfgðÒtßB!ÀùÃ¯ß%?¼ì!0ïäèØªs`¨S<Þ~!pUòpñ \IµlÉgõALÕ?Ãì*@/X@yÆª"4kFo7ÎkÀ{,4£]#­ÆÛbr×âwÙ/u©·µð"XÓm*&ÆÂ¬´ç»ÄE°;µ;Éÿ>6	ÐOö¢$<©[u¡µ`÷Hîi¢b·',j)ª*¯³EUö~)10?â 4È½ÐMHYÃÜoò~ðÞáÿòVÃà+NÒ§eôSjóÇ0¸§yÞðî²Ç_º³«ê¨e  §jH¦k,æá¤ëÿ¹Ümô)û .E§îûÃEa¤è"kÌóL[¸ÊÏcÄÛÞ/$ÏDÝ'ïåÛ-×¢ï¥4ÙäCmµNcï·Ìi¨Ü4Â¤ÁÂ)uÛÑIR1§Í·êkþ$ÑÅ¥ý;?3qè~°	ÛGÐ4çu¢}É¾RßYj ^Xys×auÆQHäZhëmmÂøÍ®¯2ðªÃ*pFdÐ_Zvþ®fºíÁõ"Wö-6=&Ó2®J/íëB,GxI:;ö©jªw«åQf6­Íï¦Ù%Û!']"VT¥ÝK´Ü°GøÀÜ%¬£á¨­³¹öÚ%ÊºëÂp2{ëYÁë¸V¬çÌÝIQ_So>¦¨0r.Ôdä'¥Ø_CFþ³*ã÷úwçõ1o2¯GÅ¿Âêt/­9z
ñ§¥xD$[Äw»Mämdf7{`1Ø[étPìarWç=ÿÉY	á9=;LÒÑ®_ÇJÅ<
ûb~FúÇQk ÑúÔÀØ^]ÛnN&*Ãzå©Õù:Dÿ]½®\xMððQ£BàvkjóÍäµ1ÁT;M£aÓûÚÛ®Bùüª¯ÒÆwQÅêXsËÇãY:p6äU$Gì§ÂÌ¸3r59lcöKóþq6eÊü®!4æáQü¯$°Ñ,tãp8rFÌÕ«ö5Þ6*52cç@ôc¿[jR[_UÈ»õë¥ÄàJÅ×	FòH£Ê0 vÍ97ô©­Âoük­Ï-H_¹a%B¹¼¤NîG¼õívñ}ðT^¢Ûª@¬&z¥Vò(.X<ÜÓ9Aù\X=[ÕR±¡#ËæDK°ÊÃû3ÜNþ}i`ãê:óáO)S7NÅÒ¼K%u£Ð,rÝ÷åC{Lf}öTHc­^ d6qm*M\@ÜL¶äÁ±ßdò¿dî O?âGG×á#"àøyI÷dv¸ßRÑEÁòíü+®øÌ¤õ]IÇö­¡«VÞ«¼ÑRR}ßRc¸ñUáHºÎP\YÂD­ðüT­Ú]ø­Iq}-®Cu¸¹yè-Hz¿v§ÁÆD73?Lö®¹X÷b-·®pxÏ}Ü¡{2Pÿª¡pkbc~Tß)iæ~UnþU¯+/V>îwF~
SÄÿZégÇxäÏ°/äî]FUf7=n	Môb'Ð#ïHOçc/TuAÿã-9Gb®b];ÅPÃ­úØ±±ÃM(Vçë¢§°[Uw*oQ$Z?Ê¥k2·Ï²\èü=_Í\ûzs©k§¼"**mÃÓÉ¶Xa¨ôúà¢4{hJÃÃ³F~³oØü2ýK»"T7í­n Åòçã=HAbüEy{q6RïËÉF'Ã\3ÍðVm3aíp¹C£'{½°7LJM!öaX¬cÏ{Ü7j¡<TlJ`S®q¨¾âªçE÷½úuÐâiù!£"Ì:Ê®±2 j,7vÒþ!6Ü¬HÀ¥²kÑ:âYRý&~¦wt<.¸I¯3J$ñ*Ä7÷7ÊcïÛò;É/l0N/xµmÏ*Ö"hÄKD¿hõóÞù¼ê-c#ùü¾¸pá¬ÙªzÊUÃâ[ü­°íÇÑqúD.ß`ôNÃÓsR:Ôqc½	uÎ	úýMf&mãØîuËÕ ZgV!É{¤N«5Ë9wÎ¬=4¹jW= î0 Kï
*·Gx.­g±±öI:KØbÌçÜÉ,ÇåÜÊ¦äºÏ«_© \Ð2x0rf]Ó6¾Å«ÏÓzÁIu*ßvåó2Ü\7SüE­öí[) !ßÜEÂV¼TRgñ,o¤Êà	~>·¾OÃñZÔESUýüYÜÁÆ|FHfa&ÌÓdýUÚ²,~¢UßñK.Èk&«1ÚÐYJs¯Â§Mkø>*ìG'cXç:ö)+ã6ck¨ªù­åÏFï¼È"|(?ÿ7ÿV¯#ÞÌ.è]Rínþö%n»Y"ÚqORºFZµUµk"¨ÕµL(ý?/!¥!òy ×ïâßgpW£ö$8÷öb  X­Gv®ã£§{øNº+_àôøæî¾h	=ùxÄË¿µ¿ @Þ)u(kÜÓ:3iË#¹cD1JêgÌ`5 N£.D38}À"Näjôá7æj6f0ÚÛçéK)°ô{hç=Yuùleh´1hË3ÉÁ×ò?îhà+²çÎð\=ê¯Þ­à1ßoDÕcAàiQ%#1yq`Ñ®³è¬ Â¢g¼}[éx¬ÞÅ'íWÕ~?J2LBR®¾U#  «îîÉH+R4KÞÆ3|
{éwQêø8ÕTªkÛäÌþR¦$ÿ^{·¢döôs × Ù:û^$ÞÒ¨Å5qPj7¬*û3	"ÓRÚsë|û[û±ÖSkÒb(Ý,Ã¯ôøn²Kr²ª¿ò9ÀÌÎáßYDÍÝèJf%ÊÆ9ÄðXùM]È;dß·ø|YsMWÞg:¥+|«,öÒ0 ÅÇá  =_¹1KsÉ¦ÝX»­eCµ­Ã*ÕØ¤Ó/jmÕ«wWÀÂàÍLwÔ÷EÁ?U4ÿ$SøÔV-ÐË÷f22=ëS¬9/&gè¤BÅc¡:râÆá²£c)#L]Ådÿû4ÉêÕ@®9P|ÄC¢$ãÆûÛop/HÝ&ÊLâ<|AÒ%ã/É®(<ºEàéüY*tio5éniï·'EeZs lèÆ!XÂiãúyRÁAÚÃÄ+>Ë{HQ)3ËtìæZ¤Vj³I3¨ò/´¡ÜbDk.iâEÛé?¤ÁfHÌ±ß·+lkdm~gtdÃÞjÊiò2+ê+Î,DSßË-¶Ée`P¥*1%NnÝN:çÛÜ¢ ÝPEnÒ3íÍýæýL ìánCHÂÓTûØ&=LsÈõSÑ0´eÚ°ÐÛ)È1¶ÖÀàÖP¶¸6¿3ö2loÁU`3¬ªkÒ¸Òw6üàWÑÓÈs;ÆØé@cL'àg4·{¬ùUéõOG÷9H|ÖáÃOÞD	»*BKê®N«Öòq«Û­5áøñPÛöÅ¯Ä'¸È1.5åaèxÂå}É*»¼óN½ª>üû¼ä­²Ç«ð`ð{wE<ßRd#qÑ©âä>î·É $@(;+ßæJhì"Ý ½ñ;qiOô¶ÓëìÅß)[S¹ÈÉ¶s¤àúýnÈøxòÖí]³ºøµãý/hºMýj7Ô§pð×.púô^?dxéöOä]åá¦àp±¦"Ê¹6Ô$ÜìLQÈËb¨É<(ým1LY¹$g 1Lf	e;¾jÁTÁmôBÄøaFB(}WÒô;4ÙZéïcAØ Ùì¯$ÂðÃ¦"¹ÉG7-ÚÖ.ÎÝ:¶59µ<-?ç1×õ[¹ìr)w¥Õµ?àÆD:ÕrÿÀókÜ_w 0úAÉcGO¼jdp{êj³­=5ËîþñÝ¾Ý$ü½æ8ÂF#Hå3ì-!UÛ_=ïB8ïì¬´³ádgEáúÉFyÙà5ª<Êï]D^[¯BfPVÆÇÞëMî=(à¾÷k"?Xn'´,g'{òÑÍµÈÃd\vgR¾/8px
KOj|Zñ\gÉËÔ8'ÄieéùØ¬:5Áã]ª$õ/iê¨,KË}{ò¡¢å-NÃÏÕ.ò|õÅé_©çøÝñ6s¦èÆíTGgúÛ¢Í7C­ '{KIÊû é­H«±üúç~«ÍÁùkE¿-Mµ1iæ(Ïe #MQºÖÎPLtmõV5-§ÃôÅ^;L«}÷XQ£&vX]ÄQJ3è·Ú*ùìd0Ù1³¯×Æfj/'A;h>µMw(¥»£!XEªSÄ{«Öù¥¡ÅËI´Ï3+äsÎJÝìçÝ'*dýv^UT3,ÒÒ¢ÓFøºBÏâ&l&,,_fØ¼UÖÅ­QºÍIþ°î­Ó\Hô´(j¿ïÝçy4F§ÚÎà øu×ò'$»vÙZ«©A0n#g´ÔLZ¯bÊ4~uwKb3F©6~])7£rS­<6°Q¥ûIykÔN×©ápçí÷VMTÑ·_	ö|¨ËNnyë=tB-ÖöóSDU5¾¡\0pÕ2"ºÎ§`nÕJ@µéDÓpºd¡À[¡-Q0xQ1§eÐ?Q skS½d¯æÿX÷Uaí}Ý+ÔJ³GÔÔ<ä¬ù¸Î?wI;þEÒMæ¶ê öqðÎÉ1aÕ ¿tNÒØ2ý³EN*5MÌÑ7a¶¯-;jèUH!5xZ&Ã»NgyÚfüÇ9+õY×o:·Ù¿	¨@4úøõêlB¾qjÏásï²ù!Æ<ô3B&¨ÂámdCÞÒnÒ$;M'{vBp5¿-|h*ú\¬dc/óZÄ
ydNCµ
=ú0RÐÛ¯ïø	¨®*\Ø&dN¸Õf§©_QÂðö¯âÜ7¨¶©°ÀÚMb*+«§T³Ý,rÃ@báL7°_ @³9Õûï³s
tåEå«ÐE9}Ñ:ï~¢¤AÊ.ßjênó][F7'#Uj|¤³®ÄcµÚXÄ1_£Í¦DÔ±ÀVA¤ü- ÚÚ/¬lgðgÇà/Ãð§i}Ni9.^sa³ds§´0 ð}
4·IÇºLïðìÊÊ½HµnñH½_ÝT ßáAloá4¶ßjYv4¿gd¼²ÞÍp½¤3ñ÷Cà]¸eNçR-a½
ÿ×Û÷üÄ¯ùÆ¤KG?ëK[\TEíÈ´òÆ±X§©Ðý`÷fLñD	ÿÊâµÇÖ[¨âgA&7"Ôã6AMoùÊÒÚ§VN ùÛûJñº> ñ«+Ck,Ã¥¨QÜê¼ÍUÍÏI%ñý;çÒD{ý»bXL+6ô=99DÅµ1y°ñ%§;ÃÍ|¥zâñs?1ûwº*pº8äiÔ%ÕçoÅâÍPàÊ²Ú§&sf¤;68U_èxç±oÀú2_M|ºáGº²Ò)xó"#£Ýyª[ÛÛS´ýC³ 'ý!Nù§~k/ÌØk¼Ô­ÙmsôÎñ53??0+«ôÖi³zÛ2Ïx¦F	«d÷KCÝ>?³ð<ÊË1)£{ GF 2{Ä<øx¹xCz{ß=C¤ä®Z1÷4GcøWF¿ÏøWêô¼Ü«ä8´!BÈk]Û½tFó}]ZÒdéÊDòZ°Ä_M?ÒoÚÌõu¶3(ô¦Ìîg²o¾hÔgD5¢fëá{Õ×+9å Ë4´ÈÑL}»"O¿´E([£Íó(ùÄ²q4ÃøkïO\À¥4çÃë=/ª­5ÄC*ëUB"÷×û	¹g18xê@ô3ö*sðì	2=·¢²O×nì¤-Ê~Wóã½.ÁlËÆãÊq¹×gC?Q^åät7A¿Ø¶8Fâ'ÚZÍCÒ¬¼Iå8QIàèy¿§QG-l!??Ü\_8Ó4n}ä  S|ùÅô®#âgA½ñíY]f ¹)-^ cmÿ:´åÄÌS÷®ânÐ|üN¬¦> {ÙÖsPO³²ßo#£)x;?ÒÕ@b8ù½-Ï<tõ§9Á{©_©k¦q¿o»ê÷¨~ìÃuièìz./º2EýNuÔÍ|9TàvµZ§ö(îÁisT
mk§ë&=
5Æ÷ÃÎíH§ùÓï¯m²­%:mÓiTæÃ«­¢¯Ï³Ûæn;URp(î½)~Ó.Àl6ªU×ÚÃüYTúãIsfKz<° FU$¤ÔÂìò±Ð\­5Úïd|2,{â/¶smÒ61'£=u$ÓNâPÅ[yè¡ø«ªÕVf«:tÏÕ¬î3vÝ¿M¬?¿Os11õ5\¢äÀoý¾×ãm`nù]÷ôZÎÔÔÓú:jÕ!}v_"ãí§¡ÑcõBRZ3¨ü$WÔÜ¤7<o9ïr3ßKþå½VLC(ÎSãÒßWä®Sêz·c¾%WóÈG	É k«Ø±ì1Å¸î\&èAgÑâIü°h·Ô^8Ô¯ªpÉäÕJ¼ßÅÉxz&ùs<^cùÆl%ªß¢?6­+6A9ÑD8*MÞr¦jÝþÉuÚ9¥G/{ñÞp®FóCc5êÿ^ÅYå3®óiáDù{>ùì¯°\(õ9¸$´E?úÌH¦tÔñü{øÐ~6µù[#µ:@ÝÒ(mV¹«]ÜÚnùonÞ±0½²y3>j¿øä¼Ë¢w¤rºi@­Jü-G¦-!8í)2ôoX¨)£nÐÝBC»i&ôrD²ÞM_	Æ\£Í¿¯hbá¸3¯ÙF2ö-|ÑuL7=G(M%uÅÿõA××Bbø-÷3L|n8W^¥?`<t'kÏ`h#öýäþ£È_·Ç5"QÛ_Ig"%î5+sý²1!üÐÍ<Ä}¥6K ¦µvÁü	{rÊ6We!-ËX×WA±·­h`Í5{=c'\}L5ÕÏRç6ä!Â?X_QÌu´R{w$V®hÙ+¥øÔ"jd¸{Åx,í/^ez@};{x ¤iÁî¹Æ¬s¶[ øÎBL½ñq,Á'ÇÀ/¶úCmÀsIþ¤	|a¬íÛ>ãÄ®$ÎdØTîvI¹ÌYwT,¬BÃÃëPôÕ/j(ÙnaùLZá\L8ø-k´¦>IÉ¦×Ý÷ÞRC/´3@ïy ¬;¾[ÃêO	³fò¤º.Ìz'u»ÆÞ=Ù¶F3ûeìÙIjº¦D~ZI¤/%;rðmá ú5íQU¯Q'Ê¹ß¡)Å>øª²%[¼C)¸ëëªÕþä¶`}n`à IrxA¢£úøìc·ÒWÉîf^F[|2ÃÌÃ0Oc|C_¼z w
ÏÖoK)SêÁãgm7­VqÍØ£ÅÏe~ºYê¿ âÞJ>Cù"µîÄT·o;§ÅµRke<êêvAèv
Óô½Ý3wr³_¿vÙZ¢ß¤ñõ>Fdm)Ýdæí5ìÀ×#vÕf(ÅEWÛä9µ2!ËËtñD¨À»>á%D`§¬¹¦Æ¸ÝÚ¾z¢*wÅ4'#ðÏ%-1âS3ÛY 
avuuH#:úî à;6@êFÃápË0Dh½D»rÊÏLç:Ç±hÂ­ðyêËtà&¸g$uc1_"ÍÓHÀl:¯Ø¦ËÊQ«ùîsÓÏ/¯u÷òèâ±Â ¤oi­i*ñï÷ýh1dÝ÷zÂOzhÈ®»Pã®ì²2LÑ©?çO2ñ³-{>NÂ¤ÆyCÆÄ}µÖ[JîNùÿ}mê¼'×Ûÿ¼[à(ù.3¹ oMë3')AbéÑäpÿùG0ÉOCÙÇ4%ï!çÆádÕéT²:su§N.¢ ¹QÒ^"OóûÅinhé,rÎ)TèßlC*DTJ.Ù
ÃX	« ªc¸Eq1PBÑîsê,Æ¯gºxÓØO#Oñ.°u+ÙúúZ³áí©OÚôÚÎáæéa,ËðÙñu±GÎG×%K×\åo¿ß
yÐL¥Ï ôdÇÒl2{níØ8jË¢+à`4ü:i\×ÕMñq<%\½«¸¦Ç|+¥#^È2JJ6)%6¼D(A´üa°ÇÐ±f¼½ÑØ`«µaýQPåæµòëÕk#þ¸òBWêçØ/pÃiXÞ940PÎÕÍáú;Æ0Æ:Öxüï¸Ç$VÀfû~<%ù­zÂö04÷Åk3^iH²¯ÈÄq	X
ß«¢+
*m4ÈN¡?hÌìmE%A×ñÌBýÉÞñAþ·j·_Aáú²gõwgcó3ú	¡R©?Ä}>-OÉ!F^´7]'®l¾\YxD¢·¾¯êîìjÊÛ×NÙõ×ë×Êº¨:ýQ°B$3M9L$ÆËêÊ´¢5¦J5FµÙKë!{¿(ÊåÜwxU's¢ÃÄ¢1ªó¯È·ÌüÿpòG^qéÎ¬l6MiKÀ¿Îá¾KÓ2|aUkåÍhëy"çé4ñoÔsn¿C}Jî/"¬îí©¼ÐýÝþ õ±H¡¨ÉIgÿ"µÂù§NEÇh;pVîÎEÞk¯Çá)åß+ùÚñûòÊe
ÉµÓ§1¦f&NüTÆioÿÛöðyÕêk(UC±µ\¸Æ1¹	5Ìi\ºj~ês³E¨¿ÿ:ØªtöUÆ º9çU´aìÈ[æìòÜwâ\k¡[½#
¾y×øÂu`éÖî je^í_÷6ÛíÜêEä27V¶..bËñÅ¬¦·îßWYkîÖC¤^¼Æ»h¿ôÞëîô}Þ[¬µ43 -Ã{\M¥:åýÀ¸.T©!<a}v··±. §§ì å|{zSKá`ÅææÇV¬¿Ù8ÚÌq:û!yxi
Å<»ÐfÞàÊ¿ô#¯}ÏBÄH_&c¨9ûir×kCü`Ò¦¯ÒO*1D Ötã"õÎü9ÎåMÍ°üi§]ûx×_!·ÇÆÜEø×ÜÈÊaf7Ub¡|Áµâðxn[úåÒÐg²h+Tü,zµÃÛ¬¨x6-0Æ;ºN¿uÓ«ó^3?Û<¾9DD»½Fy(TVÈ ÙiÍ:1©Þ©ªÜ35p,Ç²eT·¦ÔæKðë8,± ^ý3ç¿%S=+>.hã®ÍÝc8¥|t×tKÛºç:§euø>{Jì»ùzÌÝ»têá©<kZ ¨:¬j¡ÒålðtðÁTærÔe"B	é3Ú»×¢k9fÌ#a ×QÉED@¿õÉ7ô¹«lÖF2ØöÞâRuäJ­2,t2àÏ¡À`Wõ·±qÞlÉÈi#	YòývòYBãºÖr
z|*ì/ö!yW'pqnjn#`!°1c¢=µY¥LÉsXüF¿èèTQ9ÙYÝ%TÚÇô8-ë=³õb÷¦älm¸¥C% 8.Óaf¥ÖÛÒéÇ«¸i*ÚýÂxÃi(ÏÈîZc5¥QrIK«Ê=©Dx%sãè¹q$ð¹Ñ);ßÑpÿ¬ÓàÖºgZ²tye³3fÖrßîÙv:Y@µv³ùÑ=ô@Z®VPí\ÐâNÜ¿=HÏ-P&¾Ö Üzi9`TÀ}4$AúÛ®ýÙ{Ø{ ×ïÉXÁ©Ñdi¬Ã@UñÙå¡LáåõwOæ(î,´îyL¥ì©:~®­ïùÚùÃ¹'Fè&§Dêjhº';Z?õã`=û}W5&1«Dö/¨Bï~!èàèîºÞô"aMÅQx}ÄQâ²»x.Wë¯Qá¨ÐÁ@ÙsbÚèõ¡1>î} +e¿O	oe_R¢À±Å³Jr¸#ÓFËÚB£÷f­Vi,;~,ç"¶!-»JnhfÏo¸Mø0NâÃ³5,îß¬);}k9º,¥Ìåã×²áãûéäy?yË¼ ·OD¯£ï,ëÛp]ÜÕ_ýMySØóãRâ(¨= /5©Òk«nþ- óÇzdûVIk Úó'²±Ié§äX fÍ7âüð´Ä½b8bÈÁÓòË¾¥¨Ó« #Ë¡/ßy	5}ûLo¶æ÷FüÃO/°¥j?ûûÎ5­,üþ~Ïß1ÍÂ~|ªuURGÖ8ûéº´`×Ô	ìûMéDbàjÝ4Q{Õ@-¤Xèñ2È<õ(TCõ§+¦ª ¿7<¶Ô
ßuôÚ4ñú>æÿ.bö²#o$tú+}±ó¢7]o­öµòäøáPtØþòµêÍ8ML±Ê5Tvxfý¡'äYÆ»­=½Í Û	h¦°è<'e?ÖpðZ+Æ;|'Î:¼dÙSmxÀÈçb Zgzî8=,Ù¤°b*VP1t [á}Ýï7®ÕøK$Múýõ{InÛ®ZxÉ±6YK5;GàKà´°ZP%eG Ñùø«oq¤h/2	ÔP²â/£nû5ð¦f	·¦Æh´Y,z]ÈÉ_Liª{ï¢ÙUëiã[JÊÓè¾å¢ÿ¹VL:¯~­D1ë¡¨&2ìíÅ ö<3ï¡ªªÍï?È,Ö^3Gr¤ ºaé±|ÆµóÍ)@%rËèT1¸ðTC÷1ÝÌ%K+zÅ£b¤W§/"m´<Ïiõ]V7%4$(¼WÉtâù3ÿI'òÓÒ¦7[³w³­Z~
»ììù*}7¶&çÈ_@uMAú0?Jà=dÐ[ÄEwÖ«kü*là,I2ù£eb# ¤eZ§}d>Qã¯K^ûJyOÁÊzüìÆaý[&ÖÏ§ôÇÖCk^Ïq<j©Í C>©Xd¢¿e*±[MAé^?xLÈº±{a}»°R9d¤jõÝ±îÕ-á%l	³	¨Ú9^zÈµÈ/}!b¦ågô»@¸t±~g)MÅL§£æ¥6ÿÛ°3f_1§½ºDüiÂÔ<À7*8xÂCleuo°ÁOíçH!ÿZÒÛEz²ö&².ÚV§e#Ò¼ÜJÂlYxx¦MÄfe,~yÿr0¯·«g»°zcåðRÕM	@ÂëÂêÃ¹½*®J®úyCÖËWªï*FLß$'=T;QËÃÒ7
¯ÕÄRdñÏÚ;XØHõaßï¤8l0±¹2Crýß}r8~-ü(ß¯l¡´G¬pBªÛáÓùôLÀç;ªòæésL²¤JÖífÀ9Úz»kz¥ábpEýõ3×£±s`èìËkÃýü¼¸ýÌ.UùKd{¨µÝbêBÒ]ð ¼®ßýU¯ãQCj7[_iÝiÃÞÏëÈ°ØôWü¶²+(ò×óOc&lSGyy½	5«¡Ô¥`ÄqÕ/øßU/øöâò}»Ý4ÅÒXfØ]kÉ}3ùnwf{Ý¦¦.j©`"R»óxÌjÉò>9OTxÝDÔ§ZyÆÁ"âÚü+bë4çFÛî÷n>l¿8³§JÃNBá­°_ÛlÝÈ<¶ÙèCâÙó²ºÈûíÂ·'~Ü±ó¼ßæ×û nÆ¿aËØ:âWùUf¿»¢Ô"æ¬\(
_áH»ï¼úÙKõ }õ&/D¾^Ê-4H&6C+TáÜ
ß49[nÓ)wÓÏ=ÎVg³ö«¤J¾ÌçKZC!³4éÂìøkLÿ¹¸§lò2g D»±añvÛÊ­¾))ºÝqÎû!Ê^.aPáÊÉv/"Ì¢ýãWiMÖ\ÛOÊw¼Tà$ér©ÖGI\"®¢`»sáòçäù9O¨®jHåþ8v«ã·00NÀä/£ U/ÐðeÉw.âÿ1Ù]ËMùxà9òCdÙ-#¾#ü
×yÁ* 00Gt\ü¡ÙNÕÝêßis¶hûÁ7J^¥aàasõÀÉ²¡®=(nïäwùÅ"µÂkïö))ô¯×f1+®
óÓÆêø££íoë9 ¾(ôXT@ÇO1gGV¨M8µCÎa<£G¶
!?Æ:<]måæzH
:_vé¨R0àgYkò#j8t®>sæ£Ö  Î+h¡°«õ£Ì7ÅûæESñe´ëcN@7ÚXÒ_ì¥;-1´¼¡	1FÌ9²³¯ßùuCòßÕéóöÆ%pä»àâ÷SSAïêïjGk4U¾)HwBå¸HðAÚ¢Kæûî±!ë=Déix¨*pD÷ÔËOÿàD´
%í²»å¡4A[dEbëÓÂ#;YY¦æé×izÕDOÚkjâÃNîiÍ3Ù¡h©èXã·SZB
TTåñ7Ôá,y¼øÉW(BõiÔÖ4ú¡ Áñd9ñ«.¯á|2Bd.e;#ÿ#°§i»TvÝOéMÀÀ/éJäë³DBÞ©©+[fÐ,y²ÉºKàù<é,s®£c×Ð­$¡ü×$øMÈzYØëÒFÏ¶ßÌé¶R®ib~æ
endstream
endobj
372 0 obj
<<
/Length1 1644
/Length2 8638
/Length3 0
/Length 9488      
/Filter /FlateDecode
>>
stream
xÚ­veXÛ5$	Á¤	îÜÝ%¸[C7ÐX#{ xpw»»»[pA×Às¾¹w;ßü¹¿úÝµv­U»¦"WVcAMÀRP[3+@	bcâä¨
µQò*0©Í ÏvNt**q0ÚJ a`> >| °ñòò¢SÄ¡vnsVCUñ?W &nÿ<{:BÌmÔÏÎ`k¨ØöLñ¿vT00ÀbTÖUÐJ+i ¤Á¶` 5@ÙÉÄb
PmÁt 3¨ÀúïÀjü)ÍùKÔ 8ÚM!Ïn`WS°Ý`v°8:>  s -ì¹0( bkjíúÀ³ÝúWBvÐç6ÏØ32Ôæhê ±£*KHý'ÌûÛò fÏ7APS§?%ý=Ó<£0 ÄÖ »ÂþÄ2@G;k Ûsìg2;È_i89BlÍÿ#Àlt Yi¹ÿtçuþKõ@;;k·¿¼¡ÝúG#ØÚíÃsLSØsls-:ËYµ5ØXÿ¶ìþs;üÕ Ú?3C÷µµvÀfè,JPØsH íÿNeæÈÿÿ-ÿ[äý¿û¯ýGü}ÏÿJ-ådm­´y¿wàyÉ mÏ{  ø³h¬ÿÍh±vû¼þõ¶øïtÿ2Yð¹-¢¶æÏÒ0ñ2sð°òþ@¥ ®`2fj0Z?÷í/»-ì`±?ëûWkLl¬¬ÿ©[@L­lÿÁù7¶ýkÏýUª¼<Ã_²LjÖÏÃfÄÆÅý·òóXÀÔÝìÀÿOK
úÇá¡ÔàÁÄÆÅ`úÀÃöüSãýÀáõÿ	þÛ?Ï@Ä ÇÊÌÊÊöLúçõOì ÿB#ik
ý$5Ðô<{ÿ0üM%ÿk<×ÿç¿^ì
6E_òX&¥&Ã*	2ûG%ôº;Ùû?ÛÔ¨ç~õ-vø$¯ó?T|f®ç{lrÝ·û½%G¿=ØoMÓ >Î&ñ¢ ëú³JÝÂÍ°ýÅ°àUòV¸ÇÉÂw$].VÍí£*ªù/HÇ[ØPO®é|)¿ú¾¡¼²Ãô6M¬ÄkÅ®{]³@ûóú¦wh ¿¯ã¹k!#Hà¿Os3v¸¨1}D¾sæv,MkÐ*ÇÕpq'¾szGy±Ë|ÄNfþ$
¿É*2g)ïrø2âCnã»añ	u9ÃªÖ9Ù®¥Ãj!¾$«ÔÞÈËÚ°9é$\ÎµGMZÞTÝÀh&+v²fà7GÕ[a*I!Ì0Jß¡â¸"y_[`^d¨ípeêI=UéÊLýD¦/l;.¡ö¬"":ôáW(wªEÂoVkñÅÇ,K¿õ/"£'ÕE´áT¸ÈoR±ßáÈ¬ÚÔ¾ãÍ¤:÷<7lèÐkkOäüôjZØxb·»V>ÿª[M¿Lû\¡<PR7G¼îÁoÌ¾ÚZF½°úë%ÄiÍb	©¡\qü¤©«üjgaìáW®¡VÓ}¯åà/XÌY­÷äÊµÑªü-ºazfÕ7Ù¡6&?|ÆVPÄï4}âJ\V²ìÂ¨©ì6Ñ<Sg£²2Ëð(6ÛÈf8uÖyÄÃèLåéÛÕ$Û­L8¿H[N²È5±4-'ÕJ@ÇUjS©#.rÍtvU·Z»RHS¨´Âùå=:Ê¤A%Ú}>2Õy
ée6Ø6~F]«5±¯]ýíÞ°]~UfSÔó^hcK`åjÝ½ÇEeÀT	26TD^ ²¼+®b>2eÝJlsØ²;ÙºBð9~ºE.uY2 	ªä±Y~ÌteKÚ
!Ã)dì)|Ö?'nÜØ	:Û(Ê\ÔQj¢ÇNéL2ÓçaÆ/f²íáçîØ(W´}ÖÐ¦Ì÷NÖd»ýW%~³WÊçîùÕìN_w¦kê^²>Døµ!*k¥"?õ#<ß¼/yµËñáÄóÖ
¤1ó¢Ö©±/ÜÔ+£é	ÝÇéJ-¿ç¦yA9ÇJbË>h°qsñýµÒü[ä.òÎEú µt¸Ómyeß«Z!a(ÄqèíBûd%'§ul÷"0Á°YêÏÍázyAù:}NÃBÆ< !êgåÎÏûòâ¼QÄ®®ú[äNïõnPÂ¾#m²*}Q|;¼&ÍáhþÅÒÌ°¹òL~j£.zeÆ4èáKátþÏòí-¼¥ü?¯;ÐÀà»zìöXââ±®9¡ U¥Xû	U÷è}ÏgãÑxjY1hÔ}%q?çDEÓ&fÍí{bÁ1,Ùè·è¸¿WI÷~ds¡LåÝ¾É4LO÷Bn[PDyi'Ô<&Gîéy©ÎVôîLg	Px²=ì^Ìæßl3_¯Ò¡z^Ç.:Øò(Léva$S®á1±Içó×4_³÷l'ÈKÙÈûÐ=g×.à>ÐÑk1(q
°Ë2 Í[éù÷E²Ð4¼ÈqÉiUïºôÅò1¾@êw@%;¾S×Ú©I¤^¢98æàCo¶¬ãÉO)7°¯¼aX¼]ò§Iw9¢ÿ2ÄNyáI5äÙ!h²îs)¸¦P/¶÷¸D)­BdçÈÛÒøÎÐû×§¥>°RL;üZ[Gkë"îÏuÊ°,©Ð10$Sªè¢	^/ÒÇ ÌüLtõÓ3ê£_§j2·ß|R´bþ7Åï­\J_ã_;¥wNÚ=ûSÛ¾÷ºq¿Ï]0¸0çs¦ÝÃ]&ûå	9_EúÙQúÕ¬.oÊ(nÊ
ÆààcWôçj*m ²ñUéwCÀ7È_C#8)FCÚ,M-eq¾[iÐÊXÉä.ì`Ú¥öLAU}Ë\06¹ô­.ÇDo¸f¢]ÅúÎbSÑû¸³åàM'Ü	ýõ»V\¦vÍÚó·?äIKÆrÃÕá¿Ô`¾¯<æ4uG¸(aÊS<Ñ76L\Ñ~WD¥»¨ÚÚAòSOA­WPf8ÖÞÃ³bõ°(àæWT«14B«1;©ô½Ñº¤Ý4ó}¦ðu'¤?åµüÌð·fQ43SoT6%cïõ`}£¿y©ãXA7¿ø]~^¼Ri½>¡rßï§"üp×¸Nå¦gl ¿·´¢4Ò¬¤vCÌ%Þ_tñ1º_©B,ê¤¡4À-Ú¡[Ý¿Û:ÑB§æ©òúLîªst+ïyT^M~OYnm(ô*¾!=
÷ØOîJÏ°ò+[Ä3ò¨Ò,tÌ8[E105}Miå®"¢²ÓíØW)LNpG4a½cªÕ%ïÖ4\ÁüºBæñF²¾ÝÉ[øXÂÍìíD1QQ2<lÖ,®^q3Y»Ï²íkÎùµt}Aã:y<Û{Û)³t¬Ç¸W³¸?ÒÅrî-~;Gf°2ìßDyã^N;Q3_õÕ¿\ ¥±3´jváTÛI·Øv
ÉåÎ¸~×àWÉINsÅ1¾é.ug~!Í=<òûÔ{¦îêô±£*qôÆ`«Ih$·k²¶o@]³Æç»m)+S¤:i]ÊGZ¥©üWÕ.¦Èc>éí¿ðÙ;Ä{ÑHã%WµñPr[«ðjè±$×	¬liDÜ< ]g3a¬ã>5:%Ú¨IÌ÷:7ì­Øä´ÿºûÜ»·Ô\fÇ¥Ànf ÊÝÏq+ÈRÏ{CL:»Ã6H{BÖNrfô*«ìÊR%ÿàèÀ"Ò}) SJ:«¥bß÷Jx[£-E$M¾U·®à)Z+è)ß"7saNM%ÉÐMÉó~É s¾~è>ñC f+Íæ;tìÙ£ÃÝÏQSx2w>ÕûòSJvSÀ$=O¨?++vsçÆ`yô^÷![­éÚöq}Ã¥^èoßçÍ	Õ}òîÜ$þeN´¥çó·ÝÝðô]æZÛËüàVÊbqâQh§gÆwÆSÚ=õÙ'¡X55í ZkÃé_©Ìýß®îDnÕZò´Ì_¼¥ÙxbMï|Ilú½:>HVlùíUÜãu õQæµÎÝêüUe¹TO·ßÂàÊw{kº=¾r¸¬W 27+îIiÅ¡p.|ÐnBIcaÄÊî3p±1hp5+Qn_1Lö³.Rü¡'Ýý¦yÐ ­Y·©O2 N¯c~qÁ¢g	0ë§(¥\ÝõpTÌáÈf 6¢vÈi0*ÝLî0y7ÇK.b'Á1ÝÒý=KXJXJ\45÷ÁðTò)wQ¨jg»Aç$î\fªEÒ{H£®`,÷"·Ë@ãEå¹º¸gÔá¿Ó7ÿØ²­ÂüôÄ)uÊSï-¾í?åÛ×ÍzØÒS¦§63ceLu-tWècªÊ0,(eî@®
Þát1aó*à'ÃãO}±Âðâ7ý£|bFÞM@CïQLùoA;eÉt,a¾Õ-yE²¶|s[O±1B\4.Ø¥J¿[¯¦õ¾¶Îzengoá¼¶ÀÄ§lbWdÿ¦Á)3Vï»À
õþ6cf-ðç·åGV¸¯KÔ´>lÔÊ[yHî±H,ÜÏdÈ}I["Sél&P%Z¡ÍÂç5&DQ¾³º¹Á¦0ºsCðÃ"Ì5ö5Õà´l® ÛÀ÷ ~Yúvz3óDØ¯*}÷=©wèû;Ùb©óµÑæ¹ÎJxÛößRí(À³h"¯9gRì~î*ÎL=pû«ä,+LÈõµ¢ExÆ4ÊQ<­O;Á¼9kñ`'ö£¤,;Â²Ok¦âri+ï>{Ç¾}/Ñ6ì!3ªà"Á¡8§n ÅéSWúz#d)öÒõ^gñXêÝÄôc¢ö'¢ÌIo³jLûáG!H1\ü<:µ¶f$\i¶V¯¿7g&¢¯Jo«ÙÙß»ó/yãÂ\ó5-LïTÛ²WÚ^è<º·t»ÊTñjzLª¾«"d|àðÇ_Á¢Ì¼µeÄÅ®ºø.8=Mëw)sx­2ÐKYæà[¾àBb»q½±`­	koáT"úüfM|q?´?ÛUQ²Iþx¼W½¿y?õqhEtpeõkÌòy¨và§À\!>3XÃïÜk¶HbCD|g+s|EyÅ¹iÄ¸Uò@äßº×Co¼8ÑÏÓi´CÅ8ìFµ÷r©aºÔ	í!VZ2ÓösÞºÕJ¶Þ6\HE?¡õÈ%.Dè©l­! ¡p
·áTUOÆ4'²ØUoÚ¡v¾âË¥N$à¢ßLÀ÷Ô|*É8ÌKñlÂ_¹5¾-×V+á°:^(ÚÄs²h÷ì9{	Ïx6òËµOå­=b&ngùDYÁ¥c²áùy'Ìry×2e°õãÂl-ETM³¤æi-áov")Ò»üø+}òühg_«ýd)Ú;á¶½õÚª){ßóÎÏ_9Õ?sÓéteD¡dô{Ö¯eµ¹6!{ù,_OeógJ4¢Æ^tU¹møØõEÃEßÒUåYô³{åxóý5cÀÁB½RÞéÔÆp¸~3¬îÐ.$×æsê<BVKÕÂòUsnÁAëáÕÔÎ¤1L¦Ê%Ý  uÓÌhEàEDÄ·pýÓnltõXk¥/¹Ã¸¨ëtÅÎ(¬<ö,ú{±äèüãXO¿´&_¬sæ~¬)hh*vÖ|zÚKÀÐ{Ï#K4ì"3ü~Q
[Zû[ÈÀDèÜçìÐYôr³W´ÃÒ"ü;fÖºç'ë\tÄêQÐ&&íøûÃÂ¬P¥ø<Ü.¸®ÂôÑìcVþ^Ú×ÎNÕ¼ï¤°óÂC	¿èvìúKVy|Jì;ØO·Î ¯ÖSZ8]¢äAOÆµ¬Gé
5úÀYLÌ¼fmï4¢OáD"¨­:u6×ôb¼ßTÙâ«ÙÜ¯>>¥6 J?À4o\ÙGµM<mæÚíû­¯å,&xúL¬çGÌYp_èpÔ&¯wµM§¼5(o¥89yÈMYÀ²ß­d&ýÎôÓãÁå­ÇàVR®h
ä|×Z´QÍxÖafë^eNË>Ã<|°ùÁwî(s_¯d2ÚýûÐqð=÷ë/ö¸Zû@>¶/Þ¼\}õ¯<¦kà¢ûöèV{qó+FbPhãÚøø¾¯ò`<7¤ÆÆÙ[×ÀbÄHÈdG¦}Þû¸{áõÆPPü1`×5ÊÒ#4ÙuccêN·(§ybÌ*ÄÍFËfýòk:iÊAîWýªì&Iü««úHþwîÇ)³ÜÒs×Ì§V{TKªI°õV¹VOïfðÍÓmÂÑn}HÈR]¿VåMÓj'ÎÑ_Å#ßG=KèER8¶äå´¤õsôw7áô²ÖõÍ9]Oéôê½¦µÖã»ÿâÛ'ê²» ÆÅOi®sÈxkÞò1?¨+WíhRÑ¢åÓ¤ý¼ó´üòxÇ~ÃA?}V<Õp÷jid3¹:vÙñÖ¯ì e[$?ÎíuÔ(Ø£V¼ØpÎï­ï¬FñµÒóeb7|Ï%À'n©íy#|ÍÝsJù²måû;@ÿ Û2MøI²mÌ¨ÛxÎ«ó­GUKÕnvúâê¨ã=C »*¼G°
²hß©tñ?ª9*ûÛ~²BÅû.ôÛÕ»!ÅÊ¨·?TQÀ{+çdÃ§kíÐðx¥
`enTÁ!ªçÍÎ]ºç÷sÅì·r ±,.æä1ÁÍ4·o±øð=Z?Ã,~{\_h }÷Ðk×Ç;$évzyN«-æ§ùò¶fCêøÝ[dD^3Ø³§É¶©õæy¾øJýx¾ÀQêY*Î8J»ï~å\ÝsÍ^ÙÔ	¥¼ÉQJt8$r^0G¬8±E¾mï¥µ3þíèZ¦W M]=ÓÇ®RÔÔ,3êµÛ0ê±àº¶(ÞçðpçTyY*:dn¿GðÛ MOM$4:Êt~ÂéSXÕslM GÖ2 ZðÌnuODû«Ù~ÌÁ ü¹U,/¢PæUÓìkÞ=B|Vï² £ÚÊ¢Ôý&¥+òâß\ãZ É®@¹Fè ÿÏÒM26Bû¢!ÙËàþz>ãW4d$rlw>C¦¹ÚMO½öGìÙæ<7ifVø	[m]5ÔÍýÒ¸ ÄzÏÆ/ß^M%bäÚ"2Z%ß°E`¤Ñy²pðÉ29I(xâu¼}©¿Õy©°jÇÑ4ÇÙi ªH]ðKàam~T´þÆi)HÃ~Í§Ý¹#8Ú>üº÷±ãÉg¨÷êõøN.3	ðüµCJF{:$¡_±ez([/Òé¨0HcýECR67t M³±%µ·ª´lÒæ[FsÍÔÌü{Cwîõqmáy>dÃ¾ôr²9uGÎ*°¡ZØÁVµ0ý´ýéË¬[,òsÔWjbj88úçüçÅxãQx¼Îì #úGI¦`,æ\ü_8þ=C>vLB9Òc?ÑEjÈÎãk©ß£û²=hT?õø3B¯âóö*$ØØß>]àhö&ÕõVë+EJk¢¿5B³h8¯ù¥,óîLäF¢#ÊõËð+a¿6ê,Ñ8QdVçË6û¢úÒÄë}pþòt%¶²:+×ªË;8Yí-ýSäÐ©BfÎètàçÍMÎáÙÃ¤/¼eÌ!£îõ7ÉYW8jn_oVý¥ª7âaÏ¥¼ÎÇ/ï=åÙ?:ú
0
C-.Þ/º«HoDLZc2õ5¥õÐÄ.çòRÈiÔ8½òôúàÉË*o["Ó%_Ú=º=ïwCë´Óá²ðØ+.nýúÛ/¢ÝòCkYý;`¬D¾ìqï®»6¥í\ë\añ_)ÐÚ{!h(CÀ0kì¾ÉmT«W7k¬Gd¯Jërm2yXøù|É{-Óù5:ìÔ(jà7Xve(ºÖ¡ðòzgÖ`×Øvcïæ=J3ÚVÛ þÇj§W>³eÝ?=ñ|INiUe7õéåz5\©:].OÊeBDÃDúZ¥hû÷ØjH¡Õôz¨C*Ýê%ÇCï}(¢dxæ9Þ)ë
.«ùMºãPäe8æ¬ýRïÛË+¹£Ç©ÐVËN7öTñ@Içá*[È$Q¹9L¬¾Ñ`1*¶Îþ¯^:qùð|´çP·"ÍÄ·Û[6÷~«1Ô8¿eäW<R£×@aROÕGï%51oTÚ"¥á¦ÇÎÅ°¸[ë^¦ÄlYV	®ì:^N­ÌÀ7qj[%©înÖ]bÐºÆh¼;&_"¥ì_Ná£ø)ÚÛVä°ÜòôÍ­;ÅÚ±§ $~wøn¬ÃÇÕH¾b¢ÌÆa¯Ò<M­­kúQg8Â©ÐÏÿárÀ­	ý/=ã§»ÓßyK
AWqGtÜÝ'K¥}¡Y1M½6u!$z28RÇ;4øð«ÌØ·)½¢.Ëdb;Æ|_E^!e{ª²w1M
¼¦£¤Ívyo·Ï´ùv!&³fV¿¿ò.¸ñ²XjÅAÖJýhm{çxÑ5Æ$kºÓ·_f2baVû4=é5Ø:DeL÷m¾ßÔÏ}þGVâ%¡Ë Ãq&'àÈ<òåïÏÌl[¦:i¯úU=Ú¼Ë@R]$ß±98)¬?jé,ñ$Å0M±öÚ¿²îºdëôv9Ä¿þyÙÐÏÍí+níÿÎ1G/ ÷zn®æ40¾#Ø&û¼EfÉ ÊN¢)éåòÕ_e,6p2/¦õ­ãR<ø©ÆÀ8ÃY%m<¦^[Áª(oÕdËv¼RwºpÆ·D"v«´d ¾ ÑÕÕt¬æû[íA¯ÿþ£¸i0ö>Ì>ÝjºópîôÖÀ·0 |k¯ï«[xÉaðã{gÊh7ÛøØN¬sN¹ËÏ&c_È_]&±Ê{»PmJºÝ³Þá!bæ9¼«Üàjº)
Q¹±xÁ®¶ïA´'_Ù«@~8üµOTî^ÿ,«²Õþ'¬Ê~2fÐºLmv©ÙåÉÏO=KRµ5"AwY¸¨³¯·\`¨×|øW,êþ§7cRÒÔðJFÍ_S)Ð}Áä n ùBáf'm9t2ûGZkîýÎkõ¼Í¯ ríËìþÞ+27-óÄ´CÎì×¥5ë:Áe­nÔÚÑ©Å(jÕòYÙÐ·ËÝ(Gû,^òö¯;VI·ÇEpëkwb³§´ÌVôña .Oî VV%ÙnWØzÛb]g¡7AM#Ý¡)e"8'´°ïx_Z
[[Ñ§J4tj9÷¥DËà6Ùê¤e§ævJ¸Þ÷UÚDû},b)ÏXR|?Ex0GLöÒ'6L«_êûbán,V5pÇÒó û¼aóÖ+;5¥NåR®òÚáëk!íÛ;j¨óèÇ*èmÇ¥q\8ù=XoTA<n`¡NøG-7bTÓtµIíµä
RNK°Uõ}®=ôBdy| ï¾¸µMyÄ±eúë|;ú­v²BÎü¥[Yá«øqÇäéÝÈmÊeîÛoþðhDMÍ?³Lµ=yòÉ¼ÔòÞ±t±~ÏÄ®Vh3»\Eh¬w¨À%ìNsx@è-aeûfÔQªås¡ó0½ýâôEÆði6ê(Â¼ðNéìéæ´á¢Á¾Ce½ÎKù+ócof8q|ýñS1ºå¶K}PÆ¥ökaK+Dòå°d©¶FlRb½¹ø¯ú|ÇêdÚÙß"gXdúë8²²FÆ'ÊZ¸ä»µÕðgeüÜ?/T^ó¾g¬»*8nFh¼kfv°¶±ÎáåjÏ)ÌfCQ{ÅaÙ½RpõjÕÉÎY±]·wIå`s®¨£&µÛ¿$åMp°:_OX6î:)ô3Tç+zlÛ²ýÚ
]3^$éñYÚ§HPRDâ@¶æù'º9«RIAå´_-ÞcïÞ.Ï&qjSgøe¢\ºx°ÓÞ:Ü_W|BÃeU±Úaþ=<Ïã$Ñ7éªü_6¡Ñ®ãÀµ«2.âuÄ¤HqOuº-49ªÂÚJÏ%r+S@ú6éû{æ÷_\;ó=1Ø*¾«%òÿ½ZiôóîFÖ1»¨(s|ÂUEJ<y{´2ÚF3seÿà|i&Ì]ÁÖ¥`l­âeÂLV0UF4Ö;P2¯i|I.àç9¡r]9±F-	Õ4ÇÿÄb*Ð7{ïL? [·4Ä~ms\ä{ûd£¥!èÃ¬$!«î<Åbî¥bµãÏ!\/édÙ'ÛÜ¸5ÕõeÅÿªÏÙë5:N»"ò)ìFÁmOÈlDÅnÚ¶-ÆAK¦n¼{X}ÑµÁës#ÚØ^Î?-CË¼ÁÑÔj<øëmÌ%³^,BâãßNwbè%ªéà
Ky®Q-ÊJRj+u°.ª!Daü"éÝßBïçvýÔ3ð
®ç´\Ý	cwÓk]ãn¤yÉKÖF0å ÍðÀGü9Ñë{óÍÄÇ·Z@ù¬½Ï>|0¯NÒfw0ú¿r	ZÞÙ^Èæ¥Ã·ú¼u,YN$q¯è½ OAûÑÀÉïó	'(>¡«§f^CÐSðå;ò¹7&Raû{i@ÎúÝÅôµý)ðg"by°ëºrÏa·gd$Ìe¢õ»áô\ônï1#cKÿ¼?©*¨´ßz¾¶&SEÈ{ª»ñJòÑº?// @û´Ð8ÿð".Á32%y¾ox=é¾{/|vJ"q¡Ú£¯¹³á®éýÆßÝ)UÊö1mRDûè».Ü¼%ù;bðFy¯Aù;PÝ¯|-	Ä]%¥4½q?ÊÕH÷ØÎ«¾ÎÔH-wæ®>/Êº|g·RãðÓ¸çU2âgø¨Á|âoU¿Ó¼6ð£¶7ÃW`
vÄD
ýåe
endstream
endobj
374 0 obj
<<
/Length1 1647
/Length2 13165
/Length3 0
/Length 14024     
/Filter /FlateDecode
>>
stream
xÚ­weT]Ý-®;@p÷àî®AÎÁ»»www·ànÁÝßwûöíqßë?ýúÇ9c¯«fU­Y«ÆÞTdJªÂ@;c- `acìì¤bg£`Ç#Ç 2sYÞ1$**QGØÂÎVÌâh 1	ÀÂÃÃDµ³ww´03hÕU4?ÑÓþå¯- c÷"ïNf¶ ê÷µ½ÈüNñ?vT `sÀÔÂUTÒVÐJ*¨$A¶ Ç÷"­-L r& ['Ð'©#Àú-Ðâ¯Òß¹ F '{Å»ÈÍdÿô`r´±przX8ÌlÁïg ¶XØX;ÿJàÝnj÷wBövï;lÞ±w2%;'°£=ðUILâyÍÀÅv²xv¦ï;v&Îô7öNó,l `ø¯XÆ  ÐÂÉÞÚÈý=ö;½£Åßi8;YØý+Ï G#ÐääôNóÎý×éü«NÀ©ÞÈÞÞÚýoo»¿wýg`'µ)#ë{Lð{l3[$¦¿úEÚÖÔÀÂü;ÐÙþÈñï¢ý«g>½'a´³µv A¦HL
và÷ ÚÿÊÿ{"ÿ/Hü¿"ðÿ¼ÿâþ»FÿåÿÿÞç§p¶¶V0²yoÌÀû 1²¼Ïà¯acmäøkàXü_®F6Öîÿó¿ïÖý#ëÿàüwø!mÍÞb`á`äøÙÂIÂÂT² L¬ßïo»º-ähmazùïó}wbfþ7LÍÜÂÄÊö/58þlÿ^Ã»nWÀ¤"¯  *IÿßLÛ¿7+½wXÍÝøHòvÀÿ\üE%"bçðd`áä0°r1¿_Æ÷ëÈÃÊþíÿöo"­åÀn ]fFffÀûÿ?ÿZéÿ¸­ð¯>RÙß[ï?Á&Îïÿ=Þ+ÿçúïK ¹LìLø-SÒSÁÕ¸Ùãbº½Ý,ÐAöEujy¾v]>)!<eÏUAõ¼¯-î?ì_vdèv»q¬iº@r¾Q|êÉC_§nã¢ßõg2(BI=Öð<û£ÃÉ¬±»5®¬bPøG<ÙÆæpv÷ÉÂ%ÏòÖÕÛ$¹6»ýc=FuþÑ1uüÁÝ-MÿÈÐà@×lÏ!}V4"®wâYØÝÐñºÎäöÑËÙÅ3õÅÂÏ<ÅN´ÆcöÕ¶­è*`RO$Ù©nÙ¼ÙãlðÚ\Tð(è9ËËO¢"Ê$øòüãN/ß3Qâ½zZïMÝR-[Ú´Û¥Q¦»yÄ
­Ê*q:²ê­³rãV\næ"x|0wº+´ªV¶§î­8MìÁS\ÞÈ/×©B/ù!µ	6të@*ØìÇCòÛGJUS&Á£Õ<æÂ2ËåKçZs.)ïI¬NÌ\ÌÙoýÒå^CLwM,ybÆW]û¢x%Y+ÓAPâ³øé¾<%*_ïÂhFEWn!~ü	Ðõ¯¾+M,|fÄ=m4.«ÃÅ­ZUF+%ÒÉ'ãÇ*£x·"KµÌCÏYBcÿðÁÑmÂÃfÿ¤í9Aü½ ö"ÈGX×eâm*­pÈ¯©»æ iµ" UYBþ'y©õ­I·÷J&/ý?§A0DÈ¡î,ÄýÏëÈ0µ¢ðI!±þÊno×öD¾î?0Üå]Qx æiGKû'Ï¦0TµµÂã¨@ey=îµ?¨ä¸Ã[d¼.¬Qsh"rIéwm*ê«E»ÜH°	ä)c»òæy#îrôÚyxK«H,.,  _µñCmê²XîÎ»*Ur8\PßVRLHÏëûZ3V{ã!Ål¾ä"Â~f»×¿ÍªkYQÕñã£ä¸/st>¢O]ï]©¶·ú:PáÑ =@v}µ²è£p$óÞ¸f	"5lA=ê¬A 8YJÏ<ÖQ6@÷|ZÄé¯oÞJs%È·åÅPÂ!ý^´>ôC«6gÀ4TcOïK8g,:'ÔõîsN 9µE5N=ï3±^	âíËk+Ô©eÂ®ÝZyt½Fv¡%	Yób 8Q d±Ù#á·?cð5Uö³1¨+¢Vj8¹¤Ì£÷Ýb°ÁÚYà¾9ýÒRÇVÁó2MÙxI²~tcÃF]B%ì"Yf[uPë¢Ðj¬½ðZKÕÛOî¬a)ÍýªH»xôõ)aÙæ¶îaäº}&¬Ö}&y?ß¹ª$&?=­ëç¯°|¿ÃnBÎl_Gq#}ð6t_ÙQ²ÝßdÁz8°÷µ¯¡2_îÛ¹YVUxÊè^áÀ¡DÍ4¡½P6k3M[@»¯«»åj°È)VU#|ÆJå¼2~àHï³ãlLn\¢90Ü«òÑÛTæ!Üç~V0ª»±uÓýh¾k_|¨-GÊ³8¥v¼àAÁj½ôÜå<`
ÍÁâJsI^]P^Ýæ¦Âr ÿ²ÎÝ¾´Gìô¹ðïc?´6þPÂ -kýÅßèÁAk>póÝ
ËÝ~&s¬°â2²±N?ãôÄ´u3ÑVb­WJ&i­
Ý|¤u°Ê3=ÃidÛTìÌXK,Ñûè¶ªvP&}SMÐ¶XE}¢F/>;$ÂÓø	Ö#nÙ
6¦fÅw£5ÌNÊ8ü.³º¸ÍûÙÔ]¦?VÓXCXÀtÕÌ§ßtÖréÌwä!¼ <¾¿eþ8´· B$é2YØ¥%((x\¥ª2øÑæQ)fÃ­o£b2Éz_ÑÖã/#ûF³ïè§¶b°!f§ã8Éjã#¸dwvVÝ¡Å@Þ=ÿ0x1êPö{6]ÛøÔÜÓÉû&ì¶Íò#Ò<qÅ«yçuY@]ÆðQn+*{×ôvbmÞ*í4Kµµ/ñÚ©â¾Ã<õö$å²DÚnÑ\ÔÑ×Éä'wÿñ9fDùý§ùåÄÍææ.ÆEÔoÿpKØf.ì¯3£@ã5ÒÜ6^9Ú¹õäz"ãOÜOðÙ¯=G¦`ß¦YØ"Þé&ÄÛ"LðÇ	Ù¥Î@tÑÕT,´éYÇ_*¸Õï°É½éiD«Ô¤²µ¾OktjZ¿y+Áë~fGlÆÆ;\ÛììÐfÄ,_ÐMá2Ê@è¡ÖbPUó¢¶ÿÒé`%¥ö}uO?Eæ¾Õð®ôû}`/4¤"2ÆÈ¯c}Bo+:Õàw~h¯þ^±0ûÑ¦6àPºHò²úx§¤<«~MèwÎË{³éÕª¿- æ]üÊ|9×yÔøà`ì|cíªØ?ídÒ)o¿f5K×>-J.Ëÿ3iö+CpÓ°1@pGÙsô'=ÏQ24H"óíqlî¶8¿±ú¤èé´çÇPêbò	Cí×âö¡+Óª1´z/Ø~±ÛtÏ¶þOtëP¡×ÎcÕ#¶D.¼(hk3_[+¡yö-Öô³ÝaWÖXÁ7Å%y8øýµç¨¬ÐÏt>#¶Æ$åC)É¨aQ/}Ôfª´>¥ÛQÔDkV{ôC5/<Pe-JôEª~pÅ6è´òÚ³²·Ãì"p0K¾^d=P}Ûe&NÕàLç;¦#Ø±n ë|ùJèîØF¡()\ìáO)wôíä¨¤OÂpÙºëøÉ¢³ìC+{#ÛÏ|{YÿL´AlO²èH3 ú+áMF, òH¢6[D$ _D´¼,	¤_Vn?ûN ~ÛNpdnÁEfÖ!x®]n;ì}º 81@®á]à­Ú!®&úþÕ¿#¡Î÷5ÌÍÕ95[í%T¶ÁÇþü¸C .sn<×hîtn:&ß
É¢Êð7éñÔ®-åìz8BOÖåmSÑäB@h¢6}Ym`0O¤ãZ^,µ*xIpú°.M 9Mg¿tÚÍXD]$ÈI«Þÿy4O`_u¨ZÅ¼¼~I%cBâÐ(§çx\=Ýã|ú´ëSÏÞ¯¹\úòTêy¿?-\¥À7L|ÓÃNõþeã³Jùó*ævy	®b*ËØúïHA
¦ÛëÇá	¾9muªÃÔ%gÁ¦#F¿Ý^³¡û±xèÈF«|eqa¼àÙ°j¦­a¿Ä°MàþäÖvIQGixM}gn­ÓòÓ±çe4kPg`½ãsâQíñ.%ÒÑOOE°ðï?qÂ»®Np¡£}×ûm F©uÌk
üâ~kØ¿Nò!ÝÜRí£/H·wÝªj¿@­åÔOÅHð 'ÐGN3Òp­Û[­s}8ÛÄ}ç5GÞ½ ÎÒqÞ+`ÌRÝfÑN]É2Ì¤Z3~IöàH¿×Nd%FfCÆÆù1=¾Ò-+yÇçÿHÝÄjäZ@cÂªmvïZ$´¤h~Ö7óTmDÛS`ÖeüÉwªÊ ±:-Ïûãc-Ak#$×"Æz¾È©×lÀ5d`IüZe¥'3rcpµ')º¦08Q0¡øÕÄYfhöp×H)v¸)_³ëuàyÌÀ'3ÛFgÇËh°«²°·\*îºkùz¿êÌW#KÛàî.ÃJóÇA~Oì´Ûíûq ºhåFÏÓO®¥:;->ÔE¢Þö1¶¸ku?7Ù¹0ÛâÈ½g¤÷ºèTGìkíðn±òRük!°ý1æ[2¯¾NäÙìE+Éé#éç :ï« çàµi/1'®hEÞØÁÌ¹àÔ-Ôgð´4Ç¦Þzâvç³ðvdåüI½edçÓææt!ù¦¥¹ÖàyzôÛ§Üºuß ³]éÌÌjÅ¥Qç4¸Íó7l©Uï-hí:¸#£tpÜ7<uÅ>P²3m:YK»Pz¿@]ëÒqqè)¥Óïç4}+}Äõ±`óë¾WäÁ%(¾ªtê.Háslt¾ëàX~ÈÐó'Rª_0¬Að´Àz¡æ¾ZEÃÕØ3b:²Ñõ{¾ù>¹«[gÐçI[4×l¯§¥}Øk9´vãÉãGªs5°Á¶?gç×|gµ¤#Y¼Û Q©ô\¬Gî3²Ë)C·JâýÎDÈ[qáB|¨µè]?ÄiQ©ËÎÛÛÉÏã=ô×·^ÀÑ,ÔzÃïX})ê¶5Èicûâ¥QqP5Ù&åÕ Sµ`ki?#³À@¿ÈN¸ï Bfæöã-¥÷×m`°5GÁÓ¸nó£bTi=Jë´LP^yÀ$(US#ÕU)v9ãÃø#ú¶ú"õC(ÇsÛßÁwpE¦îÁ5 4¤c'9Zö¤ËK@/:¯g¾!­6¨@×¤ÐÐ°]ÏúRTïÜ`GW</ú#põÊÇüÚaØåyÓ.5_5kÇÝT«mÛn·b`p=ù(l+á tHe¯gÿ|êYZh%î)' IEÆ%Nè>@ÿ`¥ ººÀH* y,UY:0É/RÌ,C¸GÏYûC¬<lÞxÖöÓæÜ*KåÑÒ8ìTv³®êÃÒ =êôè<ýa;}WÍm»-ÐøQ«ãDê9ñwø÷Å¸mSÜüí¹·³+=³¿ùláD_Ôñè$«Í*£\Ê|Q/5#Ñ¿3vGËJ7´Í'ÕWõDþáI%¯'nbþÙ÷±è³ 4aÅOJaÜÜ>1Ú¬mrr³2XÇeÞkbÆùS)itz®Ï1?Âþòß¤Øhç»]!´mt\å SM}ñB%¦yþ¹v7Ê¼¡[MEú@¶Èü("FÁÌïFÃÓ¨äÅ\^D-	Ð<T¦[Ê¾uU?Î»@ZÿBrý{H_|cT2·f±LF³ªÌN£y©fÖ'å^¥Ã¥%^Ð×Óìg@Ð²5O+6ht¥fõËPY5`_;ýÂ	¸PÔp­aµ¤¡¶¶H ë=Ø>-³9¤	K.8À³°ãí9YÒ\\.).RªùkPÎªbû\õHbå^gB+2|RÚê~åMZ³±×¤ã*w%e{aª¦NÙYÚ¾à]ÅdeG7ê¬º©ÿ
§ÿÂaøÈÀ-R­pá){B¢ñÔ}ÓñÞÏêÃywdA»×?IàHiÔK5;üLþ¡FäTJHø;WÍI+èY	\åñÄ^k±L7rÑµ²qfÛ¶AËtlSÍßæ÷©vÃóånÛiWÄ||âÖÎ'>SãàfÌSYÿY%îU!S ÎIqz$ßÛ)(=\Kåµè- ¬E+YiêÂµ½ÅX©Cò§Í¬ÉR[¬¡W/ÎxwJÛ³¦^2f::ÂõPk¶JKÙ¿Ôý3Ô|¶¶A 1s0(gãQC-.HrZà!¸6
¾õùhKí	sU5ÎíÅÃ]c>veí<22óMíâã¯Oøã8^½{j}$w×Ïb%ð-Ý/´§ðð<KÚéÜ¿_-éºc°©JÍDárÌ{¡z;Ó^p Â,ðÓÏ<»êEQ3K²Cj­¦¿oaFR>òLÜgÅò
?^64>ÁÿÍàÃ{ñÑÃX?!jìJSæiÛ.R¯_-×DåKp¬²+%\»+æü0<s_ðX`f·¤¯L¶w2åÕzãÌ×s}SÞõÁ*u¤E äè6Ú\%A*S~)yÊ¹OQ¿êa×LÚ_XÛ@P/åÛèÎ $êo²"Êe¨þ¾×ógujzRýî¨#ìÍ"5Hæµ5pï+dóê#7N¯?÷s«Ã^ßDÍ,?Lù×U­ég¢-ÍçÁñL0×.»Aô]ÿÐoÓ~îp¿¥òCE>û«P=ÚòÂùsUÓ{Eåhê{çqW\?Â®ägÍ£èFA|$Ò0Ðµ\þ8á£D\Ônñt/Ó²®÷à#ÝOÓQâ2$ÁÑQÇè~ªN3¦[&=î¢è-!í¨g'îlõÃ¹LuXu÷_ã4ðv{1}6ÁÁ­{²Þ4Ã¢%]_óðw'|}${Tä¬ £½@-óÁuc¾RR|ERg;ë(o2ZÅi¿úuìPãÑaíä¼n$?yâ¡ø}à®DªÒ)RË`fÏù¼Jº;|zëøÍØ8gÁ¨sÏ­"ýwB¥¿}øã=õÛ3\b'5Ò§È¹Iôd½ËL>ªW ¤ëTÈødQ¯£a½UNø  °4Iµ(Øo5h0âkóN$ÚÜ`KñéÍ¾á[øôÐ·QZ`"yø×]ÚýÛ(*
%4wËÐ­®u.T6ñIO¦vkfÜ;£2·WßµåmÓÊ¾èÎl[îßCòâIi©Ja½3ivyÐ;"±89QA:8vï(\xìIeØºjÒ5¼ð°Ü¿¿rî1ÀloüZsã*áð~ñïçwv	¬é¯6§²IÐf\­£}GQ±ëpNöòd×DKaþYsEéü×'ö´úÁ1Íþ~h;n}ªó EÅ­º~3>ÿ6§¯ÒdJ_2k	¢R3~,XB Xg,~»oÒ¯H%ù.]OVZ¨*Ñc$:oT /6u4E°¸_±
 jºNà±W %(áZheY¾äÑó%*ìÐK	RF1^WsÚâO#R%ÎAo=bãéc·®È´dÓ¥ÐÝõÉµ½]ÔO><;'V*^>Ûê¸É[ÉQÊ'ü,ï¿UkFK,`²!C]ßDÛ	&×XZ½e¸Ís¼MÙJàvi^Ã¿¨ÌFëugÓÌZójc,=ÃDQúa;°ñaÙl.;Tôc¦2¬÷Ñ¡ }ü·ûì æØ]IâíAHËÈ¡ý¶SCü­ýcPð¦ÝêÚYfV%¨Ø¿S>Vê>ÿWKäHnñV=eFH"ñr¢*þ³RÃê+½IA½CWå\!î¤XÇ_	Aq]R¨F£R\RàNó]SÆçÅ_/gIl¨Jû~lªþÄ_úêò¾¿]Úà¸àÌ&sZ¯Ú¯#EðÍaZ¢È«tÁ@¹ÙAþ	Í¨?jéÕ2-?@ì>fsÄúVìF²lxýÚðT¦þ1N>Q±¹	(Ø]·G¼aHV~c;ÅA;IzR]Ýç_=+äcæLûH~æ+Ñ7aÓpÂ~àØ®þÝÛõqÛüL.(ÈX¦BñÎæö@R«ú¸×Gmyé´1&[YÓØ´x:Ô«Ú´áØS8¦{7$[Z@pÔ>B!5¬kÀ¶z½É«­¬HääÀ<euàb\Ùß^«NOw3ì[`AqÖ0o;p4>÷(mêNËµÍ$(!ÇÄ©æ·¶Vü¹øñÒËatð³Jéh¬1ñk_FÇae£ÝËç·?,dKL¸Ä{ÂCßùÏP¼Ü³sccRT^};^J=* \@ÅÙ¡èUê5ì\	ClWq^®Te±rrn¾
QØhµÍ<}<XÛ³LbÈIõþ&ÑDÙ6J?««ÈMtâ8¬çáÆuÇ?"ò°îY.î¤GâQåÐºÙ]ð kæÚvS×ÉðRÍ{â¿e!®ÉT5ì9»%W>PÃ7¶ÆÇñJªmw7ôèþN_óè¿ãÿ%4hJýÑ¡VWÂL×u!lÌìhO`*þ:z"¿æî­Eërl§®?äñµ¿g~K¾¸Ô}QRîqÀÍãGq#}ÑÓ'Írß=t\ª£þíZ³îØËôS­Á´ÐìÉ9NJÑâZñÍÒ$Íõb(c®¿ßHX±ílE°E×\5,Ô6Y}w )Ì9NÉIªüÎ@~ÅÔ&­<µÂ=s¶SÔñ	¨¾UÜÊ!>+òÐ÷kvÔxÏCüy`m8ÒT{¸ªäÜá^ªrQJO½¹¿*¤2e&(¬BÝ¶Ìg|74îÉ2dÐaV-õûJ|ÓRÑX©äÀðôezÃà<ÏæWº?Ìw6ÊùS_§Yéº÷ÌR£¬½qß²½÷ð~¼ "«	¨.¥f ¿«?©° A>'ÙÀBb×WG»!+ÇEtª$ý¦Á/z¢Çÿ¥N±¼ó­à	áÂ7Íx[^Üºìzçô»Hÿí\» 'õ-ÐÏÓ¢ó2ÇîoÕ=Ë\r¢O0hî÷z9ßl¬ROä?{^Vc£1¡rÀK'X\7Pkð¼±ñsquý²eºC_ñ~rc"egËUè¹ó>p<7ÞE1¨Yz(ßÀ-c¥õ¸'WÍ!¦[5ï³Eb+¨ßµd×nÉ)8Ð:bÿCÎÞÖ:Ð»`ËÊäûK`}í )ÖÀ&jz-ÕæÖ-ðÛ6ºë>º÷¤«í¼Ì@Iå>UÓÊVëROÅêZoI°6ÍRcjñ¸yXE¾^cú%¦ïÊ¦?"Bôàð-¦V¦9±N#«bú¾9øJ!MãÏvõë¬æHpmÎoò¨z/Ôf?Ì{¨IC%ÂïÝ?¶;ô¸búÍ­À«ÝPåÓ4P5{ßz·Ò|vY¢Î^­À:-ÿ¦nt6WÎz)Bê¶0Î<µ+Üà²Ú~	Äëù`bù*}§CJ@#ÀAîN´OXÓ|æ½4·'éd°yBMH¦W;=&WÛLåHGÖEæµú8ßÊ`eÊhóZù<ß£0î·dúeÑ=N£þÆßªpSý÷0Mø¶ç
õO°vÚåÑµÌ¾Ü8ð<geÚÚÒ®T'bX#îq1Òè=¹î¿»Ë®DÊyÜ£ÐlÔzm,7C§LÆº ñ{¢Cnr®Ä)µaL7Yô	?æòY°ô÷À¢àÒutJäuÙÁÒº.Âhûz7ÞØíåäØ¥°{1E½8nüýp¯í!)^/<£_::!Á­þÞßZ¿q©Yu-b
cµ K¹¶»sÑ5©ð¡øìy¬lÒITÔ Jt >çÅaÀQPþáB¶S~Ø(2\jvòR^à*NL|î~(S¼[©%(¬Ä28¶¼ºJ²¥¡Ôu¢#ºíw¥ßaTòý80ëP-0«FÓ;øE6/n´eøÊf¸e@Ïh¸§ü=ÂY·º¡4	·s¨¶­D¡jZºòTcúö µ"¦ç,°!)'KÚbYGÚ]~:å~:dÀW0bv²ÌçøXÇü$ÝóòÆ50IaXÊ¡3]V75M´WÑì$è¢¢<wöóüÉ"íw,õÐ^
t½A«Yãxícª^éê¦ìyvãë÷9[Plñ¢[ÎñzµÌÚ7ýgêmôÍ±4Lø['Ö*Ô¶º<½ ìC×;ã s%²ØÏ­1¯l?^U:8¯ñúNÙy¿é';W}Õ«9]kþtsßs ¸P4Ô¡Ú{Âscº'ÈèX\uÿÓf»Òd¼Q *è!Ð¶¥"ÙRº£.õ¬:"zbm/ìÈÏí FùbôK¡â;¬ÛëFb=aj [â
fxIííWI¯ªÈ GüDnÞ9à$âÒáca£aA3Äs!üëdê³ÚßjÙC2±}mb	{mÈâbMÝÏ(É¨×üw´æT§^(R(<&æÃèÂ\VOí]§ê²ÇÚ^ô³yÑ¢Ô³CÕ'1À°+w)ör»Ø@qªê.tyXEªÃâáLQ½ºyçM¡é±Tßß+ÛiFÇáBJQdºTZ¤
YIÚõ$_âCõ¢ì¬8b¿g'l÷p½­Â"Îº×ÊhA°A·Ñh·Ñ¹dÓ¯³ÆT­@ÝÏüZ¦x¦eH$LgMªËâ8
\·Þ{»ïþ°Áîò}òÖ¾xX¯^ÑéKÄ,Ê$VöÞÃg+1ä$WIU ÖtQüVzã£û¯¾­_¹R5[aâúg¥´}ØÖôFè"?b$·û/ëØT?*<µÂªæÎª5~Ì­©&>Öq[z¸Ý¡+ºÒiLµªR?k_J6·ºÍ%¥mr6ÅËçS!Ûµ´Ò¹ß_~øX,>ËÅ0IZz1ÕÎp~ÆYôûÇLÎò`»1#ëìî·ÀJì¶ÄËo[=­Y»æÿÍZ@Á\QËúÁaÚÿ#5ã\nõtþ;?Q¢55É93ÂàBÖôµÕPöHmórù
~ñ*ÂÀ¤á%äÂ6Xâù|Ø
ç®E!-]jæ½yü­«¾ò;©"ÌÊéÀC@ø»/
hî[ýlÆÝ.{|þaGÆÄ¯¶aÒUûv·ÞµÚ«U27-dü6¢wíylÛ@:@9ð=ÅÕpÛ¼TÕrJ¸ºJ!¹Õç¥«bî¨fVSJìÒ­ßÍ£ÿc9©ÍJSDÏzçÃ`o>làÕjPsÚ$^
B1s´½ýL\<eô6ºìíùáëäWìÁSUrrKxu¯Åö£¾ÌþÂÍØÜéÈu¹S¹ó¾üO·kXkÝ?ýZNªÖRèÉªË
Tg¿gí2ã×ù§%sÜ=¨¾^ÝPÐþ±=ò5Û¶o@xFöÂò>Ùú,d=ÁÆ'?ÏåJËs¦ÃË¶ÊWaÞ­{h!8ªËïçÎ})(ð&:í3p{Îä5ÀÙ8]5´Æ÷l==;¯\ÀÀ6¯>l>×YXÖ~Ð¯ÛÄÅÔei(80ö83ÅÚÃ¹ãRh$Hü«ã÷À³ï	@¤=Cù¡­:	}û§ch:£%ár§#l¼³ê©négþÜùtNÔz<TæAã¾9îæJ"@¯±ØýcÀ5ÜKyÓõ¦­²gé×«ñ¶·Áå½D
ä~v)>v¾¥à¢h<kÍç«´©Ö¯8 ¦SHøÏ35t4µ¾SV°>«w¯FQð\dRqìé\³uRëJ·=ê_Û#nqÝC!¨RZ]æô´e»¿£~Å×í»õ£?Ûò#ã|4!ºP`,Ã
Î@L9¤Á*×EÒbëf$aÑ¤SAàôÁkÓÊÂØµ7N-a°PÛe(rOräh¦øþÚÛ¸tGì@±\÷þ¨¼VÑ4CGYV+Ô§pÑ¦Å(¿íÄ»?8$¦e¾EÜÀ¸5(i° Ð'}ëØæRÅ£µ@uæ<ÒkÛ»
­CY¦[ÐX;´,1¡³¶¡OQ¨t1q-7yÃôsr¨"T!¯C+²ÇWá1Ú<w©å>\ÄÐßYÀÚSCc®êI;Næ|ÐTëÕ«TæâÑ;|l³¥Pý¥Ä×·& Ï3AâS LpÜ[äà¤ó¤9ÿ5kIøÛ87ÜuÝo!R§ÖÕ¾Ôõ5êÆ8½m?)QßTæõ*L!?2úJûuïKÄÒ<û`£ÝúZuúl3¶¶X2ÞÆ<{sã<¬³ÿ<S$ß=oºaÕObò¡L1Q/ttç¯B(XæýªB*#{hø;ó+hä!°ù^ª3Ã¼'1î·IwBh)y[¼u"À t·¬­¨ÖÔX`[ï²¬ZlF´k¡°ÀmÆ;êtÞIÝ«+EÜÊ«.{)M3 ;Hð¸jÞJOV}$4"2¬þà+ÉG£üÜ]V#¢l}Võ	j»µÊÆe<Ñ#Æë¸Uv¼æy¡iv38ÙãKMN´ò&³³åE·;¿3îÓe
 ³>d%mq}&¥ÉÆF)ºÑÊH¾n~Çí°äÂlåÓY¾X3ÁYu=dÎµªi6ÙÒel]9~Â`¸}UoD.ë·HZ!ÂüÅ­¬ÙÊ-oPL[â`ú´¦³&0|þÛJ¦Ä:/ÜÑz`]úE$ÅáCìÁÐ\výÞ¶Is-÷ù$]P°|¨º¤¼¯Üé`A¬ÉTµ]¬ {®ý¢ý©ª.ï8sâBéÿì0&´çÒ¼_ÂNHn-ãÀü3w oì2FÎAuUJD:	îøÂùißqñÅ@GÄ+¾Sv¼hY1c\/-/­±´×#+¿uëï>=«Ck$¼Èê¯ñWBª)Ö'dbT¨7¯)ªoÔ5EþcÀ KÐ3©©e%ê¼äÝµ¼OSRîS/øk
Qõ²Äë	 Y¨I=ìã[ÉI
PÉ#çë½ÿ>ìn+­¥ÛÑ*S÷Â¡ì~ù¨÷Kõrç`kç}ý|Ëá*u©y¹|¦Í9íÁî2UÝ:vE(ºgh¯â8¾¿<}6Ìac÷d¶¸×TÁ·désnÀiðlÈÉ©¢)N>ñc¢à§@t²ÙKrhÍö}þ³0u	yÌ¸åô«R`aêùÝ«Õ÷zPõXqþ²B¨ç2ä
FÙe>R*/ÂóhíSÖ8æ(o=ñ±¿v!³s]ýáÓlä/\yfáÍÒ÷&¬²üÊ2zñóa1ú	Í ©µ@ÇuÕxº´n¨ù$/Toé E«$!¸OêR´ý©´ì*ú½s7BÓX½Rf)¤8Þ¦<h 0c.45RñÚax.ãDóRFrÿ©Îp*è¬#
xónÂH¢yôYÞ+áÏaÒãó&Ððhppçû]¹!tY¬ÚË>=ó¶µ|]þ¡bÅd+¬ÔßLgÒtNSçõhå¯«.ª§²Lü§E  qB~åþÅ®YûÝ÷jG¯óà½UWüµ@Ê¡zXæûÏÛØ)Ìgùi¯¼&²Ã¹is:JSA¾öswbñt4B(À`Ä	v­3Ç@t+±4wa¢8¦\85û 7BëÐYÃ£Uþ+Òª¨Ýüá&k®åO Í¢óÇüº^Ak7]Ìpg+¤Øý$ÓÌÅZ± Â¬õXó÷(rB&p8DzÀ¹Ê¼íÈZú³	F0LðÄÂBU9¨Ú<Y¦1gÑ¿({´)ñÑÃ$|2 >³Ë/èÿÊáÍép9s±m££¡^ßhâXT¨¡u~ÇñXräàÛXCPËi2Mh i¡7Kmo<ßXTûÅR;=à;ÆÅßZS¤AåZá{.ÉgÜ»ðYGªá¡vI;D[QÏ¤Ó¨?^zknÂ	ËåpÒ¾T ïðÕ/î­KãÍÈ,	1,¥»Wò.KúýMâÈòÉý=òÍJ
äwÒÎÈ¢æ=É=5÷>w~/ÐbS@#Ïk¸ÔÍo&%]ÙäF;e/í*é>Ï¦ëÿ¬êøLó¦Øã_ÚÉK\àÈ\ð GÎAAs¯õ:Ô1|ccP¼LÁß®ìghÒ/ûéÏÙÊãÃöcQ".ëð1dPPá\¦:YÚ\öW¯Ââ¤@$§9ÃûCàõÈ¾©¾¨Ìá%;ê Ï¸MM~3hüe]å½°@§ÒaÚ¡JÄì¤µf$ Ä9Ò¯¾«6ßhÒÅêèsüDóuÁ1Û=É-`©p+>Ú![ÝÆ¤|I«ê=DëoüqBÂBeü´íÌ72=ÞöCUf£ßG3=iIiÕ±Â~¿tk_V{¼n:(k!ZzèÞj?«8Í¶äOaåÊLËçè%`ug!í:LmÀü.ä¿"Pá±_à2dÙl£\^
ká©´<#qÒþ¢È>XGB¸ûÅaäKk@D¶rº]3Y¹P®µVH¹ÉCwô¯ê|ÿÈ¾q(]­9ò`gÀØ#mþi=ÝFQT
!ý
ÁÏ»üCÙ
â¡¨¿u¢Çê^88&X.+O){~¯8Ä50æDÆæÖec±¤÷ö£­ðn¡þ2íd_hðøQï¬ëÏ(m¶8äHH'TÉníYøU²qÃÜä>
#LçÅ±/Óq­*ÍÈÛØ]Ù6x£G-ý3:öö HÍ16ÅK5.Aq¢f.Ãò?b&özvboÀÕW?7äj¿{9H®B4ýíù¥TÎR¡ ÄÚÂæØ6ªÖÆH.E9HÆ5nç{úô¿.ÆC±Åí0ûù +,f¢ÈW¤Ís¬ÑEzIjD<äµÅs¦7Òl"Þ5<ê©ëbÈ\dÖ¦üãDk©ßÐéÀ&Ù×>¼à áOH_4w 71#EöWJÊ,¼'N@ªK)ýüßVch"àXÐÊÚâîÍ¼0«`OJÛ!ó²âl}¯ôgÇÊXw5ÓcÖÐf>Ì¾#ù_>wç9eÄÛi«Bûæ#ÝNÇ=wÂOBîÑ
ÓlaÒý4#PóÂbkÏm?WÙI7Í #;ç»ùÝâWIÛ&ÂÜj8Î¿ð×PÁ{³óÚB4<yÐºóYJ%Q|Å~ª HÀ{>{ep'p~õBø üÐÛê´èÝÅÍôom4ûfqM2âÞdL'é}ÎºÛCsÎ8Ý
/Í	JaOf¤^x{°{Ø µarØDÉ=öVRù5uÉíOjq×.6ä-r¤lÍ0uâ 5ºafw\= >4ÖÝ
1*Í@(+¯o&0L@SpÑ7FeÀqÓñÎ¦¥ÂÏøÍè«ç ¨Û[17Wùi[¬?	|&OiÁ£$A×óäÌ+ls}Ä!ÍwuÄfÙÕýu<Í;µðtvÆJ«¦§¾ÎÜÊyaÙÆËÍóW/NÎ·©¾IV¾®l"h;Íð·hÂ8Çöõ.éá­X
±^?·ÕoÑiOcp%d¦ÔZßâl­Ê§µµ?$`?0GÊV{¬ÔCø0á(}4>zØ|R,»Ô$S½Ê÷¦ØcÊ/Ã[0Gy^+
Ì¯=ü¬µ®:Ìç!±J@ô[>(+ÖÜÀÿçÍEàî*»¾þÏMó<ÙU	?&¸ßñxðw©nøá.LHUf^ø³`r²	»]3Ø¯ÝX¹KÑÁ+Ö®ÒZe&´Ð"ª¶Rê?×D0Kr¿Rú2 n²iùerh¹² ¤ÀõÑ.¢agbÔZfÄìÂ,~;rhªÔuÊD¾Ï ÍØ]§m" øpè:©8U2hDÆTk?ÍB¯#2D>-P5Ç%+~,­Â8Why¾bàpfµ¢^ZÎ?âÚÉdGd*ûõDÜµ «Ga·ÿ4Å¿è
~nÌèLf'SSóD!//}* OµIï;7u¯o>Ñ5pE? ef5Ü±Cm^J)+ÍçÌC!Ñ²Ï¾A­-»òò&
C;Ö8¦ àíÄÉ+@P´ó\[5ÂH«ÕaªEAeS]ÄÅZKá|[¹*Þ=að?Oi3Bö\R»»ÐGþêzÀ³¢gd§tfë ½Oã3ÊÔ³ÑþÎE<Ö?!} (nÍªø5úö ¼Õ
endstream
endobj
376 0 obj
<<
/Length 696       
/Filter /FlateDecode
>>
stream
xÚmTMoâ0½çWxÚÅ$
!Ù	8l[jµWHL7IPþûõ¬V=MßÌ¼ñs÷ëu;ÑU··õÈÙ=w¾´ì÷îÝÝå]yil;<[[Ùj<=?±×¾+·v`÷Ù&ß´õðàÈ¶<^*;²~&ûQ·>ìþÝþMS>Ù_êãP·ò{=éÇsæ@ödôÇöçºkxä;`ÝVY×`s4½JaÓQÜ¡n«þªí¡.Uu9\ßèY6î>¼ý<¶Ù´.Z.ÙôÍþ4>DÓ¾²}Ý~°û¯ÒÜÑör:-d0­V¬²WÑÍÿ¼k,þ8ãóþy²LÒ»ðºÊ®²çÓ®´ý®ý°Ñó[Å*²mõíLr²?ÜÔqù¥ãâ5F8@ = @ð)&°  	È8 Ô¹ÂÅRx uDº\j2 H ª¡ÐVÁ¹0CzL]øÂb°ctI	©g$`htÑ0Æ\Fá0Ã¤sêájd<I ê6»õñzgóñºË»þêW¤qÈ£+#öñÌÇkÄÞ.bªsré¤áæÄçbïmXú¾Kß7ÇµHß7Géûû¾nb§>&jÊØµäu¯¼úñ1ÜV÷âÜãâµÇOu$ÕqWèS/%1{\øxB!§ÔK(hH©TÐæ»J©ÏÏ¯v×ÜëÁ=küÒ2ø¥UðKÏ_:~é$ø¥ÓàÖÁ/¿~Eð+7¿èË¢/	ÿlì¡ÛÒ(/}ïö	-+ZXukoûìÔE?ZãæÅÛKýqíÄ
endstream
endobj
377 0 obj
<<
/Length 900       
/Filter /FlateDecode
>>
stream
xÚmUMoÛ:¼ëW° éÁ5?$R.¤d9ôMðð®Ää	eC¶ù÷³kmCÕp¹;;w~>Î|¿3óE_ñ¸?O]5ß¶âî®Ýwç]Oßcìc]=~?§}÷Oâ¾yhÆáô9%?ÝÛ¹×¬B|Æ>âþ)þ;ëvÇw%gÏçáí43ä§áô>\	6ý§ã°¿
õEJõØ7ûÆ8ó1¿{Æ~ºðÏ`W(-ú¡;]¾è·Û%=°ùñýx»ñe_,bþ+-OÓ;qü\ÌL}ñUÜÿI--=·B«èãKªæÿ¾ÝE1ÿpÆ[ÎÓû!
Mßyuû>Û.NÛñ5K)Wb¹Ù¬8ö­iÇ[_®¹uÊMúÑzQ­¥Ò)VÚ(TØà x¿àÞ¢ jy°°!ÀÐÔ µZ ÔÀ2à P="¦ZdÔ0\ÃG©R\¡·).2*ÎÐ¨a!U¼Ä,³ÔÛHð° `+j ÐÃ. ¸5 NÎ±@èâ°èÐVK-àx%ôÜ3% A°YÓz¡ÎÔ>kP#¬³¦õ5m0W£o¦Ã¾j­®§Üý·.ÐZ¡T$X /©)n)æ#Wo(æoÀRZÞ$K¢p4Z¶-bâ\­1¦Ü°Jä	æP"GñXÔQ¬i/8ºkÉ^ÂZq:Zs½9d ­Bù)ßsLù-ï7½æxÏJ¡¾Ò`¯aÉ½)f¥É$µ1¸
dÑcªCZCù<£7Ã3JÊgózÌnøþHÈ°íáÌYÉäT¯aï¯Æ,_»-Oë87Ë}êÛKÔ´ÜLl¹oKñò+Êg­JÌâ.¾GZyóºVðc­48¸ï¼äØWtù]Í:P~`áñ±rZq.nÍ1]ÇÇàSÿæ/©ßPýïuö¿7Ùÿ¾Ìþ÷Uö¿·ÙÿÞeÿû:û?Èìÿ ²ÿÎþ&û?Ùÿ!dÿ&û¿1y¦¼ÍH·n5þ¹ã)º½ÝyÒBï½x#1Þ´Ãþ]ôGoáõñÅ×Mñ?®Xê
endstream
endobj
378 0 obj
<<
/Length 700       
/Filter /FlateDecode
>>
stream
xÚmTÁn£0½óÞC¥öÆ@LE"¤¶­jµ×©Dú÷;oÆ¤Ýj¥gæ½y_ýxÜN²º{qèV«'wìÎCå&ùÏ]\]]u>¸ötï\íêq÷x§®ÚººÎ7Å¦mN7¼i«÷síÆ¬ÿ'­ÜkÓ~¦G]?»ßþíÏ`	ý4òÓ;íßR´VµâÔ_n86]{§Ì­Öu[çÝºÁÔs«é¨fß´õà¨È	L¨ê¦:ù?«âíÇñävß>Ñæñ4|°²`ú0ÔnhÚWu}QEèöÜ÷ï
KU»=5£Yïw§¦ßºl?ôN¼6¢¦êjwìwví«Z/Õ¢,këo{&ýP®ãaffIÀqÉÀ¼ ÀXMJ0Lfhr¦ dÄ¥ ÄP<çF:ASlPJÒâtÆÉ #¡Gs=2ô+æ¬	(@»´ës°5¤È.WPL ²KF1õèLõ¶Èðë°HáI(£$ôçuô¹x-Ìà¥üÚJ¼BJ!^IÑ:ggM«5ã9¤æ7F7ÌFáN°}Y{}&þFÈûf.pÑdkæ_	Î¢NÅ0VG9×ú×Ê±çÐúwþDKù¬Ä4XÃ=CøaCÉg2)4X( ÍÆrb0§/sù4êlÆµ¬Ç®ËÃÄÜúÉb®]ËÌ[r<ÎÔs!?õïf*µ{.øz.ôI=ÎmZoàJ+Î9ÇRàÊ
ñÏ¨xè?Wúðáâr¹\Õyè¦ào|ÿMë.Tßõ¨â?ßnãýÕCü_er¨
endstream
endobj
278 0 obj
<<
/Type /ObjStm
/N 100
/First 878
/Length 3514      
/Filter /FlateDecode
>>
stream
xÚí[ioÜFý®_ÑÀ~}_7ÙÇâHÇ0DI³qäíä×ï«æ1Cg¤],°d¬î®zõªúàXyÁSÞ05SôçqËTLãOY¦ñç"Ó©ðÎ3c®!¨SrGùÈ¼1¸,à
hRE!ªÔ¤hMÏ¤2è+D&µe©QÉàQYH/vTpLZV#8RZJ/³hÕ;Å,úDô,lx"Õd4°G mEú¢$Úvx¦´`°EÊiI5Ð FëZàÁk-PÅ:Ç`¦rRàºrÖ @`X±£k a¤ÐBÕ © ·è^Ã8­LºcZÅk#E´qqG+tg½Bn´B{zPxê©Â+øOèO®3"á1¥H.ÔÔ)<k¬°;Zkf¡!ì=É8¸USu`,¨eàcGhb6Ì:AO"³~Cm@Môfü¦êD2ÍàI´dh"¦FoNP°¶Psp$Õá"P	ÆG(jøÓÑp@!êj8ã¡EnÖð
	+[HÆ³ á9³ô$²dÑY¢¶f1x¹£ñTÖH
çMâ=q=8¢=(Ó TgñLY4§ á'@j¼§¶PRÎï<~¼Ã_ýy3¾Wãr?OÎòÉ;AñÿÈñ§¸A÷;ü(?-Ù;ÄEÃY9FLÎdÎFHÏNJ´È_|ïñãÔ>ß;-ãó_ÑñÕeY^Ãy^d×ùÙp'îøñÅðt0úãt\ètø)ÿÛá Mðh4(.füÑ·ßîàø½#:vÄøooG$fQé½f³Ñèý²®Õ6C<ôEe ô:po/YDA>¢
hßÙ¬@<8I»dÙþ¸(ÙãÇïY$øjíSBD³ÕDpÃÙõ4#U7Ä8a72nÐ<9ç 
ã/¿ÛgüUþ¥dmÏÙ^Â;ü)´ÈrÜú$MÇ³Éi>M¹9=: f<aK$<½LPHJ.ñw^)ï.÷éºÔuÍó¥,Ñt=íeºihoàu#¤Í"º@ÊX`TÈ¼'ö¢Çÿ0~5fpÇW?Ç%ºË3±9a78Äqf1Ê5'Á¤Ú¸gÇ?ÿKa6«ðÜëpêfêmÍ¶°Ê6·ÛºVûò+l´ÈÒ½d¥7L½dxôr6éýBlÓtGØ5	a[ì£ZÁ>m±²?ö²w$ý5².ÌÆ~²6ªè^²AeB>@zîÌÄH\¸uÄb$®²à\?Ye3áB/YL¡2ÕSLU3³ìÓÍãiÁMOZ¬Ä­úøIWJuì¦µE_?-ÊÞO[pùþô%-V`±[ÃâúÁr¯ôº­¥R®Z·µTþXíE¯Ë¥]Bê­0ºüO_¶¶-®Úæ·¶-üWÙ¦Væþ´u°¥mJ=mÛ£WN­ûÚØ¥¥í.´aR]«¥mTW]_9W_Cý\ÔWU_ÍC.$B´ë¢06Ø-1ög2*sZÞµ$7.6ÖÈV&*Âç´÷×K-Ní$æèÀDú,jaíâÌyw&òá4±Â`Ö$[M¬4W¦¯&êá4Áô-b1¨VÎ`fÀlX#±pVwúFßcá,ÍhWZÒ'hAãõÚn¼tNó"Ï®r~	©Éh8-ù£íÓ1ðö¥K6$£,ÄÍõ?Î>¯hEÌTF«d£<Y4PqcH*C©<+òOO'ÃërZ_³ëËëTÅ?g7B¸{èî"5Ì«ÌÐ¾1è.i'ØPfØ
Îb6H¦ãóò3r4Ï¯§Ó{¸|l­cY6ÅeæµgXÕ´´¹W4¢ÐþÍ|#'2oPºb¦6´ßbHF Úorú¡ôüþÌ)j|ójç{ÅÙA^ÌwèËAïé¨^·TÅxÔGV¥+}»l½«){¦cè%-ØK4ØÌ÷kÔÓd/IÚsróyÝC,MÍêLÈl6êØf6 Yu¯7 øû.MoGâ÷iÅú;Þï¼£r{ÿ g)ÐX:­Úô7Òß;)3Y×¦OEIòõ9`àõÜfÉõ¹H¦"èTsî(YõæcÈ,sð
}@B6Ä[Lè{IÒY7èÇ¼µéìªvb©¾Õ
A"JPÑ1Ô2)j<UI=4@	×&ÐèÛZêJgj1+j¼ñÜÌ M³æÜ ¯DÕYµ°-ð(7,Þ¥ï¤}ç©\MìélÓçpzgèS¬ÖIFÜð¯y¯l]ÛÚENºñæH/ÑES®Ôíé¶£mÇùçQ'&$ÅéÚ <ÒAß0ªàé]4¦õa.û4bvÚ©xÚi´±:)d«XR	¹æÚ}ÞÖ©Ë¡.7ïÛ:ô]»ó.)U ?n
YòÉ;ÓÔKÄª·©6` ^kÜÐ¦yêrSS?A&eû®¶®×EÌ¸Ø"B¹{mëê^ý»»,!Ö´Rc|×ÑÊ3?(r´p­°L©VrrË2ªWËµõê2AÖ´MÏ%Ò7?«a_&M×8QµùtmIÖ9Ûz+µA\Ó½Kßy²pi+&µXSöÎdA?e©cß¨¹Jö©ûæ
j£9R®P)1VGø]7äìz±+ÛKí6@H®¢UçS#Ü%xø]ÛZÏ×Ï;Þé¤ý¸@üF_º6iÄ¤¶lºZ#;h4uVl4kÇuº!Rv]Øe[¢(·ÿÿøëÆó:i,çÎ°î}ÇsæÃ³áÎ¥¶Ñÿñ±©
UÂÊa]ÄÂT{£u"'»»>lÃßvæa)hó´O×¢¾vÍjÍ÷÷¾³è¢5Ìwyµ2TkÃÁÞ¿Ýùäõ×OI£ÁÅJâIZ{íjÅv"égÞÒÝÞôV`.BòéàúÇ|xqÛ ±´Ê«w»^>+£áé^q1ÊñËüê5Øá¿Õµhär0¡õÒWübÊ|ÂGùtú¨ÒcÚÚîjï.»?yúv¿½É.ÙnD«ÖuÞÛ¹]ô³È­ì2âF»N§¦£Áô¥	?NóQ~^V¥	Õàãë¼8ÁÒ3/W~pðâÍáó¯Ë/e¹Þli£× ë8Ó£êíü¢Ñ¢19ØÉnÁä=þ?åßñïù>ÿ!í!ýÄóüòùKþ?âÇüÿ¿æoøoü-ÿøàê:LÅLAáô?i1û-j(W¸òÓñh\à|u5àgülOòépÊsôâùÇÙ`ÄÏùùðSÎÏÇ³	¿hyvIÛ´yÁüü%âñ+^ðbXä¼]@áEÁÇ|×ü¶©Té 	)ºÇgüz4òüã,¦ý®³qªBUeÂ§|_+å§ù'(1~áKJ^^NòÇ|ÆgÅ´8Orþæ_øü/þW>/2ÅlÂ£½·û/¿>^Ì¦ÇâÅîQ~1[Oé@úI´,ZÝ	©º¼I·-oÔ=xcîòæ)3WÏàÀ8hÈ	üë[Â­.Úî6±ýøèõþ³jÛÆWãøbön0ß¶K?
NiI£sÝÎÍñóåBª¸+nÖGÍ[ tRãDä^àwËjâôïÐwâsl[Á6lí«~yyôz	Û[¨EØ¦Ù'lé`ëSÔr}RRJåJJF7%¢*y÷ÈGÅø<-ÕµÎ[NJÛä£ÛòPonª[f¦[ÒßhÄ>z~|üäùÚìEùGþ­Ú=DÉ¸B,ð:ÜòS¡ÅHòåGÇ?¬´¾	Ìj§Ù\ci§ÛÎ¬F/Ïjl;[4ÌRªú>EEÌn¥«xX
Þ0¾ì[°|Ëë¼f`ý¾88<?GôñâJÖ0ïÄ*fð$ÒÑa99Vq[áUQÛX )¢ô®,HÀ%S¤¦­`Ny£	å:¨±ªÒsz²Û6	²ãrõ×YôT5/ºôcíN.¡ÿFuëD[kéÐæØ÷«±Õù-=¦yú¬³²üYÅô¿mÒ¨ýádZëÔAs©ÎáYy9eô|è«ñ¯0>#ÖÜ0%¹M¡åuË²BzY!Z|´
IªÓj¤V5òktã4qY5¿¬q]Õì¨Vákb(ýO¤eÛYÇ¿ ûÚA
endstream
endobj
379 0 obj
<<
/Length 699       
/Filter /FlateDecode
>>
stream
xÚmTÁn£0½óÞC¥öÆ@LE"¤¶­jµ×.RCÿ~çÍ8i·Z)AãçyoÆ7?·¬îönÝkõâNÝy¨Ü$ÿ¹ë¢«ÎG×ÎÕ®¾ìÔóÐU[7ªÛ|SlÚf¼£äM[½kwÉúÒÊ½5íg
xÔí«û=éÇãÞúiä½6ã;íßR´V×µâÔ_n85]û Ì½Öu[çÝºOÁÔs«éEÍ¡iëÁP{È	L¨ê¦ýÕ@ñöã4ºã¦=tÁb¡¦/´yVvLÚMû¦n¯ªÝûþÝAÒÁr©jw f4ëãîèÔôûP×í×Þ©×FÔT]íNý®rÃ®}sÁBë¥Zå2pmýmÏÄR²?\rÊÕs<ÌÌ,	X#.K±IéÉíC®Ó¸ÀçÜH'hjmÁJIQÎ09 d¤a"2ôÈrî¡G~Å\5h×Qv]`n¶ôÙå	@v)Â(A'b}q¦ú³Èðë°HáI(£$ôçuô¹x-Ìà¥üÚJ¼BJ!^IÑ:ggM«5ã9¤æ7F7ÌFáN°}Y{}&þFÈûf.pÑdkæ_	Î¢NÅ0VG9×ú×Ê±çÐúwþDKù¬Ä4XÃ=CøaCÉg2)4X( ÍÆrb0§/sù4êlÆµ¬Ç®ËÃÄÜúÉb®]ËÌ[r<ÎÔs!?õïf*µ{.øz.ôI=ÎmZoàJ+Î9ÇRàÊ
ñÏ¨xè?Wúðáâr¹^Õyè¦ào|ÿMë®Tßõ¨â?ßnû«§2ø%ôrg
endstream
endobj
381 0 obj
<<
/Length 699       
/Filter /FlateDecode
>>
stream
xÚmTÁn£0½óÞC¥öÆ@LE"¤¶­hµ×.RCÿ~çÍ8i·Z)AãçyoÆ7?·¬î^Ý$º×êÅºóP¹Iþsß77EW®«]}Ù==¨ç¡«¶nT·ù¦Ø´ÍxGÉ¶z?×îõÿ¤{kÚÏð¨Ûû=éÇã`	ý4òvÍøNûß·­Õu­8õNM×>(s¯µ&`ÝÖywîS0õÜjzQshÚzðÔ+ä&TuS~ÅÏêH xûqÝqÓº`±PÓÚ<Ã+»¦OCí¦}S·WUnÏ}ÿî @é`¹Tµ;P3õqtjú}¨ëöî£w*äµ5UW»S¿¯Ü°oß\°Ðz©e¹\[Û3±¼.¹	åê9ff¬Ì¥Ø¤ôÃdF@ö!×i	@F\
`	HÅsn¤4µÈ¶`	¥$(Ng 2RÉ0zd9÷ÈÐ#C¿b.À´kÉ(@».0·[CzìrÅ Å »aÃ ±¾8SýÙäøuX¤ð$Qúó:ú\C¼AfpGÇR~m%^!N%Î¯$h³³&ÕñRó£æ#Æ¿p'XÏ¾¬½>ÿA£IäÂ}3N¸h25ó¯gNÑE'b«£kýkåØ¿sè
ý»¢%Æ|Vâ¬á!ü°¡äÀË3¬?Ðfc91Ó9Ç|u6ãZÖcWCåabî	ýd1×®eFæ-9Agê¹ú÷Æ3ZÆ=üI=ú¤ç6-Ä7p¥Ìçã?)peøÆgT<ô«?}øpq¹\¯ê<tSðÄ· ¾ÿ¦u×KªïzTño·ËýÕSü¨r·
endstream
endobj
382 0 obj
<<
/Length 700       
/Filter /FlateDecode
>>
stream
xÚmTÁn£0½óÞC¥öÆ@LE"¤¶­jµ×.RCÿ~çÍ8M»])AãÇÌ¼7ÏÆW?·¬î^Ü$ºÕêÉ»ÓP¹Iþs×WWEW®ï«]}~{¼SCWmÝ¨®óM±iñ7mõvªÝ9ëÿI+÷Ú´ð¨ëg÷{Ò¡±Ã~ÏÍøF	ßÞ)ÔPüËÇ¦kï¹ÕZ°në¼;@ú1zz5=Ú7m=xêªº©F¿âgu P¼}?î°i÷]°X¨é½<Ã;k»	¦Cí¦}U×YoO}ÿæ Aé`¹TµÛS7÷~wpjúm®÷Ïï½S!¯è©ºÚû]å]ûêÖKµ(ËeàÚúw&ý97¡\=ÇÃÌÌ5âyA±aÌÑ>ä:M1ÈK,¡xÎt¦Ù,¡¤Åé@F*&" C,çzdèWÌXPv-h×æakH/]®  d"btv"Öggª?»| ¿2JB^G5Äkdwt,uà×VââTâñJbÖ9;kBX­Ï!Õ0¿0ºaþ0büwõìÓÚë3ñWM";÷Í\8á¢É8ÖÌ¿9Ea¬r®õÛÊ±ßsè
ýÞ?Ñc>+qÖpÏ~ØPràåL
Ö
h³±ÌiÅËc>:q-ë±+Á¡ÁòÁ01÷~²k×2#óÏ 3õ\ÈOý¾ñÁL¥qÏRÏ>©çÂ¹Mñ\)sÅ9çøO
\Y!¾ñýçêO>\\/÷Auº*øâ[ ßÓºkªïzTñï·ó%ÕCü0tÄ
endstream
endobj
383 0 obj
<<
/Length 700       
/Filter /FlateDecode
>>
stream
xÚmTÁn£0½óÞC¥öÆ@LE"¤¶­jµ×.RCÿ~çÍ8M»])AãÇÌ¼7ÏÆW?·¬î^Ü$ºÕêÉ»ÓP¹Iþs×WWEW®ï«]}~{¼SCWmÝ¨®óM±iñ7mõvªÝ9ëÿI+÷Ú´ð¨ëg÷{Ò¡³Ã~ÏÍøF	ßÞ)ÔPüËÇ¦kï¹ÕZ°në¼;@ú1zz5=Ú7m=xêªº©F¿âgu P¼}?î°i÷]°X¨é½<Ã;k»	¦Cí¦}U×YoO}ÿæ Aé`¹TµÛS7÷~wpjúm®÷Ïï½S!¯è©ºÚû]å]ûêÖKµ(ËeàÚúw&ý97¡\=ÇÃÌÌ5âyA±aÌÑ>ä:M1ÈK,¡xÎt¦Ù,¡¤Åé@F*&" C,çzdèWÌXPv-h×æakH/]®  d"btv"Öggª?»| ¿2JB^G5Äkdwt,uà×VââTâñJbÖ9;kBX­Ï!Õ0¿0ºaþ0büwõìÓÚë3ñWM";÷Í\8á¢É8ÖÌ¿9Ea¬r®õÛÊ±ßsè
ýÞ?Ñc>+qÖpÏ~ØPràåL
Ö
h³±ÌiÅËc>:q-ë±+Á¡ÁòÁ01÷~²k×2#óÏ 3õ\ÈOý¾ñÁL¥qÏRÏ>©çÂ¹Mñ\)sÅ9çøO
\Y!¾ñýçêO>\\/÷Auº*øâ[ ßÓºkªïzTñï·ó%ÕCü¬2tâ
endstream
endobj
384 0 obj
<<
/Length 578       
/Filter /FlateDecode
>>
stream
xÚmMoâ0ïùÞ=¤Ø	PEHùBâ°mUÐªWH	(Òòï×3ÐjÅðfüÎÌc3fòë}çFEu×{âÚªorpßÚLÒ*ï¯`ºWqµ}ïMï ÓdnMÙ=YóÖä¾ÑõØÃ¹4ßì#¦{øt»¿]çûòÒÆhÝÝÅZ¬
?Cþ@ÓyêYJi)êhÙ !f#Ö©4E3#r9J¢Ì»áùÕ&ïnm×­9UNÙ]l»æF|OÎì­) )ÍYLÙ]_×@!õZp²õì¾_W³»»;ö·¦wÅLyU@[rhæN(åZÍÚSü·æsÆñ4ZÖ*øð"íZY­H«m ýKÐ±à@H[y°»õçjìLz+Ï¦Iê¤eZsëKuzÎ:Cí3¥D°¦:+ÖaM¥©fLz2aMþa/ÔSgC:¶ç*âTÆrJí¡_iÞ62(Þq<GM:!qêydD5P/9<Ä/SòD¤3äW11øÈ¬oÈÏü	y2öhÔÌO}5òë¹Æ\}µ´mÐÏs}öûØ7ìÁÜ{Ò5{èlÄ¦æôû&>óàôd¬íOýê8x_îã÷Mc'.4sià~ïêªÆ,úÐÿðímãüÍ<ÿ
endstream
endobj
408 0 obj
<<
/Producer (pdfTeX-1.40.26)
/Author()/Title()/Subject()/Creator(LaTeX with hyperref)/Keywords()
/CreationDate (D:20250428225239+02'00')
/ModDate (D:20250428225239+02'00')
/Trapped /False
/PTEX.Fullbanner (This is pdfTeX, Version 3.141592653-2.6-1.40.26 (TeX Live 2025/dev/Debian) kpathsea version 6.4.0/dev)
>>
endobj
380 0 obj
<<
/Type /ObjStm
/N 56
/First 470
/Length 1704      
/Filter /FlateDecode
>>
stream
xÚXÛnÜ6}ß¯àc¶A¼äðriÒÔö6µÓä¡­:Ø+cWÒ¿ïÈ¥)«$~1¥£¹93¤ÖÒ1ÎLX«fRã½4LÇ{Å¬ Ü2§ñÞ9æµc`Ù:&Ñ@ºPhÚÍ¤Ã	IgPØ®F0ô8sè¢tÇLvY´³Rl§ÃGÂÌÚy/68âL§`|¥pµ)Îh wP	 BÐNcPÀKcÍ) ¹Åäøm^(É+,JãgãV
òX&ýñd*½ ;1XâX£D
$] !é /0¤/SEÞ"÷qLs «ÂúçL+ `X§áz¦80m±jRR;Ee*¦=ÕÜÇê033DUaböôélñþ¿Û-^·n¶8¿ûÜõ·ÙâÅj×Ð¶8?ûðúíÇËõÍç»ÝY{³lýÉÓær=ë]_5»íú¶k·X±ÇI9C|½Ýu/¿¬¶fU¼q?®/»/;!LÝ\´ëÍ"2 ïÛ¿6k&m÷ìÙOÐ}ÿûïÎ>è5Ww%]+&éÑõ?@×§{vº\¿©Ð}Û­®+õ$eÍ3ÊöG(Ã(¿8®P~r~½Útÿc+Äå¸2gCÿsùóÌOOO>.wßº®2¼´RÚ¡+ù¨Ï»ÕU³-^¶wË}·Ú6xE`ï~¼¾Ü±¿}G¢+®ýj"§_¿ñúôÂÅX>Æöý<ÓiV%Âj"_°V·_mX}ÌáísHbH4ÇUÅÕà{9à`øJõ]`ÀÜÆ&¹(d$Â#1¥+Áþ¸ë®××g"Í½ûI&ÏuwÝ07Äs:câý¶ùÊ¡«ó{×dZudÍ·DfG§80G,NØÇ±nGäa âimòTO{Ú
wä³ü°§qõ°aLÒ0¹56&)i`"ÏÂ&	©]5LðT¥§NBê¡à2²2Ñé5U¢'±õhV!®*©¤¯2¹¾º¢¯Jú*ë[eôîp­*bË$¶TÕ0ÁW<WÛ0yötú6ih$±ÁLìÃ\lÇ© O5£\©# ¹òÔ Hõ£#xV R:¼òìOÄP-äó¿"VkFÉRßÄäaåÓæþ°·GTöB^ÔJs¿åê¦Á7Ü£WíÅónµíæXFxµ?úíß¶í6m×	D¥/P>gôØFk{c Áº%Á&¼?'ëu7â34þ4f=UÊ4Á®ÁeQáø#-Á¢=Á0f?ä4´( ºÐHæ
L2ëBf u!3ÌaÛ`LÛÃüa>2¢OBëBh ¡u!4Ð¶èÐ®äBKU´Ebj¾Í'èKN)KAp±%$\tEJ®(âYäDx××Ù£ù{C±
QcaÕ¡-ò~ë¿íÚõàUÐhy}/rØLoñ§uÄùè#ýé!sÒBÃl^4Ç¶}Òdt®Sy<YçsÆÕXÐ¤ú)ÏmhGK]§¥çÉ¨N6¾ä.G³( GhÉ@à9¢ÉË£m!Ã^ð¢¬Éê 1CCWÞïÃü C4ë6¯ÖåZÑ¬:[çdæÉ¨NFÚçúiN£¶]]mW·_Ô<4R×¾þk¼Ëá#¬VÕ»yÍºRÃÐÕÒUò@äµ¯?BòFÖ!ùûv!y{ Ò°é-¸VwÍE·n7¿KI÷ý[7}ZûÁC¨?kÇ¤óìå!T%Çt£ì8²~ýîs
Ûè+8d²ÓyfPîõY´óçÔÐ,ûÀµUzüt)Ý(vÕ/1Y¢R2~1ñ,ñ²IS¿üÆ/<Ã2¾düÆF_ØÃ{7ñB88°û$1}«©ï¢âÛUÅWâjªøÉ¯:¨ðoøÝéåª[]·W³ð5ëþØþ{Töï@?=§9®Óö²Y,ÛMö·ÍæyùôOÖÿé
­ª
endstream
endobj
409 0 obj
<<
/Type /XRef
/Index [0 410]
/Size 410
/W [1 3 1]
/Root 407 0 R
/Info 408 0 R
/ID [<B506116BFCE914471B5AC89E89D55E7A> <B506116BFCE914471B5AC89E89D55E7A>]
/Length 1000      
/Filter /FlateDecode
>>
stream
xÚ%KhUWÏÚçj1F£øHÑ¨1WoÆøJ¢ñ5Ñ¼o£ÒÖ¡¥{P°tÔÐ:«*Ö("*Î:)uPÚI{¾ßÉÇ^ÿ>÷sïúö:I$ÿ$	buÂj&_ÇfVB$ÛBYl3å°lleXF6O¶²,ÏË,5QVd)Y#e5XIV k ¬«Èm \jÉÕS®kÉVÕQ®ÇõBÙ²R_°l=>¦7qq\K©ßH¢n©½lY-¥þ°f26¢·l%ÛB¶²l#k%ÓOmÛÉv­¤ÜÚÉÈô7í\ [A¹t= Ó´^­-%IÊ½`3 ?ÎdWX©«ûA78 pôÃà8
ã ôpà8Î³`# Ë»õ¤çy ©w²a0ÆÁ¸&Áe0eÉgºø"£<x£lÌ23»Õ¨E´üWX³ïûÙpÇpÌfßÖ)Óàs
_ä'êæ»Ú]Ýi£WZèùItËi£ã×X(j-×¼ÖÂP2yª¯Ç]_gaä®6p×q×Õ9Î9r<u$ô:]ºèÈê]ß
-Ì©]ìômÆ;:Ý÷í 	¼ #¡cïháHè¸áèâèèXâ U'_i|À/ôñ.CN§½ÕÂÕ^=3J969696969696ùyp #´prÌq¤qlrÜðI×u)° f,|ü²YúÁsKÆÍ4ð-Üx­c-Paò§ÚÐ¬s¹·þÒ&a5ÐË¸Ý ¾7þç*eiõ@CK¦ÑÂ¯ßh·	hª´Xxô2O\Æjh³ðämhÒìíßQ¶t¯®)ÛYÑÂoíûAÉÂï+ëÀp=à8^Ð³ ÛÂz-eýà$à-§Á~L%+B6dá{úÄ9ÀÈÈÁà-`\Á¸Ôg',Ínj5iiéí÷MYZÔjÚÒk3ZÍXúÃ}­f-ýû©Ve+4i5g±¯+cúÃïÜÉïåxï<ÌqýEF1"bDljÞt0¶zé[äiOÔË¾Å@{"-E@g¢|	ÐH£b·>y?¿ùÉÿ¨¯ãL
endstream
endobj
startxref
295890
%%EOF
doc/HyperListTutorialAndTestSuite.hl	[[[1
167
HyperList Test Suite (V1.1); Press '\f' to uncollapse this whole HyperList
	This HyperList serves two purposes
		A tutorial for all hyperlist.vim features 
			Do each item and you will learn all the features of this VIM plugin
		A fully fledged test suite
			Doing each item will confirm the plugin version is working correctly
	Requires the files HyperListTestSuite.hl and hyperlist.vim
		Set the cursor on a file link and press 'gf' to open the file; OR: 
			vim: <~/.vim/doc/hyperlist.txt>
			nvim: <~/.local/share/nvim/site/doc/hyperlist.txt>
	Tests are broken into 3 major categories, "SYNTAX HIGHLIGHTING", "FUNCTIONALITY TEST" And "MENU TEST"
	SYNTAX HIGHLIGHTING
		Ensure that all HyperList elements are correctly highlighted in the HyperList definition file; OR: 
			vim: <~/.vim/doc/hyperlist.txt>
			nvim: <~/.local/share/nvim/site/doc/hyperlist.txt>
		Check: The Property should be in red
		CHECK: The Operator should be in blue
		[? OK] Qualifier in green
		A #hashtag should be in yellow; And the preceding semicolon in green
		1. The numbering is an identifier and should appear in magenta
		+ The multi-line indicator should appear in red
		 and indicates the item runs across more than one line
		This link should be in magenta <link to nowhere>
		This comment should be in teal with the link inside in magenta (the <link to nowhere>)
		Quotes are also in "teal" and with "links inside in magenta, <link to nowhere>"
		Check (comment): Comment within a Property should be in teal
		Keywords END and SKIP should be in magenta
		Keywords FIXME and TODO should be in black on yellow
		Markup like *bold* /italics/ and _underline_ should appear correctly
		Fold this item and child by pressing 'SPACE' and see that it goes from bold to normal text
			This is a child item
		Press '\h' and move the cursor one line down
			This line should appear as normal while all other lines are dimmed
			Press '\h' again to remove the highlighting
		Collapse and uncollapse the next line to hide/show the literal block of lines
		\
			Check: This "literal" block should not contain any colors
			[? OK] *bold* /italics/ _underline_ FIXME TODO #hashtag
		\
		Check that State items and Transition items are underlined correctly
			By pressing '\u' State items should be underlined
			Pressing it again, Transition items should be underlined
			Pressing it a third time should toggle off underling of such items
			Now press '\u' three times
				S: This is a state item (indicates an item that is describing something)
				| This is a state item (indicates an item that is describing something)
				T: This is a transition item (indicates an item to be done/processed)
				/ This is a transition item (indicates an item to be done/processed)
	FUNCTIONALITY TEST
		Toggle folds; Press 'SPACE' twice to see the child of this line collapse and uncollapse
			This is a child item
		On the next item, press 'CONTROL+SPACE' twice to see that the fold toggles recursively
		Do all these: '\3' '\4' '\5' '\6' '\7' '\8' '\9' '\a' '\b' '\c' '\d' '\e' '\f'
			Observe that the children appear at the correct fold level
			'\3'
				'\4'
					'\5' 
						'\6' 
							'\7'
								'\8'
									'\9'
										'\a'
											'\b'
												'\c'
													'\d'
														'\e'
															'\f'
		By placing the cursor in the reference and press 'gr' you jump to the next item (<42>)
		42. This is an item that you will jump to
		By placing the cursor in the file reference and press 'gf' you open the HyperList definition file; OR: 
			vim: <~/.vim/doc/hyperlist.txt>
			nvim: <~/.local/share/nvim/site/doc/hyperlist.txt>
		Close that file to come back to this file
		Toggle autonumbering of items
			Press '\an' or '\#' to toggle autonumbering on/off; Press '\an' now and go to next line
				You should see the message "Autonumber ON"
			1.1. Go to the end of this line and enter insert mode and press enter
			1.3. You should now have a line "1.2." above this line
				Place the cursor on that "1.2." line in normal mode and press 'CTRL-T'
					Observe that it numbers the line as a child of "1.1." (1.1.1.)
				On that line, press 'CTRL-D' to observe it goes back to "1.2."
			Press '\#' to toggle off autonumbering; You should see the message "Autonumber OFF"
		Sort lines correctly
			The following lines are incorrectly sorted
				2 Item2
				3 Item3
					3.1 Child of Item3
				1 Item1
					1.1 Child of Item1
			Mark the numbered lines visually ('V') and press '\s'
				Observe that the lines are now sorted correctly with their children in the right places
		Create and use checkboxes for items
			With the cursor on this line, press '\v' to see a checkbox appear
				With the cursor on the above line, press '\v' again to see an "x" appear in the checkbox
			[_] With the cursor on this line, press '\o' to see the item marked as "in progress" = "[x]"
			[_] With the cursor on this line, press '\V' to mark the checkbox with a time stamp
		Show/hide items with specific words
			This is an item with the word "simple"
			This is an item with the word "amazing"
			This is an item with the word "simple"
			Now go to the word "simple" and press 'zs'
			Observe that all items that does not contain "simple are folded"; Press 'zh'
				Observe that items containing the word are hidden/folded
				Go here and press 'z0' to remove all hide/show behaviour; Press '\f' to again uncollapse the whole HyperList
		Check "presentation mode"
			With the cursor on this item, press 'gDOWN' to go to the next item and collapse all other items
				Now again press 'gDOWN' to go to the next item in presentation mode (see this line collapsed)
			With the above line collapsed, again press 'gDOWN' to go to the next item in presentation mode
				Now again press 'gDOWN' to go to the next item in presentation mode
			Now press 'gUP' three times and 'gDOWN' three times and observe the current line "presented"
		Check that filling put forms work correctly
			Press '\SPACE' to jump to the next line in insert mode to fill out the item
				Fill out the rest = 
		Encryption and decryption
			Note: Encryption requires OpenSSL to be installed
			With the cursor on this line, press '\z' and enter the required password twice to encrypt the line
			Mark the above encrypted lines visually and press '\x' to decrypt it with the password you used
			You can now create a HyperList password file and save it as ".pass.hl" (not the dot preceding the file name)
				When opening the encrypted file, VIM will automatically ask you for a password to decrypt that hyperlist
		Export to HTML
			You can convert this whole HyperList to HTML and save the output to "test.html"
			Pressing 'u' will undo the conversion, but you need to do ':set ft=hyperlist' to set the right filetype again
			Press '\H' to convert this whole HyperList to HTML format
		Export to LaTeX
			You can convert this whole HyperList to LaTeX and save the output to "test.tex"
			Pressing 'u' will undo the conversion, but you need to do ':set ft=hyperlist' to set the right filetype again
			Press '\L' to convert this whole HyperList to LaTeX format
		Export to TPP
			tpp: <https://github.com/cbbrowne/tpp>
			You can convert this whole HyperList to the TPP presentation format and save the output to "test.tpp"
			Pressing 'u' will undo the conversion, but you need to do ':set ft=hyperlist' to set the right filetype again
			Press '\T' to convert this whole HyperList to TPP format
		Export to Markdown
			You can convert this whole HyperList to GitHub-flavored Markdown and save the output to "test.md"
			Pressing 'u' will undo the conversion, but you need to do ':set ft=hyperlist' to set the right filetype again
			Press '\M' to convert this whole HyperList to Markdown format
		Modern Export Commands (Enhanced versions)
			The modern export commands provide enhanced versions of the export functions
			They use the same key with an 'e' prefix: \eH (HTML), \eL (LaTeX), \eM (Markdown), \eT (TPP)
			Try pressing '\eH' to see the enhanced HTML export with responsive design
			Try pressing '\eL' to see the enhanced LaTeX export with modern packages
		Export lines to your Google calendar
			To use this feature, you need to have the program 'gcalcli' installed and properly set up
				gcalcli: <https://github.com/insanum/gcalcli>
				Now press '\G' to see that the below item appears in your Google calendar or an .ics file appear
				2040-01-01 08.00: Item from the HyperList Test Suite
		Show the complexity level of this HyperList
			Using ':call Complexity()' you should see the number "157" displayed
	MENU TEST
		When opening <HyperListTestSuite.hl>
				The "HyperList" menu item should appear in the menu line
			During insert operations('i,'o','O','a','A', etc)
				The menu should be greyed out
			Using 'ESC' at the end of insert operations should un-grey the menu
		Selecting the menu
			A TearOff dashed line appear at the top
				Clicking the TearOff dashed line
					The Hyperlist menu should detach and be moveable
					Menu items ending with '>>', when selected, also show a TearOff line and a submenu
					Each submenu should detach when their TearOff line is clicked
		Closing TearOff Menus
			Each Torn off menu should have an 'x' in the upper right corner
			Each Torn off menu should close when the 'x' is clicked
			All torn off menus should close when Gvim closes
		Go through all parts of the <FUNCTIONALITY TEST> using the gVIM menus to see that they work correctly


ftdetect/hyperlist.vim	[[[1
50
" Script info {{{1
" Vim filetype detection for HyperList files (.hl)
" Language:   Self defined file detection for HyperLists in Vim
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
" Version:    2.4.4 - compatible with the HyperList definition v. 2.4
" Modified:   2020-08-06
" Changes:    Refactoring (thanks to Nick Jensen [nickspoons] for guidance)

" File detection {{{1
" WOIM files are included for backward compatability (HyperList was earlier WOIM)
au BufRead,BufNewFile *.hl,*.woim						 set filetype=hyperlist

" Encryption autocommands {{{1
" Using code from openssl.vim by Noah Spurrier <noah@noah.org>
" dot-files (files starting with ".") gets auto en-/decryption
augroup hl_autoencryption
    autocmd!
    autocmd BufReadPre,FileReadPre			.*.hl,.*.woim setlocal viminfo=
    autocmd BufReadPre,FileReadPre			.*.hl,.*.woim setlocal noswapfile
    autocmd BufReadPre,FileReadPre			.*.hl,.*.woim setlocal bin
    autocmd BufReadPre,FileReadPre     	.*.hl,.*.woim setlocal cmdheight=2
    autocmd BufReadPre,FileReadPre     	.*.hl,.*.woim setlocal shell=/bin/sh
    autocmd BufReadPost,FileReadPost    .*.hl,.*.woim %!openssl aes-256-cbc -d -pbkdf2 -a -salt 2>/dev/null
    autocmd BufReadPost,FileReadPost		.*.hl,.*.woim setlocal nobin
    autocmd BufReadPost,FileReadPost    .*.hl,.*.woim setlocal cmdheight&
    autocmd BufReadPost,FileReadPost		.*.hl,.*.woim setlocal shell&
    autocmd BufReadPost,FileReadPost		.*.hl,.*.woim execute ":doautocmd BufReadPost ".expand("%:r")
    autocmd BufWritePre,FileWritePre		.*.hl,.*.woim setlocal bin
    autocmd BufWritePre,FileWritePre		.*.hl,.*.woim setlocal cmdheight=2
    autocmd BufWritePre,FileWritePre		.*.hl,.*.woim setlocal shell=/bin/sh
    autocmd BufWritePre,FileWritePre    .*.hl,.*.woim %!openssl aes-256-cbc -e -pbkdf2 -a -salt 2>/dev/null
    autocmd BufWritePost,FileWritePost	.*.hl,.*.woim silent u
    autocmd BufWritePost,FileWritePost	.*.hl,.*.woim setlocal nobin
    autocmd BufWritePost,FileWritePost	.*.hl,.*.woim setlocal cmdheight&
    autocmd BufWritePost,FileWritePost	.*.hl,.*.woim setlocal shell&
augroup END
" vim modeline {{{1
" vim: set sw=2 sts=2 et fdm=marker fillchars=fold\:\ :
README.md	[[[1
284
# hyperlist.vim
This VIM plugin makes it easy to create and manage HyperLists using VIM

---------------------------------------------------------------------------

## GENERAL INFORMATION ABOUT THE VIM PLUGIN FOR HYPERLISTS

HyperLists are used to describe anything - any state, item(s), pattern,
action, process, transition, program, instruction set etc. So, you can use it
as an outliner, a ToDo list handler, a process design tool, a data modeler, or
any other way you want to describe something.

This plugin does both highlighting and various automatic handling of
HyperLists, like collapsing lists or parts of lists in a sophisticated way.

This VIM plugin makes it easy to work with HyperLists. It has a vast range of
features:

* Automatically recognize files with the extension ".hl"
* Syntax highlighting of every HyperList element
* Syntax highlighting of bold, italics and underline (using \*word\*, /word/ and \_word\_)
* Automatic underlining of State or Transition items in a list
* Collapse and uncollapse parts of a HyperList
* Syntax highlighting of folded parts of a list
* Set a specific fold level to unfold items down to that level
* Linking/referencing between elements (items) in a list
* Easy navigation in lists, including jumping to references
* Easy navigation to elements that needs filling out (when you use a list as a template)
* Open referenced file under cursor using (g)VIM or external program (user definable)
* Autonumbering of items and sub-items (children) and renumbering of visually selected items
* Sorting a visually selected set of items (while letting the children stay with their parents
* Create and toggle checkboxes, even with a time stamp for completion
* Show/hide of words or regex patterns
* "Presentation mode" that folds everything but the current item
* Highlighting of the current item and its children
* Encrypt and decrypt whole lists or parts of a list
* Autoencrypt/decrypt files that have a file name starting with a dot
* Export a HyperList to HTML, LaTeX, Markdown, or TPP formats
* Modern export commands with enhanced features (responsive HTML, modern LaTeX packages)
* Transfer all items tagged with future dates/times to a Google calendar
* Show the complexity level of a HyperList
* Description on how to include HyperLists within other filetypes, taking full advantage of the above features when including a HyperList in e.g. a normal .txt document
* Menus with submenus for gVIM users
* ... and there are many more features. Check out the comprehensive documentation (type ":help HyperList" in VIM after install)

For a complete tutorial, go through the file HyperListTutorialAndTestSuite.hl in the documentation folder (~/.vim/doc/HyperListTutorialAndTestSuite.hl). This file also serves as a complete test suite for releases of this plugin. 

For a compact primer on HyperList, read this OnePageBook:

![HyperList OnePageBook cover](https://isene.org/assets/onepagebooks/7-hyperlist/cover.jpg)
**[Downloadable PDF](https://isene.org/assets/onepagebooks/7-hyperlist/1PB_HyperList.pdf)**

And for an introduction to the VIM plugin's most sexy features, watch the
screencast:

[![HyperList screencast](https://isene.org/assets/videos/screencast.jpg)](https://www.youtube.com/watch?v=xVUPJQhOBiU&t=1s)

GVIM users can enjoy the commands organized in a menu with submenus.

### Installation

The easiest way to install this VIM plugin is to use [Vizardry](https://github.com/ardagnir/vizardry). Simply do

```
:Invoke hyperlist
```

Or use any other plugin manager like
[vim-plug](https://github.com/junegunn/vim-plug) to install the HyperList
plugin. With [minpac](https://github.com/k-takata/minpac) you would do:

```
call minpac#add('isene/hyperlist.vim')
```

Or download hyperlist.vmb and do:

```
vim hyperlist.vmb
:so %
```

You will then discover that this file (README_HyperList will appear in the VIM
directory, while the documentation will be placed in the "doc" subdirectory,
the HyperList plugin will be placed in the "syntax" subdirectory. A HyperList
filetype detection file is placed in the "ftdetect" subdirectory.

From now on all files with the ".hl" file extension will be treated as a
HyperList file, syntax highlighted correctly and you can use all the neat
HyperList functionality for VIM.

### Include Hyperlists in other document types

To use HyperLists within other file types (other than ".hl"), add the
following to those syntax files:

```
syn include @HL ~/.vim/syntax/hyperlist.vim
syn region HLSnip matchgroup=Snip start="HLstart" end="HLend" contains=@HL
hi link Snip SpecialComment
```

The documentation file contains all of the HyperList definition and is part of
the full specification for HyperList as found here:

  https://isene.org/hyperlist/


## INSTRUCTIONS

Use tabs for indentation.

Use SPACE to toggle one fold. Use <c-SPACE> to toggle a fold recursively.
Use \0 to \9, \a, \b, \c, \d, \e, \f to show up to 15 levels expanded.

### Autonumbering and renumbering

Use \\# or \an toggles autonumbering of new items (the previous item must be
numbered for the next item to be autonumbered). An item is indented to the
right with c-t, adding one level of numbering. An item is indented to the left
with c-d, removing one level of numbering and increasing the number by one.

To number or renumber a set of items, select them visually (using V in VIM)
and press \R. If the items are not previously numbered, they will now be
numbered from 1 and onward. Only items with the same indentation as the first
selected line will be numbered. If the first item is already numbered (such as
1.2.6), the remaining items within the selection (with the same indentation)
will be numbered accordingly (such as 1.2.7, 1.2.8, etc.).

### Presentation mode

As a sort of presentation mode, you can traverse a HyperList by using "g DOWN"
or "g UP" to view only the current line and its ancestors. An alternative is
\DOWN and \UP to open more levels down.

### Highlighting

To highlight the current part of a HyperList (the current item and all its
children), press \h. This will uncollapse the whole HyperList and dim the
whole HyperList except the current item and its children. To remove the
highlighting, simply press \h again (the fold level is restored).

### Jumping to references

Use "gr" (without the quotation marks, signifies "Goto Ref") or simply press
the "Enter" ("CR") key while the cursor is on a HyperList reference to jump to
that destination in a HyperList. Use "n" after a "gr" to verify that the
reference destination is unique. A reference can be in the list or to a file
by the use of <file:/pathto/filename> or an relative reference such as <-4> to
reference four items/lines up the list.

Whenever you jump to a reference in this way, the mark "'" is set at the point
you jumped from so that you may easily jump back by hitting "''" (single
quoutes twice). 

### Opening referenced files

Use "gf" to open the file under the cursor. Graphic files are opened in "feh",
pdf files in "zathura" and MS/OOO docs in "LibreOffice". Other filetypes are
opened in VIM for editing. These can be changed by setting these global
variables in your vimrc:
```
let g:wordprocessingprogram = ""
let g:spreadsheetprogram    = ""
let g:presentationprogram   = ""
let g:imageprogram          = ""
let g:pdfprogram            = ""
let g:browserprogram        = ""
```

### Simple tricks
```
Use \u to toggle underlining of Transitions, States or no underlining.

Use \v to add a checkbox at start of item or to toggle a checkbox.
Use \V to add/toggle a checkbox with a date stamp for completion.
Use \o to mark an item as 'in progress' (seen as '[O] My Item')

Use \SPACE to go to the next open template element
(A template element is a HyperList item ending in an equal sign).

Use \L to convert the entire document to LaTeX.
Use \H to convert the entire document to HTML.
Use \T to convert the entire document to a basic TPP presentation.
```

For information on the Text Presentation Program (TPP), see: 
https://github.com/cbbrowne/tpp

### Encryption
```
Using \z encrypts the current line (including all sublevels if folded).
Using \Z encrypts the current file (all lines).
Using \x decrypts the current line.
Using \X decrypts the current file (all lines).
Using \z and \x can be used with visual ranges.
```

A dot file (file name starts with a "." such as .test.woim) is automatically
encrypted on save and decrypted on opening.

When running gVIM under Windows, encryption will spawn a DOS window where you
enter the password for encryption/decryption. This window may be hidden under
other windows.

### Syntax refresh

Syntax updated at start and every time you leave Insert mode, or you can press
"zx" to update the syntax. 

### Speeding up hyperlist.vim

You may speed up larger HyperLists by setting the the global variable
"disable_collapse" - add the following to your .vimrc:

  `let g:disable_collapse = 1`

If you want to disable or override these keymaps with your own, simply add to
your .vimrc file:

  `let g:HLDisableMapping = 1`

### Show/hide

You can show/hide words or regex patterns by using these keys and commands:
```
  zs    Show all lines containing word under cursor
  zh    Hide all lines containing word under cursor
  z0    Go back to normal HyperList folding
  :SHOW word/pattern
        Show lines containing either word or pattern
  :HIDE word/pattern
        Hide lines containing either word or pattern
        Pattern can be any regular expression
```

This functionality is useful for easily showing e.g. a specific tag or hash.
The functionality is taken from VIM script #1594 (thanks to Amit Sethi).

### Sort items

To sort a set of items at a specific indentation, visually select (V) the
items you want to sort (including all the children of those items) and press
\s and the items in the range will be alphabetically sorted - but only the
items on the same level/indentation as the first item selected. The sorted
items will keep their children. This is useful if parts of a HyperList are
numbered and you get the numbering out of sequence and want to resort them.
One caveat, the last line in the selection cannot be the very last line in the
document (there must be an item or an empty line below it).

### Add items as reminders to your Google Calendar

By doing :call CalendarAdd() all items containing a future date will be added
as reminders to your Google Calendar. If an item includes a time, the event is
added from that time with duration of 30 minutes.

This function requires gcalcli (https://github.com/insanum/gcalcli)

The function is mapped to \G to add events to the default calendar. The
default calendar is defined as b:calendar at the start of the HyperList.vim
script. To add the events to another calendar, do :call
CalendarAdd("yourcalendar")

The title of the calendar is the item in the HyperList without the date/time
tag. If there is no time tag for the item, an event is created at the start of
the date. If there is a time tag for the item, the event is created at that
time with the default duration (30 minutes). The description for the event is
the item and all its child items.

### More help

For this help and more, including the full HyperList definition/description, type:

  `:help hyperlist`

If you use tab completion after the "HyperList", you will find all the help
tags in the documentation.


Enjoy.

## Contact

Geir Isene <g@isene.com> ...explorer of free will... http://isene.org
