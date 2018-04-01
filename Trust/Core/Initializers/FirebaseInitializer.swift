// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Firebase

struct FirebaseInitializer: Initializer {

    func perform() {
        //guard !isDebug else { return }

        FirebaseApp.configure()
    }
}
