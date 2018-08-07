#!/bin/sh
find $1 -name "*.swift" ! -path "$1/R.generated.swift" -print0 | xargs -0 xcrun extractLocStrings

scripts/tools/lokalise --token $2 import 3947163159df13df851b51.98101647 --file Localizable.strings --lang_iso en --replace 1
scripts/tools/lokalise --token $2 export 3947163159df13df851b51.98101647 --type strings --bundle_structure %LANG_ISO%.lproj/Localizable.%FORMAT% --export_empty base
unzip -o Trust-Localizable.zip -d $1/Localization
