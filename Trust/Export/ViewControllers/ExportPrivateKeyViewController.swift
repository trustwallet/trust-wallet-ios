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
        return label
    }()

    lazy var hud: MBProgressHUD = {
        let hud = MBProgressHUD.showAdded(to: imageView, animated: true)
        hud.mode = .text
        hud.label.text = NSLocalizedString("export.qrCode.loading.label", value: "Generating QR Code", comment: "")
        return hud
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
            revalQRCodeButton,
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

            revalQRCodeButton.trailingAnchor.constraint(equalTo: stackView.layoutMarginsGuide.trailingAnchor),
            revalQRCodeButton.leadingAnchor.constraint(equalTo: stackView.layoutMarginsGuide.leadingAnchor),

            imageView.heightAnchor.constraint(equalToConstant: Layout.widthAndHeight),
            imageView.trailingAnchor.constraint(lessThanOrEqualTo: stackView.layoutMarginsGuide.trailingAnchor, constant: StyleLayout.sideMargin * 2.5),
            imageView.leadingAnchor.constraint(lessThanOrEqualTo: stackView.layoutMarginsGuide.leadingAnchor, constant: StyleLayout.sideMargin * 2.5),

        ])
    }

    func blur(image: UIImageView) {
        let blur = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: blur)

        view.frame = image.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.alpha = CGFloat(0.95)

        image.addSubview(view)
    }

    @objc func unBlur() {
        createQRCode()
        for view in imageView.subviews {
            guard let view = view as? UIVisualEffectView else { return }
            view.removeFromSuperview()
        }
    }

    func createQRCode() {
        hud.show(animated: true)
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let `self` = self else { return }
            let string = self.viewModel.privateKey
            let image = self.generateQRCode(from: string)
            DispatchQueue.main.async {
                self.imageView.image = image
                self.hud.hide(animated: true)
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
