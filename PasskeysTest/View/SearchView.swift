import SwiftUI

struct SearchView: View {
    enum Mode {
        case search
        case pay
    }
    var mode: Mode
    
    var body: some View {
        VStack {
            Text("Search View")
            NavigationLink(destination: { MyProfileView() }) {
                Text("GO")
            }
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(mode: .pay)
    }
}
