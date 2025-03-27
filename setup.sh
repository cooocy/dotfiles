#!/bin/sh


# ---------------------- zsh ----------------------

# install oh-my-zsh
#sh -c "$(curl -fsSL https://gitee.com/Devkings/oh_my_zsh_install/raw/master/install.sh)"

# install some custom omz plugins
#git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
#git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
#git clone --depth=1 https://github.com/paulirish/git-open.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/git-open



# --------------------- install some kits ---------------------
kits_home="$HOME/kits"

if [ ! -d "$kits_home" ]; then
    mkdir -p "$kits_home"
fi
git clone --depth=1 git@github.com:cooocy/fia.git $kits_home/fia




# --------------------- soft links ---------------------

ln -sf ~/.dotfiles/vim/vimrc         ~/.vimrc
ln -sf ~/.dotfiles/git/gitconfig     ~/.gitconfig
ln -sf ~/.dotfiles/zsh/zshrc         ~/.zshrc
ln -sf ~/.dotfiles/hyper/hyper.js    ~/.hyper.js

# Although -f is used, recursion will still occur if the target(~/.config/macchina) exists.
rm -rf ~/.config/macchina
ln -sf ~/.dotfiles/macchina          ~/.config/macchina

rm -rf ~/.config/lsd
ln -sf ~/.dotfiles/lsd               ~/.config/lsd

rm -rf ~/.config/neofetch
ln -sf ~/.dotfiles/neofetch          ~/.config/neofetch

rm -rf ~/.config/bat
ln -sf ~/.dotfiles/bat               ~/.config/bat
