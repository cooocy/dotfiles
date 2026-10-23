# ====================================================== ENV 规范
# 本文件随 fish 启动加载，自定义环境变量统一使用 set -gx NAME VALUE。
# set 的 -g（--global）：设置当前 fish 的全局变量，函数内外均可访问；不影响其他已运行的 shell。
# set 的 -x（--export）：让当前 fish 启动的子进程继承变量，不决定变量的作用域。
# set 的 -gx 等同于 -g -x：同时明确全局作用域和导出属性。
# 只写 set -x 时，已有变量沿用原作用域；变量不存在时，在函数内创建函数作用域变量，在函数外创建全局变量。因此启动配置中 set -x 通常也能工作，但 -gx 的意图更明确。
# set 的 -U（--universal）：跨 fish 会话共享，默认持久化到 fish_variables；本文件不使用。
# 示例：set -gx EDITOR vim，让当前 fish 全局可用，并让后续启动的子进程继承 EDITOR。

# ====================================================== PATH 规范
# fish 的 PATH 是目录列表，不使用 bash 的冒号字符串拼接方式。
# 自定义命令目录统一使用 fish_add_path -g DIR ... 添加。
# fish_add_path 的 -g：使用 global 的 fish_user_paths，避免默认创建 universal 变量。
# fish_user_paths 中的目录会自动前置到 PATH，添加时无需再使用 set -x。
# fish_add_path 默认前置新目录；多个新目录按参数顺序排列，越靠前优先级越高。
# 已有目录不会重复添加或重新排序；不存在的目录会被跳过。
# 如需将已有目录移到前面，显式使用 --move；默认不强制调整顺序。
# Homebrew 的命令路径由 shellenv 管理，不在这里手动重复添加。

# ====================================================== Homebrew
# Homebrew 环境交给 brew shellenv | source 初始化，信任其生成的配置。
/opt/homebrew/bin/brew shellenv | source

# ====================================================== 用户工具 / Node.js 24
fish_add_path -g ~/.local/bin /opt/homebrew/opt/node@24/bin

# ====================================================== Vim / 默认编辑器
set -gx EDITOR vim

# ====================================================== tldr
set -gx TLDR_AUTO_UPDATE_DISABLED true

# ====================================================== ls
# LS_COLORS 供 GNU ls 等支持它的工具使用；macOS 自带 ls 使用 LSCOLORS。
set -gx LS_COLORS 'di=38;5;74'

# ====================================================== Go
set -gx GOPATH /opt/go
fish_add_path -g $GOPATH/bin
