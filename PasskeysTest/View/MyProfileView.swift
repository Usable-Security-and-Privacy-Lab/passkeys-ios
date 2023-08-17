//
//  MyProfileView.swift
//  PasskeysTest
//
//  Created by David Gaag on 7/18/23.
//

import SwiftUI

struct MyProfileView: View {
    @EnvironmentObject private var accountStore: AccountStore
    
    var body: some View {
        NavigationStack {
            Text("Profile View")
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
        }
    }
    
    private func checkAuthenticated() {
        
    }
}

struct MyProfileView_Previews: PreviewProvider {
    static var previews: some View {
        MyProfileView()
    }
}
