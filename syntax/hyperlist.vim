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
