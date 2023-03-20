#!/bin/bash

# Link .vimrc
# ln -sf $PWD/vimrc ~/.vimrc
ln -sf $PWD/nvim ~/.config/nvim/init.vim

# link gitignore
ln -sf $PWD/gitignore ~/.config/git/ignore
git config --global core.excludesfile ~/.config/git/ignore

# # create undodir
# if [[ ! -d ~/.vim/undodir ]]
# then
# 	mkdir -p ~/.vim/undodir
# fi

# install vim-plug

# if [[ ! -f ~/.vim/autoload/plug.vim ]]
# then
# 	curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
# fi
