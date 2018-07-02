// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import QRCodeReaderViewController

protocol ScanQRCodeCoordinatorDelegate: class {
    func didCancel(in coordinator: ScanQRCodeCoordinator)
    func didScan(result: String, in coordinator: ScanQRCodeCoordinator)
}

class ScanQRCodeCoordinator: NSObject, Coordinator {
    var coordinators: [Coordinator] = []
    weak var delegate: ScanQRCodeCoordinatorDelegate?

    let navigationController: NavigationController
    lazy var qrcodeController: QRCodeReaderViewController = {
        let controller = QRCodeReaderViewController(cancelButtonTitle: R.string.localizable.cancel())
        controller.delegate = self
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss))
        controller.delegate = self
        return controller
    }()

    init(
        navigationController: NavigationController = NavigationController()
        ) {
        self.navigationController = navigationController
    }

    func start() {
        navigationController.present(qrcodeController, animated: true, completion: nil)
    }

    @objc func dismiss() {
        qrcodeController.dismiss(animated: true, completion: nil)
    }
}

extension ScanQRCodeCoordinator: QRCodeReaderDelegate {
    func readerDidCancel(_ reader: QRCodeReaderViewController!) {
        reader.stopScanning()
        reader.dismiss(animated: true)
        delegate?.didCancel(in: self)
    }

    func reader(_ reader: QRCodeReaderViewController!, didScanResult result: String!) {
        reader.stopScanning()
        delegate?.didScan(result: result, in: self)
        reader.dismiss(animated: true)
    }
}
