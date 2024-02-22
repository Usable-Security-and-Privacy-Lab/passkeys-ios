import Foundation

struct Profile: Codable, Hashable {
    var username: String
    var firstName: String?
    var lastName: String?
    var displayName: String? {
        set {
            if let newValue {
                self.displayName = newValue
            }
        }
        get {
            if let firstName = firstName, let lastName = lastName {
                return firstName + " " + lastName
            } else if let firstName = firstName {
                return firstName
            } else if let lastName = lastName {
                return lastName
            } else {
                return username
            }
        }
    }
    var relationship: Relationship?
    var friendsCount: Int?
    var id: Int
    var balance: Decimal?
}

enum Relationship: String, Codable, Hashable {
    case me = "me"
    case friend = "friend"
    case none = "none"
    case youRequested = "youRequested"
    case theyRequested = "theyRequested"
}
