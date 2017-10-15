// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class AccountViewCell: UITableViewCell {

    static let identifier = "AccountViewCell"

    let walletImageView = UIImageView()
    let walletLabel = UILabel()

    private struct Layout {
        static let activeSize: CGFloat = 8
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        walletImageView.translatesAutoresizingMaskIntoConstraints = false
        walletImageView.layer.cornerRadius = Layout.activeSize / 2
        walletImageView.layer.masksToBounds = true

        walletLabel.translatesAutoresizingMaskIntoConstraints = false
        walletLabel.lineBreakMode = .byTruncatingMiddle

        contentView.addSubview(walletImageView)
        contentView.addSubview(walletLabel)

        NSLayoutConstraint.activate([
            walletImageView.widthAnchor.constraint(equalToConstant: Layout.activeSize),
            walletImageView.heightAnchor.constraint(equalToConstant: Layout.activeSize),
            walletImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            walletImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: StyleLayout.sideMargin),

            walletLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -StyleLayout.sideMargin),
            walletLabel.leadingAnchor.constraint(equalTo: walletImageView.trailingAnchor, constant: StyleLayout.sideMargin),
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
