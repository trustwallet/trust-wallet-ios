// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class ExchangeTokenTableViewCell: UITableViewCell {

    let tokenImageView = UIImageView()
    let tokenNameLabel = UILabel()
    let balanceLabel = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        tokenImageView.translatesAutoresizingMaskIntoConstraints = false
        tokenImageView.contentMode = .scaleAspectFit

        tokenNameLabel.translatesAutoresizingMaskIntoConstraints = false
        balanceLabel.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView(arrangedSubviews: [
            tokenImageView,
            tokenNameLabel,
            balanceLabel,
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 10

        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            tokenImageView.widthAnchor.constraint(equalToConstant: 40),
            tokenImageView.heightAnchor.constraint(equalToConstant: 40),

            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            stackView.heightAnchor.constraint(equalToConstant: 70),
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
