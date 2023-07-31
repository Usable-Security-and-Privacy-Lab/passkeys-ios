//
//  HomeView.swift
//  PasskeysTest
//
//  Created by David Gaag on 7/18/23.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var app: VenmoViewController
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack {
                    ForEach(app.friendTransactionFeed!) { transaction in
                        NavigationLink {
//                            TransactionView()
                        } label: {
                            VStack(alignment: .leading) {
                                HStack(alignment: .top) {
                                    Image(systemName: "person.circle")
                                        .font(.title)
                                        .padding(.horizontal)
                                    VStack(alignment: .leading) {
                                        Text("\(transaction.payer.fullName) paid \(transaction.payee.fullName)")
                                            .font(.headline)
                                        Text("Placeholder message")
                                    }
                                }
                                .padding()
                                Divider()
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle("Feed")
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(app: VenmoViewController())
    }
}
