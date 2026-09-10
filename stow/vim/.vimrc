" -----------------------------------------------------------------------------
" Core
" -----------------------------------------------------------------------------

syntax on
filetype plugin indent on

set termguicolors
set background=dark
set encoding=utf-8

set mouse=a
set hidden

set scrolloff=5
set sidescrolloff=5
set nowrap

" -----------------------------------------------------------------------------
" Line numbers
" -----------------------------------------------------------------------------

set number
set norelativenumber
set numberwidth=2
set signcolumn=no

" -----------------------------------------------------------------------------
" Editing
" -----------------------------------------------------------------------------

set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab

set autoindent
set smartindent
set backspace=indent,eol,start

" -----------------------------------------------------------------------------
" Search
" -----------------------------------------------------------------------------

set ignorecase
set smartcase
set incsearch
set hlsearch

" -----------------------------------------------------------------------------
" UI
" -----------------------------------------------------------------------------

set showmode
set showcmd
set noruler
set laststatus=0

" Open splits in natural directions
set splitright
set splitbelow

" -----------------------------------------------------------------------------
" Files
" -----------------------------------------------------------------------------

set nobackup
set nowritebackup
set noswapfile

" -----------------------------------------------------------------------------
" Clipboard
" -----------------------------------------------------------------------------

set clipboard=unnamedplus

" -----------------------------------------------------------------------------
" Monochrome theme
" -----------------------------------------------------------------------------

" Main text
highlight Normal       guifg=#c0c0c0 guibg=NONE

" Line numbers
highlight LineNr       guifg=#686868 guibg=NONE
highlight CursorLineNr guifg=#c0c0c0 guibg=NONE gui=bold

" Selection / search
highlight Visual       guifg=NONE    guibg=#3a3a3a
highlight Search       guifg=#121212 guibg=#a0a0a0
highlight IncSearch    guifg=#121212 guibg=#c0c0c0

" UI leftovers
highlight SignColumn   guibg=NONE
highlight VertSplit    guifg=#404040 guibg=NONE gui=NONE
highlight NonText      guifg=#404040 guibg=NONE
highlight EndOfBuffer  guifg=#121212 guibg=NONE

" -----------------------------------------------------------------------------
" Syntax
" -----------------------------------------------------------------------------

" Comments
highlight Comment      guifg=#858585 gui=italic

" Values
highlight Constant     guifg=#b0b0b0
highlight String       guifg=#b0b0b0
highlight Character    guifg=#b0b0b0
highlight Number       guifg=#b0b0b0
highlight Boolean      guifg=#b0b0b0

" Names
highlight Identifier   guifg=#c0c0c0
highlight Function     guifg=#c8c8c8

" Language structure
highlight Statement    guifg=#b8b8b8 gui=bold
highlight Conditional  guifg=#b8b8b8
highlight Repeat       guifg=#b8b8b8
highlight Keyword      guifg=#b8b8b8
highlight Type         guifg=#b8b8b8

" Operators / special syntax
highlight Operator     guifg=#a0a0a0
highlight PreProc      guifg=#a0a0a0
highlight Special      guifg=#a0a0a0

" Errors / TODO
highlight Error        guifg=#a87070 guibg=NONE
highlight Todo         guifg=#c0c0c0 guibg=#303030 gui=bold

" -----------------------------------------------------------------------------
" Mappings
" -----------------------------------------------------------------------------

" Clear search highlighting
nnoremap <Esc> :nohlsearch<CR>

" Move between splits
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
