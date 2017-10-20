// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum Web3RequestType {
    case function(command: String)
    case variable(command: String)
    case script(command: String)
}
