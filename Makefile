.DEFAULT_GOAL := bootstrap

exists_pod = $(shell command -v pod 2> /dev/null)

install_env:

ifeq "${exists_pod}" ""
	sudo gem install cocoapods
endif

	@echo "All dependencies was installed"

install:

ifeq "${exists_pod}" ""
	@echo "Cocopods is not installed. Use `make install_env`"
endif

	pod install --repo-update

bootstrap: install

release:
	fastlane release
