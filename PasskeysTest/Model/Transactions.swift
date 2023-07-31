//
//  TransactionHistory.swift
//  PasskeysTest
//
//  Created by David Gaag on 7/18/23.
//

import Foundation

struct TransactionFeed {
    var associatedUsername: String?
    var transactions: [Transaction]
}

struct Transaction: Identifiable {
    var id: UUID
    var payee: Account
    var payer: Account
    var amount: Double
    var date: Date
}
