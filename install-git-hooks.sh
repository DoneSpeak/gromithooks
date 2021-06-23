#!/bin/bash

STAGES="pre-commit pre-merge-commit pre-push prepare-commit-msg commit-msg post-checkout post-commit post-merge"

installPreCommit() {
    HAS_PRE_COMMIT=$(which pre-commit)
    if [ -n "$HAS_PRE_COMMIT" ]; then
        return;
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
                echo "WARN:Fail to install $STAGE_HOOK becuase it exists."
                continue
            fi
            pre-commit install -t "$stage"
    done
}

ignoreCustomizedGitHook() {
    CUSTOMIZED_GITHOOK_DIR=".git_hooks/"
    GITIGNORE_FILE=".gitignore"
    if [ -f "$GITIGNORE_FILE" ]; then
        if [ "$(grep -c "$CUSTOMIZED_GITHOOK_DIR" $GITIGNORE_FILE)" -ne '0' ]; then
            # 判断文件中已经有配置
            return;
        fi
    fi
    echo -e "\n# 忽略.git_hooks中文件，使得其中的脚本不提交到代码仓库\n$CUSTOMIZED_GITHOOK_DIR\n!.git_hooks/.gitkeeper" >> $GITIGNORE_FILE
}

installPreCommit
touchCustomizedGitHook
preCommitInstall
ignoreCustomizedGitHook
