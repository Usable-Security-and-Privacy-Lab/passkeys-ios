import SwiftUI

struct ProfileView: View {
    @ObservedObject private var app = VenmoViewController()
    @EnvironmentObject private var accountStore: AccountStore
    @State private var profile: Profile? = nil
    @State private var recentTransactions: [Transaction]? = nil
    var id: Int
    
    // TODO: use fetched profile information
    private var firstName = "Mash"
    private var lastName = "Burnedead"
    private var username = "mash"
    private var balance: Decimal = 20.66
        
    enum ActiveButton {
        case recent, outstanding
        
        var description : String {
            switch self {
            case .recent: return "recent"
            case .outstanding: return "outstanding"
            }
          }
    }
    @State private var activeButton: ActiveButton?
    @State private var showRecentTransactions = false;
    @State private var showOutstandingTransactions = false;
    
    // FAKE DATA
    var fakeDataGenerator : FakeData = FakeData()
    var fakeOutstandingTransactions: [Transaction] {
        fakeDataGenerator.getFakeOutstandingTransactions()
    }
    
    init(id: Int) {
        self.id = id
//        Task { [weak app] in
//            guard let app = app else { return }
//            await app.getProfileWithID(id)
//        }
//        if let userProfile = self.app.requestedUserProfile {
//            self.profile = userProfile
//        }
        // add recent and outstanding
    }
    var body: some View {
        NavigationView {
            VStack {
                //name
                Text(firstName + " " + lastName)
                    .bold()
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment:  .leading)
                    .padding(.horizontal)
                    .padding(.top, 15)
                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                
                //username
                Text("@" + username)
                    .bold()
                    .font(.title2)
                    .frame(maxWidth: .infinity, alignment:  .leading)
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                    .foregroundColor(.blue)
                
                // TODO: check if friends with user
                // TODO: toggle buttons based on friend status
                Button(action: {
                    // update as friend
                }) {
                    Text("Add as friend")
                }
                Button(action: {
                    // remove as friend
                }) {
                    Text("Remove as friend")
                }
                
                // recent-outstanding buttons
                HStack {
                    Button(action: {
                        showRecentTransactions = true
                        updateActiveButton(.recent)
                        showOutstandingTransactions = false
                    }) {
                        Text("Recent")
                    }
                    .buttonStyle(.bordered)
                    .font(.title3)
                    
                    Button(action: {
                        showOutstandingTransactions = true
                        updateActiveButton(.outstanding)
                        showRecentTransactions = false
                    }) {
                        Text("Outstanding")
                    }
                    .buttonStyle(.bordered)
                    .font(.title3)
                }
                
                if (showRecentTransactions && activeButton == .recent) {
                    ShowRecentTransactionView()
                }
                if (showOutstandingTransactions && activeButton == .outstanding) {
                    let currentUsername: String? = app.currentUserProfile?.username
                    ShowOutstandingTransactionView(username: currentUsername!, transactions: fakeOutstandingTransactions)
                }
                Spacer()
            }
                .navigationBarTitle(firstName + "'s Profile")
        }
        .onAppear {
            Task {
                await app.getProfileWithID(id)
                // recent and outstanding
            }
            
            if let userProfile = self.app.requestedUserProfile {
                self.profile = userProfile
            }
            
            // recent and outstanding
        }
    }
    
    private func checkAuthenticated() {
        
    }
    private func updateActiveButton(_ button: ActiveButton) {
        if activeButton == button {
            activeButton = nil
        } else {
            activeButton = button
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(id: 1)
    }
}
