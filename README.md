# hyperlist.vim
This VIM plugin makes it easy to create and manage HyperLists using VIM

---------------------------------------------------------------------------

## GENERAL INFORMATION ABOUT THE VIM PLUGIN FOR HYPERLISTS (version 2.4.1)

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
* Export a HyperList to HTML, LaTeX or TPP formats
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

[![HyperList screencast](https://isene.org/assets/videos/screencast.jpg)](https://isene.org/assets/videos/HyperListVIM.mp4)

GVIM users can enjoy the commands organized in a menu with submenus.

### Installation

The easiest way to install this VIM plugin is to use [Vizardry](https://github.com/ardagnir/vizardry). Simply do

```
:Invoke hyperlist
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

Use SPACE to toggle one fold.
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
opened in VIM for editing. All this can be changed by editing the file
handlers at the top of the hyperlist.vim script in your VIM syntax folder.

### Simple tricks
```
Use \u to toggle underlining of Transitions, States or no underlining.

Use \v to add a checkbox at start of item or to toggle a checkbox.
Use \V to add/toggle a checkbox with a date stamp for completion.

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

  `let "g:disable_collapse" = 1`

If you want to disable or override these keymaps with your own, simply add to
your .vimrc file:

  `let "g:HLDisableMapping" = 1`

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
