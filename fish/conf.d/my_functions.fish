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

# ── Happ 代理 ─────────────────────────────────────────────
# 两层代理模型：
#   happ-env on/off   开关代理环境变量（终端工具层，本会话，免 sudo）
#   happ-sys on/off   开关 macOS 系统代理（GUI 应用层，需 sudo）
#   happ-status       只读总览两层状态

function happ-env --description "开关当前 fish 会话的代理环境变量（终端工具层）"
    if test (count $argv) -ne 1
        echo "用法：happ-env on|off" >&2
        return 2
    end
    if not contains -- "$argv[1]" on off
        echo "用法：happ-env on|off" >&2
        return 2
    end

    if test "$argv[1]" = off
        for name in http_proxy https_proxy HTTP_PROXY HTTPS_PROXY no_proxy NO_PROXY
            set -eg $name
        end
        echo "本会话代理环境变量已清除，系统代理不受影响"
        return 0
    end

    set -l proxy_host 127.0.0.1
    set -l proxy_port 10809
    set -l proxy_url http://$proxy_host:$proxy_port

    set -l ok ✓
    set -l warn '!'
    set -l hint ''
    set -l reset ''
    if isatty stdout
        set ok (set_color green)✓(set_color normal)
        set warn (set_color yellow)!(set_color normal)
        set hint (set_color brblack)
        set reset (set_color normal)
    end

    set -gx http_proxy  $proxy_url
    set -gx https_proxy $proxy_url
    set -gx HTTP_PROXY  $proxy_url
    set -gx HTTPS_PROXY $proxy_url

    set -gx no_proxy localhost,127.0.0.1,::1
    set -gx NO_PROXY localhost,127.0.0.1,::1

    echo "$ok 本会话终端工具已走代理"
    echo "  http_proxy · https_proxy · 大写别名  →  $proxy_url"
    echo "  $hint 撤销：happ-env off$reset"

    if not nc -z $proxy_host $proxy_port >/dev/null 2>&1
        echo "$warn $proxy_host:$proxy_port 当前无人监听：Happ 核心启动前终端联网会失败"
    end
end

function happ-sys --description "开关 macOS 系统代理（GUI 应用层，需 sudo）"
    if test (count $argv) -ne 1
        echo "用法：happ-sys on|off" >&2
        return 2
    end
    if not contains -- "$argv[1]" on off
        echo "用法：happ-sys on|off" >&2
        return 2
    end

    set -l action $argv[1]
    set -l proxy_host 127.0.0.1
    set -l proxy_port 10809
    set -l services "Wi-Fi"

    set -l ok ✓
    set -l bad ✗
    set -l warn '!'
    set -l hint ''
    set -l reset ''
    if isatty stdout
        set ok (set_color green)✓(set_color normal)
        set bad (set_color red)✗(set_color normal)
        set warn (set_color yellow)!(set_color normal)
        set hint (set_color brblack)
        set reset (set_color normal)
    end

    if test "$action" = on
        if not nc -z $proxy_host $proxy_port >/dev/null 2>&1
            echo "$bad Happ 未监听 $proxy_host:$proxy_port，请先启动 Happ 的 Proxy 模式"
            return 1
        end
    end

    if not sudo -v
        echo "$bad 需要 sudo 权限，已取消"
        return 1
    end

    set -l existing_services \
        (networksetup -listallnetworkservices \
        | string match -rv '^An asterisk' \
        | string replace -r '^\*' '')

    for service in $services
        if not contains -- $service $existing_services
            echo "$warn 网络服务不存在，已跳过：$service"
            continue
        end

        switch $action
            case on
                echo "开启 $service：HTTP/HTTPS → $proxy_host:$proxy_port"

                sudo networksetup -setwebproxy \
                    "$service" $proxy_host $proxy_port

                sudo networksetup -setsecurewebproxy \
                    "$service" $proxy_host $proxy_port

                sudo networksetup -setwebproxystate \
                    "$service" on

                sudo networksetup -setsecurewebproxystate \
                    "$service" on

            case off
                echo "关闭 $service：系统代理（HTTP/HTTPS/SOCKS）"

                sudo networksetup -setwebproxystate \
                    "$service" off

                sudo networksetup -setsecurewebproxystate \
                    "$service" off

                sudo networksetup -setsocksfirewallproxystate \
                    "$service" off
        end
    end

    echo
    switch $action
        case on
            set -l proxy_lines (scutil --proxy)
            set -l http_en (printf '%s\n' $proxy_lines | string match -r 'HTTPEnable : (\S+)' | tail -1)
            set -l https_en (printf '%s\n' $proxy_lines | string match -r 'HTTPSEnable : (\S+)' | tail -1)

            if test "$http_en" = 1 -a "$https_en" = 1
                echo "$ok 系统代理已开启（GUI 应用走 $proxy_host:$proxy_port）"
            else
                echo "$bad 设置后未见生效，请手动检查：scutil --proxy"
                return 1
            end

        case off
            echo "$ok 系统代理已关闭（GUI 应用恢复直连）"

            if set -q http_proxy
                echo "$hint 本会话终端不受影响：http_proxy 仍指向 $http_proxy$reset"
            end
    end
end

