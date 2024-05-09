import SwiftUI

struct FakeData {
    // TODO: this is fake data; set back to app.friendTransactionFeed
    public func populateFakeData() -> [Transaction] {
        var fakeData: [Transaction] = []

        var p1 = Profile(username: "finn", id: 1)
        p1.firstName = "Finn"
        p1.lastName = "Ames"
        
        var p2 = Profile(username: "mash", id: 2)
        p2.firstName = "Mash"
        p2.lastName = "Burnedead"
        
        var p3 = Profile(username: "lemon", id: 3)
        p3.firstName = "Lemon"
        p3.lastName = "Irving"
                
        let t1 = Transaction(id: 1, actor: p1, target: p2, amount: 10, action: TransactionAction.pay, note: "Pizza", dateCreated: getDate(day: 5, month: 3, year: 2024), dateCompleted: getDate(day: 6, month: 3, year: 2024), audience: TransactionAudience.public)
        let t2 = Transaction(id: 2, actor: p2, target: p3, amount: 10, action: TransactionAction.pay, note: "Cream Puffs", dateCreated: getDate(day: 5, month: 2, year: 2024), dateCompleted: getDate(day: 6, month: 2, year: 2024), audience: TransactionAudience.public)
        let t3 = Transaction(id: 3, actor: p3, target: p1, amount: 10, action: TransactionAction.pay, note: "Pretzels", dateCreated: getDate(day: 5, month: 1, year: 2024), dateCompleted: getDate(day: 6, month: 1, year: 2024), audience: TransactionAudience.public)
        
        fakeData.append(t1)
        fakeData.append(t2)
        fakeData.append(t3)
        return fakeData
    }
    
    private func getDate(day: Int, month: Int, year: Int) -> Date {
        if let date = Calendar.current.date(from: DateComponents(year: year, month: month, day: day)) {
            return date
        }
        return Date()
    }
    
    public func getFakeTransaction() -> Transaction {
        var p1 = Profile(username: "lance", id: 1)
        p1.firstName = "Lance"
        p1.lastName = "Crown"
        
        var p2 = Profile(username: "dot", id: 2)
        p2.firstName = "Dot"
        p2.lastName = "Barrett"
        
        return Transaction(id: 1, actor: p1, target: p2, amount: 19.99, action: TransactionAction.pay, note: "Pizza", dateCreated: getDate(day: 5, month: 3, year: 2024), audience: TransactionAudience.public)
    }
    
    public func getFakeOutstandingTransactions() -> [Transaction] {
        var p1 = Profile(username: "finn", id: 1)
        p1.firstName = "Finn"
        p1.lastName = "Ames"
        
        var p2 = Profile(username: "mash", id: 2)
        p2.firstName = "Mash"
        p2.lastName = "Burnedead"
        
        var p3 = Profile(username: "lemon", id: 3)
        p3.firstName = "Lemon"
        p3.lastName = "Irving"
        
        let t1 = Transaction(id: 1, actor: p2, target: p1, amount: 10, action: TransactionAction.request, note: "Pizza", dateCreated: getDate(day: 5, month: 3, year: 2024), audience: TransactionAudience.public)
        let t2 = Transaction(id: 2, actor: p2, target: p1, amount: 10, action: TransactionAction.request, note: "Cream Puffs", dateCreated: getDate(day: 5, month: 2, year: 2024), audience: TransactionAudience.public)
        let t3 = Transaction(id: 3, actor: p3, target: p1, amount: 10, action: TransactionAction.pay, note: "Pretzels", dateCreated: getDate(day: 5, month: 1, year: 2024), audience: TransactionAudience.public)
        
        var outstanding: [Transaction] = []
        outstanding.append(t1)
        outstanding.append(t2)
        outstanding.append(t3)

        return outstanding
    }
}
