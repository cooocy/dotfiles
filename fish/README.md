# fish + fisher 配置说明

本目录是 fish shell 的配置，通过软链挂载到 `~/.config/fish/`。
本文档梳理 fish 加载机制、fisher 插件管理机制，以及新机器初始化流程。

---

## 一、fish 自身的加载机制

### 1.1 配置目录结构

fish 启动时，**自动**扫描 `~/.config/fish/` 下这些目录：

```
~/.config/fish/
├── config.fish           # 主配置, 每次启动都跑（交互/非交互/登录 shell 都跑）
├── fish_plugins          # fisher 用的插件清单（fish 本身不读它）
├── fish_variables        # universal 变量持久化文件（fish 自动维护, 别手编辑）
│
├── conf.d/*.fish         # 启动时自动 source（按文件名字母序）
├── functions/*.fish      # 按需懒加载, 文件名 = 函数名
├── completions/*.fish    # tab 补全, 按需懒加载
└── themes/*.theme        # 主题文件
```

### 1.2 启动加载顺序（重要）

每次 fish 启动，按下面这个顺序加载：

```
1. 读取 universal 变量（从 fish_variables 文件）
2. 加载 fish 内置的 conf.d/*.fish（系统级）
3. 加载用户 conf.d/*.fish（你的）           ← 按文件名字母序
4. 跑 config.fish
5. 进入交互（如果是交互式 shell）
```

- `functions/*.fish` **不在启动时加载**。当你输入命令 `foo`，fish 找不到内建/PATH 里的 `foo`，就去 `functions/foo.fish` 加载并执行。**懒加载** = 启动快。
- `completions/*.fish` 同理，按 tab 时才加载。
- 这就是为什么"放新函数到 `functions/`"比"在 `config.fish` 里 `function ... end`"更好——前者不拖累启动速度。

### 1.3 变量作用域（决定行为）

| scope     | 标志           | 生存期             | 持久化到 `fish_variables` | 用途                       |
| --------- | -------------- | ------------------ | ------------------------- | -------------------------- |
| local     | `-l`           | 当前函数/块        | 否                        | 临时变量                   |
| global    | `-g`           | 当前 shell 进程    | 否                        | 配置文件里设环境变量       |
| universal | `-U`           | **跨 shell、跨重启** | ✅ 是                     | 极少用，让工具自己维护     |
| exported  | `-x`（可叠加） | 跟随上面 + 导出给子进程 | 与上面一致                | 环境变量                   |

**经验法则**：你写的配置全用 `-gx`（global + export），不要用 `-U`。`-U` 留给工具自己（如 fisher）。

### 1.4 PATH 管理

fish **不要**直接拼 `$PATH`，用：

```fish
fish_add_path -g /opt/homebrew/bin ~/.local/bin /usr/local/bin
```

- `-g` global，每次启动跑一次，自带去重
- 不写磁盘，不污染 universal
- 多次 add 同一路径不会重复

---

## 二、fisher 机制

### 2.1 fisher 是什么

- 一个 fish 函数（`functions/fisher.fish`），不是后台服务
- 只在你显式调用 `fisher install/update/remove/list` 时运行
- 装/卸/更新插件，本质是**复制/删除文件**到 `~/.config/fish/` 各目录

### 2.2 "插件"的本质

插件就是一个 GitHub 仓库，结构和 fish 配置目录一致：

```
github.com/<user>/<repo>
├── functions/*.fish     → 复制到 ~/.config/fish/functions/
├── completions/*.fish   → 复制到 ~/.config/fish/completions/
├── conf.d/*.fish        → 复制到 ~/.config/fish/conf.d/
└── themes/*.theme       → 复制到 ~/.config/fish/themes/
```

fisher 装插件 = 下载 zip → 把这几个目录的文件复制到你的对应目录 → 记账。

### 2.3 fisher 的两个"账本"

