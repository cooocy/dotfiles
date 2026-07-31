# 个人 tools 入口
set -x MINE_TOOLS $HOME/firelink
set -x CODING_ROOT $HOME/CodingRoot

function fia
    $MINE_TOOLS/fia/fia.py $argv
end

function lk
    $MINE_TOOLS/leyndell-knight/leyndell_knight.py $argv
end

function token-usage
    $MINE_TOOLS/leyndell-grace/token_usage.py $argv
end

function tt-collector
    $CODING_ROOT/token-tide/cli/token_usage_collector.py $argv
end

function gitremote --description 'Open the remote origin in the browser' --argument-names browser
    # Usage: gitremote [chrome|opera|safari|browser app name]
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
    if test -n "$browser"
        switch $browser
            case chrome
                set browser 'Google Chrome'
            case opera
                set browser 'Opera Air'
            case safari
                set browser Safari
        end
        open -a "$browser" $remote
    else
        open $remote
    end
end
