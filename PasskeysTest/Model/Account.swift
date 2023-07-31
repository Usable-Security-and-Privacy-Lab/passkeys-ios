//
//  Account.swift
//  PasskeysTest
//
//  Created by David Gaag on 7/18/23.
//

import Foundation

struct Account: Equatable, Identifiable {
    var id: UUID
    var profilePicture: Data?
    var username: String
    var fullName: String
    var balance: Double?
    var friends: [Account] = []
    
    mutating func addFunds(amount: Double) {
        balance? += amount
    }
    
    mutating func subtractFunds(amount: Double) {
        balance? -= amount
    }
    
//    mutating func addFriend(withUsername username: String) {
//        friends.append(username)
//    }
    
    mutating func removeFriend(withUsername username: String) {
        if let index = friends.firstIndex(where: { $0.username == username }) {
            friends.remove(at: index)
        }
    }
}


