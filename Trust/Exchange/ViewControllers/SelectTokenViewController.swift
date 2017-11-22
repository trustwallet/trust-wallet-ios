// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

protocol SelectTokenViewControllerDelegate: class {
    func didSelect(token: ExchangeToken, in viewController: SelectTokenViewController)
}

enum SelectTokenDirection {
    case to
    case from
}

class SelectTokenViewController: UITableViewController {

    private struct Keys {
        static let cell = "cell"
    }
    weak var delegate: SelectTokenViewControllerDelegate?

    let tokens: [ExchangeToken]
    let direction: SelectTokenDirection

    init(
        tokens: [ExchangeToken],
        direction: SelectTokenDirection
    ) {
        self.tokens = tokens
        self.direction = direction

        super.init(nibName: nil, bundle: nil)

        view.backgroundColor = .white

        tableView.register(ExchangeTokenTableViewCell.self, forCellReuseIdentifier: Keys.cell)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tokens.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Keys.cell, for: indexPath as IndexPath) as? ExchangeTokenTableViewCell
        let token = tokens[indexPath.row]
        cell?.textLabel!.text = token.name
        return cell ?? UITableViewCell()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let token = tokens[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)

        NSLog("didSelectRowAt \(token)")

        delegate?.didSelect(token: token, in: self)

        navigationController?.popViewController(animated: true)
    }
}
