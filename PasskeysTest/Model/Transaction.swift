import Foundation

struct Transaction: Identifiable, Codable {
    var id: Int
    var actor: Profile
    var target: Profile
    var amount: Double?
    var action: TransactionAction
    var note: String
    var dateCreated: Date
    var dateCompleted: Date
    var audience: TransactionAudience
}

enum TransactionAction: String, Codable {
    case pay = "pay"
    case request = "request"
}

enum TransactionAudience: String, Codable {
    case `public` = "public"
    case friends = "friends"
    case `private` = "private"
}

enum TransactionCompletion: String {
    case approve = "approve"
    case deny = "deny"
    case cancel = "cancel"
}
