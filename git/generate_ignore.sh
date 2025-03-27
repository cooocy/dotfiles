#!/bin/sh

file_name="$HOME/.dotfiles/git/$1.gitignore"
echo "Generate gitignore by: $file_name"
cat $file_name > .gitignore