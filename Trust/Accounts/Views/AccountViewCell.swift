// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class AccountViewCell: UITableViewCell {

    static let identifier = "AccountViewCell"

    let walletImageView = UIImageView()
    let walletLabel = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        walletImageView.translatesAutoresizingMaskIntoConstraints = false
        walletImageView.layer.cornerRadius = 6
        walletImageView.layer.masksToBounds = true

        walletLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(walletImageView)
        contentView.addSubview(walletLabel)

        NSLayoutConstraint.activate([
            walletImageView.widthAnchor.constraint(equalToConstant: 34),
            walletImageView.heightAnchor.constraint(equalToConstant: 34),
            walletImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            walletImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.sideMargin),

            walletLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Layout.sideMargin),
            walletLabel.leadingAnchor.constraint(equalTo: walletImageView.trailingAnchor, constant: Layout.sideMargin),
            walletLabel.topAnchor.constraint(equalTo: topAnchor),
            walletLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    func configure(viewModel: AccountViewModel) {
        walletImageView.image = viewModel.image
        walletLabel.text = viewModel.title
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
