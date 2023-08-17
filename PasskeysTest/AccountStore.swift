import AuthenticationServices
import SwiftUI
import os

public extension Logger {
    static let authorization = Logger(subsystem: "PasskeysTest", category: "PasskeysTest Authorization")
}

public enum AuthorizationHandlingError: Error {
    case unknownAuthorizationResult(ASAuthorizationResult)
    case otherError
}

extension AuthorizationHandlingError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unknownAuthorizationResult:
            return NSLocalizedString("Received an unknown authorization result.",
                                     comment: "Human readable description of receiving an unknown authorization result.")
        case .otherError:
            return NSLocalizedString("Encountered an error handling the authorization result.",
                                     comment: "Human readable description of an unknown error while handling the authorization result.")
        }
    }
}

@MainActor
public final class AccountStore: NSObject, ObservableObject, ASAuthorizationControllerDelegate {
    @Published public private(set) var currentUser: User? = nil
    
    public weak var presentationContextProvider: ASAuthorizationControllerPresentationContextProviding?
    
    public var isSignedIn: Bool {
        currentUser != nil
    }
    
    func beginAutoFillAssistedPasskeySignIn(authorizationController: AuthorizationController) async {
        do {
            let authorizationResult = try await authorizationController.performAutoFillAssistedRequest(passkeyAssertionRequest())
            try await handleAuthorizationResult(authorizationResult)
        } catch let authorizationError as ASAuthorizationError {
            Logger.authorization.error("Passkey authorization failed. Error: \(authorizationError.localizedDescription)")
        } catch AuthorizationHandlingError.unknownAuthorizationResult(let authorizationResult) {
            // Received an unknown response.
            Logger.authorization.error("""
            Passkey authorization handling failed. \
            Received an unknown result: \(String(describing: authorizationResult))
            """)
        } catch {
            // Some other error occurred while handling the authorization.
            Logger.authorization.error("""
            Passkey authorization handling failed. \
            Caught an unknown error during passkey authorization or handling: \(error.localizedDescription)"
            """)
        }
    }
    
    public func signIntoPasskeyAccount(authorizationController: AuthorizationController,
                                       options: ASAuthorizationController.RequestOptions = []) async {
        do {
            let authorizationResult = try await authorizationController.performRequests(
                [passkeyAssertionRequest()],
                options: options // currently, none
            )
            try await handleAuthorizationResult(authorizationResult)
        } catch let authorizationError as ASAuthorizationError where authorizationError.code == .canceled {
            // The user cancelled the authorization.
            Logger.authorization.log("The user cancelled passkey authorization.")
        } catch let authorizationError as ASAuthorizationError {
            // Some other error occurred occurred during authorization.
            Logger.authorization.error("Passkey authorization failed. Error: \(authorizationError.localizedDescription)")
        } catch AuthorizationHandlingError.unknownAuthorizationResult(let authorizationResult) {
            // Received an unknown response.
            Logger.authorization.error("""
            Passkey authorization handling failed. \
            Received an unknown result: \(String(describing: authorizationResult))
            """)
        } catch {
            // Some other error occurred while handling the authorization.
            Logger.authorization.error("""
            Passkey authorization handling failed. \
            Caught an unknown error during passkey authorization or handling: \(error.localizedDescription)"
            """)
        }
    }
    
    public func createPasskeyAccount(authorizationController: AuthorizationController, username: String,
                                     options: ASAuthorizationController.RequestOptions = []) async {
        do {
            let authorizationResult = try await authorizationController.performRequests(
                [passkeyRegistrationRequest(username: username)],
                options: options
            )
            try await handleAuthorizationResult(authorizationResult, username: username)
        } catch let authorizationError as ASAuthorizationError where authorizationError.code == .canceled {
            // The user cancelled the registration.
            Logger.authorization.log("The user cancelled passkey registration.")
        } catch let authorizationError as ASAuthorizationError {
            // Some other error occurred occurred during registration.
            Logger.authorization.error("Passkey registration failed. Error: \(authorizationError.localizedDescription)")
        } catch AuthorizationHandlingError.unknownAuthorizationResult(let authorizationResult) {
            // Received an unknown response.
            Logger.authorization.error("""
            Passkey registration handling failed. \
            Received an unknown result: \(String(describing: authorizationResult))
            """)
        } catch {
            // Some other error occurred while handling the registration.
            Logger.authorization.error("""
            Passkey registration handling failed. \
            Caught an unknown error during passkey registration or handling: \(error.localizedDescription).
            """)
        }
    }
    
