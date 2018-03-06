// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import RealmSwift

class Bookmark: Object {
    @objc dynamic var url: String = ""
    
    convenience init(
            url: String = ""
        ) {
        self.init()
        self.url = url
    }
}
