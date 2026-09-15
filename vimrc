" ~/.vimrc — Vim 9.1

" ---------- General ----------
set nocompatible              " Vim mode, not vi
filetype plugin indent on     " Filetype detection, plugins, indent rules
syntax on                     " Syntax highlighting
set encoding=utf-8
set fileformats=unix,dos
set hidden                    " Switch buffers without saving
set history=1000
set undolevels=1000
set autoread                  " Reload files changed outside Vim
set backspace=indent,eol,start
set clipboard^=unnamed,unnamedplus   " Use system clipboard if available
set mouse=a                   " Mouse support in all modes
set ttimeoutlen=50            " Faster Esc response
set updatetime=300
set nobackup
set nowritebackup
set noswapfile

" Persistent undo across sessions
if has('persistent_undo')
  silent !mkdir -p ~/.vim/undo
  set undodir=~/.vim/undo
  set undofile
endif

" ---------- Plugins (vim-plug) ----------
" Install:  :PlugInstall     Update: :PlugUpdate     Remove unused: :PlugClean
call plug#begin('~/.vim/plugged')

" LSP client + auto-installer for language servers
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'
" Async completion popup, fed by LSP
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
" Fuzzy finder (files, buffers, ripgrep, symbols)
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
" Function / symbol outline sidebar (uses vim-lsp)
Plug 'liuchengxu/vista.vim'
" Editing helpers
Plug 'tpope/vim-commentary'       " gcc / gc{motion} to comment
Plug 'tpope/vim-surround'         " cs"' ds( ysiw)
Plug 'tpope/vim-repeat'
Plug 'jiangmiao/auto-pairs'
Plug 'airblade/vim-gitgutter'     " Git diff signs in the gutter
Plug 'rust-lang/rust.vim'         " Rust syntax + :RustFmt

call plug#end()

" ---------- vim-lsp ----------
let g:lsp_diagnostics_enabled = 1
let g:lsp_diagnostics_echo_cursor = 1          " Show error under cursor in cmdline
let g:lsp_diagnostics_virtual_text_enabled = 0 " Set 1 for inline error text
let g:lsp_diagnostics_signs_enabled = 1
let g:lsp_diagnostics_float_cursor = 1
let g:lsp_document_highlight_enabled = 1       " Highlight other uses of symbol
let g:lsp_semantic_enabled = 0
let g:lsp_format_sync_timeout = 1000
let g:lsp_diagnostics_signs_error   = {'text': 'E'}
let g:lsp_diagnostics_signs_warning = {'text': 'W'}
let g:lsp_diagnostics_signs_hint    = {'text': 'H'}
let g:lsp_diagnostics_signs_information = {'text': 'I'}

" Servers auto-installed by vim-lsp-settings with :LspInstallServer
"   C/C++  -> clangd          Python -> pylsp
"   Rust   -> rust-analyzer   Go     -> gopls
let g:lsp_settings = {
      \ 'clangd': {'cmd': ['clangd', '--background-index', '--clang-tidy', '--header-insertion=never']},
      \ 'pylsp':  {'workspace_config': {'pylsp': {'plugins': {
      \     'pycodestyle': {'maxLineLength': 120}}}}},
      \ 'rust-analyzer': {'initialization_options': {'cargo': {'features': 'all'}}},
      \ 'gopls':  {'initialization_options': {'usePlaceholders': v:true, 'staticcheck': v:true}},
      \ }
let g:lsp_settings_filetype_python = ['pylsp']
let g:lsp_settings_filetype_c   = ['clangd']
let g:lsp_settings_filetype_cpp = ['clangd']

