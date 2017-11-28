#!/usr/bin/env bash

brew update

bundler install
bundle exec fastlane
