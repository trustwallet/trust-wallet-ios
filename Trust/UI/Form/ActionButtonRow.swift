// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Eureka

public typealias ActionButtonRow = ActionButtonCellOf<String>

public final class ActionButtonCellOf<T: Equatable>: Row<ActionButtonCell<T>>, SelectableRowType, RowType {
    public var selectableValue: T?
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
    }
}

public class ActionButtonCell<T: Equatable> : Cell<T>, CellType {

    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func update() {
        super.update()

        backgroundColor = .clear
        contentView.backgroundColor = .clear

        let button = Button(size: .extraLarge, style: .solid)
        button.setTitle("Create Wallet", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(button)
        button.anchor(to: self, margin: 10)
        button.addTarget(self, action: #selector(self.tap), for: .touchUpInside)
    }

    public override func setup() {
        super.setup()
        accessoryType = .none

    }

    public override func didSelect() {
        row.reload()
        row.select()
        row.deselect()
    }

    func tap() {

    }
}