| 名字                                                   | 位置                                        | 性质                                | 进 Git？     |
| ------------------------------------------------------ | ------------------------------------------- | ----------------------------------- | ------------ |
| `fish_plugins`                                         | `~/.config/fish/fish_plugins` 文本文件      | **声明**（我想要哪些插件）          | ✅ 进        |
| `_fisher_plugins`、`_fisher_<owner>_2F_<repo>_files`   | universal 变量（在 `fish_variables` 里）    | **状态**（本机实际装了什么、放了哪些文件） | ❌ 不进     |

**类比 npm**：

| fish 世界                       | npm 世界                                   |
| ------------------------------- | ------------------------------------------ |
| fisher                          | npm                                        |
| `fish_plugins`                  | `package.json`（dependencies 字段）        |
| `_fisher_*` 变量                | `package-lock.json` + `node_modules/` 的元数据 |
| `functions/*.fish`（插件来的）  | `node_modules/` 里的代码                   |
| `fisher update`                 | `npm install`                              |

### 2.4 fisher 的 5 个命令

```fish
fisher install <user>/<repo>     # 装一个插件（写入 fish_plugins 和 _fisher_plugins）
fisher remove  <user>/<repo>     # 卸载
fisher update                    # 按 fish_plugins 清单同步全部
fisher update  <user>/<repo>     # 只更新指定插件
fisher list                      # 列出已装
```

`fisher update`（无参数）做的事：

1. 读 `fish_plugins`
2. 对比 `_fisher_plugins`
3. 清单里有、本机没有 → 安装
4. 本机有、清单里没有 → 卸载
5. 两边都有 → 拉最新版替换
6. 同步账本

---

## 三、什么进 Git、什么不进 Git

### ✅ 进 Git（声明式配置）

```
fish/
├── config.fish
├── fish_plugins            ← 插件清单
├── conf.d/
│   ├── my_env.fish         ← 你写的环境变量
│   ├── my_functions.fish   ← 你写的函数
│   └── ...
└── functions/
    └── fish_prompt.fish    ← 你自己写的函数
```

### ❌ 不进 Git（本机状态 / fisher 装出来的产物）

```
fish_variables                            ← 本机 universal 变量快照
functions/fisher.fish                     ← fisher 自己（让 install 命令重装）
completions/fisher.fish                   ← fisher 的补全
functions/__z.fish                        ← 插件来的
functions/__z_add.fish                    ← 插件来的
functions/__z_clean.fish                  ← 插件来的
functions/__z_complete.fish               ← 插件来的
conf.d/z.fish                             ← 插件来的
themes/                                   ← 如果空就删掉; 用插件主题则忽略
```

**`.gitignore` 示例**：

```gitignore
# 本机状态
fish/fish_variables
fish/fish_variables.bak

# fisher 自身
fish/functions/fisher.fish
fish/completions/fisher.fish

# 第三方插件文件（按你装的插件来）
fish/functions/__z*.fish
fish/conf.d/z.fish
```

---

## 四、新机器初始化流程

假设你已经把 dotfiles clone 到 `~/.dotfiles`。

### 步骤 0：装前置依赖

```fish
# 在 bash/zsh 里跑（还没装 fish 之前）
# macOS
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install fish lsd zoxide fzf macchina

# 让 fish 成为登录 shell（可选）
echo (which fish) | sudo tee -a /etc/shells
chsh -s (which fish)
```

### 步骤 1：链接 dotfiles 到 fish 配置目录

```fish
# 备份原有配置（如果有）
mv ~/.config/fish ~/.config/fish.bak 2>/dev/null

# 软链 dotfiles
ln -s ~/.dotfiles/fish ~/.config/fish
```

软链方式的好处：你在 `~/.dotfiles/fish/` 改文件，`git status` 直接能看到，不用复制来复制去。

### 步骤 2：装 fisher 本身（先有鸡）

```fish
# 启动一个 fish
fish

# 装 fisher
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
fisher install jorgebucaran/fisher
```

这一步会创建 `~/.config/fish/functions/fisher.fish` 和 `_fisher_*` universal 变量。

### 步骤 3：按 fish_plugins 装所有插件

```fish
fisher update
```

fisher 读 `~/.config/fish/fish_plugins`（已经通过软链指向你 dotfiles 里的清单），拉所有插件并复制文件、写账本。

