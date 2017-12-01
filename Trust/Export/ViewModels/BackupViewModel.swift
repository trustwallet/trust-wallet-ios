// Copyright SIX DAY LLC. All rights reserved.

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
            format: NSLocalizedString("export.noBackup.title", value: "No backup, no %@.", comment: ""),
            config.server.name
        )
    }
}
