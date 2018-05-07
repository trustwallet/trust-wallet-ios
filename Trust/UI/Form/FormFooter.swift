// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class FormFooterView: UIView {

    let titleLabel = UILabel(frame: .zero)
    let errorLabel = UILabel(frame: .zero)

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.numberOfLines = 0

        addSubview(titleLabel)
        addSubview(errorLabel)

        NSLayoutConstraint.activate([
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 25),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            errorLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            errorLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            ])

        backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
