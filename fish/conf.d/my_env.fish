# 不用使用 `set -U` 参数, 会往 `fish_variables` 文件中写入
# 直接使用 `set -x` 即可, `-x = --export` 导出成环境变量

set -U fish_user_paths /usr/local/bin /opt/homebrew/bin $fish_user_paths

set -x TLDR_AUTO_UPDATE_DISABLED true

set -x EDITOR vim

# ====================================================== claude

set -U fish_user_paths ~/.local/bin $fish_user_paths

# ====================================================== claude


# ====================================================== ghostty

# set -x XDG_CONFIG_HOME $HOME/.dotfiles/

# ====================================================== ghostty


# ====================================================== ls

set -x LS_COLORS 'di=38;5;74'

# ====================================================== ls
