import SwiftUI

class VenmoViewController: ObservableObject {
    @Published var currentUserProfile: Profile?
    @Published var userTransactions: [Transaction]?
    @Published var friendTransactionFeed: [Transaction]?
    
    init() {
        // TODO: Implement
        currentUserProfile = Profile(username: "davidgaag", firstName: "David", lastName: "Gaag", relationship: .me, friendsCount: 1, id: 1, balance: 100.0)
    }
    
    
    
}
