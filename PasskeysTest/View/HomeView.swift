//
//  HomeView.swift
//  PasskeysTest
//
//  Created by David Gaag on 7/18/23.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var app: VenmoViewController
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack {
                    ForEach(app.friendTransactionFeed!) { transaction in
                        NavigationLink {
//                            TransactionView()
                        } label: {
                            // TODO: refactor
                            VStack(alignment: .leading) {
                                HStack(alignment: .top) {
                                    Image(systemName: "person.circle")
                                        .font(.title)
                                        .padding(.horizontal)
                                    VStack(alignment: .leading) {
                                        let paymentVerb = transaction.action == .pay ? "paid" : "charged"
                                        Text(transaction.actor.displayName + " " + paymentVerb + " " + transaction.target.displayName)
                                            .font(.headline)
                                        Text(transaction.note)
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
        let app = VenmoViewController()
        HomeView()
            .environmentObject(app)
    }
}
