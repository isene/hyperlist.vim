" WOIM files are included for backward compatability (HyperList was earlier WOIM)
au BufRead,BufNewFile *.hl		set filetype=hyperlist
au BufRead,BufNewFile *.woim            set filetype=hyperlist

" Using code from openssl.vim by Noah Spurrier <noah@noah.org>
" dot-files (files starting with ".") gets auto en-/decryption
augroup hl_autoencryption
    autocmd!
    autocmd BufReadPre,FileReadPre	.*.hl set viminfo=
    autocmd BufReadPre,FileReadPre	.*.hl set noswapfile
    autocmd BufReadPre,FileReadPre	.*.hl set bin
    autocmd BufReadPre,FileReadPre     	.*.hl set cmdheight=2
    autocmd BufReadPre,FileReadPre     	.*.hl	set shell=/bin/sh
    autocmd BufReadPost,FileReadPost    .*.hl %!openssl bf -d -a 2>/dev/null
    autocmd BufReadPost,FileReadPost	.*.hl set nobin
    autocmd BufReadPost,FileReadPost    .*.hl set cmdheight&
    autocmd BufReadPost,FileReadPost	.*.hl set shell&
    autocmd BufReadPost,FileReadPost	.*.hl execute ":doautocmd BufReadPost ".expand("%:r")
    autocmd BufWritePre,FileWritePre	.*.hl set bin
    autocmd BufWritePre,FileWritePre	.*.hl set cmdheight=2
    autocmd BufWritePre,FileWritePre	.*.hl set shell=/bin/sh
    autocmd BufWritePre,FileWritePre    .*.hl %!openssl bf -e -a -salt 2>/dev/null
    autocmd BufWritePost,FileWritePost	.*.hl silent u
    autocmd BufWritePost,FileWritePost	.*.hl set nobin
    autocmd BufWritePost,FileWritePost	.*.hl set cmdheight&
    autocmd BufWritePost,FileWritePost	.*.hl set shell&
augroup END

augroup woim_autoencryption
    autocmd!
    autocmd BufReadPre,FileReadPre	.*.woim set viminfo=
    autocmd BufReadPre,FileReadPre	.*.woim set noswapfile
    autocmd BufReadPre,FileReadPre	.*.woim set bin
    autocmd BufReadPre,FileReadPre     	.*.woim set cmdheight=2
    autocmd BufReadPre,FileReadPre     	.*.woim	set shell=/bin/sh
    autocmd BufReadPost,FileReadPost    .*.woim %!openssl bf -d -a 2>/dev/null
    autocmd BufReadPost,FileReadPost	.*.woim set nobin
    autocmd BufReadPost,FileReadPost    .*.woim set cmdheight&
    autocmd BufReadPost,FileReadPost	.*.woim set shell&
    autocmd BufReadPost,FileReadPost	.*.woim execute ":doautocmd BufReadPost ".expand("%:r")
    autocmd BufWritePre,FileWritePre	.*.woim set bin
    autocmd BufWritePre,FileWritePre	.*.woim set cmdheight=2
    autocmd BufWritePre,FileWritePre	.*.woim set shell=/bin/sh
    autocmd BufWritePre,FileWritePre    .*.woim %!openssl bf -e -a -salt 2>/dev/null
    autocmd BufWritePost,FileWritePost	.*.woim silent u
    autocmd BufWritePost,FileWritePost	.*.woim set nobin
    autocmd BufWritePost,FileWritePost	.*.woim set cmdheight&
    autocmd BufWritePost,FileWritePost	.*.woim set shell&
augroup END

