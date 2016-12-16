DOTPATH    := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
CANDIDATES := $(wildcard .??*)
EXCLUSIONS := .DS_Store .git .gitignore
DOTFILES   := $(filter-out $(EXCLUSIONS), $(CANDIDATES))

all:
	@make help

deploy:
	@echo 'Deploy dotfiles to home directory...'
	@$(foreach val, ${DOTFILES}, ln -sfnv $(abspath $(val)) $(HOME)/$(val);)

update:
	@echo 'Pull dotfiles from remote repository...'
	git pull origin master

clear:
	@echo 'Remove dotfiles in home directory...'
	@$(foreach val, $(DOTFILES), rm -vrf $(HOME)/$(val);)
	rm -rf $(DOTPATH)

help:
	@echo ''
	@echo 'Usage: make <command>'
	@echo ''
	@echo '  make deploy	deploy dotfiles to home directory'
	@echo '  make update	pull dotfiles from remote repository'
	@echo '  make clean 	remove dotfiles in home directory'
	@echo ''
