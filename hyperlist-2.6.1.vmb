" Vimball Archiver by Charles E. Campbell
UseVimball
finish
syntax/hyperlist.vim	[[[1
2256
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
" Version:    2.6.1 - compatible with the HyperList definition v. 2.6
" Modified:   2025-01-04
" Changes:    Major performance and feature enhancements (see doc for details)

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
" nnoremap <leader>eM       :call MarkdownConversion()<CR>
" nnoremap <leader>eH       :call HTMLConversionModern()<CR>
" nnoremap <leader>eL       :call LaTeXConversionModern()<CR>

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
doc/hyperlist.txt	[[[1
1606
*hyperlist.txt*   The VIM plugin for HyperList (version 2.6.1, 2025-01-04)
 
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
doc/HyperListTutorialAndTestSuite.hl	[[[1
158
HyperList Test Suite (V1.0); Press '\f' to uncollapse this whole HyperList
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
			Press '\L' to convert this whole HyperList to HTML format
		Export to TPP
			tpp: <https://github.com/cbbrowne/tpp>
			You can convert this whole HyperList to the TPP presentation format and save the output to "test.tpp"
			Pressing 'u' will undo the conversion, but you need to do ':set ft=hyperlist' to set the right filetype again
			Press '\T' to convert this whole HyperList to HTML format
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

