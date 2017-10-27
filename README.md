# hyperlist.vim
This VIM plugin makes it easy to create and manage HyperLists using VIM

---------------------------------------------------------------------------

GENERAL INFORAMTION ABOUT THE VIM PLUGIN FOR HYPERLISTS (version 2.3.8)

HyperLists are used to describe anything - any state, item(s), pattern,
action, process, transition, program, instruction set etc. So, you can use
it as an outliner, a ToDo list handler, a process design tool, a data
modeler, or any other way you want to describe something.

This plugin does both highlighting and various automatic handling of
HyperLists, like collapsing lists or parts of lists in a sophisticated
way.

The plugin incorporates encryption. You can encrypt any part of a
HyperList or take advantage of the autoencryption feature by making the
HyperList a dot file - i.e. prefixing the file name with a dot (such as
".test.hl"). You can use this plugin to make a password safe.

As you most certainly have already done, to install the HyperList plugin
for VIM, dowmload woim.vba and do:

  vim hyperlist.vba
  :so %
  :q

You will then discover that this file (README_HyperList will appear in the
VIM directory, while the documentation will be placed in the "doc"
subdirectory, the HyperList plugin will be placed in the "syntax"
subdirectory.  A HyperList filetype detection file is placed in the
"ftdetect" subdirectory.

From now on all files with the ".hl" file extension will be treated as a
HyperList file, syntax highlighted corrrectly and you can use all the neat
HyperList functionality for VIM.

To use HyperLists within other file types (other than ".hl"), add the
following to those syntax files:

  syn include @HL ~/.vim/syntax/hyperlist.vim
  syn region HLSnip matchgroup=Snip start="HLstart" end="HLend" contains=@HL
  hi link Snip SpecialComment

The documentation file contains all of the HyperList definition and is
part of the full specification for HyperList as found here:

  http://isene.me/hyperlist/


INSTRUCTIONS

Use tabs for indentation.

Use <SPACE> to toggle one fold.
Use \0 to \9, \a, \b, \c, \d, \e, \f to show up to 15 levels expanded.

<leader># or <leader>an toggles autonumbering of new items (the previous
item must be numbered for the next item to be autonumbered). An item is
indented to the right with <c-t>, adding one level of numbering. An item
is indented to the left with <c-d>, removing one level of numbering and
increasing the number by one.

As a sort of "presentation mode", you can traverse a WOIM list by using
g<DOWN> or g<UP> to view only the current line and its ancestors.
An alternative is <leader><DOWN> and <leader><UP> to open more levels down.

Use "gr" (without the quotation marks, signifies "Goto Ref") or simply
press the "Enter" ("<CR>") key while the cursor is on a HyperList
reference to jump to that destination in a HyperList. Use "n" after a "gr"
to verify that the reference destination is unique. A reference can be in
the list or to a file by the use of <file:/pathto/filename>,

Whenever you jump to a reference in this way, the mark "'" is set at the
point you jumped from so that you may easily jump back by hitting "''"
(single quoutes twice). 

Use "gf" to open the file under the cursor. Graphic files are opened in
"feh", pdf files in "zathura" and MS/OOO docs in "LibreOffice". Other
filetypes are opened in VIM for editing. All this can be changed by
editing the function OpenFile() in the file "hyperlist.vim".

Use <leader>u to toggle underlining of Transitions, States or no underlining.

Use <leader>v to add a checkbox at start of item or to toggle a checkbox.
Use <leader>V to add/toggle a checkbox with a date stamp for completion.

Use <leader><SPACE> to go to the next open template element
(A template element is a WOIM item ending in an equal sign).

Use <leader>L to convert the entire document to LaTaX.
Use <leader>H to convert the entire document to HTML.

Use <leader>z encrypts the current line (including all sublevels if folded).
Use <leader>Z encrypts the current file (all lines).
Use <leader>x decrypts the current line.
Use <leader>X decrypts the current file (all lines).
<leader>z and <leader>x can be used with visual ranges.

A dot file (file name starts with a "." such as .test.woim) is
automatically encrypted on save and decrypted on opening.

Syntax updated at start and every time you leave Insert mode, or you can
press "zx" to update the syntax. 

You may speed up larger HyperLists by setting the the global variable
"disable_collapse" - add the following to your .vimrc:

  let "g:disable_collapse" = 1

If you want to disable or override these keymaps with your own, simply add
to your .vimrc file:

  let "g:HLDisableMapping" = 1

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

For this help and more, including the full HyperList definition/description, type 

  :help HyperList

If you use tab completion after the "HyperList", you will find all the help
tags in the documentation.


Enjoy.


Geir Isene <g@isene.com>
...explorer of free will
   http://isene.com
