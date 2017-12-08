// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct SkipBackupFilesInitializer: Initializer {

    func perform() {
        let directories = NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true)

        directories.forEach { addSkipBackupAttributeToItemAtURL(filePath: $0) }
    }

    @discardableResult
    func addSkipBackupAttributeToItemAtURL(filePath: String) -> Bool {
        let url: NSURL = NSURL.fileURL(withPath: filePath) as NSURL
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
