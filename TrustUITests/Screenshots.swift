// Copyright SIX DAY LLC. All rights reserved.

import XCTest

class Screenshots: XCTestCase {
        
    override func setUp() {
        super.setUp()
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }

    func testMakeScreenshots() {
        let app = XCUIApplication()
        
        snapshot("0Launch")

        app.buttons["import-wallet"].tap()

        snapshot("3ImportWallet")
        sleep(6)

        app.buttons["send-button"].tap()
        app.tables.textFields["amount-field"].tap()

        snapshot("1SendRequest")

        app.navigationBars.buttons.element(boundBy: 0).tap()

        snapshot("4Transactions")

        app.tabBars.buttons.element(boundBy: 1).tap()
        sleep(8)
        snapshot("2Tokens")
    }

    var currentLanguage: (langCode: String, localeCode: String)? {
        let currentLocale = Locale(identifier: Locale.preferredLanguages.first!)
        guard let langCode = currentLocale.languageCode else {
            return nil
        }
        var localeCode = langCode
        if let scriptCode = currentLocale.scriptCode {
            localeCode = "\(langCode)-\(scriptCode)"
        } else if let regionCode = currentLocale.regionCode {
            localeCode = "\(langCode)-\(regionCode)"
        }
        return (langCode, localeCode)
    }

    func localized(_ key: String) -> String {
        let testBundle = Bundle(for: TrustUITests.self)
        if let currentLanguage = currentLanguage,
            let testBundlePath = testBundle.path(forResource: currentLanguage.localeCode, ofType: "lproj") ?? testBundle.path(forResource: currentLanguage.langCode, ofType: "lproj"),
            let localizedBundle = Bundle(path: testBundlePath)
        {
            return NSLocalizedString(key, bundle: localizedBundle, comment: "")
        }
        return "?"
    }
}
