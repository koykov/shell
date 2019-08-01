#!/bin/sh

mkdir -p ~/bin
wget --no-check-certificate -O ~/bin/git-prompt.sh https://raw.github.com/git/git/master/contrib/completion/git-prompt.sh
echo "source ~/bin/git-prompt.sh" >> ~/.bashrc
echo "PS1='\[\e[1;32m\][\u\[\e[m\]@\[\e[1;33m\]\h\[\e[1;34m\] \w]\[\e[1;32m\]\$(__git_ps1) \[\e[1;36m\]$\[\e[1;37m\] '" >> ~/.bashrc
source ~/.bashrc
