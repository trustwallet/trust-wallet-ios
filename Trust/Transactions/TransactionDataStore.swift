// Copyright SIX DAY LLC, Inc. All rights reserved.

import Foundation
import APIKit

protocol TransactionDataStoreDelegate: class {
    func didUpdate(viewModel: TransactionsViewModel)
    func didFail(with error: Error, viewModel: TransactionsViewModel)
}

class TransactionDataStore {
    
    var viewModel: TransactionsViewModel {
        return .init(transactions: transactions)
    }
    weak var delegate: TransactionDataStoreDelegate?
    
    let account: Account
    var transactions: [Transaction] = []
    init(account: Account) {
        self.account = account
    }
    
    func fetch() {
        let request = FetchTransactionsRequest(address: account.address)
        Session.send(request) { result in
            switch result {
            case .success(let response):
                self.update(transactions: response)
            case .failure(let error):
                self.delegate?.didFail(with: error, viewModel: self.viewModel)
            }
        }
    }
    
    func update(transactions: [Transaction]) {
        self.transactions = transactions
        
        delegate?.didUpdate(viewModel: viewModel)
    }
}

struct FetchTransactionsRequest: APIKit.Request {
    typealias Response = [Transaction]
    
    let address: String
    
    var baseURL: URL {
        let config = Config()
        return config.etherScanURL
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var path: String {
        return ""
    }
    
    var parameters: Any? {
        return [
            "module": "account",
            "action": "txlist",
            "address": address,
            "startblock": "0",
            "endblock": "99999999",
            "sort": "asc",
            "apikey": "7V8AMAVQWKNAZHZG8ARYB9SQWWKBBDA7S8",
        ]
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        NSLog("transactions urlResponse \(urlResponse)")
        if
            let objectJSON = object as? [String: AnyObject],
            let transactionJSON = objectJSON["result"] as? [[String: AnyObject]] {
            let transactions: [Transaction] = transactionJSON.map { json in
                
                let blockHash = json["blockHash"] as? String ?? ""
                let blockNumber = json["blockNumber"] as? String ?? ""
                let confirmation = json["confirmations"] as? String ?? ""
                let cumulativeGasUsed = json["cumulativeGasUsed"] as? String ?? ""
                let from = json["from"] as? String ?? ""
                let to = json["to"] as? String ?? ""
                let gas = json["gas"] as? String ?? ""
                let gasPrice = json["gasPrice"] as? String ?? ""
                let gasUsed = json["gasUsed"] as? String ?? ""
                let hash = json["hash"] as? String ?? ""
                let isError = Bool(json["isError"] as? String ?? "") ?? false
                let timestamp = (json["timeStamp"] as? String ?? "")
                
                let hex = (json["value"] as? String ?? "")
                let value = BInt(hex)
                
                return Transaction(
                    blockHash: blockHash,
                    blockNumber: blockNumber,
                    confirmations: confirmation,
                    cumulativeGasUsed: cumulativeGasUsed,
                    from: from,
                    to: to,
                    owner: address,
                    gas: gas,
                    gasPrice: gasPrice,
                    gasUsed: gasUsed,
                    hash: hash,
                    value: value,
                    timestamp: timestamp,
                    isError: isError
                )
            }
         return transactions
        }
        return []
    }
}

