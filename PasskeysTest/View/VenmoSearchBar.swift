import SwiftUI

struct PaySearchBar: ViewModifier {
    @Binding var searchQuery: String
    func body(content: Content) -> some View {
        return content.searchable(text: $searchQuery, placement: .navigationBarDrawer(displayMode: .always), prompt: "Username")
    }
}

extension View {
    func paySearchBar(searchQuery: Binding<String>) -> some View {
        modifier(PaySearchBar(searchQuery: searchQuery))
    }
}
