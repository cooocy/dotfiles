# zoxide 自动跳转, 本身通过 brew install zoxide 安装
zoxide init fish | source


if status is-interactive
    # Commands to run in interactive sessions can go here
    # source $HOME/.config/fish/functions/*.fish
    sleep 0.1
    macchina
end

