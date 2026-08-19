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

function happ-on --description "开启 Happ 系统代理"
    set -l proxy_host 127.0.0.1
    set -l proxy_port 10809
    set -l services "Wi-Fi"

    # 确认 Happ 的 HTTP 代理已启动
    if not nc -z $proxy_host $proxy_port >/dev/null 2>&1
        echo "❌ Happ 未监听 $proxy_host:$proxy_port"
        echo "请先在 Happ 中启动 Proxy 模式。"
        return 1
    end

    sudo -v
    or return 1

    set -l existing_services \
        (networksetup -listallnetworkservices \
        | string match -rv '^An asterisk' \
        | string replace -r '^\*' '')

    for service in $services
        if not contains -- $service $existing_services
            echo "⚠️ 网络服务不存在，已跳过：$service"
            continue
        end

        echo "→ 开启 $service 的 HTTP/HTTPS 代理"

        sudo networksetup -setwebproxy \
            "$service" $proxy_host $proxy_port

        sudo networksetup -setsecurewebproxy \
            "$service" $proxy_host $proxy_port

        sudo networksetup -setwebproxystate \
            "$service" on

        sudo networksetup -setsecurewebproxystate \
            "$service" on
    end

    echo
    echo "✅ Happ 系统代理已开启：$proxy_host:$proxy_port"
    scutil --proxy
end

function happ-off --description "关闭 Happ 系统代理"
    set -l services "Wi-Fi"

    sudo -v
    or return 1

    set -l existing_services \
        (networksetup -listallnetworkservices \
        | string match -rv '^An asterisk' \
        | string replace -r '^\*' '')

    for service in $services
        if not contains -- $service $existing_services
            echo "⚠️ 网络服务不存在，已跳过：$service"
            continue
        end

        echo "→ 关闭 $service 的系统代理"

        sudo networksetup -setwebproxystate \
            "$service" off

        sudo networksetup -setsecurewebproxystate \
            "$service" off

        sudo networksetup -setsocksfirewallproxystate \
            "$service" off
    end

    echo
    echo "✅ 系统代理已关闭"
    scutil --proxy
end

function happ-env --description "为当前 Fish 会话启用 Happ HTTP 代理"
    set -l proxy_url http://127.0.0.1:10809

    set -gx http_proxy  $proxy_url
    set -gx https_proxy $proxy_url
    set -gx HTTP_PROXY  $http_proxy
    set -gx HTTPS_PROXY $https_proxy

    set -gx no_proxy localhost,127.0.0.1,::1
    set -gx NO_PROXY $no_proxy

    echo "✅ 当前 Fish 已启用代理：$proxy_url"
end
