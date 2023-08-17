import SwiftUI

@MainActor
class VenmoViewController: ObservableObject {
    @Published var currentUserProfile: Profile?
    @Published var userTransactions: [Transaction]?
    @Published var friendTransactionFeed: [Transaction]?
    private var networkManager = NetworkManager()
    
    init() {
        // TODO: Implement
    }
    
    
    public func getCurrentUserInfo() {
    }
    
    public func getProfileWithID() {
    }
    
    public func addFriendWithID() {
    }
    
    public func removeFriendWithID() {
    }

    
    public func getFriendsForProfileWithID() {
    }
    
    public func makeTransaction() {
        
    }
    
    public func getFriendsFeed() async {
        friendTransactionFeed = await networkManager.getFriendsFeed()
    }
    
    public func loadMoreTransactions(feed: TransactionFeedType) {
        switch feed {
        case .friends:
            break // TODO: implement
        case .user:
            break // TODO: implement
        case .betweenUs:
            break // TODO: implement
        }
    }
    
    public func getUserTransactions() {
    }
    
    public func getMyTransactionsWith() {
    }
    
    public func getOutstandingTransactions() {
    }
    
    public func getTransactionByID() {
    }
    
    public func completeTransaction() {
    }
}
