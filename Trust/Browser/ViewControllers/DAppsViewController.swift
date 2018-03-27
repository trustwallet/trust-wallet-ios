// Copyright SIX DAY LLC. All rights reserved.

import UIKit

protocol DAppsViewControllerDelegate: class {
    func didSelect(dapp: DAppModel, in viewController: DAppsViewController)
}

class DAppsViewController: UIViewController {

    struct Layout {
        static let cellHeight: CGFloat = 86
    }

    let tableView = UITableView()
    let dapps: [DAppModel] = []
    weak var delegate: DAppsViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)
    }
}

extension DAppsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.didSelect(dapp: dapps[indexPath.row], in: self)
    }
}

extension DAppsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Layout.cellHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.dAppTableViewCell.identifier, for: indexPath) as! DAppTableViewCell
        let viewModel = DAppViewModel(dapp: dapps[indexPath.row])
        cell.selectionStyle = .none
        cell.nameLabel.text = viewModel.title
        cell.dappImageView?.kf.setImage(
            with: viewModel.imageURL,
            placeholder: viewModel.placeholderImage
        )
        cell.descriptionLabel.text = viewModel.description
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dapps.count
    }
}
