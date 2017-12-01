.DEFAULT_GOAL := help

exists_pod = $(shell command -v pod 2> /dev/null)
exists_fastlane = $(shell command -v fastlane 2> /dev/null)

install_env: ## Install environment

ifeq "${exists_pod}" ""
	sudo gem install cocoapods
endif

ifeq "${exists_fastlane}" ""
	brew cask install fastlane
endif

	@echo "\033[36mAll dependencies was installed\033[0m"

install: ## Install libraries
	pod install

bootstrap: ## Bootstrap app
	install

release: ## Release app
	fastlane release

help:
	@grep --extended-regexp '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
