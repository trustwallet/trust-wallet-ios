.DEFAULT_GOAL := bootstrap

exists_bundler = $(shell command -v bundle 2> /dev/null)
bundle_check = $(shell bundle check 1> /dev/null; echo $$?)

install_env:

ifeq "${exists_bundler}" ""
	sudo gem install bundler
endif

	@echo "All dependencies was installed"

install:

ifeq "${exists_bundler}" ""
	@echo "Bundler is not installed. Use `make install_env`"
endif

ifneq ($(bundle_check), 0)
	bundle install
endif

	bundle exec pod install --repo-update

bootstrap: install

release:

ifeq "${exists_bundler}" ""
	@echo "Bundler is not installed. Use `make install_env`"
endif

	bundle exec fastlane release
