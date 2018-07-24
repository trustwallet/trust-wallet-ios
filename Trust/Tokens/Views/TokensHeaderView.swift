// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit

final class TokensHeaderView: UIView {

    lazy var amountLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = Colors.black
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        amountLabel.translatesAutoresizingMaskIntoConstraints = false

        let spacing = StyleLayout.sideMargin + 10
        let stackView = UIStackView(arrangedSubviews: [
            .spacer(height: spacing),
            amountLabel,
            .spacer(height: spacing),
            .spacer(height: 0.5, backgroundColor: Colors.lightGray, alpha: 0.5),
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
