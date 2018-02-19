// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import TrustKeystore
import UIKit
import MBProgressHUD

class ExportPrivateKeyViewConroller: UIViewController {

    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        blur(image: imageView)
        return imageView
    }()

    lazy var revalQRCodeButton: UIButton = {
        let button = Button(size: .normal, style: .border)
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(unBlur))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(viewModel.revealButtonTitle, for: .normal)
        button.addGestureRecognizer(longGesture)
        return button
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
        label.lineBreakMode = .byWordWrapping
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
            .spacer(),
            imageView,
            warningKeyLabel,
            .spacer(height: 15),
            revalQRCodeButton,
            ]
        )
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.backgroundColor = viewModel.backgroundColor
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(greaterThanOrEqualTo: view.layoutGuide.topAnchor, constant: StyleLayout.sideMargin),
            stackView.leadingAnchor.constraint(equalTo: view.layoutGuide.leadingAnchor, constant: StyleLayout.sideMargin),
            stackView.trailingAnchor.constraint(equalTo: view.layoutGuide.trailingAnchor, constant: -StyleLayout.sideMargin),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.layoutGuide.bottomAnchor, constant: -StyleLayout.bottomMargin),

            revalQRCodeButton.trailingAnchor.constraint(equalTo: stackView.layoutMarginsGuide.trailingAnchor),
            revalQRCodeButton.leadingAnchor.constraint(equalTo: stackView.layoutMarginsGuide.leadingAnchor),

            imageView.widthAnchor.constraint(equalToConstant: 260),
            imageView.heightAnchor.constraint(equalToConstant: 260),
            ])
        createQRCode()
    }

    func blur(image: UIImageView) {
        let blur = UIBlurEffect(style: .extraLight)
        let view = UIVisualEffectView(effect: blur)

        view.frame = image.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.alpha = CGFloat(0.95)

        image.addSubview(view)
    }

    @objc func unBlur() {
        for view in imageView.subviews {
            guard let view = view as? UIVisualEffectView else { return }
            view.removeFromSuperview()
        }
    }

    func createQRCode() {
        let string = viewModel.privateKey

        DispatchQueue.global(qos: .background).async {
            let image = self.generateQRCode(from: string)
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
    }

    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 7, y: 7)
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
