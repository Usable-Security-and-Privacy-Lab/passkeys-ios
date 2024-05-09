import SwiftUI

@MainActor
class VenmoViewController: ObservableObject {
    @Published var currentUserProfile: Profile?
    @Published var userTransactions: [Transaction]?
    @Published var requestedUserProfile: Profile?
    @Published var friendTransactionFeed: [Transaction]? {
        didSet {
            print("SET friendTransactionFeed: \(friendTransactionFeed)")
        }
    }
    private var networkManager = NetworkManager()
    
    init() {
        // TODO: Implement
    }
    
    // TODO: search function
    
    public func getCurrentUserInfo() async {
        self.currentUserProfile = await networkManager.getCurrentUserInfo();
    }
    
    public func updateCurrentUserInfo(oldFN : String, oldLN : String, firstName : String, lastName : String) async {
        if (firstName != "" && firstName != oldFN) {
            if (lastName != "" && lastName != oldLN) {
                await networkManager.updateCurrentUserInfo(firstName: firstName, lastName: lastName)
            }
            else {
                await networkManager.updateCurrentUserInfo(firstName: firstName, lastName: oldLN)
            }
        }
        else {
            if (lastName != "" && lastName != oldLN) {
                await networkManager.updateCurrentUserInfo(firstName: oldFN, lastName: lastName)
            }
            else {
                await networkManager.updateCurrentUserInfo(firstName: oldFN, lastName: oldLN)
            }
        }
        await getCurrentUserInfo();
    }
    
    public func getProfileWithID(_ id : Int) async {
        self.requestedUserProfile = await networkManager.getProfileWithID(id)
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
        self.friendTransactionFeed = await networkManager.getFriendsFeed()
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
    
    public func getUserTransactions(userID: Int) async {
        self.userTransactions = await networkManager.getMyTransactionsWith(userID: userID)
    }
    
    public func getMyTransactionsWith() {
    }
    
    public func getOutstandingTransactions() async {
    }
    
    public func getTransactionByID() {
    }
    
    public func completeTransaction(id: Int, action: TransactionCompletion) async {
        await networkManager.completeTransaction(withID: id, action: action)
    }
}