" Keymaps only active in buffers with an LSP server attached
function! s:on_lsp_buffer_enabled() abort
  setlocal omnifunc=lsp#complete
  setlocal signcolumn=yes
  if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif  " Ctrl-] uses LSP

  nmap <buffer> gd         <plug>(lsp-definition)
  nmap <buffer> gD         <plug>(lsp-declaration)
  nmap <buffer> gi         <plug>(lsp-implementation)
  nmap <buffer> gy         <plug>(lsp-type-definition)
  nmap <buffer> gr         <plug>(lsp-references)
  nmap <buffer> gs         <plug>(lsp-document-symbol-search)
  nmap <buffer> gS         <plug>(lsp-workspace-symbol-search)
  nmap <buffer> K          <plug>(lsp-hover)
  nmap <buffer> <leader>rn <plug>(lsp-rename)
  nmap <buffer> <leader>ca <plug>(lsp-code-action)
  nmap <buffer> <leader>f  <plug>(lsp-document-format)
  vmap <buffer> <leader>f  <plug>(lsp-document-range-format)
  nmap <buffer> [d         <plug>(lsp-previous-diagnostic)
  nmap <buffer> ]d         <plug>(lsp-next-diagnostic)
  nmap <buffer> <leader>d  <plug>(lsp-document-diagnostics)
  nmap <buffer> <leader>ch <plug>(lsp-call-hierarchy-incoming)
  nmap <buffer> <leader>sh <plug>(lsp-signature-help)
  " Scroll the hover/diagnostic popup
  nnoremap <buffer> <expr><C-f> lsp#scroll(+4)
  nnoremap <buffer> <expr><C-b> lsp#scroll(-4)

  " Format on save for languages with reliable formatters
  autocmd! BufWritePre <buffer>
  if index(['rust', 'go'], &filetype) >= 0
    autocmd BufWritePre <buffer> call execute('LspDocumentFormatSync')
  endif
endfunction

augroup lsp_install
  autocmd!
  autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

" ---------- asyncomplete ----------
let g:asyncomplete_auto_popup = 1
let g:asyncomplete_auto_completeopt = 0
set completeopt=menuone,noinsert,noselect,preview
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <CR>    pumvisible() ? asyncomplete#close_popup() : "\<CR>"

" ---------- fzf ----------
let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.8 } }
let g:fzf_preview_window = ['right:50%', 'ctrl-/']
nnoremap <leader>ff :Files<CR>
nnoremap <leader>fg :GFiles<CR>
nnoremap <leader>fb :Buffers<CR>
nnoremap <leader>fr :Rg<CR>
nnoremap <leader>fw :Rg <C-r><C-w><CR>
nnoremap <leader>fl :BLines<CR>
nnoremap <leader>fh :History<CR>
nnoremap <leader>ft :BTags<CR>

" ---------- vista (symbol outline) ----------
let g:vista_default_executive = 'vim_lsp'
let g:vista_sidebar_width = 35
let g:vista_echo_cursor = 0
let g:vista#renderer#enable_icon = 0
nnoremap <leader>o  :Vista!!<CR>
nnoremap <leader>fs :Vista finder vim_lsp<CR>

