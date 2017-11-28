#!/usr/bin/env bash

rvm install ruby-2.3.1
brew update

bundler install
bundle exec fastlane
