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
    autocmd BufReadPost,FileReadPost    .*.hl,.*.woim %!openssl bf -d -a 2>/dev/null
    autocmd BufReadPost,FileReadPost		.*.hl,.*.woim setlocal nobin
    autocmd BufReadPost,FileReadPost    .*.hl,.*.woim setlocal cmdheight&
    autocmd BufReadPost,FileReadPost		.*.hl,.*.woim setlocal shell&
    autocmd BufReadPost,FileReadPost		.*.hl,.*.woim execute ":doautocmd BufReadPost ".expand("%:r")
    autocmd BufWritePre,FileWritePre		.*.hl,.*.woim setlocal bin
    autocmd BufWritePre,FileWritePre		.*.hl,.*.woim setlocal cmdheight=2
    autocmd BufWritePre,FileWritePre		.*.hl,.*.woim setlocal shell=/bin/sh
    autocmd BufWritePre,FileWritePre    .*.hl,.*.woim %!openssl bf -e -a -salt 2>/dev/null
    autocmd BufWritePost,FileWritePost	.*.hl,.*.woim silent u
    autocmd BufWritePost,FileWritePost	.*.hl,.*.woim setlocal nobin
    autocmd BufWritePost,FileWritePost	.*.hl,.*.woim setlocal cmdheight&
    autocmd BufWritePost,FileWritePost	.*.hl,.*.woim setlocal shell&
augroup END
" vim modeline {{{1
" vim: set sw=2 sts=2 et fdm=marker fillchars=fold\:\ :
