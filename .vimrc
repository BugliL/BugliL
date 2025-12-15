" Set shift width to 4 spaces.
set shiftwidth=4

" Set tab dimension to 4
set tabstop=4

" Tab to spaces
set expandtab

" Enable syntax highliting
syntax on

" Show line numbers
set number

" Enable type file detection. Vim will be able to try to detect the type of file in use.
filetype on

" Enable plugins and load plugin for the detected file type.
filetype plugin on

" Load an indent file for the detected file type.
filetype indent on

" Set copy and paste to system clipboard.
" set clipboard+=unnamedplus

" Highlight cursor line underneath the cursor horizontally.
set cursorline

" Highlight cursor line underneath the cursor vertically.
set cursorcolumn

" Do not let cursor scroll below or above N number of lines when scrolling.
set scrolloff=24

" Do not wrap lines. Allow long lines to extend as far as the line goes.
set nowrap

" While searching though a file incrementally highlight matching characters as you type.
set incsearch

" Ignore capital letters during search.
set ignorecase

" Override the ignorecase option if searching for capital letters.
" This will allow you to search specifically for capital letters.
set smartcase

" Show partial command you type in the last line of the screen.
set showcmd

" Show the mode you are on the last line.
set showmode

" Show matching words during a search.
set showmatch

" Use highlighting when doing a search.
set hlsearch

" Set the commands to save in history default number is 20.
set history=1000

" Set listchars to show special characters to show tabs
set listchars=tab:→\ ,trail:·,extends:>,precedes:<,nbsp:%,space:·

" Set colorscheme
colorscheme retrobox

" Show vertical line at 80 and 120 characters
autocmd FileType markdown setlocal colorcolumn=80,120

" Set max text width to 80 characters when writing MARKDOWN/TEXT files and 
" wrap text when it exceed the space when writing and saving the file.
augroup markdown_settings
  autocmd!
  autocmd FileType markdown,text setlocal textwidth=80
  autocmd FileType markdown,text setlocal wrap
  autocmd FileType markdown,text setlocal formatoptions+=t
  autocmd BufWritePost *.md,*.txt setlocal wrap
augroup END

" Vim plug plugin section
call plug#begin()

Plug 'tpope/vim-sensible'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'github/copilot.vim'
Plug 'preservim/nerdtree'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'justinmk/vim-syntax-extra'
Plug 'vim-airline/vim-airline'
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}

call plug#end()


" Coc.nvim configuration
" Map leader to space
let g:coc_global_extensions = ['coc-json', 'coc-tsserver', 'coc-html', 'coc-css', 'coc-python', 'coc-vetur', 'coc-prettier']

" Setup NERDTree
nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <C-n> :NERDTree<CR>
nnoremap <C-t> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>
let NERDTreeShowHidden=0

" Open NERDTree automatically on Vim start if no files are specified
autocmd VimEnter * if argc() == 0 | NERDTree | wincmd p | endif

" Prevent closing if NERDTree is the only window
autocmd BufEnter * if winnr('$') == 1 && exists("b:NERDTree") | quit | endif

" Set NERDTree window to always be on the left
let g:NERDTreeWinPos = "left"

" Fix NERDTree width to 30 columns
autocmd VimEnter * NERDTree | set winfixwidth

" Nerdtree with vim-airline
let g:airline#extensions#tabline#enabled = 1


" coc-prettier
command! -nargs=0 Prettier :CocCommand prettier.forceFormatDocument
vmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

" FIXME: BROKEN
" Use <CR> to confirm completion.
" inoremap <expr> <cr> pumvisible() ? coc#_select_confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
