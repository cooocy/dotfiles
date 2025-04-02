function dof
    cd ~/.dotfiles
end

function ossh
    python $HOME/.dotfiles/oss_helper/oss_helper.py $argv
end

function fia
    python $HOME/kits/fia/fia.py $argv
end

function ls
    lsd $argv
end

function ll
    lsd -l $argv
end

# function lsf
    # lsd --directory-only (.*|*)(^/)
# end

# function llf
    # lsd --directory-only (.*|*)(^/) -l
# end

function gitig
    sh $HOME/.dotfiles/git/generate_ignore.sh
end

function mac
    macchina $argv
end

function st
    open -a 'Sublime Text' $argv
end

function idea
    open -a 'IntelliJ IDEA Ultimate' $argv
end

function pycharm
    open -a 'PyCharm Professional Edition' $argv
end