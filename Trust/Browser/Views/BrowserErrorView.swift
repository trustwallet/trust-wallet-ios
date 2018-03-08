// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class BrowserErrorView: UIView {

    private let topMargin: CGFloat = 120
    private let leftMargin: CGFloat = 40

    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = Colors.gray
        label.font = UIFont.systemFont(ofSize: 18)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    init() {
        super.init(frame: CGRect.zero)
        finishInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        finishInit()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show(error: Error) {
        self.isHidden = false
        textLabel.text = error.localizedDescription
        textLabel.textAlignment = .center
        textLabel.setNeedsLayout()
    }

    private func finishInit() {
        self.backgroundColor = .white
        addSubview(textLabel)
        NSLayoutConstraint.activate([
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leftMargin),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -leftMargin),
            textLabel.topAnchor.constraint(equalTo: topAnchor, constant: topMargin),
        ])
    }
}
