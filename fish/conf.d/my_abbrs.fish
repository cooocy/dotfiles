# 简单的命令替换用 abbr 而不是 function.
# - abbr 在回车/空格时展开成真实命令, 历史记录看到的是真命令
# - function 会全局覆盖命令, 脚本里调用同名命令也会触发, 可能有副作用
# - abbr 只在交互式回车时生效, 脚本不受影响

abbr -a ls   lsd
abbr -a ll   'lsd -l'

abbr -a kc   kubectl

abbr -a mac  macchina

abbr -a st      'open -a "Sublime Text"'
abbr -a tp      'open -a Typora'
abbr -a idea    'open -a "IntelliJ IDEA"'
abbr -a pycharm 'open -a "PyCharm Professional"'
