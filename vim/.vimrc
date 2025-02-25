" ~~~ new (post-switching-to-neovim) vimrc ~~~

" i'm considering maintaining both a vimrc and a neovim config. the neovim
" config might actually source the vim config so that i don't have as much
" duplication. this can be accomplished with vim.cmd.source("~/.vimrc")

" the vimconfig uses no plugins and is only a single file. vim should be as
" fast and minimal as possible. neovim is for plugins (still minimal


" source otherfile.vim

let mapleader = "<space>"
nnoremap <space>/ :nohlsearch<CR>
color slate
syntax on
set number
set ignorecase smartcase
set hlsearch incsearch nowrapscan
set wildmenu
set nowrap
set textwidth=80
set colorcolumn=+0 " +0 syncs colorcolumn with textwidth
set scrolloff=3 sidescrolloff=3
set formatoptions=jcrq " this is always in flux but i guess it's fine for now
set cursorline
set breakindent
set noswapfile
set autoindent
set laststatus=1
set list lcs=lead:·,trail:·,tab:>-
	" test tab here
    " test leading/trailing space here  
set splitbelow splitright
" allow viewing other buffers without saving the current buffer " (neovim
" enables this by default, i don't know why vim doesn't)
set hidden
" backspace should work as expected (another of nvim's better defaults)
" 'eol'    : lets you backspace onto the previous line
" 'start'  : lets you backspace characters that weren't typed during
"            this current insert session (i think)
" 'indent' : lets you backspace indentation that was created by autoindent
set backspace=indent,eol,start

" user command and autocommand examples (i prefer lua but it's good to know how to do this from vimscript)
command SetPreferredIndentSettings set shiftwidth=4 tabstop=4 softtabstop=4 expandtab
SetPreferredIndentSettings
" long autocmd syntax
autocmd BufEnter "*" {
    " commands go here
    " they can span multiple lines
}
" short autocmd syntax
au bufnew * SetPreferredIndentSettings
