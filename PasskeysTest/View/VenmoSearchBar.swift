import SwiftUI

struct VenmoSearchBar: ViewModifier {
    @Binding var searchQuery: String
    func body(content: Content) -> some View {
        return content.searchable(text: $searchQuery, placement: .navigationBarDrawer(displayMode: .always), prompt: "Username")
    }
}

extension View {
    func venmoSearchBar(searchQuery: Binding<String>) -> some View {
        modifier(VenmoSearchBar(searchQuery: searchQuery))
    }
}
