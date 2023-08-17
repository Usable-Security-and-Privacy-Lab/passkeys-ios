import Foundation

struct Profile: Codable {
    var username: String
    var firstName: String
    var lastName: String
    var displayName: String { firstName + " " + lastName }
    var relationship: Relationship?
    var friendsCount: Int?
    var id: Int
    var balance: Double?
}

enum Relationship: String, Codable {
    case me = "me"
    case friend = "friend"
    case none = "none"
    case youRequested = "youRequested"
    case theyRequested = "theyRequested"
}
