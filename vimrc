" install vim-plug if not installed
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" plugin directory, don't use standard Vim names like 'plugin'
call plug#begin('~/.vim/plugged')

" plugins go here
" ---------------

" highlights code problems: https://github.com/w0rp/ale
" Plug 'w0rp/ale' " do i need this if I have jedi?

" adds a status bar: https://github.com/itchyny/lightline.vim
Plug 'itchyny/lightline.vim'

" distraction free writing: https://github.com/junegunn/goyo.vim
Plug 'junegunn/goyo.vim'

" for python auto completion: https://github.com/davidhalter/jedi-vim
Plug 'davidhalter/jedi-vim'

" find a markdown plugin 

" search using fzf
Plug 'junegunn/fzf.vim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }

" Initialize plugin system
call plug#end()
