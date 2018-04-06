// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class FloatingBrowserFooter: UIView {

    struct Layout {
        static let width: CGFloat = 52
        static let offset: CGFloat = 5
    }

    lazy var historyButton: UIButton = {
        let button = Button(size: .normal, style: .borderless)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(R.image.browserHistory(), for: .normal)
        return button
    }()

    lazy var bookmarksButton: UIButton = {
        let button = Button(size: .normal, style: .borderless)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(R.image.browserBookmark(), for: .normal)
        return button
    }()

    lazy var qrcodeButton: UIButton = {
        let button = Button(size: .normal, style: .borderless)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(R.image.qr_code_icon(), for: .normal)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        let stackView = UIStackView(arrangedSubviews: [
            bookmarksButton,
            historyButton,
            qrcodeButton,
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        addSubview(stackView)

        backgroundColor = .white
        layer.cornerRadius = 5
        layer.masksToBounds = true
        layer.borderWidth = 0.5
        layer.borderColor = Colors.lightGray.cgColor

        NSLayoutConstraint.activate([

            bookmarksButton.widthAnchor.constraint(equalToConstant: Layout.width),
            historyButton.widthAnchor.constraint(equalToConstant: Layout.width),
            qrcodeButton.widthAnchor.constraint(equalToConstant: Layout.width),

            stackView.topAnchor.constraint(equalTo: topAnchor, constant: Layout.offset),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.offset),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Layout.offset),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Layout.offset),
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
