// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit

final class FieldAppereance {

    static func addressFieldRightView(
        pasteAction: @escaping () -> Void,
        qrAction: @escaping () -> Void
    ) -> UIView {
        let pasteButton = Button(size: .normal, style: .borderless)
        pasteButton.translatesAutoresizingMaskIntoConstraints = false
        pasteButton.setTitle(NSLocalizedString("send.paste.button.title", value: "Paste", comment: ""), for: .normal)
        UITapGestureRecognizer(addToView: pasteButton) {
            pasteAction()
        }

        let qrButton = UIButton(type: .custom)
        qrButton.translatesAutoresizingMaskIntoConstraints = false
        qrButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        qrButton.setImage(R.image.qr_code_icon(), for: .normal)
        qrButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        UITapGestureRecognizer(addToView: qrButton) {
            qrAction()
        }
        let recipientRightView = UIStackView(arrangedSubviews: [
            pasteButton,
            qrButton,
        ])
        recipientRightView.translatesAutoresizingMaskIntoConstraints = false
        recipientRightView.distribution = .equalSpacing
        recipientRightView.spacing = 2
        recipientRightView.axis = .horizontal
        return recipientRightView
    }
}
