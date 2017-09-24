# Warn when there is a big PR
warn("Big PR") if git.lines_of_code > 300
warn("Large PR") if git.lines_of_code > 500
warn("Huge PR") if git.lines_of_code > 700

xcode_summary.ignored_files = "**/Pods/**"
xcode_summary.test_summary = false
xcode_summary.report "build/reports/errors.json"

swiftlint.config_file = ".swiftlint.yml"
swiftlint.lint_files inline_mode: true
