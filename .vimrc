set nocompatible

filetype plugin indent on
syntax enable

set number
set ruler
set hidden
set wildmenu
set showcmd
set showmatch
set laststatus=2

set ignorecase
set smartcase
set incsearch
set hlsearch

set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set smartindent

set backspace=indent,eol,start
set splitbelow
set splitright
set scrolloff=5
set mouse=a

if has('persistent_undo')
  let s:undo_dir = expand('~/.vim/undo')
  silent! call mkdir(s:undo_dir, 'p', 0700)
  if isdirectory(s:undo_dir)
    execute 'set undodir=' . fnameescape(s:undo_dir)
    set undofile
  endif
endif

if has('macunix')
  set clipboard=unnamed
elseif has('unix') && has('clipboard')
  set clipboard=unnamedplus
endif

augroup local_filetypes
  autocmd!
  autocmd FileType python setlocal tabstop=4 shiftwidth=4 softtabstop=4
  autocmd FileType go setlocal noexpandtab tabstop=4 shiftwidth=4
  autocmd FileType make setlocal noexpandtab tabstop=8 shiftwidth=8
  autocmd FileType markdown setlocal textwidth=0 wrap linebreak
augroup END
