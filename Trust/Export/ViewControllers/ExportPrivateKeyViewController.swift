// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import TrustKeystore
import UIKit
import StackViewController
import MBProgressHUD
import CoreImage

class ExportPrivateKeyViewConroller: UIViewController {

    let stackViewController = StackViewController()
    var context = CIContext()

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
        button.setTitle(viewModel.btnTitlte, for: .normal)
        button.addGestureRecognizer(longGesture)
        return button
    }()

    lazy var hintLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.text = viewModel.headlineText
        label.textColor = .red
        return label
    }()

    lazy var warningKeyLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = viewModel.warningText
        label.textColor = .red
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    let viewModel: ExportPrivateKeyViewModel

    init(
        viewModel: ExportPrivateKeyViewModel
        ) {
        self.viewModel = viewModel

        stackViewController.scrollView.alwaysBounceVertical = true

        super.init(nibName: nil, bundle: nil)

        view.backgroundColor = viewModel.backgroundColor

        displayStackViewController()

        stackViewController.addItem(hintLabel)

        stackViewController.addItem(imageView)
        stackViewController.addItem(warningKeyLabel)
        stackViewController.addItem(revalQRCodeButton)

        NSLayoutConstraint.activate([
            revalQRCodeButton.trailingAnchor.constraint(equalTo: stackViewController.stackView.layoutMarginsGuide.trailingAnchor),
            revalQRCodeButton.leadingAnchor.constraint(equalTo: stackViewController.stackView.layoutMarginsGuide.leadingAnchor),

            imageView.widthAnchor.constraint(equalToConstant: 260),
            imageView.heightAnchor.constraint(equalToConstant: 260),
            ])

        changeQRCode(value: 0)
    }

    private func displayStackViewController() {
        addChildViewController(stackViewController)
        view.addSubview(stackViewController.view)
        _ = stackViewController.view.activateSuperviewHuggingConstraints()
        stackViewController.didMove(toParentViewController: self)

        stackViewController.stackView.spacing = 20
        stackViewController.stackView.alignment = .center
        stackViewController.stackView.layoutMargins = UIEdgeInsets(top: 20, left: 15, bottom: 0, right: 15)
        stackViewController.stackView.isLayoutMarginsRelativeArrangement = true
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        changeQRCode(value: Int(textField.text ?? "0") ?? 0)
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

    func changeQRCode(value: Int) {
        let string = viewModel.privateKey

        // EIP67 format not being used much yet, use hex value for now
        // let string = "ethereum:\(account.address.address)?value=\(value)"

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
