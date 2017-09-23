// Copyright SIX DAY LLC, Inc. All rights reserved.

import Foundation
import UIKit

class LoadingView: UIView {

    let label = UILabel()
    let imageView = UIImageView()

    init(message: String = "Loading...", image: UIImage? = .none) {
        super.init(frame: .zero)

        backgroundColor = .white

        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = message

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = image

        let stackView = UIStackView(arrangedSubviews: [label, imageView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.spacing = 10

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
