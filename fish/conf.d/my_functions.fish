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
    sh $HOME/.dotfiles/git/generate_ignore.sh $argv
end

function gitop --description 'Open the remote origin in the browser'
    set -l remote (git remote get-url origin)
    if test $status -ne 0
        # Not a git repository
        return
    end
    # -r: regex; -q: quiet, otherwise fish will print the result
    if string match -rq "^git" $remote
        # git@github.com:cooocy/attre.git >> https://github.com/cooocy/attre
        set remote (string replace ':' '/' $remote)
        set remote (string replace 'git@' 'https://' $remote)
        set remote (string replace '.git' '' $remote)
    end
    if string match -rq "^http" $remote
        # https://github.com/cooocy/attre.git >> https://github.com/cooocy/attre
        set remote (string replace '.git' '' $remote)
    end
    open $remote
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