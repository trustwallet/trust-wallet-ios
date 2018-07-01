// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import QRCodeReaderViewController

protocol ScanQRCodeCoordinatorDelegate: class {
    func didCancel(in coordinator: ScanQRCodeCoordinator)
    func didScan(result: String, in coordinator: ScanQRCodeCoordinator)
}

class ScanQRCodeCoordinator: NSObject, Coordinator, RootViewControllerProvider {
    var coordinators: [Coordinator] = []
    weak var delegate: ScanQRCodeCoordinatorDelegate?

    let navigationController: NavigationController
    lazy var qrcodeController: QRCodeReaderViewController = {
        let controller = QRCodeReaderViewController(cancelButtonTitle: "Cancel")
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
        delegate?.didCancel(in: self)
    }
    
    var rootViewController: UIViewController {
        return qrcodeController
    }
}

extension ScanQRCodeCoordinator: QRCodeReaderDelegate {
    func readerDidCancel(_ reader: QRCodeReaderViewController!) {
        reader.stopScanning()
        delegate?.didCancel(in: self)
    }

    func reader(_ reader: QRCodeReaderViewController!, didScanResult result: String!) {
        reader.stopScanning()
        delegate?.didScan(result: result, in: self)
    }
}
