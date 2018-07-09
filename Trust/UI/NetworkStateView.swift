// Copyright DApps Platform Inc. All rights reserved.

import UIKit

enum NetworkCondition {
    case good(Int)
    case bad

    static func from(_ state: Bool, _ block: Int) -> NetworkCondition {
        return state == true ? .good(block) : .bad
    }
}

final class NetworkStateView: UIView {
    var viewModel: NetworkConditionViewModel? = nil {
        didSet {
            guard let viewModel = viewModel else { return }
            updateLayout(with: viewModel)
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
        view.image = R.image.cube()
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

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    private func updateLayout(with viewModel: NetworkConditionViewModel) {
        stateRoundView.backgroundColor = viewModel.color
        stateViewLabel.text = viewModel.localizedTitle
        blockViewLabel.text = viewModel.block
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
