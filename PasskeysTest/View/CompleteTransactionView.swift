import SwiftUI

struct CompleteTransactionView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var app = VenmoViewController()
    var transaction: Transaction
    
    var body: some View {
        let actorName = transaction.actor.displayName!
        var placeholder = transaction.amount
        var amount = Decimal()
        NSDecimalRound(&amount, &placeholder, 2, .bankers)
        
        return NavigationView {
            VStack {
                Text(actorName + " requested $" + String(describing: amount) + ".")
                    .font(.title)
                    .padding(.top, 40)
                    .padding()
                
                // TODO: figure out difference between cancel and deny
                HStack {
                    // approve payment
                    Button(action: {
                        Task {
                            await app.completeTransaction(id: transaction.id, action: TransactionCompletion.approve)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        Text("Pay")
                    }
                    .buttonStyle(.borderedProminent)
                    .font(.title2)
                    
                    // deny transaction
                    Button(action: {
                        Task {
                            await app.completeTransaction(id: transaction.id, action: TransactionCompletion.deny)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        Text("Deny")
                    }
                    .buttonStyle(.borderedProminent)
                    .font(.title2)
                    
                }
                Spacer()
            }
            .navigationTitle("Complete Transaction")
            .onDisappear {
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    appDelegate.myBool = false
                }
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    var myBool: Bool = true

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
}

struct CompleteTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        let fakeDataGenerator : FakeData = FakeData()
        var transaction : Transaction {
            fakeDataGenerator.getFakeTransaction()
        }
        CompleteTransactionView(transaction: transaction)
    }
}
