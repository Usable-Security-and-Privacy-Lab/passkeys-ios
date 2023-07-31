//
//  PasskeysTestApp.swift
//  PasskeysTest
//
//  Created by David Gaag on 7/12/23.
//

import SwiftUI

@main
struct PasskeysTestApp: App {
    @StateObject private var accountStore = AccountStore()
    
    var body: some Scene {
        WindowGroup {
            AppView(accountStore: accountStore)
        }
    }
}
