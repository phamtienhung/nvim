lua print('Neovim started...')

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => General settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set mouse=a                 " Enable mouse
set expandtab               " Tab setting 
set tabstop=4               " Tab setting 
set shiftwidth=4            " Tab setting
set listchars=tab:\¦\       " Tab charactor 
set list
set foldmethod=syntax         
set foldnestmax=1
set foldlevelstart=3        "  
set number                  " Show line number
set ignorecase              " Enable case-sensitive 
set encoding=UTF-8

" Disable backup
set nobackup
set nowb
set noswapfile

" Optimize 
set synmaxcol=3000    "Prevent breaking syntax hightlight when string too long. Max = 3000"
set lazyredraw
au! BufNewFile,BufRead *.json set foldmethod=indent " Change foldmethod for specific filetype

syntax on

" Enable copying from vim to clipboard
if has('win32')
  set clipboard=unnamed  
else
  set clipboard=unnamedplus
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Key mappings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" 
" Resize pane
nmap <M-Right> :vertical resize +1<CR>    
nmap <M-Left> :vertical resize -1<CR>
nmap <M-Down> :resize +1<CR>
nmap <M-Up> :resize -1<CR>

" Search a hightlighted text
vnoremap // y/\V<C-R>=escape(@",'/\')<CR><CR>
nmap /\ :noh<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Plugin list
" (used with Vim-plug - https://github.com/junegunn/vim-plug)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Auto reload content changed outside
au CursorHold,CursorHoldI * checktime
au FocusGained,BufEnter * :checktime
autocmd FocusGained,BufEnter,CursorHold,CursorHoldI *
    \ if mode() !~ '\v(c|r.?|!|t)' && getcmdwintype() == ''
      \ | checktime 
    \ | endif
autocmd FileChangedShellPost *
    \ echohl WarningMsg 
    \ | echo "File changed on disk. Buffer reloaded."
    \ | echohl None

call plug#begin('~/AppData/Local/nvim/plugged')

" Theme
" Plug 'joshdick/onedark.vim'		       " Dark theme
Plug 'gruvbox-community/gruvbox'

" Easy motion 
Plug 'easymotion/vim-easymotion'

" File browser
Plug 'preservim/nerdTree'                     " File browser
Plug 'Xuyuanp/nerdtree-git-plugin'            " Git status
Plug 'ryanoasis/vim-devicons'                 " Icon
Plug 'unkiwii/vim-nerdtree-sync'              " Sync current file 
Plug 'jcharum/vim-nerdtree-syntax-highlight', {'branch': 'escape-keys'}

" File search
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }            " Fuzzy finder 
Plug 'junegunn/fzf.vim'

" Status bar
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Terminal
Plug 'voldikss/vim-floaterm'      

" Code intellisense
Plug 'neoclide/coc.nvim', {'branch': 'release'} " Language server protocol (LSP) 
Plug 'jiangmiao/auto-pairs'                   " Parenthesis auto
Plug 'alvan/vim-closetag'
" Plug 'mattn/emmet-vim'
Plug 'preservim/nerdcommenter'                " Comment code
Plug 'liuchengxu/vista.vim'                   " Function tag bar
Plug 'alvan/vim-closetag'                     " Auto close HTML/XML tag
  \ {
    \ 'do': 'yarn install '
            \ .'--frozen-lockfile '
            \ .'&& yarn build',
    \ 'branch': 'main'
  \ }
  
" Run after install :CocInstall coc-omnisharp
Plug 'OmniSharp/omnisharp-vim'


" Enable snippet => no need , use :CocInstall coc-snippets instead
" Plug 'sirver/ultisnips'
" Snippets are separated from the engine. Add this if you want them:
" Plug 'honza/vim-snippets'
" Snippet auto complete

Plug 'prabirshrestha/asyncomplete.vim'

" Code analysis
Plug 'dense-analysis/ale'

" Code syntax highlight
Plug 'sheerun/vim-polyglot'

" Debugging
Plug 'puremourning/vimspector'

" Fold 
" Plug 'tmhedberg/SimpylFold'

" Source code version control 
Plug 'tpope/vim-fugitive'                     " Git infomation 
Plug 'tpope/vim-rhubarb' 
Plug 'airblade/vim-gitgutter'                 " Git show changes 
Plug 'samoshkin/vim-mergetool'                " Git merge

call plug#end()

" colorscheme gruvbox

" Overwrite some color highlight 
if (has("autocmd"))
  augroup colorextend
    autocmd ColorScheme 
      \ * call onedark#extend_highlight("Comment",{"fg": {"gui": "#728083"}})
    autocmd ColorScheme 
      \ * call onedark#extend_highlight("LineNr", {"fg": {"gui": "#728083"}})
  augroup END
endif

" Use truecolor in the termi" Statusline
if has('termguicolors')
  set termguicolors
endif

" Other setting
for setting_file in split(glob(stdpath('config').'/settings/*.vim'))
  execute 'source' setting_file
endfor

set shell=powershell
set shellcmdflag=-command
set shellquote=\"
set shellxquote=


