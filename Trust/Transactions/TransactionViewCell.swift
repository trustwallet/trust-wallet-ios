// Copyright SIX DAY LLC, Inc. All rights reserved.

import UIKit

class TransactionViewCell: UITableViewCell {

    static let identifier = "TransactionTableViewCell"
    
    
    let titleLabel = UILabel()
    let amountLabel = UILabel()
    let subTitleLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subTitleLabel.lineBreakMode = .byTruncatingMiddle
        
        amountLabel.textAlignment = .right
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let leftStackView = UIStackView(arrangedSubviews: [titleLabel, subTitleLabel])
        leftStackView.translatesAutoresizingMaskIntoConstraints = false
        leftStackView.axis = .vertical
        leftStackView.spacing = 6
        
        let rightStackView = UIStackView(arrangedSubviews: [amountLabel])
        rightStackView.translatesAutoresizingMaskIntoConstraints = false
        rightStackView.axis = .vertical
        
        let stackView = UIStackView(arrangedSubviews: [leftStackView, rightStackView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        
        subTitleLabel.setContentHuggingPriority(UILayoutPriorityDefaultLow, for: .horizontal)
        titleLabel.setContentHuggingPriority(UILayoutPriorityDefaultLow, for: .horizontal)
        
        amountLabel.setContentHuggingPriority(UILayoutPriorityRequired, for: .horizontal)
        stackView.setContentHuggingPriority(UILayoutPriorityRequired, for: .horizontal)
        
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: Layout.sideMargin),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Layout.sideMargin),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -Layout.sideMargin),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.sideMargin),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(viewModel: TransactionViewCellViewModel) {
        titleLabel.text = viewModel.title
        
        subTitleLabel.text = viewModel.subTitle
        subTitleLabel.textColor = viewModel.subTitleTextColor
        subTitleLabel.font = viewModel.subTitleFont
        
        amountLabel.text = viewModel.amount
        amountLabel.textColor = viewModel.amountTextColor
        amountLabel.font = viewModel.amountFont
        
        backgroundColor = viewModel.backgroundColor
    }
}
