.DEFAULT_GOAL := bootstrap

exists_pod = $(shell command -v pod 2> /dev/null)
exists_fastlane = $(shell command -v fastlane 2> /dev/null)

install_env:

ifeq "${exists_pod}" ""
	sudo gem install cocoapods
endif

ifeq "${exists_fastlane}" ""
	brew cask install fastlane
endif

	@echo "All dependencies was installed"

install:

ifeq "${exists_pod}" ""
	@echo "Cocopods is not installed. Use `make install_env`"
endif

	pod install

bootstrap: install

release:
	fastlane release
