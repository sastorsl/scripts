#!/bin/zsh
# 06.10.2023, sastorsl
# Ensure my custom zsh config is added to oh-my-zsh
test -d ~/.oh-my-zsh && test -d ~/.oh-my-zsh/custom || { echo "ERROR ~/.oh-my-zsh/custom is missing" ; exit 1 }
ln -v -fs ~/bin/zshrc-custom.zsh ~/.oh-my-zsh/custom/