" ---------- gitgutter ----------
let g:gitgutter_map_keys = 0
nmap ]h <Plug>(GitGutterNextHunk)
nmap [h <Plug>(GitGutterPrevHunk)
nmap <leader>hp <Plug>(GitGutterPreviewHunk)
nmap <leader>hu <Plug>(GitGutterUndoHunk)

" ---------- rust.vim ----------
let g:rustfmt_autosave = 0     " LSP handles formatting

" ---------- Jump between functions (all languages) ----------
" [[ / ]] go to previous / next function start. C-family already works
" natively; these regexes cover Python, Rust and Go.
augroup function_motions
  autocmd!
  autocmd FileType python nnoremap <buffer><silent> ]] :call search('^\s*\(async \)\?def \|^\s*class ', 'W')<CR>
  autocmd FileType python nnoremap <buffer><silent> [[ :call search('^\s*\(async \)\?def \|^\s*class ', 'bW')<CR>
  autocmd FileType rust   nnoremap <buffer><silent> ]] :call search('^\s*\(pub\(([^)]*)\)\?\s\+\)\?\(async \)\?\(unsafe \)\?fn \|^\s*impl\>\|^\s*\(pub \)\?\(struct\|enum\|trait\) ', 'W')<CR>
  autocmd FileType rust   nnoremap <buffer><silent> [[ :call search('^\s*\(pub\(([^)]*)\)\?\s\+\)\?\(async \)\?\(unsafe \)\?fn \|^\s*impl\>\|^\s*\(pub \)\?\(struct\|enum\|trait\) ', 'bW')<CR>
  autocmd FileType go     nnoremap <buffer><silent> ]] :call search('^func \|^type ', 'W')<CR>
  autocmd FileType go     nnoremap <buffer><silent> [[ :call search('^func \|^type ', 'bW')<CR>
augroup END

" ---------- UI ----------
set number                    " Line numbers
set relativenumber            " Relative numbers (easier for motions)
set cursorline                " Highlight current line
set showcmd                   " Show partial commands
set showmatch                 " Highlight matching brackets
set ruler
set laststatus=2              " Always show status line
set wildmenu                  " Command-line completion menu
set wildmode=longest:full,full
set wildignore+=*.o,*.pyc,*.swp,*/.git/*,*/node_modules/*
set scrolloff=5               " Keep 5 lines visible above/below cursor
set sidescrolloff=5
set signcolumn=yes
set splitbelow                " New horizontal splits below
set splitright                " New vertical splits right
set shortmess+=c
set noerrorbells
set visualbell t_vb=
set list                      " Show invisible characters
set listchars=tab:»\ ,trail:·,nbsp:␣,extends:›,precedes:‹
set colorcolumn=80,120
set termguicolors             " True color (comment out if colors look wrong)
set background=dark
colorscheme habamax

" ---------- Search ----------
set incsearch                 " Search as you type
set hlsearch                  " Highlight matches
set ignorecase                " Case-insensitive...
set smartcase                 " ...unless the pattern has uppercase

" ---------- Indentation ----------
set expandtab                 " Spaces instead of tabs
set tabstop=4
set shiftwidth=4
set softtabstop=4
set autoindent
set smartindent
set shiftround                " Round indent to multiple of shiftwidth

" Per-language overrides
augroup indent_overrides
  autocmd!
  autocmd FileType make       setlocal noexpandtab
  autocmd FileType go         setlocal noexpandtab tabstop=4 shiftwidth=4
  autocmd FileType yaml,json,html,css,javascript,typescript,sh,vim
        \ setlocal tabstop=2 shiftwidth=2 softtabstop=2
augroup END

" ---------- Status line ----------
set statusline=
set statusline+=\ %f                        " File path
set statusline+=\ %m%r%h%w                  " Modified / readonly / help / preview
set statusline+=%=                          " Right side
set statusline+=\ %y                        " Filetype
set statusline+=\ [%{&fileencoding?&fileencoding:&encoding}]
set statusline+=\ [%{&fileformat}]
set statusline+=\ %l:%c\ %p%%\              " Line:col percent

" ---------- Key mappings ----------
let mapleader = " "           " Space as leader key

" Clear search highlight
nnoremap <silent> <Esc><Esc> :nohlsearch<CR>
" Save / quit
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
" Buffers
nnoremap <leader>bn :bnext<CR>
nnoremap <leader>bp :bprevious<CR>
nnoremap <leader>bd :bdelete<CR>
" Window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
" Resize windows
nnoremap <silent> <C-Up>    :resize +2<CR>
nnoremap <silent> <C-Down>  :resize -2<CR>
nnoremap <silent> <C-Left>  :vertical resize -2<CR>
nnoremap <silent> <C-Right> :vertical resize +2<CR>
" Move lines up/down in visual mode
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv
" Keep selection after indenting
vnoremap < <gv
vnoremap > >gv
" Keep cursor centered when jumping
nnoremap n nzzzv
nnoremap N Nzzzv
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz
" Paste without overwriting the register
xnoremap <leader>p "_dP
" Toggle paste mode / line numbers / list chars
set pastetoggle=<F2>
nnoremap <F3> :set number! relativenumber!<CR>
nnoremap <F4> :set list!<CR>
" Quickfix / location list (LSP references land here)
nnoremap [q :cprevious<CR>
nnoremap ]q :cnext<CR>
nnoremap <leader>co :copen<CR>
nnoremap <leader>cc :cclose<CR>
" Edit / reload vimrc
nnoremap <leader>ev :edit $MYVIMRC<CR>
nnoremap <leader>sv :source $MYVIMRC<CR>

" ---------- netrw (built-in file browser) ----------
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_winsize = 25
nnoremap <leader>e :Explore<CR>

" ---------- Autocommands ----------
augroup general
  autocmd!
  " Strip trailing whitespace on save (except for markdown/diff)
  autocmd BufWritePre * if &ft !~# 'markdown\|diff' | %s/\s\+$//e | endif
  " Return to last edit position when opening a file
  autocmd BufReadPost *
        \ if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
  " Auto-resize splits when the terminal resizes
  autocmd VimResized * wincmd =
  " Close some windows with q
  autocmd FileType help,qf nnoremap <buffer> q :close<CR>
augroup END
