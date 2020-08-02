" WOIM files are included for backward compatability (HyperList was earlier WOIM)
au BufRead,BufNewFile *.hl,*.woim						  set filetype=hyperlist

" Using code from openssl.vim by Noah Spurrier <noah@noah.org>
" dot-files (files starting with ".") gets auto en-/decryption
augroup hl_autoencryption
    autocmd!
    autocmd BufReadPre,FileReadPre			.*.hl,*.woim set viminfo=
    autocmd BufReadPre,FileReadPre			.*.hl,*.woim set noswapfile
    autocmd BufReadPre,FileReadPre			.*.hl,*.woim set bin
    autocmd BufReadPre,FileReadPre     	.*.hl,*.woim set cmdheight=2
    autocmd BufReadPre,FileReadPre     	.*.hl,*.woim set shell=/bin/sh
    autocmd BufReadPost,FileReadPost    .*.hl,*.woim %!openssl bf -pbkdf2 -d -a 2>/dev/null
    autocmd BufReadPost,FileReadPost		.*.hl,*.woim set nobin
    autocmd BufReadPost,FileReadPost    .*.hl,*.woim set cmdheight&
    autocmd BufReadPost,FileReadPost		.*.hl,*.woim set shell&
    autocmd BufReadPost,FileReadPost		.*.hl,*.woim execute ":doautocmd BufReadPost ".expand("%:r")
    autocmd BufWritePre,FileWritePre		.*.hl,*.woim set bin
    autocmd BufWritePre,FileWritePre		.*.hl,*.woim set cmdheight=2
    autocmd BufWritePre,FileWritePre		.*.hl,*.woim set shell=/bin/sh
    autocmd BufWritePre,FileWritePre    .*.hl,*.woim %!openssl bf -pbkdf2 -e -a -salt 2>/dev/null
    autocmd BufWritePost,FileWritePost	.*.hl,*.woim silent u
    autocmd BufWritePost,FileWritePost	.*.hl,*.woim set nobin
    autocmd BufWritePost,FileWritePost	.*.hl,*.woim set cmdheight&
    autocmd BufWritePost,FileWritePost	.*.hl,*.woim set shell&
augroup END
