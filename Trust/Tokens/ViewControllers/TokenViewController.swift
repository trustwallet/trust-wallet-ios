// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class TokenViewController: UIViewController {

    let tableView = UITableView()
    let headerView = TokenHeaderView()
    let viewModel: TokenViewModel

    init(viewModel: TokenViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)

        configure(with: viewModel)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        headerView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(headerView)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 200),
            //headerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

//            tableView.topAnchor.constraint(equalTo: view.topAnchor),
//            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    func configure(with viewModel: TokenViewModel) {
        navigationItem.title = viewModel.title
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
