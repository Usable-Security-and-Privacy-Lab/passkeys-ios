//
//  ContentView.swift
//  PasskeysTest
//
//  Created by David Gaag on 7/12/23.
//

import SwiftUI

struct LoginView: View {
    @State private var username: String = ""
    
    @EnvironmentObject private var accountStore: AccountStore
    @Environment(\.authorizationController) private var authorizationController
    
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            Text("Not Venmo")
                .font(.title.bold())
            Spacer()
            TextField("Username", text: $username)
                .textFieldStyle(.roundedBorder)
                .frame(width: 300, height: 70)
            Button("Login") {
                Task {
                    await signIn()
                }
            }
            .padding(.bottom, 5)
            .buttonStyle(.borderedProminent)
            Button("Register") {
                Task {
                    await register()
                }
            }
            .buttonStyle(.bordered)
            Spacer()
        }
        .onAppear {
            
        }
    }
    
    private func signIn() async {
        await accountStore.signIntoPasskeyAccount(authorizationController: authorizationController)
    }
    
    private func register() async {
        await accountStore.createPasskeyAccount(authorizationController: authorizationController, username: username)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
