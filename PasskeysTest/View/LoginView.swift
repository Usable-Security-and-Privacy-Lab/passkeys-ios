//
//  ContentView.swift
//  PasskeysTest
//
//  Created by David Gaag on 7/12/23.
//

import SwiftUI

struct LoginView: View {
    @State private var username: String = ""
    @State private var autoFillAuthorizeTask: Task<Void, Error>?
    
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
                .textContentType(.username)
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
            Button("Default User") {
                Task {
                    accountStore.signInDefaultUser()
                }
            }
            .padding(.top)
            Spacer()
        }
        .onAppear {
            autoFillAuthorizeTask = Task {
                await beginAutoFillAssistedSignIn()
//                await signIn() // This will bring the prompt up immediately
            }
        }
        .onDisappear {
            autoFillAuthorizeTask?.cancel()
            autoFillAuthorizeTask = nil
        }
    }
    
    private func beginAutoFillAssistedSignIn() async {
        await accountStore.beginAutoFillAssistedPasskeySignIn(authorizationController: authorizationController)
    }
    
    private func signIn() async {
        autoFillAuthorizeTask?.cancel()
        autoFillAuthorizeTask = nil
        await accountStore.signIntoPasskeyAccount(authorizationController: authorizationController)
    }
    
    private func register() async {
        await accountStore.createPasskeyAccount(authorizationController: authorizationController, username: username)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        let accountStore = AccountStore()
        LoginView()
            .environmentObject(accountStore)
            .onAppear {
                accountStore.signInDefaultUser()
            }
    }
}
