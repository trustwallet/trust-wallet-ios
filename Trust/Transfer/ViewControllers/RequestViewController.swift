// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import CoreImage
import MBProgressHUD
import StackViewController

class RequestViewController: UIViewController {

    let stackViewController = StackViewController()

    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    lazy var copyButton: UIButton = {
        let button = Button(size: .normal, style: .border)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(viewModel.copyWalletText, for: .normal)
        button.addTarget(self, action: #selector(copyAddress), for: .touchUpInside)
        return button
    }()

    lazy var addressHintLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.text = viewModel.headlineText
        return label
    }()

    lazy var addressLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = viewModel.myAddressText
        label.textAlignment = .center
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    let viewModel: RequestViewModel

    init(
        viewModel: RequestViewModel
    ) {
        self.viewModel = viewModel

        stackViewController.scrollView.alwaysBounceVertical = true

        super.init(nibName: nil, bundle: nil)

        view.backgroundColor = viewModel.backgroundColor

        displayStackViewController()

        stackViewController.addItem(addressHintLabel)

        stackViewController.addItem(imageView)
        stackViewController.addItem(addressLabel)
        stackViewController.addItem(copyButton)

        NSLayoutConstraint.activate([
            copyButton.trailingAnchor.constraint(equalTo: stackViewController.stackView.layoutMarginsGuide.trailingAnchor),
            copyButton.leadingAnchor.constraint(equalTo: stackViewController.stackView.layoutMarginsGuide.leadingAnchor),

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

    func changeQRCode(value: Int) {
        let string = viewModel.myAddressText

        // EIP67 format not being used much yet, use hex value for now
        // let string = "ethereum:\(account.address.address)?value=\(value)"

        DispatchQueue.global(qos: .background).async {
            let image = self.generateQRCode(from: string)
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
    }

    @objc func copyAddress() {
        UIPasteboard.general.string = viewModel.myAddressText

        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = .text
        hud.label.text = viewModel.addressCopiedText
        hud.hide(animated: true, afterDelay: 1.5)
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
