import Foundation

class NetworkManager {
    private let baseURL = "https://passkeys-backend-7c680c0b8dcc.herokuapp.com"
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
    }
    
    private struct TransactionResponse: Codable {
        let pagination: Pagination
        let data: [Transaction]
    }
    private struct Pagination: Codable {
        let lastTransactionID: Int
    }
    
    
    private func makeAPIRequest(endpoint: String, method: HTTPMethod, reqBody: Data? = nil) async -> (Data?, HTTPURLResponse?) {
        let url = URL(string: baseURL + endpoint)
        var req = URLRequest(url: url!)
        req.httpMethod = method.rawValue
        
        if let reqBody {
            req.httpBody = reqBody
        }
        
        var (data, response): (Data?, URLResponse?)
        do {
            (data, response) = try await URLSession.shared.data(for: req)
        } catch {
            print("URLSession error: \(error)")
        }
        
        if let response = response as? HTTPURLResponse {
            switch response.statusCode {
            case 200...299: break
            default:
                print("Error: Reponse code: \(response.statusCode)")
                try? print("Message: \(JSONDecoder().decode([String: String].self, from: data!))")
                
            }
            return (data, response)
        } else {
            print("Error: No response")
            return (nil, nil)
        }
    }
    
    // GET /me
    public func getCurrentUserInfo() async -> Profile? {
        let endpoint = "/me"
        let (data, _) = await makeAPIRequest(endpoint: endpoint, method: .get)
        
        if let data {
            let decoder = JSONDecoder()
            let profile = try? decoder.decode(Profile.self, from: data)
            return profile
        } else {
            return nil
        }
    }
    
    // GET /profiles/:userID
    public func getProfileWithID(_ id: Int) async -> Profile? {
        let endpoint = "/profiles/\(id)"
        let (data, _) = await makeAPIRequest(endpoint: endpoint, method: .get)
        
        if let data {
            let decoder = JSONDecoder()
            let profile = try? decoder.decode(Profile.self, from: data)
            return profile
        } else {
            return nil
        }
    }
    
    // POST /profiles/:userID/friends
    /// Returns true if the request was successful
    public func addFriendWithID(_ id: Int) async -> Bool {
        await performFriendOperation("friend", withUserID: id)
    }
    
    /// Returns true if the request was successful
    public func removeFriendWithID(_ id: Int) async -> Bool {
        await performFriendOperation("none", withUserID: id)
    }
    
    private func performFriendOperation(_ operation: String, withUserID userID: Int) async -> Bool {
        guard operation == "friend" || operation == "none" else {
            print("Error: Invalid friend operation")
            return false
        }
        
        let endpoint = "/profiles/\(userID)/friends"
        let reqBody = try? JSONEncoder().encode(["relationship": operation])
        let (_, response) = await makeAPIRequest(endpoint: endpoint, method: .post, reqBody: reqBody)
        
        if response?.statusCode == 200 {
            return true
        } else {
            return false
        }
    }
    
    // GET /profiles/:userID/friends
    public func getFriendsForProfileWithID(_ id: Int) async -> [Profile]? {
        let endpoint = "/profiles/\(id)/friends"
        let (data, _) = await makeAPIRequest(endpoint: endpoint, method: .get)
        
        if let data {
            let decoder = JSONDecoder()
            let friends = try? decoder.decode([Profile].self, from: data)
            return friends
        } else {
            return nil
        }
    }
    
    // POST /transactions
    // TODO: implement
    
    // GET /transactions
    public func getFriendsFeed(lastFetchedTransactionID: Int? = nil) async -> [Transaction]? {
        await fetchTransactions(feedType: "friends", lastFetchedTransactionID: lastFetchedTransactionID)
    }
    
    public func getUserTransactions(userID: Int, lastFetchedTransactionID: Int? = nil) async -> [Transaction]? {
        await fetchTransactions(feedType: "user", partyID: userID, lastFetchedTransactionID: lastFetchedTransactionID)
    }
    
    public func getMyTransactionsWith(userID: Int, lastFetchedTransactionID: Int? = nil) async -> [Transaction]? {
        await fetchTransactions(feedType: "betweenUs", partyID: userID, lastFetchedTransactionID: lastFetchedTransactionID)
    }
    
    private func fetchTransactions(feedType: String, partyID: Int? = nil, lastFetchedTransactionID: Int? = nil) async -> [Transaction]? {
        let endpoint = "/transactions"
        var reqJSON: [String:Any] = ["feed":feedType] // friends, user, or betweenUs
        if let partyID {
            reqJSON["partyID"] = partyID
        }
        if let lastFetchedTransactionID {
            reqJSON["lastTransactionID"] = lastFetchedTransactionID
        }
        
        let reqBody = try? JSONSerialization.data(withJSONObject: reqJSON)
        let (data, _) = await makeAPIRequest(endpoint: endpoint, method: .get, reqBody: reqBody)
        
        if let data {
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                
                let response = try decoder.decode(TransactionResponse.self, from: data)
                return response.data
            } catch {
                print("Error decoding transactions JSON: \(error)")
            }
        }
        return nil
    }
    
    // GET /transactions/outstanding
    public func getOutstandingTransactions(lastFetchedTransactionID: Int? = nil) async -> [Transaction]? {
        let endpoint = "/transactions/outstanding"
        
        var reqBody: Data?
        if let lastFetchedTransactionID {
            reqBody = try? JSONSerialization.data(withJSONObject: ["lastTransactionID": lastFetchedTransactionID])
        }
        let (data, _) = await makeAPIRequest(endpoint: endpoint, method: .get, reqBody: reqBody)
        
        if let data {
            let decoder = JSONDecoder()
            let transactionResponse = try? decoder.decode(TransactionResponse.self, from: data)
            return transactionResponse?.data
        } else {
            return nil
        }
    }
    
    // GET /transactions/:transactionID
    public func getTransactionByID(_ id: Int) async -> Transaction? {
        let endpoint = "/transactions/\(id)"
        let (data, _) = await makeAPIRequest(endpoint: endpoint, method: .get)
        
        if let data {
            let decoder = JSONDecoder()
            let transaction = try? decoder.decode(Transaction.self, from: data)
            return transaction
        } else {
            return nil
        }
    }
    
    // PUT /transactions/:transactionID
    public func completeTransaction(withID id: Int, action: TransactionCompletion) async -> Transaction? {
        let endpoint = "/transactions/\(id)"
        let reqBody = try? JSONEncoder().encode(["action": action.rawValue])
        
        let (data, _) = await makeAPIRequest(endpoint: endpoint, method: .put, reqBody: reqBody)
        
        if let data {
            let decoder = JSONDecoder()
            let transaction = try? decoder.decode(Transaction.self, from: data)
            return transaction
        } else {
            return nil
        }
    }
}
