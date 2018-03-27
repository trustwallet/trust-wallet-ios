// Copyright SIX DAY LLC. All rights reserved.

import UIKit

protocol DAppsTableViewDelegate: class {
    func didSelect(dapp: DAppModel, in view: DAppsTableView)
}

class DAppsTableView: IntrinsicTableView {

    struct Layout {
        static let cellHeight: CGFloat = 86
    }

    weak var dappsDelegate: DAppsTableViewDelegate?

    var dapps: [DAppModel] = [] {
        didSet {
            reloadData()
        }
    }

    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)

        register(R.nib.dAppTableViewCell(), forCellReuseIdentifier: R.nib.dAppTableViewCell.identifier)
        rowHeight = Layout.cellHeight
        estimatedRowHeight = Layout.cellHeight
        delegate = self
        dataSource = self
        separatorStyle = .none
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DAppsTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        dappsDelegate?.didSelect(dapp: dapps[indexPath.row], in: self)
    }
}

extension DAppsTableView: UITableViewDataSource {
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
        return min(dapps.count, 1)
    }
}

class IntrinsicTableView: UITableView {

    override var intrinsicContentSize: CGSize {
        return contentSize
    }

    override func reloadData() {
        super.reloadData()
        invalidateIntrinsicContentSize()
    }
}
