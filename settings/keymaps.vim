nnoremap <C-Left> :tabprevious<CR>
nnoremap <C-Right> :tabnext<CR>
inoremap <expr> <Tab> pumvisible() ? coc#_select_confirm() : "<Tab>"
inoremap jj <Esc>   """ jj key is <Esc> setting
