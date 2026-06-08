# 不用使用 `set -U` 参数, 会往 `fish_variables` 文件中写入
# 直接使用 `set -x` 即可, `-x = --export` 导出成环境变量

# fish 不像 bash 那样直接拼 PATH 字符串, 它有一个专门的变量 fish_user_paths, fish 启动时会把这个数组自动 prepend 到 $PATH 前面.
# 所以只要管好 fish_user_paths, PATH 就管好了.

# fish_add_path 自带去重: 已存在就不加
# -g 是 global, 只活在当前 shell, 下次启动再加一次也无所谓(反正去重)
# 不写磁盘, 新机器直接同步 dotfiles 就生效
fish_add_path -g /opt/homebrew/bin /usr/local/bin ~/.local/bin /opt/homebrew/opt/node@24/bin

set -x TLDR_AUTO_UPDATE_DISABLED true
set -x EDITOR vim

# ====================================================== ghostty

# set -x XDG_CONFIG_HOME $HOME/.dotfiles/

# ====================================================== ghostty


# ====================================================== ls

set -x LS_COLORS 'di=38;5;74'

# ====================================================== ls

# ====================================================== go
set -x GOPATH /opt/go
fish_add_path $GOPATH/bin
# ====================================================== go