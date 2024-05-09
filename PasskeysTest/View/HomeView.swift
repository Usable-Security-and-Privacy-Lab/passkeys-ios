import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var app: VenmoViewController
    @State private var searchQuery = ""
    @State private var path = NavigationPath()
    var fakeDataGenerator = FakeData()
    
    var body: some View {
        NavigationStack(path: $path) {
            let user = app.currentUserProfile
            //if app.friendTransactionFeed != nil && //!app.friendTransactionFeed!.isEmpty {
            FeedView(transactions: fakeDataGenerator.populateFakeData())
                    .environmentObject(app)
                    .navigationTitle("Feed")
                    .venmoSearchBar(searchQuery: $searchQuery)
                    .navigationDestination(for: Transaction.self) { transaction in
                        TransactionView(userName: user!.username, transaction: transaction)
                    }
            //} else {
                Color(.clear)
                    .navigationTitle("Feed")
            //}
        }
//        .overlay {
////            if false { // TODO: delete
//                if app.friendTransactionFeed == nil {
//                    ProgressView()
//                        .controlSize(.large)
//                } else if app.friendTransactionFeed!.isEmpty {
//                    VStack {
//                        Text("There's nothing here... 😕")
//                            .padding()
//                        Text("Add friends to see their transactions!")
//                    }
//                    .foregroundColor(.gray)
//                }
////            }
//        }
        .onAppear {
            Task {
                await app.getFriendsFeed()
                await app.getCurrentUserInfo()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let app = VenmoViewController()
        HomeView()
            .environmentObject(app)
    }
}
