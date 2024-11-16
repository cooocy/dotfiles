# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
export PATH=/opt/bin/:/opt/homebrew/bin/:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="robbyrussell"
# ZSH_THEME="half-life"
ZSH_THEME="pygmalion"
# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  # git
  gitignore
  git-open
  hitokoto
  rand-quote
  web-search
  z
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh
source $ZSH/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️ zsh 

# alias
alias dof="cd ~/.dotfiles"

alias ossh="python $HOME/.dotfiles/oss_helper/oss_helper.py"

alias kc="kubectl"
alias ls="lsd"
alias ll="lsd -l"
# Only list files.
alias lf="lsd --directory-only (.*|*)(^/)"
# Only list visiable files.
alias lfv="lsd --directory-only *(^/)"
# Only list hidden files.
alias lfh="lsd --directory-only .*(^/)"
alias mac="macchina"

# Source others if exist.
source $HOME/.dotfiles/zshrc_private
source $HOME/.dotfiles/zshrc_workspace

neofetch
