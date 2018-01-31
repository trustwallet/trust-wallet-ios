// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct SkipBackupFilesInitializer: Initializer {

    let paths: [String]

    init(paths: [String]) {
        self.paths = paths
    }

    func perform() {
        paths.forEach { addSkipBackupAttributeToItemAtURL(filePath: $0) }
    }

    @discardableResult
    func addSkipBackupAttributeToItemAtURL(filePath: String) -> Bool {
        let url = NSURL.fileURL(withPath: filePath) as NSURL
        do {
            try url.setResourceValue(true, forKey: .isExcludedFromBackupKey)
            try url.setResourceValue(false, forKey: .isUbiquitousItemKey)
            return true
        } catch let error {
            NSLog("Failed to exclude datastore from backup \(error.localizedDescription)")
            return false
        }
    }
}
