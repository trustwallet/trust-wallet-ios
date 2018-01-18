// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct TestKeyStore {
    static let keystore: String = "{\"address\":\"5e9c27156a612a2d516c74c7a80af107856f8539\",\"crypto\":{\"cipher\":\"aes-128-ctr\",\"ciphertext\":\"5eb0c790d1fb27824c78acac9233241b340c329b46aba08c6533b70ab67ea74f\",\"cipherparams\":{\"iv\":\"e5ab559977af075eda00a97c8f0ce506\"},\"kdf\":\"scrypt\",\"kdfparams\":{\"dklen\":32,\"n\":4096,\"p\":6,\"r\":8,\"salt\":\"b43142f34caf2b3b39c16f52344701f800711589f799cdae1827ac2f844f9602\"},\"mac\":\"c6ccaecca7896974dacac91a8116216ec287930bc74bfd7694a94f08bd992095\"},\"id\":\"e3554f73-4d0a-40a0-b721-fc801623d5ba\",\"version\":3}"
    static let password: String = "test"
    static let newPassword: String = "test123"
    static let testPrivateKey = "9cdb5cab19aec3bd0fcd614c5f185e7a1d97634d4225730eba22497dc89a716c"
}
