import SwiftUI

struct AppView: View {
    @ObservedObject private var app = VenmoViewController()
    @ObservedObject var accountStore: AccountStore
    
    @State private var displaySplashScreen = true
    @State private var showPayView = false
    @State private var selectedTab = Tab.home
    
    private enum Tab {
        case home
        case pay
        case myProfile
    }
    
    var body: some View {
        if displaySplashScreen {
            splashScreen
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        withAnimation {
                            displaySplashScreen = false
                        }
                    }
                }
        } else {
            if !accountStore.isSignedIn {
                LoginView()
                    .environmentObject(accountStore)
            } else {
                venmoView
            }
        }
    }
    
    private var splashScreen: some View {
        VStack {
            Image(systemName: "banknote")
                .font(.system(size: 56.0))
            Text("Not Venmo")
                .font(.title)
                .padding()
        }
    }
    
    private var venmoView: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .environmentObject(app)
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
