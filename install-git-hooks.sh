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

installPreCommit
touchCustomizedGitHook
preCommitInstall
