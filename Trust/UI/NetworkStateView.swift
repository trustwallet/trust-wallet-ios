// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class NetworkStateView: UIView {

    enum NetworkCondition {
        case good(Int)
        case bad

        func localizedTitle() -> String {
            return Config().server.name
        }

        func color() -> UIColor {
            switch self {
            case .good:
                return Colors.green
            case .bad:
                return Colors.red
            }
        }

        func block() -> Int {
            switch self {
            case .good(let block):
                return block
            case .bad:
                return 0
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
        stackView.spacing = 5
        stackView.distribution = .fill
        stackView.axis = .vertical
        return stackView
    }()

    private lazy var containerForTop: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 5
        return stackView
    }()

    private lazy var containerForBottom: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 5
        return stackView
    }()

    private lazy var stateRoundView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 12))
        view.clipsToBounds = true
        view.layer.cornerRadius = view.frame.width/2
        return view
    }()

    private lazy var blockImageView: UIImageView = {
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: 12, height: 12))
        view.image = UIImage(named: "cube")
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

    private lazy var blockViewLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .left
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()

    private let formmater = StringFormatter()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    private func updateLayout() {
        guard let state = currentState else {
            return
        }

        stateRoundView.backgroundColor = state.color()
        stateViewLabel.text = state.localizedTitle()
        blockViewLabel.text = formmater.formatter(for: state.block())
    }

    private func setupLayout() {

        containerForTop.addArrangedSubview(stateRoundView)
        containerForTop.addArrangedSubview(stateViewLabel)

        containerForBottom.addArrangedSubview(blockImageView)
        containerForBottom.addArrangedSubview(blockViewLabel)

        container.addArrangedSubview(containerForTop)
        container.addArrangedSubview(containerForBottom)

        self.addSubview(container)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),
            stateRoundView.widthAnchor.constraint(equalToConstant: 12),
            stateRoundView.heightAnchor.constraint(equalToConstant: 12),
            blockImageView.widthAnchor.constraint(equalToConstant: 12),
            blockImageView.heightAnchor.constraint(equalToConstant: 12),
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
