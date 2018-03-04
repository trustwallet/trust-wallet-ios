// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import RealmSwift

class BookmarkObject: Object {
    @objc dynamic var url: String = ""
    
    convenience init(
            url: String = ""
        ) {
        self.init()
        self.url = url
    }
}
