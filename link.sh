#!/bin/bash

DIRNAME=$(cd $(dirname $0) && pwd)

if [ ! -d $HOME/.config ]; then
  mkdir $HOME/.config
fi

rm -rf $HOME/.config/fish
ln -sfnv $DIRNAME/.config/fish $HOME/.config/fish

rm -rf $HOME/.config/karabiner
ln -sfnv $DIRNAME/.config/karabiner $HOME/.config/karabiner

rm -rf $HOME/.config/nodenv
ln -sfnv $DIRNAME/.config/nodenv $HOME/.config/nodenv

if [ ! -d $HOME/.ssh ]; then
  mkdir $HOME/.ssh
fi

ln -sfnv $DIRNAME/.ssh/config $HOME/.ssh/config

rm -rf $HOME/.vim
ln -sfnv $DIRNAME/.vim $HOME/.vim

ln -sfnv $DIRNAME/.editorconfig $HOME/.editorconfig
ln -sfnv $DIRNAME/.fixpackrc $HOME/.fixpackrc
ln -sfnv $DIRNAME/.gitconfig $HOME/.gitconfig
ln -sfnv $DIRNAME/.gitexclude $HOME/.gitexclude
ln -sfnv $DIRNAME/.hyper.js $HOME/.hyper.js
