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

    let logoView = UIImageView(frame: .zero)
    let label = UILabel(frame: .zero)

    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        logoView.translatesAutoresizingMaskIntoConstraints = false
        logoView.image = R.image.accountsSwitch()
        logoView.contentMode = .scaleAspectFit

        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Hello"
        label.numberOfLines = 2

        contentView.addSubview(logoView)
        contentView.addSubview(label)

        NSLayoutConstraint.activate([
            logoView.widthAnchor.constraint(equalToConstant: 44),
            logoView.heightAnchor.constraint(equalToConstant: 44),
            logoView.topAnchor.constraint(equalTo: topAnchor),
            logoView.trailingAnchor.constraint(equalTo: label.leadingAnchor, constant: -15),
            logoView.bottomAnchor.constraint(equalTo: bottomAnchor),
            logoView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),

            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        height = { 60 }

        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func update() {
        super.update()
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
}
