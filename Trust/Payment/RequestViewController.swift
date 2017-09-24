// Copyright SIX DAY LLC, Inc. All rights reserved.

import Foundation
import UIKit
import CoreImage
import MBProgressHUD

class RequestViewController: UIViewController {

    private lazy var viewModel: RequestViewModel = {
        return .init(transferType: self.transferType)
    }()

    let account: Account
    let amountTextField: UITextField
    let QRImageView: UIImageView
    let copyButton: UIButton
    let addressLabel: UILabel
    let transferType: TransferType

    init(account: Account, transferType: TransferType = .ether) {
        self.account = account
        self.transferType = transferType
        amountTextField = UITextField(frame: .zero)
        QRImageView = UIImageView(frame: .zero)
        copyButton = Button(size: .normal, style: .border)
        addressLabel = UILabel(frame: .zero)

        super.init(nibName: nil, bundle: nil)

        title = viewModel.title
        view.backgroundColor = viewModel.backgroundColor

        amountTextField.translatesAutoresizingMaskIntoConstraints = false
        amountTextField.placeholder = "Enter ETH amount"
        amountTextField.textAlignment = .center
        amountTextField.keyboardType = .decimalPad
        amountTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        QRImageView.translatesAutoresizingMaskIntoConstraints = false

        copyButton.translatesAutoresizingMaskIntoConstraints = false
        copyButton.setTitle("Copy Wallet Address", for: .normal)
        copyButton.addTarget(self, action: #selector(copyAddress), for: .touchUpInside)

        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        addressLabel.text = account.address.address
        addressLabel.textAlignment = .center
        addressLabel.minimumScaleFactor = 0.5
        addressLabel.adjustsFontSizeToFitWidth = true

        let stackView = UIStackView(arrangedSubviews: [
            //amountTextField,
            QRImageView,
            addressLabel,
            copyButton,
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 20

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: Layout.sideMargin + 64),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.sideMargin),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -Layout.sideMargin),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.sideMargin),

            copyButton.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            copyButton.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),

            QRImageView.heightAnchor.constraint(equalToConstant: 290),
            QRImageView.widthAnchor.constraint(equalToConstant: 290),
        ])

        changeQRCode(value: 0)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    func textFieldDidChange(_ textField: UITextField) {
        changeQRCode(value: Int(textField.text ?? "0") ?? 0)
    }

    func changeQRCode(value: Int) {
        let string = "ethereum:\(account.address.address)?value=\(value)"

        DispatchQueue.global(qos: .background).async {
            let image = self.generateQRCode(from: string)
            DispatchQueue.main.async {
                self.QRImageView.image = image
            }
        }
    }

    @objc func copyAddress() {
        UIPasteboard.general.string = account.address.address

        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = .text
        hud.label.text = "Address Copied"
        hud.hide(animated: true, afterDelay: 1.5)
    }

    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 6, y: 6)
            if let output = filter.outputImage?.applying(transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
