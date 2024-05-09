import SwiftUI

struct FeedView: View {
    var transactions: [Transaction]
    @EnvironmentObject private var app: VenmoViewController
    //@State private var friendTransactions: [Transaction]? = nil
    @Environment(\.isSearching) private var isSearching {
        willSet {
            if newValue {
                //path.append(1) // TODO: what goes here?
            }
        }
    }
    @Environment(\.dismissSearch) private var dismissSearch
    //@Binding var path: NavigationPath
    
    // FAKE DATA
    var fakeDataGenerator : FakeData = FakeData()
   // @State private var friendTransactions: [Transaction] = []
    
    // TODO: use initializer to refresh friend feed
//    init(path: NavigationPath) {
//        self.path = path
//        Task { [weak app] in
//            guard let app = app else { return }
//            await app.getFriendsFeed()
//        }
//        if let friendTransactionFeed = app.friendTransactionFeed {
//            self.friendTransactions = friendTransactionFeed
//        }
//    }
  
    var body: some View {
            if isSearching {
                // Handle searching view
                Text("Searching...")
            } else {
                ScrollView {
                    LazyVStack {
                        // TODO: change from fake data to real data
                        ForEach(transactions ?? []) { transaction in
                            NavigationLink(value: transaction) {
                                transactionLabel(for: transaction)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    
    private func transactionLabel(for transaction: Transaction) -> some View {
        // TODO: refactor
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Image(systemName: "person.circle")
                    .font(.title)
                    .padding(.horizontal)
                VStack(alignment: .leading) {
                    let paymentVerb = transaction.action == .pay ? "paid" : "charged"
                    Text(transaction.actor.displayName! + " " + paymentVerb + " " + transaction.target.displayName!)
                        .font(.headline)
                    Text(transaction.note)
                }
            }
            .padding()
            Divider()
        }
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        @State var path = NavigationPath()
        var fakeDataGenerator : FakeData = FakeData()

        FeedView(transactions: fakeDataGenerator.populateFakeData())
            .environmentObject(VenmoViewController())
    }
}
