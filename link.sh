#!/bin/bash

DIRNAME=$(cd $(dirname $0) && pwd)

if [ ! -d $HOME/.config ]; then
  mkdir $HOME/.config
fi

rm -rf $HOME/.config/fish
ln -sfnv $DIRNAME/.config/fish $HOME/.config/fish

rm -rf $HOME/.config/fixpack
ln -sfnv $DIRNAME/.config/fixpack $HOME/.config/fixpack

rm -rf $HOME/.config/git
ln -sfnv $DIRNAME/.config/git $HOME/.config/git

rm -rf $HOME/.config/karabiner
ln -sfnv $DIRNAME/.config/karabiner $HOME/.config/karabiner

rm -rf $HOME/.config/nodenv
ln -sfnv $DIRNAME/.config/nodenv $HOME/.config/nodenv

rm -rf $HOME/.config/vim
ln -sfnv $DIRNAME/.config/vim $HOME/.config/vim

rm -rf $HOME/.ssh
ln -sfnv $DIRNAME/.ssh $HOME/.ssh

ln -sfnv $DIRNAME/.editorconfig $HOME/.editorconfig
ln -sfnv $DIRNAME/.hyper.js $HOME/.hyper.js
