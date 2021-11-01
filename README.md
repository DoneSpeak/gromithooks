Gromithooks
---

## 安装

### 通过`install-git-hooks.sh`安装

```bash
cd /项目根目录
# 下载 install-git-hooks.sh
wget https://raw.githubusercontent.com/DoneSpeak/gromithooks/v1.0.1/install-git-hooks.sh
# 也可以用curl下载
curl https://raw.githubusercontent.com/DoneSpeak/gromithooks/v1.0.1/install-git-hooks.sh -o install-git-hooks.sh

./install-git-hooks.sh
```

`install-git-hooks.sh` 是我写的一个帮助脚本，目前使用与Unix系统的安装配置，在Windows中运行可能会遇到一些问题。

### 通过`Makefile`安装

```bash
cd /项目根目录
# 下载makefile
wget https://raw.githubusercontent.com/DoneSpeak/gromithooks/main/Makefile
# 执行安装
make install-git-hooks
```
该Makefile主要为将文件执行转化为统一的命令执行，后续更换文件也可以保持一致的执行方法。

### 按照`pre-commit`的官网教程安装

[点击这里](https://pre-commit.com/#install) 直达pre-commit官网。

如果你的系统是**Windows**，建议早日使用WSL。不想用WSL，那还是按照官方教程执行。推荐使用如下指令安装：
```bash
pip install pre-commit
```

你可能在使用的过程中遇到一些Python相关的问题，如下的文章会有所帮助。

- [Windows 10 support #1976](https://github.com/pre-commit/pre-commit/issues/1976) 表明pre-commit是支持windows10的
- [Permission Denied error: Python 3.8 on Windows Gitbash @stackoverflow](https://stackoverflow.com/questions/59487242/permission-denied-error-python-3-8-on-windows-gitbash)
- ["Permission Denied" trying to run Python on Windows 10](https://stackoverflow.com/questions/56974927/permission-denied-trying-to-run-python-on-windows-10)

## 配置

```bash
cd /项目根目录
touch .pre-commit-config.yaml
# 安装
```

粘贴如下内容到`.pre-commit-config.yaml`
```yaml
repos:
- repo: https://github.com/DoneSpeak/gromithooks
  rev: v1.0.1
  hooks:
  - id: cm-tapd-autoconnect
    verbose: true
    stages: [commit-msg]
```

配置完成，按照正常使用即可。

## 脚本列表

### cm-tapd-autoconnect

```yaml
  - id: cm-tapd-autoconnect
    verbose: true
    stages: [commit-msg]
```

用于[腾讯TAPD](https://www.tapd.cn/official/index)项目管理工具。项目管理工具。根据分支名，自动添加tapd关联字符串。

需要添加环境变量：`TAPD_USERNAME=usernameInTapd`

分支名  | commit 格式 | 绑定TAPD
--- | --- | ---
tapd-S1234  | #S1234, message  | --story=1234 --user=donespeak
tapd-B1234  | #B1234, message  | --bug=1234 --user=donespeak
tapd-T1234   | #T1234, message  | --task=1234 --user=donespeak
tapd-S1234-fix-bug  | #S1234, message  | --story=1234 --user=donespeak

### pcm-tapd-ref-prefix

```yaml
  - id: pcm-tapd-ref-prefix
    verbose: true
    stages: [prepare-commit-msg]
```

用于[腾讯TAPD](https://www.tapd.cn/official/index)项目管理工具。根据分支名，自动添加commit message前缀

分支名  | commit 格式 | 绑定TAPD
--- | --- | ---
tapd-S1234  | #S1234, message  | story 1234
tapd-B1234  | #B1234, message  | bug 1234
tapd-T1234   | #T1234, message  | task 1234
tapd-S1234-fix-bug  | #S1234, message  | story 1234

### pcm-issue-ref-prefix

```yaml
  - id: pcm-issue-ref-prefix
    verbose: true
    stages: [prepare-commit-msg]
```

用于Github，Gitlab的issue管理。根据分支名，自动添加commit message前缀以关联issue和commit。

分支名  | commit 格式
--- | ---
issue-1234  | #1234, message
issue-1234-fix-bug  | #1234, message

## 个性化本地Hooks
通过local repo功能可以增加**不提交到Github**的个性化本地hooks。

```bash
chmod +x install-git-hooks.sh
./install-git-hooks.sh
# intall with initializing customized hooks
CUSTOMIZED=1 ./install-git-hooks.sh
```

执行完成之后，增加`.git_hooks`目录，并在`.pre-commit-config.yaml`中增加如下配置内容。

```yaml
- repo: local
  hooks:
  - id: commit-msg
    name: commit-msg (local)
    entry: .git_hooks/commit-msg
    language: script
    stages: [commit-msg]
    # verbose: true
  - id: post-checkout
    name:  post-checkout (local)
    entry: .git_hooks/post-checkout
    language: script
    stages: [post-checkout]
    # verbose: true
  - id: post-commit
    name: post-commit (local)
    entry: .git_hooks/post-commit
    language: script
    stages: [post-commit]
    # verbose: true
  - id: post-merge
    name: post-merge (local)
    entry: .git_hooks/post-merge
    language: script
    stages: [post-merge]
    # verbose: true
  - id: pre-commit
    name: pre-commit (local)
    entry: .git_hooks/pre-commit
    language: script
    stages: [commit]
    # verbose: true
  - id: pre-merge-commit
    name: pre-merge-commit (local)
    entry: .git_hooks/pre-merge-commit
    language: script
    stages: [merge-commit]
    # verbose: true
  - id: pre-push
    name: pre-push (local)
    entry: .git_hooks/pre-push
    language: script
    stages: [push]
    # verbose: true
  - id: prepare-commit-msg
    name: prepare-commit-msg (local)
    entry: .git_hooks/prepare-commit-msg
    language: script
    stages: [prepare-commit-msg]
    # verbose: true
```

通过修改`.git_hooks`中存在的hook文件即可实现个性化的hook，这些hooks不会提交到gitlab服务器。
