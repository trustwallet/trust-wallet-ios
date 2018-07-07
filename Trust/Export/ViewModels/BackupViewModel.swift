// Copyright DApps Platform Inc. All rights reserved.

import Foundation

struct BackupViewModel {

    let config: Config

    init(
        config: Config = Config()
    ) {
        self.config = config
    }

    var headlineText: String {
        return String(
            format: NSLocalizedString("export.noBackup.label.title", value: "No backup, no %@.", comment: ""),
            config.server.name
        )
    }
}
