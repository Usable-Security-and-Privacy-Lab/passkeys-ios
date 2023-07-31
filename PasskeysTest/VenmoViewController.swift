import SwiftUI

class VenmoViewController: ObservableObject {
    @Published var currentUser: Account?
    @Published var userTransactions: [Transaction]?
    @Published var friendTransactionFeed: [Transaction]?
    
    init() {
        currentUser = SampleData.sampleAccounts[0]
        userTransactions = SampleData.sampleTransactions.filter({ $0.payee == currentUser })
        friendTransactionFeed = SampleData.sampleTransactions
    }
    
    
}