function happ-status --description "查看 Happ 本身与两层代理的状态（只读）"
    set -l proxy_host 127.0.0.1
    set -l proxy_port 10809
    set -l happ_path /Applications/Happ.app/Contents/MacOS

    # ── 采集 ──
    set -l port_ok false
    nc -z $proxy_host $proxy_port >/dev/null 2>&1
    and set port_ok true

    set -l happ_running false
    pgrep -f "$happ_path/Happ" >/dev/null 2>&1
    and set happ_running true

    set -l xray_running false
    pgrep -f "$happ_path/core/xray" >/dev/null 2>&1
    and set xray_running true

    set -l proxy_lines (scutil --proxy)

    set -l http_en (printf '%s\n' $proxy_lines | string match -r 'HTTPEnable : (\S+)' | tail -1)
    set -l http_host (printf '%s\n' $proxy_lines | string match -r 'HTTPProxy : (\S+)' | tail -1)
    set -l http_port (printf '%s\n' $proxy_lines | string match -r 'HTTPPort : (\S+)' | tail -1)
    set -l https_en (printf '%s\n' $proxy_lines | string match -r 'HTTPSEnable : (\S+)' | tail -1)
    set -l https_host (printf '%s\n' $proxy_lines | string match -r 'HTTPSProxy : (\S+)' | tail -1)
    set -l https_port (printf '%s\n' $proxy_lines | string match -r 'HTTPSPort : (\S+)' | tail -1)
    set -l socks_en (printf '%s\n' $proxy_lines | string match -r 'SOCKSEnable : (\S+)' | tail -1)
    set -l socks_host (printf '%s\n' $proxy_lines | string match -r 'SOCKSProxy : (\S+)' | tail -1)
    set -l socks_port (printf '%s\n' $proxy_lines | string match -r 'SOCKSPort : (\S+)' | tail -1)

    set -l env_state off
    if set -q http_proxy
        set env_state on
    else if set -q HTTP_PROXY
        set env_state on
    end

    set -l sys_state mixed
    if test "$http_en" = 1 -a "$https_en" = 1
        set sys_state on
    else if test "$http_en" = 0 -a "$https_en" = 0
        set sys_state off
    end

    # ── 输出符号（管道时自动退化纯文本）──
    set -l ok ✓
    set -l off ○
    set -l warn '!'
    set -l bad ✗
    set -l hint ''
    set -l reset ''
    set -l head ''
    set -l title ''
    if isatty stdout
        set ok (set_color green)✓(set_color normal)
        set off (set_color brblack)○(set_color normal)
        set warn (set_color yellow)!(set_color normal)
        set bad (set_color red)✗(set_color normal)
        set hint (set_color brblack)
        set reset (set_color normal)
        set head (set_color cyan --bold)
        set title (set_color --bold)
    end

    set -l now (date '+%m-%d %H:%M')

    # ── 呈现 ──
    echo "$title Happ 代理状态$reset  $hint$now$reset"
    echo "$hint────────────────────────────────────────────$reset"
    echo

    echo "$head ▸ Happ 本体$reset"
    if test "$happ_running" = true
        echo "  $ok GUI 进程：运行中"
    else
        echo "  $off GUI 进程：未运行"
    end
    if test "$xray_running" = true
        echo "  $ok xray 核心：运行中"
    else
        echo "  $off xray 核心：未运行"
    end
    if test "$port_ok" = true
        echo "  $ok 端口 $proxy_host:$proxy_port：在监听"
    else
        echo "  $off 端口 $proxy_host:$proxy_port：未监听"
    end
    echo

    echo "$head ▸ 系统代理（GUI 应用层）$reset"
    if test "$http_en" = 1
        echo "  $ok HTTP    → $http_host:$http_port"
    else
        echo "  $off HTTP    未开启"
    end
    if test "$https_en" = 1
        echo "  $ok HTTPS   → $https_host:$https_port"
    else
        echo "  $off HTTPS   未开启"
    end
    if test "$socks_en" = 1
        if test -n "$socks_host"
            echo "  $ok SOCKS   → $socks_host:$socks_port"
        else
            echo "  $ok SOCKS   → 已开启"
        end
    else
        echo "  $off SOCKS   未开启"
    end
    echo

    echo "$head ▸ 终端环境变量（本会话）$reset"
    if set -q http_proxy
        echo "  $ok http_proxy → $http_proxy"
    else if set -q HTTP_PROXY
        echo "  $ok HTTP_PROXY → $HTTP_PROXY"
    else
        echo "  $off 未设置（终端工具直连）"
    end
    echo

    echo "$head ▸ 结论$reset"
    if test "$env_state" = on
        if test "$port_ok" = true
            echo "  $ok 终端工具正常走代理"
        else
            echo "  $bad 环境变量仍指向 $proxy_port，但端口无人监听——brew/curl/git 会连接失败"
            echo "    $hint 修复：启动 Happ，或运行 happ-env off$reset"
        end
    else if test "$port_ok" = true
        echo "  $off 终端工具直连中，需要时运行 happ-env on"
    end

    switch $sys_state
        case on
            if test "$port_ok" = true
                echo "  $ok GUI 应用正常走系统代理"
            else
                echo "  $bad 系统代理已开启但 Happ 未监听——网页会打不开"
                echo "    $hint 修复：happ-sys off 关闭系统代理，或重新打开 Happ.app$reset"
            end
        case off
            if test "$port_ok" = true
                echo "  $off 系统代理未开启，需要时运行 happ-sys on"
            else
                echo "  $off 系统代理已关闭，Happ 也未运行"
            end
        case mixed
            echo "  $warn 系统 HTTP/HTTPS 代理状态不一致，建议运行 happ-sys off 重置"
    end
end
