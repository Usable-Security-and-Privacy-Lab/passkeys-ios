






import Foundation

struct SampleData {
    static let sampleAccounts: [Account] = [
        Account(id: UUID(), profilePicture: nil, username: "john_doe", fullName: "John Doe", balance: nil, friends: []),
        Account(id: UUID(), profilePicture: nil, username: "jane_smith", fullName: "Jane Smith", balance: nil, friends: []),
        Account(id: UUID(), profilePicture: nil, username: "alex_garcia", fullName: "Alex Garcia", balance: nil, friends: []),
        Account(id: UUID(), profilePicture: nil, username: "emily_brown", fullName: "Emily Brown", balance: nil, friends: []),
        Account(id: UUID(), profilePicture: nil, username: "mike_johnson", fullName: "Mike Johnson", balance: nil, friends: []),
        Account(id: UUID(), profilePicture: nil, username: "lisa_walker", fullName: "Lisa Walker", balance: nil, friends: []),
        Account(id: UUID(), profilePicture: nil, username: "ryan_clark", fullName: "Ryan Clark", balance: nil, friends: []),
        Account(id: UUID(), profilePicture: nil, username: "sara_turner", fullName: "Sara Turner", balance: nil, friends: []),
        Account(id: UUID(), profilePicture: nil, username: "kevin_miller", fullName: "Kevin Miller", balance: nil, friends: []),
        Account(id: UUID(), profilePicture: nil, username: "olivia_green", fullName: "Olivia Green", balance: nil, friends: [])
    ]
    
    static let sampleTransactions: [Transaction] = [
        Transaction(id: UUID(), payee: sampleAccounts[0], payer: sampleAccounts[1], amount: 50.0, date: Date(timeIntervalSince1970: 1679281200)),
        Transaction(id: UUID(), payee: sampleAccounts[2], payer: sampleAccounts[1], amount: 200.0, date: Date(timeIntervalSince1970: 1679285800)),
        Transaction(id: UUID(), payee: sampleAccounts[3], payer: sampleAccounts[2], amount: 100.0, date: Date(timeIntervalSince1970: 1679289300)),
        Transaction(id: UUID(), payee: sampleAccounts[4], payer: sampleAccounts[0], amount: 75.0, date: Date(timeIntervalSince1970: 1679294100)),
        Transaction(id: UUID(), payee: sampleAccounts[1], payer: sampleAccounts[5], amount: 30.0, date: Date(timeIntervalSince1970: 1679298600)),
        Transaction(id: UUID(), payee: sampleAccounts[3], payer: sampleAccounts[6], amount: 500.0, date: Date(timeIntervalSince1970: 1679303100)),
        Transaction(id: UUID(), payee: sampleAccounts[7], payer: sampleAccounts[4], amount: 1000.0, date: Date(timeIntervalSince1970: 1679307000)),
        Transaction(id: UUID(), payee: sampleAccounts[6], payer: sampleAccounts[8], amount: 300.0, date: Date(timeIntervalSince1970: 1679311500)),
        Transaction(id: UUID(), payee: sampleAccounts[5], payer: sampleAccounts[9], amount: 80.0, date: Date(timeIntervalSince1970: 1679316000)),
        Transaction(id: UUID(), payee: sampleAccounts[2], payer: sampleAccounts[0], amount: 120.0, date: Date(timeIntervalSince1970: 1679320600)),
        Transaction(id: UUID(), payee: sampleAccounts[1], payer: sampleAccounts[3], amount: 90.0, date: Date(timeIntervalSince1970: 1679325100)),
        Transaction(id: UUID(), payee: sampleAccounts[8], payer: sampleAccounts[7], amount: 200.0, date: Date(timeIntervalSince1970: 1679329500)),
        Transaction(id: UUID(), payee: sampleAccounts[9], payer: sampleAccounts[6], amount: 150.0, date: Date(timeIntervalSince1970: 1679334100)),
        Transaction(id: UUID(), payee: sampleAccounts[3], payer: sampleAccounts[5], amount: 250.0, date: Date(timeIntervalSince1970: 1679376600)),
        Transaction(id: UUID(), payee: sampleAccounts[2], payer: sampleAccounts[1], amount: 70.0, date: Date(timeIntervalSince1970: 1679381100)),
        Transaction(id: UUID(), payee: sampleAccounts[4], payer: sampleAccounts[9], amount: 300.0, date: Date(timeIntervalSince1970: 1679385600)),
        Transaction(id: UUID(), payee: sampleAccounts[0], payer: sampleAccounts[6], amount: 100.0, date: Date(timeIntervalSince1970: 1679390100)),
        Transaction(id: UUID(), payee: sampleAccounts[8], payer: sampleAccounts[7], amount: 450.0, date: Date(timeIntervalSince1970: 1679394600)),
        Transaction(id: UUID(), payee: sampleAccounts[5], payer: sampleAccounts[3], amount: 60.0, date: Date(timeIntervalSince1970: 1679399100)),
        Transaction(id: UUID(), payee: sampleAccounts[1], payer: sampleAccounts[4], amount: 180.0, date: Date(timeIntervalSince1970: 1679403600)),
        Transaction(id: UUID(), payee: sampleAccounts[9], payer: sampleAccounts[2], amount: 90.0, date: Date(timeIntervalSince1970: 1679408100)),
        Transaction(id: UUID(), payee: sampleAccounts[7], payer: sampleAccounts[0], amount: 200.0, date: Date(timeIntervalSince1970: 1679412600)),
        Transaction(id: UUID(), payee: sampleAccounts[6], payer: sampleAccounts[8], amount: 120.0, date: Date(timeIntervalSince1970: 1679417100)),
        Transaction(id: UUID(), payee: sampleAccounts[5], payer: sampleAccounts[3], amount: 300.0, date: Date(timeIntervalSince1970: 1679421600)),
        Transaction(id: UUID(), payee: sampleAccounts[2], payer: sampleAccounts[1], amount: 70.0, date: Date(timeIntervalSince1970: 1679468100)),
        Transaction(id: UUID(), payee: sampleAccounts[4], payer: sampleAccounts[9], amount: 80.0, date: Date(timeIntervalSince1970: 1679472600)),
        Transaction(id: UUID(), payee: sampleAccounts[0], payer: sampleAccounts[6], amount: 150.0, date: Date(timeIntervalSince1970: 1679477100))
    ]
}