### 步骤 4：验证

```fish
fisher list             # 应该列出 fish_plugins 里的所有插件
echo $fish_user_paths   # PATH 数组, 检查目录是否齐全
type ls                 # 检查自定义函数/abbr 是否生效
z                       # 检查 z 插件
```

### 步骤 5（如果有）：恢复敏感配置

dotfiles 里**不该**有 token / 密码。新机器上单独建立 `private.fish`：

```fish
# 从密码管理器读出来, 或者从加密的备份恢复
# 例如用 1Password CLI:
op read "op://Personal/MAVEN/credential" > /tmp/maven_token
# 然后填到 ~/.config/fish/conf.d/private.fish
```

确保 `private.fish` 已经在 `.gitignore` 里。

---

## 五、日常使用速查

### 装新插件

```fish
fisher install PatrickF1/fzf.fish
# fish_plugins 文件自动更新, commit 到 dotfiles
```

### 升级所有插件

```fish
fisher update
```

### 卸载

```fish
fisher remove jethrokuan/z
# fish_plugins 自动同步
```

### 加 PATH

```fish
fish_add_path -g /some/new/path
# 写在 conf.d/my_env.fish 里, 不要在交互里跑 set -U
```

### 加环境变量

```fish
# 在 conf.d/my_env.fish 里写
set -gx MY_VAR value
# 不要用 -U
```

### 加函数

```fish
# 方式 1: 单文件（推荐, 懒加载）
# ~/.config/fish/functions/foo.fish
function foo
    echo hello
end

# 方式 2: 写在 conf.d 里（启动时加载, 适合简单封装）
```

### 加别名（推荐用 abbr 而不是 function）

```fish
# 在 conf.d/my_abbr.fish 里
abbr -a ls   lsd
abbr -a ll   'lsd -l'
abbr -a kc   kubectl
```

`abbr` 在你回车时**展开成真实命令**，历史可读、脚本里不会被影响。

### 清理某个 universal 变量

```fish
set -e Z_DATA       # 删除
set -U              # 列出所有 universal 变量（用于审计）
set -S VAR_NAME     # 看变量在哪几个 scope 同时存在
```

---

## 六、常见陷阱清单

| 陷阱                                                            | 后果                                       | 解决                                                  |
| --------------------------------------------------------------- | ------------------------------------------ | ----------------------------------------------------- |
| `conf.d/` 里写 `set -U fish_user_paths X $fish_user_paths`     | 每次启动追加，PATH 无限膨胀                | 改 `fish_add_path -g`                                 |
| `fish_variables` 进 Git                                         | diff 噪声、跨机器冲突、状态污染声明        | `.gitignore` 掉                                       |
| 把 fisher 装的插件文件进 Git                                    | 新机器 fisher 账本对不上、更新逻辑错乱     | `.gitignore` 掉，靠 `fisher update` 重建              |
| 在 `config.fish` 里 `sleep 0.1` / 启动跑慢命令                  | 每开 shell / tmux 分屏都卡                 | 删掉，需要时手动调用                                  |
| `set -U EDITOR` 一次后忘了                                      | 后续改 `conf.d` 里的 `set -gx EDITOR` 不生效 | `set -e EDITOR` 清掉旧 universal                      |
| token 写进 `conf.d/*.fish` 又 commit                           | 凭据泄露                                   | 单独 `private.fish` + `.gitignore`，或用密码管理器    |
| 用 `function ls` 别名                                           | 脚本里 `ls` 也被替换，可能有副作用         | 用 `abbr -a ls lsd`                                   |

---

## TL;DR

- **fish 启动**：universal 变量 → conf.d → config.fish
- **fisher**：fish 的 npm，把插件文件复制到你的 fish 配置目录
- **Git 管声明（`fish_plugins` + 你写的代码），不管状态（`fish_variables` + 插件文件）**
- **新机器三步**：链 dotfiles → 装 fisher → `fisher update`
- **配置永远用 `-gx` / `fish_add_path -g` / `abbr`，避开 `-U`**
