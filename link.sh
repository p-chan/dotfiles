#!/bin/bash

DIRNAME=$(cd $(dirname $0) && pwd)

if [ ! -d $HOME/.config ]; then
  mkdir $HOME/.config
fi

rm -rf $HOME/.config/fixpack
ln -sfnv $DIRNAME/home/.config/fixpack $HOME/.config/fixpack

rm -rf $HOME/.config/git
ln -sfnv $DIRNAME/home/.config/git $HOME/.config/git

rm -rf $HOME/.config/karabiner
ln -sfnv $DIRNAME/home/.config/karabiner $HOME/.config/karabiner

rm -rf $HOME/.config/nodenv
ln -sfnv $DIRNAME/home/.config/nodenv $HOME/.config/nodenv

rm -rf $HOME/.config/vim
ln -sfnv $DIRNAME/home/.config/vim $HOME/.config/vim

rm -rf $HOME/.ssh
ln -sfnv $DIRNAME/home/.ssh $HOME/.ssh

ln -sfnv $DIRNAME/home/.editorconfig $HOME/.editorconfig
ln -sfnv $DIRNAME/home/.hyper.js $HOME/.hyper.js
ln -sfnv $DIRNAME/home/.zprofile $HOME/.zprofile
ln -sfnv $DIRNAME/home/.zshenv $HOME/.zshenv
ln -sfnv $DIRNAME/home/.zshrc $HOME/.zshrc