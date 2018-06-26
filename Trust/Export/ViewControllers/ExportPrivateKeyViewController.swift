// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import TrustCore
import UIKit
import MBProgressHUD

class ExportPrivateKeyViewConroller: UIViewController {

    private struct Layout {
        static var widthAndHeight: CGFloat = 260
    }

    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    lazy var hintLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.text = viewModel.headlineText
        label.textColor = Colors.red
        return label
    }()

    lazy var warningKeyLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = viewModel.warningText
        label.textColor = Colors.red
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    let viewModel: ExportPrivateKeyViewModel

    init(
        viewModel: ExportPrivateKeyViewModel
    ) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)

        view.backgroundColor = viewModel.backgroundColor

        let stackView = UIStackView(
            arrangedSubviews: [
            hintLabel,
            imageView,
            warningKeyLabel,
        ])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.backgroundColor = viewModel.backgroundColor
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.layoutGuide.topAnchor, constant: StyleLayout.sideMargin),
            stackView.leadingAnchor.constraint(equalTo: view.layoutGuide.leadingAnchor, constant: StyleLayout.sideMargin),
            stackView.trailingAnchor.constraint(equalTo: view.layoutGuide.trailingAnchor, constant: -StyleLayout.sideMargin),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.layoutGuide.bottomAnchor, constant: -StyleLayout.sideMargin),

            imageView.heightAnchor.constraint(equalToConstant: Layout.widthAndHeight),
            imageView.trailingAnchor.constraint(lessThanOrEqualTo: stackView.layoutMarginsGuide.trailingAnchor, constant: StyleLayout.sideMargin * 2.5),
            imageView.leadingAnchor.constraint(lessThanOrEqualTo: stackView.layoutMarginsGuide.leadingAnchor, constant: StyleLayout.sideMargin * 2.5),
        ])

        createQRCode()
    }

    func createQRCode() {
        displayLoading()
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let `self` = self else { return }
            let image = QRGenerator.generate(from: self.viewModel.privateKeyString)
            DispatchQueue.main.async {
                self.imageView.image = image
                self.hideLoading()
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