    public func signOut() async {
        let url = URL(string: "https://passkeys-backend-7c680c0b8dcc.herokuapp.com/logout")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        var response: URLResponse?
        do {
            (_, response) = try await URLSession.shared.data(for: request)
        } catch {
            Logger.authorization.error("Error caught when attempting to sign out user: \(error)")
        }
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            Logger.authorization.error("Sign out response not OK/200")
            return
        }
        currentUser = nil
        await URLSession.shared.reset()
    }
    
    // MARK: - Private
    
    private static let relyingPartyIdentifier = "passkeys-backend-7c680c0b8dcc.herokuapp.com"
    
    private func passkeyChallengeSignUp(username: String) async -> (challenge: Data, userIDData: Data) {
        let url = URL(string: "https://passkeys-backend-7c680c0b8dcc.herokuapp.com/signup/public-key/challenge")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "username": username,
            "name": username + "-name"
        ])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var (data, response): (Data?, URLResponse?) = (nil, nil)
        do {
            try (data, response) = await URLSession.shared.data(for: request)
        } catch {
            Logger.authorization.error("URL request for challenge failed: \(error)")
        }
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            Logger.authorization.error("passkeyChallenge response not OK/200")
            return (Data(), Data())
        }
        
        // Decode the challenge and return it as Data
        if let responseData = data {
            do {
                if let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any],
                   let encodedChallengeString = json["challenge"] as? String,
                   let user = json["user"] as? [String: Any],
                   let userID = user["id"] as? String {
                    return (Data(base64Encoded: encodedChallengeString.base64urlToBase64)!,
                            Data(base64Encoded: userID.base64urlToBase64)!)
                } else {
                    Logger.authorization.error("Failed to extract challenge from JSON")
                }
            } catch {
                Logger.authorization.error("Failed to parse JSON response: \(error)")
            }
        } else {
            Logger.authorization.error("Failed to receive challenge data")
        }
        
        return (Data(), Data())
    }
    
    private func passkeyChallengeLogIn() async -> Data {
        let url = URL(string: "https://passkeys-backend-7c680c0b8dcc.herokuapp.com/login/public-key/challenge")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        var (data, response): (Data?, URLResponse?) = (nil, nil)
        do {
            try (data, response) = await URLSession.shared.data(for: request)
        } catch {
            Logger.authorization.error("URL request for challenge failed: \(error)")
        }
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            Logger.authorization.error("passkeyChallenge response not OK/200")
            return Data()
        }
        
        // Decode the challenge and return it as Data
        if let responseData = data {
            do {
                if let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any],
                   let encodedChallengeString = json["challenge"] as? String {
                    return Data(base64Encoded: encodedChallengeString.base64urlToBase64)!
                } else {
                    Logger.authorization.error("Failed to extract challenge from JSON")
                }
            } catch {
                Logger.authorization.error("Failed to parse JSON response: \(error)")
            }
        } else {
            Logger.authorization.error("Failed to receive challenge data")
        }
        
        return Data()
    }
    
    private func passkeyAssertionRequest() async -> ASAuthorizationRequest {
        await ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: Self.relyingPartyIdentifier)
            .createCredentialAssertionRequest(challenge: passkeyChallengeLogIn())
    }
    
    private func passkeyRegistrationRequest(username: String) async -> ASAuthorizationRequest {
        let (challenge, userID) = await passkeyChallengeSignUp(username: username)
        return ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: Self.relyingPartyIdentifier)
            .createCredentialRegistrationRequest(challenge: challenge, name: username, userID: userID)
    }
    
    // MARK: - Handle the results.
    
    private func handleAuthorizationResult(_ authorizationResult: ASAuthorizationResult, username: String? = nil) async throws {
        switch authorizationResult {
        case let .passkeyAssertion(passkeyAssertion): // LOGIN
            let (succeeded, fetchedUsername) = await finishLogin(with: passkeyAssertion)
            if succeeded {
                currentUser = .authenticated(username: fetchedUsername)
                Logger.authorization.log("Passkey authorization succeeded: \(passkeyAssertion)")
            } else {
                Logger.authorization.log("Passkey authorization failed: \(passkeyAssertion)")
            }
        case let .passkeyRegistration(passkeyRegistration): // REGISTER
            if await finishRegistration(with: passkeyRegistration) {
                Logger.authorization.log("Passkey registration succeeded: \(passkeyRegistration)")
                if let username {
                    currentUser = .authenticated(username: username)
                }
            } else {
                Logger.authorization.log("Passkey registration failed: \(passkeyRegistration)")
            }
        default:
            Logger.authorization.error("Received an unknown authorization result.")
            // Throw an error and return to the caller.
            throw AuthorizationHandlingError.unknownAuthorizationResult(authorizationResult)
        }
        // In a real app, call the code at this location to obtain and save an authentication token to the keychain and sign in the user.
    }
    
    private func finishRegistration(with passkeyRegistration: ASAuthorizationPlatformPublicKeyCredentialRegistration) async -> Bool {
        let attestationObject = passkeyRegistration.rawAttestationObject
        let clientDataJSON = passkeyRegistration.rawClientDataJSON
        //        let credentialID = passkeyRegistration.credentialID
        
        let url = URL(string: "https://passkeys-backend-7c680c0b8dcc.herokuapp.com/login/public-key")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "response": [
                "attestationObject": attestationObject?.base64EncodedString().base64ToBase64url,
                "clientDataJSON": clientDataJSON.base64EncodedString().base64ToBase64url
            ]
        ])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        var response: URLResponse? = nil
        do {
            try (_, response) = await URLSession.shared.data(for: request)
        } catch URLError.notConnectedToInternet {
            Logger.authorization.error("No internet connection (in finishRegistration)")
        } catch {
            Logger.authorization.error("URL request for login failed: \(error)")
        }
        
        switch (response as? HTTPURLResponse)?.statusCode ?? -1 {
        case 200...300:
            Logger.authorization.log("Registration succeeded")
            return true
        default:
            Logger.authorization.error("Registration failed")
            return false
        }
    }
    
    private func finishLogin(with passkeyAssertion: ASAuthorizationPlatformPublicKeyCredentialAssertion) async -> (Bool, String) {
        let credentialID = passkeyAssertion.credentialID
        let clientDataJSON = passkeyAssertion.rawClientDataJSON
        let authenticatorData = passkeyAssertion.rawAuthenticatorData
        let signature = passkeyAssertion.signature
        let userHandle = passkeyAssertion.userID
        
        let url = URL(string: "https://passkeys-backend-7c680c0b8dcc.herokuapp.com/login/public-key")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "id": credentialID.base64EncodedString().base64ToBase64url,
            "response": [
                "clientDataJSON": clientDataJSON.base64EncodedString().base64ToBase64url,
                "authenticatorData": authenticatorData?.base64EncodedString().base64ToBase64url,
                "signature": signature?.base64EncodedString().base64ToBase64url,
                "userHandle": userHandle?.base64EncodedString().base64ToBase64url
            ]
        ] as [String : Any])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        var (data, response): (Data?, URLResponse?) = (nil, nil)
        do {
            try (data, response) = await URLSession.shared.data(for: request)
        } catch URLError.notConnectedToInternet {
            Logger.authorization.error("No internet connection")
        } catch {
            Logger.authorization.error("URL request for login failed: \(error)")
        }
        
        switch (response as? HTTPURLResponse)?.statusCode ?? -1 {
        case 200...300:
            Logger.authorization.log("Login succeeded")
        default:
            Logger.authorization.error("Login failed")
            return (false, "")
        }
        
        if let responseData = data {
            do {
                if let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any],
                   let username = json["username"] as? String {
                    return (true, username)
                } else {
                    Logger.authorization.error("Failed to extract username from JSON")
                }
            } catch {
                Logger.authorization.error("Failed to parse JSON response: \(error)")
            }
        } else {
            Logger.authorization.error("Failed to receive username data")
        }
        return (false, "")
    }
    
    // MARK: Test functions - TODO: delete
    
    public func signInDefaultUser() {
        currentUser = .default
    }
    
    public func checkAuthorization() async {
        let url = URL(string: "https://passkeys-backend-7c680c0b8dcc.herokuapp.com/checkAuthentication")
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        
        var response: URLResponse?
        do {
            (_, response) = try await URLSession.shared.data(for: request)
        } catch {
            Logger.authorization.error("Error caught when attempting to sign out user: \(error)")
        }
        
        switch (response as? HTTPURLResponse)?.statusCode ?? -1 {
        case 200...300:
            Logger.authorization.debug("User authenticated according to server")
        default:
            Logger.authorization.debug("User NOT AUTHENTICATED according to server")
        }
    }
    
    public func clearURLSession() async {
        await URLSession.shared.reset()
    }
}

extension String {
    var base64urlToBase64: String {
        var base64 = self
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        if base64.count % 4 != 0 {
            base64.append(String(repeating: "=", count: 4 - base64.count % 4))
        }
        return base64
    }
    
    var base64ToBase64url: String {
        let base64url = self
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
        return base64url
    }
}
