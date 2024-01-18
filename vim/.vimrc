" (this file has kinda died since switching to neovim)

" Note: to reference this file in your local vimrc, add
" source /path/to/this/file

" Note: to disable a setting, add a "no" to the beginning of it.
" For example, the following line disables swapfiles:
" set noswapfile

" The internet says use 'filetype indent on' instead of cindent/smartindent
set nosmartindent
set nocindent
" Use indentation rules based on filetype
filetype indent on

" 'tabstop' is simply the width in characters of a tab byte
set tabstop=4

" 'shiftwidth' sets the number of characters to shift when using << or >>
set shiftwidth=4

" Copy the current line's indentation to the next line
set autoindent

" Use spaces instead of tabs
set expandtab

" When pressing backspace on a piece of indentation, delete an entire unit
" of indentation instead of just a single space.
set smarttab

" When scrolling off the edge of the screen, pad with 'scrolloff' lines
set scrolloff=5

" Big vertical red line at 100 characters
set colorcolumn=100
highlight ColorColumn ctermbg=darkred

" Highlight text matching current search, even before completing the search
set incsearch

" If a search query includes caps then searching is case-sensitive, else it's case-insensitive
set smartcase

" Pressing "backspace" should work as you expect. Here's some more info:
" 'eol'    : lets you backspace onto the previous line
" 'start'  : lets you backspace characters that weren't typed during
"            this current insert session (i think)
" 'indent' : lets you backspace indentation that was created by autoindent
" set backspace=indent,eol,start
set backspace=eol,start

" When splitting horizontally (the default way for :sp), put the new window below
set splitbelow
" When splitting vertically, put the new window on the right
set splitright

" Wrap text after 100 characters
set textwidth=100

" These are self-explanatory enough (or just :h for help)
syntax on
color slate
set showcmd
set ruler
set title
set number
set relativenumber
set cursorline

" --------------------------------
" ----- Remappings and stuff -----
" --------------------------------

" Custom leader key
let mapleader = "\<Space>"

" Save file
map <Leader>w :<CR>

" Shorter splitting keybinds
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" comment macro in normal mode (marker is 'c' for 'comment')
map <C-_> mc^i// <Esc>`c3l
" comment macro in insert mode
imap <C-_> <esc><C-_>li

" Alternate tab switching
nnoremap <Leader><Tab> gt

" Duplicate vscode vsplit keyboard shortcut. (Same as vim's ctrl+w v)
nnoremap <C-\> :vs<CR>

" Easily open terminal in vsplit
nnoremap <Leader>t :vert term<CR>

" Easier :Explore command to access file explorer
map <Leader>e :Ex<CR>
