import SwiftUI

struct FeedView: View {
    @EnvironmentObject private var app: VenmoViewController
    @Environment(\.isSearching) private var isSearching {
        willSet {
            if newValue {
                path.append(1) // TODO: what goes here?
            }
        }
    }
    @Environment(\.dismissSearch) private var dismissSearch
    @Binding var path: NavigationPath
    
    var body: some View {
        if isSearching {
            
        } else {
            ScrollView {
                LazyVStack {
                    ForEach(app.friendTransactionFeed ?? []) { transaction in // TODO: force
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

        FeedView(path: $path)
            .environmentObject(VenmoViewController())
    }
}
