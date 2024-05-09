import SwiftUI

struct TransactionView: View {
    // TODO: this variable is updated in onDisappear in CompleteTransactionView
    // to make the Complete Transaction button disappear upon return. However,
    // the button reappears after a second
    @State private var showCompleteTransaction = false
    let userName: String
    let paymentVerb: String
    var transactionType: String = ""
    let transaction: Transaction
    
    init(userName: String, transaction: Transaction) {
        self.userName = userName
        self.transaction = transaction
        self.paymentVerb = transaction.action == .pay ? "paid" : "charged"
        self.transactionType = getTransactionType(transaction: transaction)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack(alignment: .top) {
                    Image(systemName: "person.circle")
                        .font(.title)
                        .padding(.horizontal)
                    VStack(alignment: .leading) {
                        Text(transaction.actor.displayName! + " " + paymentVerb + " " + transaction.target.displayName!)
                            .font(.title2)
                        
                        //Text("Amount: " + String(transaction.amount))
                        
                        EndDateView(transaction: transaction)
                        
                        Text("Type: " + transactionType)
                        Text(transaction.note)
                            .font(.system(size: 24))
                            .padding(.top, 10)
                            .padding(.bottom, 10)
                    }
                }
                
                if transaction.actor.username != userName {
                    NavigationLink(destination: ProfileView(id: transaction.actor.id)) {
                        let actorName = transaction.actor.firstName!
                        Text(actorName + "'s Profile")
                    }
                }
                
                if transaction.target.username != userName {
                    NavigationLink(destination: ProfileView(id: transaction.target.id)) {
                        let targetName = transaction.target.firstName!
                        Text(targetName + "'s Profile")
                    }
                }
                
                let components = Calendar.current.dateComponents([.month, .day, .year], from: transaction.dateCompleted)
                if components.year == 1969 && components.day == 31 && components.month == 12 && userName == transaction.target.username && !showCompleteTransaction {
                    NavigationLink(destination: CompleteTransactionView(transaction: transaction), isActive: $showCompleteTransaction) {
                        Text("Complete Transaction")
                    }
                }
                Divider()
                Spacer()
            }
            
        }
        .padding(.top, 30)
        .padding(.trailing, 13)
            
    }
    
    private func getTransactionType(transaction: Transaction) -> String {
        var transactionType = "None"
        switch transaction.audience {
        case .public:
            transactionType = "Public"
        case .friends:
            transactionType = "Friends"
        case .private:
            transactionType = "Private"
        }
        return transactionType
    }
}
    
struct EndDateView: View {
    var transaction: Transaction
    
    var body: some View {
        let startDate = getDate(transaction: transaction, start: true)
        Text("Started: " + startDate)
        
        let endDate = getDate(transaction: transaction, start: false)
        
        if endDate != "December 31, 1969" {
            Text("Ended: " + endDate)
        } else {
            Text("Outstanding")
        }
    }
    
    public func getDate(transaction: Transaction, start: Bool) -> String {
        var date = transaction.dateCompleted
        if start {
            date = transaction.dateCreated
        }
        
        let components = Calendar.current.dateComponents([.month, .day, .year], from: date)
        if let year = components.year, let month = components.month, let day = components.day {
            let strMonth = getMonth(month: month)
            return strMonth + " " + String(day) + ", " + String(year)
        }
        return ""
    }
    
    private func getMonth(month: Int) -> String {
        if month == 1 {
            return "January"
        }
        else if month == 2 {
            return "February"
        }
        else if month == 3 {
            return "March"
        }
        else if month == 4 {
            return "April"
        }
        else if month == 5 {
            return "May"
        }
        else if month == 6 {
            return "June"
        }
        else if month == 7 {
            return "July"
        }
        else if month == 8 {
            return "August"
        }
        else if month == 9 {
            return "September"
        }
        else if month == 10 {
            return "October"
        }
        else if month == 11 {
            return "November"
        }
        else if month == 12 {
            return "December"
        }
        else {
            return "Novembruary"
        }
    }
}



struct TransactionView_Previews: PreviewProvider {
    static var previews: some View {
        let fakeDataGenerator : FakeData = FakeData()
        var transaction : Transaction {
            fakeDataGenerator.getFakeTransaction()
        }
        TransactionView(userName: "dot", transaction: transaction)
    }
}

