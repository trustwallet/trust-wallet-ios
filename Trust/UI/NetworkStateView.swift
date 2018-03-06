// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class NetworkStateView: UIView {

    enum NetworkCondition {
        case good
        case bad

        func localizedTitle() -> String {
            switch self {
            case .good:
                return NSLocalizedString("network.state.good", value: "Good", comment: "Good")
            case .bad:
                return NSLocalizedString("network.state.bad", value: "Bad", comment: "Bad")
            }
        }

        func color() -> UIColor {
            switch self {
            case .good:
                return Colors.green
            case .bad:
                return Colors.red
            }
        }
    }

    var currentState: NetworkCondition? = nil {
        didSet {
            updateLayout()
        }
    }

    private lazy var container: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.spacing = 5
        return stackView
    }()

    private lazy var stateViewRoundView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        view.clipsToBounds = true
        view.layer.cornerRadius = view.frame.width/2
        return view
    }()

    private lazy var stateViewLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .left
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    private func updateLayout() {
        guard let state = currentState else {
            return
        }

        stateViewRoundView.backgroundColor = state.color()
        stateViewLabel.text = state.localizedTitle()
    }

    private func setupLayout() {

        container.addArrangedSubview(stateViewRoundView)
        container.addArrangedSubview(stateViewLabel)

        self.addSubview(container)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),
            stateViewRoundView.widthAnchor.constraint(equalToConstant: 10),
            stateViewRoundView.heightAnchor.constraint(equalToConstant: 10),
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
