REPO := $(PWD)
REPO_GIT := $(REPO)/.git

install-git-hooks: .git/hooks/hook-exec

.git/hooks/hook-exec:
ifeq ($(wildcard $@),)
	cd $(REPO_GIT) && git clone git@gitlab.com:DoneSpeak/gromithooks.git
	mv $(REPO_GIT)/hooks/* $(REPO_GIT)/gromithooks/git-hooks/multi-hooks/customized/
	rm -rf $(REPO_GIT)/hooks
	ln -s $(REPO_GIT)/gromithooks/git-hooks/multi-hooks $(REPO_GIT)/hooks
endif

update-git-hooks: install-git-hooks
	cd $(REPO_GIT)/gromithooks && git pull
