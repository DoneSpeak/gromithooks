#!/bin/bash

:<<'COMMENT'
chmod +x install-git-hooks.sh
./install-git-hooks.sh
# intall with initializing customized hooks
CUSTOMIZED=1 ./install-git-hooks.sh
COMMENT

STAGES="pre-commit pre-merge-commit pre-push prepare-commit-msg commit-msg post-checkout post-commit post-merge"

installPreCommit() {
    HAS_PRE_COMMIT=$(which pre-commit)
    if [ -n "$HAS_PRE_COMMIT" ]; then
        return
    fi

    HAS_PIP=$(which pip)
    if [ -z "$HAS_PIP" ]; then
        echo "ERROR:pip is required, please install it mantually."
        exit 1
    fi
    pip install pre-commit
}

touchCustomizedGitHook() {
    mkdir .git_hooks
    for stage in $STAGES
        do
            STAGE_HOOK=".git_hooks/$stage"
            if [ -f "$STAGE_HOOK" ]; then
                echo "WARN:Fail to touch $STAGE_HOOK because it exists."
                continue
            fi
            echo -e "#!/bin/bash\n\n# general git hooks is available." > "$STAGE_HOOK"
            chmod +x "$STAGE_HOOK"
    done
}

preCommitInstall() {
    for stage in $STAGES
        do
            STAGE_HOOK=".git/hooks/$stage"
            if [ -f "$STAGE_HOOK" ]; then
                echo "WARN:Fail to install $STAGE_HOOK because it exists."
                continue
            fi
            pre-commit install -t "$stage"
    done
}

touchPreCommitConfigYaml() {
    PRE_COMMIT_CONFIG=".pre-commit-config.yaml"
    if [ -f "$PRE_COMMIT_CONFIG" ]; then
        echo "WARN: abort to init .pre-commit-config.yaml for it's existence."
        return 1
    fi
    touch $PRE_COMMIT_CONFIG
    echo "# 在Git项目中使用pre-commit统一管理hooks" >> $PRE_COMMIT_CONFIG
    echo "# https://donespeak.gitlab.io/posts/210525-using-pre-commit-for-git-hooks/" >> $PRE_COMMIT_CONFIG
}

initPreCommitConfigYaml() {
    touchPreCommitConfigYaml
    if [ "$?" == "1" ]; then
        return 1
    fi

    echo "" >> $PRE_COMMIT_CONFIG
    echo "repos:" >> $PRE_COMMIT_CONFIG
    echo "  - repo: local" >>  $PRE_COMMIT_CONFIG
    echo "    hooks:" >> $PRE_COMMIT_CONFIG
    for stage in $STAGES
        do
            echo "      - id: $stage" >> $PRE_COMMIT_CONFIG
            echo "        name: $stage (local)" >> $PRE_COMMIT_CONFIG
            echo "        entry: .git_hooks/$stage" >> $PRE_COMMIT_CONFIG
            echo "        language: script" >> $PRE_COMMIT_CONFIG
            if [[ $stage == pre-* ]]; then
                stage=${stage#pre-}
            fi
            echo "        stages: [$stage]" >> $PRE_COMMIT_CONFIG
            echo "        # verbose: true" >> $PRE_COMMIT_CONFIG
    done
}

ignoreCustomizedGitHook() {
    CUSTOMIZED_GITHOOK_DIR=".git_hooks/"
    GITIGNORE_FILE=".gitignore"
    if [ -f "$GITIGNORE_FILE" ]; then
        if [ "$(grep -c "$CUSTOMIZED_GITHOOK_DIR" $GITIGNORE_FILE)" -ne '0' ]; then
            # 判断文件中已经有配置
            return
        fi
    fi
    echo -e "\n# 忽略.git_hooks中文件，使得其中的脚本不提交到代码仓库\n$CUSTOMIZED_GITHOOK_DIR\n!.git_hooks/.gitkeeper" >> $GITIGNORE_FILE
}

ignoreInstallGitHookSh() {
    FILE_IGNORE="install-git-hooks.sh"
    GITIGNORE_FILE=".gitignore"
    if [ -f "$GITIGNORE_FILE" ]; then
        if [ "$(grep -c "$FILE_IGNORE" $GITIGNORE_FILE)" -ne '0' ]; then
            # 判断文件中已经有配置
            return
        fi
    fi
    echo -e "\n$FILE_IGNORE" >> $GITIGNORE_FILE
}

installPreCommit
if [ "$CUSTOMIZED" == "1" ]; then
    touchCustomizedGitHook
    initPreCommitConfigYaml
else
    touchPreCommitConfigYaml
fi
preCommitInstall
ignoreCustomizedGitHook
ignoreInstallGitHookSh
