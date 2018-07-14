// Copyright DApps Platform Inc. All rights reserved.

import Eureka
import UIKit
import TrustCore
import BigInt

//TODO: Replace with TrustCode once implemented
public final class ERC721Encoder {
    public static func encodeTransferFrom(from: EthereumAddress, to: EthereumAddress, tokenId: BigUInt) -> Data {
        let function = Function(name: "transferFrom", parameters: [.address, .address, .uint(bits: 256)])
        let encoder = ABIEncoder()
        try! encoder.encode(function: function, arguments: [from, to, tokenId])
        return encoder.data
    }
}

public class SendNFTCell: Cell<Bool>, CellType {

    public lazy var tokenImage: UIImageView = {
        let tokenImage = UIImageView()
        tokenImage.translatesAutoresizingMaskIntoConstraints = false
        tokenImage.contentMode = .scaleAspectFit
        return tokenImage
    }()

    public lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()

    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            tokenImage,
            label,
        ])
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 10
        return stackView
    }()

    public override func setup() {
        super.setup()
        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: StyleLayout.sideMargin),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: -StyleLayout.sideMargin),
            tokenImage.heightAnchor.constraint(equalToConstant: 240),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: StyleLayout.sideMargin),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -StyleLayout.sideMargin),
        ])

        selectionStyle = .none
    }

    public override func update() {
        super.update()
    }
}

// The custom Row also has the cell: CustomCell and its correspond value
public final class SendNFTRow: Row<SendNFTCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<SendNFTCell>()
    }
}
