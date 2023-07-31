import SwiftUI

struct AppView: View {
    @ObservedObject private var app = VenmoViewController()
    @ObservedObject var accountStore: AccountStore
    
    @State private var showPayView = false
    @State private var selectedTab = Tab.home
    
    private enum Tab {
        case home
        case pay
        case myProfile
    }
    
    var body: some View {
        if !accountStore.isSignedIn {
            LoginView()
                .environmentObject(accountStore)
        } else {
            venmoView
                .environmentObject(accountStore)
        }
    }
    
    private var venmoView: some View {
        TabView(selection: $selectedTab) {
            HomeView(app: app)
                .tabItem {
                    Label("Home", systemImage: "house")
                        .environment(\.symbolVariants, selectedTab != Tab.home ? .none : .fill)
                }
                .tag(Tab.home)
            PayView()
                .tabItem {
                    Label("Pay/Request", systemImage: "banknote")
                        .environment(\.symbolVariants, selectedTab != Tab.pay ? .none : .fill)
                }
                .tag(Tab.pay)
            MyProfileView()
                .tabItem {
                    Label("Me", systemImage: "person")
                        .environment(\.symbolVariants, selectedTab != Tab.myProfile ? .none : .fill)
                        .animation(.easeInOut, value: selectedTab)
                }
                .tag(Tab.myProfile)
        }
    }
}

struct VenmoView_Previews: PreviewProvider {
    struct Preview: View {
        @StateObject private var accountStore = AccountStore()
        var body: some View {
            AppView(accountStore: accountStore)
        }
    }
    static var previews: some View {
        Preview()
    }
}
