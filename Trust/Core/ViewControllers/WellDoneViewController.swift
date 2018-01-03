// Copyright SIX DAY LLC. All rights reserved.

import UIKit

enum WellDoneAction {
    case other
}

protocol WellDoneViewControllerDelegate: class {
    func didPress(action: WellDoneAction, sender: UIView, in viewController: WellDoneViewController)
}

class WellDoneViewController: UIViewController {

    weak var delegate: WellDoneViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        let imageView = UIImageView(image: R.image.mascot_happy())
        imageView.translatesAutoresizingMaskIntoConstraints = false

//        let facebookButton = Button(size: .normal, style: .solid)
//        facebookButton.translatesAutoresizingMaskIntoConstraints = false
//        facebookButton.setTitle(NSLocalizedString("Facebook", value: "Facebook", comment: ""), for: .normal)
//        facebookButton.addTarget(self, action: #selector(facebook), for: .touchUpInside)
//
//        let twitterButton = Button(size: .normal, style: .solid)
//        twitterButton.translatesAutoresizingMaskIntoConstraints = false
//        twitterButton.setTitle(NSLocalizedString("Twitter", value: "Twitter", comment: ""), for: .normal)
//        twitterButton.addTarget(self, action: #selector(twitter), for: .touchUpInside)
//
//        let buttonsStackView = UIStackView(arrangedSubviews: [
//            facebookButton,
//            twitterButton,
//        ])
//        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
//        buttonsStackView.axis = .horizontal
//        buttonsStackView.spacing = 16

//        let titleLabel = UILabel()
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        titleLabel.text = NSLocalizedString("welldone.title.label.text", value: "Thank you!", comment: "")
//        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
//        titleLabel.textColor = Colors.blue

        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = NSLocalizedString("welldone.description.label.text", value: "Help us grow by sharing this app with your friends!", comment: "")
        descriptionLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        descriptionLabel.textColor = Colors.blue
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center

        let otherButton = Button(size: .normal, style: .solid)
        otherButton.translatesAutoresizingMaskIntoConstraints = false
        otherButton.setTitle(NSLocalizedString("welldone.share.label.text", value: "Share", comment: ""), for: .normal)
        otherButton.addTarget(self, action: #selector(other(_:)), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [
            imageView,
            //titleLabel,
            descriptionLabel,
            .spacer(height: 10),
            .spacer(),
            otherButton,
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.spacing = 10

        view.backgroundColor = .white
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor),

            otherButton.widthAnchor.constraint(equalToConstant: 240),
        ])
    }

//    @objc private func facebook(sender: UIBarButtonItem) {
//        delegate?.didPress(action: .facebook, sender: sender)
//    }
//
//    @objc private func twitter(sender: UIBarButtonItem) {
//        delegate?.didPress(action: .twitter, sender: sender)
//    }

    @objc private func other(_ sender: UIView) {
        delegate?.didPress(action: .other, sender: sender, in: self)
    }
}
