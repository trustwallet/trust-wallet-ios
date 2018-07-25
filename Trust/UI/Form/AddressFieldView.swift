// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit

class AddressFieldView: UIView {
    let pasteButton: Button = Button(size: .normal, style: .borderless)
    let qrButton: UIButton = UIButton(type: .custom)

    init() {
        super.init(frame: .zero)
        pasteButton.translatesAutoresizingMaskIntoConstraints = false
        pasteButton.setTitle(R.string.localizable.sendPasteButtonTitle(), for: .normal)

        qrButton.translatesAutoresizingMaskIntoConstraints = false
        qrButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        qrButton.setImage(R.image.qr_code_icon(), for: .normal)
        qrButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        let recipientRightView = UIStackView(arrangedSubviews: [
            pasteButton,
            qrButton,
        ])
        recipientRightView.translatesAutoresizingMaskIntoConstraints = false
        recipientRightView.distribution = .equalSpacing
        recipientRightView.spacing = 2
        recipientRightView.axis = .horizontal

        addSubview(recipientRightView)

        NSLayoutConstraint.activate([
            recipientRightView.topAnchor.constraint(equalTo: topAnchor),
            recipientRightView.leadingAnchor.constraint(equalTo: leadingAnchor),
            recipientRightView.bottomAnchor.constraint(equalTo: bottomAnchor),
            recipientRightView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
