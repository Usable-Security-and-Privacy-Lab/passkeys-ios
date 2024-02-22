import Foundation

struct Transaction: Identifiable, Codable, Hashable {
    var id: Int
    var actor: Profile
    var target: Profile
    var amount: Decimal?
    var action: TransactionAction
    var note: String
    var dateCreated: Date
    var dateCompleted: Date
    var audience: TransactionAudience
}

enum TransactionAction: String, Codable, Hashable {
    case pay = "pay"
    case request = "request"
}

enum TransactionAudience: String, Codable, Hashable {
    case `public` = "public"
    case friends = "friends"
    case `private` = "private"
}

enum TransactionCompletion: String {
    case approve = "approve"
    case deny = "deny"
    case cancel = "cancel"
}

enum TransactionFeedType: String {
    case friends = "friends"
    case user = "user"
    case betweenUs = "betweenUs"
}
