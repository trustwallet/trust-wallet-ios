// Copyright SIX DAY LLC, Inc. All rights reserved.

import UIKit

class TransactionViewController: UIViewController {

    private lazy var viewModel: TransactionViewModel = {
        return .init(transaction: self.transaction)
    }()
    
    let transaction: Transaction
    
    let stackView: UIStackView
    let amountLabel = UILabel()
    let memoLabel = UILabel()
    
    init(transaction: Transaction) {
        self.transaction = transaction
        
        stackView = UIStackView(arrangedSubviews: [amountLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        super.init(nibName: nil, bundle: nil)
        
        title = viewModel.title
        view.backgroundColor = viewModel.backgroundColor
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
