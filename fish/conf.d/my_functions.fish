# 个人 tools 入口
set -x MINE_TOOLS $HOME/firelink

function fia
    $MINE_TOOLS/fia/.venv/bin/python $MINE_TOOLS/fia/fia.py $argv
end

function lk
    $MINE_TOOLS/leyndell-knight/.venv/bin/python $MINE_TOOLS/leyndell-knight/leyndell_knight.py $argv
end

function token_usage
    $MINE_TOOLS/leyndell-grace/.venv/bin/python $MINE_TOOLS/leyndell-grace/token_usage.py $argv
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

# cc — 在 claude-code 工作区里启动 claude, 临时挂代理
# 用法: cc              # 进入交互模式
#      cc -p "xxx"     # 透传参数给 claude
function cc
  # 进入 claude-code 项目目录; 用 pushd 是为了函数退出时能 popd 回到原目录
  pushd /Users/cooocy/QuickRoom/claude-code

  # set -lx：local + exported
  # local  = 变量只活在本函数作用域, 函数返回后自动消失
  # export = 导出给 claude 子进程使用
  # 好处: 不污染当前 shell (不像 bash 的 export 会长期挂着)
  set -lx http_proxy  http://127.0.0.1:1087
  set -lx https_proxy http://127.0.0.1:1087
  set -lx ALL_PROXY   socks5://127.0.0.1:1080

  # $argv: 透传函数参数给 claude
  claude $argv

  # 回到调用前的目录
  popd
end
