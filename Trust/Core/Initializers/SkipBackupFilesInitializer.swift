// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct SkipBackupFilesInitializer: Initializer {

    let urls: [URL]

    init(paths: [URL]) {
        self.urls = paths
    }

    func perform() {
        urls.forEach { addSkipBackupAttributeToItemAtURL($0) }
    }

    @discardableResult
    func addSkipBackupAttributeToItemAtURL(_ url: URL) -> Bool {
        let url = NSURL.fileURL(withPath: url.path) as NSURL
        do {
            try url.setResourceValue(true, forKey: .isExcludedFromBackupKey)
            try url.setResourceValue(false, forKey: .isUbiquitousItemKey)
            return true
        } catch let error {
            return false
        }
    }
}
