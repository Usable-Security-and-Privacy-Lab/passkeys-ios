import SwiftUI

struct MyProfileView: View {
    @ObservedObject private var app = VenmoViewController()
    @EnvironmentObject private var accountStore: AccountStore
    @State private var profile: Profile? = nil
    @State private var recentTransactions: [Transaction]? = nil
    
    // TODO: use fetched profile information
    private var firstName = "Finn"
    private var lastName = "Ames"
    private var username = "finn"
    private var balance: Decimal = 14.59
        
    enum ActiveButton {
        case wallet, recent, outstanding
        
        var description : String {
            switch self {
            case .wallet: return "wallet"
            case .recent: return "recent"
            case .outstanding: return "outstanding"
            }
          }
    }
    @State private var activeButton: ActiveButton?
    @State private var showBalance = false;
    @State private var showRecentTransactions = false;
    @State private var showOutstandingTransactions = false;
    
    // FAKE DATA
    var fakeDataGenerator : FakeData = FakeData()
    var fakeOutstandingTransactions: [Transaction] {
        fakeDataGenerator.getFakeOutstandingTransactions()
    }
    
//    init() {
//        Task { [weak app] in
//            guard let app = app else { return }
//            await app.getCurrentUserInfo()
//        }
//        if let userProfile = self.app.currentUserProfile {
//            self.profile = userProfile
//        }
//        // add recent and outstanding
//    }
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
                
                
                // wallet-recent-outstanding buttons
                HStack {
                    Button(action: {
                        showBalance = true;
                        updateActiveButton(.wallet)
                        showRecentTransactions = false
                        showOutstandingTransactions = false
                    }) {
                        Text("Wallet")
                    }
                    .buttonStyle(.bordered)
                    .font(.title3)
                    
                    Button(action: {
                        showRecentTransactions = true
                        updateActiveButton(.recent)
                        showBalance = false
                        showOutstandingTransactions = false
                    }) {
                        Text("Recent")
                    }
                    .buttonStyle(.bordered)
                    .font(.title3)
                    
                    Button(action: {
                        showOutstandingTransactions = true
                        updateActiveButton(.outstanding)
                        showBalance = false
                        showRecentTransactions = false
                    }) {
                        Text("Outstanding")
                    }
                    .buttonStyle(.bordered)
                    .font(.title3)
                }
                
                if (showBalance && activeButton == .wallet) {
                    ShowWalletView(balance: balance)
                }
                if (showRecentTransactions && activeButton == .recent) {
                    ShowRecentTransactionView()
                }
                if (showOutstandingTransactions && activeButton == .outstanding) {
                    ShowOutstandingTransactionView(username: username, transactions: fakeOutstandingTransactions)
                }
                Spacer()
                
                NavigationLink(destination: EditProfileView(app: app, oldFirstName: firstName, oldLastName: lastName)) {
                    Text("Edit Profile")
                }
            }
                .toolbar {
                    ToolbarItem {
                        Button() {
                            Task {
                                await accountStore.checkAuthorization()
                            }
                        } label: {
                            Text("Authenticated?")
                        }
                        
                    }
                    ToolbarItem {
                        Button() {
                            Task {
                                await accountStore.signOut()
                            }
                        } label: {
                            Text("Sign out")
                        }
                    }
                    ToolbarItem {
                        Button() {
                            Task {
                                await accountStore.clearURLSession()
                            }
                        } label: {
                            Text("Clear")
                        }
                    }
                }
                .navigationBarTitle("My Profile")
        }
        .onAppear {
            Task {
                await app.getCurrentUserInfo()
                await app.getOutstandingTransactions()
                // recent transactions
            }
            
            if let userProfile = self.app.currentUserProfile {
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

struct ShowWalletView: View {
    var balance: Decimal
    
    var body: some View {
        VStack {
            // balance
            Text("Balance: $" + String(describing: balance))
                .font(.title)
                .padding(.vertical)
        }
    }
}

struct ShowRecentTransactionView: View {
    var body: some View {
        Text("TODO: recent transactions")
    }
}

struct ShowOutstandingTransactionView: View {
    @ObservedObject private var app = VenmoViewController()
    var username: String
    //@State private var path = NavigationPath()

    var transactions: [Transaction]
    
    var body: some View {
        NavigationStack() {
            //if app.friendTransactionFeed != nil && //!app.friendTransactionFeed!.isEmpty {
                FeedView(transactions: transactions)
                    .environmentObject(app)
                    .navigationDestination(for: Transaction.self) { transaction in
                        TransactionView(userName: username, transaction: transaction)
                    }
            //} else {
                Color(.clear)
            //}
        }
    }
}

struct EditProfileView: View {
    var app: VenmoViewController
    var oldFirstName: String
    var oldLastName: String
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    
    var body: some View {
        VStack {
            HStack {
                Text("First Name")
                    .padding(.horizontal)
                TextField(oldFirstName, text: $firstName)
                    .padding()
                    .background(Color.gray.opacity(0.1)) // Box-like background
                    .cornerRadius(8) // Rounded corners to resemble a box
                    .padding(.horizontal)
            }
            HStack {
                Text("Last Name")
                    .padding(.horizontal)
                TextField(oldLastName, text: $lastName)
                    .padding()
                    .background(Color.gray.opacity(0.1)) // Box-like background
                    .cornerRadius(8) // Rounded corners to resemble a box
                    .padding(.horizontal)
            }
            Button(action: {
                Task {
                    await app.updateCurrentUserInfo(oldFN: oldFirstName, oldLN: oldLastName, firstName: firstName, lastName: lastName)
                }
            }) {
                Text("Save Profile")
            }
            .buttonStyle(.borderedProminent)
            .padding(.vertical)
                .navigationBarTitle("Edit Profile")
        }
    }
}

struct MyProfileView_Previews: PreviewProvider {
    static var previews: some View {
        MyProfileView()
    }
}
