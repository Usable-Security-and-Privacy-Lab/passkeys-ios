/*
 See the LICENSE.txt file for this sample’s licensing information.
 
 Abstract:
 AccountStore manages account sign in and out.
 */

import AuthenticationServices
import SwiftUI
import Combine
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
    
    //    No passwords in our project
    //    public func createPasswordAccount(username: String, password: String) async {
    //        currentUser = .authenticated(username: username)
    //    }
    
    public func signOut() {
        currentUser = nil
    }
    
    // MARK: - Private
    
    private static let relyingPartyIdentifier = "passkeys-backend-7c680c0b8dcc.herokuapp.com"
    
    
    // TODO: we need two different passkey challenge functions b/c one sends the user, and we need to deal with that as well when this function is called
    private func passkeyChallenge(type: String) async -> Data {
        let url = URL(string: "https://passkeys-backend-7c680c0b8dcc.herokuapp.com/\(type)/public-key/challenge")
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
                    print(json)
                    print(encodedChallengeString)
                    
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
            .createCredentialAssertionRequest(challenge: passkeyChallenge(type: "login"))
    }
    
    private func passkeyRegistrationRequest(username: String) async -> ASAuthorizationRequest {
        await ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: Self.relyingPartyIdentifier)
            .createCredentialRegistrationRequest(challenge: passkeyChallenge(type: "signup"), name: username, userID: Data(username.utf8)) // TODO userID should come from server
    }
    
//    private func signInRequests() async -> [ASAuthorizationRequest] {
//        await [passkeyAssertionRequest(), ASAuthorizationPasswordProvider().createRequest()]
//    }
    
    // MARK: - Handle the results.
    
    private func handleAuthorizationResult(_ authorizationResult: ASAuthorizationResult, username: String? = nil) async throws {
        switch authorizationResult {
        case let .passkeyAssertion(passkeyAssertion):
            // The login was successful.
            
//            currentUser = .authenticated(username: username)
            Logger.authorization.log("Passkey authorization succeeded: \(passkeyAssertion)")
        case let .passkeyRegistration(passkeyRegistration):
            // The registration was successful.
            await finishRegistration(with: passkeyRegistration)
            
//            if let username {
//                currentUser = .authenticated(username: username)
//            }
            Logger.authorization.log("Passkey registration succeeded: \(passkeyRegistration)")
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
            "attestationObject": attestationObject?.base64EncodedString().base64ToBase64url,
            "clientDataJSON": clientDataJSON.base64EncodedString().base64ToBase64url,
            //            "credentialID": credentialID.base64EncodedString(),
        ])
        
        var response: URLResponse? = nil
        do {
            try (_, response) = await URLSession.shared.data(for: request)
        } catch URLError.notConnectedToInternet {
            Logger.authorization.error("No internet connection")
        } catch {
            Logger.authorization.error("URL request for challenge failed: \(error)")
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
    
    private func finishLogin(with passkeyAssertion: ASAuthorizationPlatformPublicKeyCredentialAssertion) async {
        let clientDataJSON = passkeyAssertion.rawClientDataJSON
        let authenticatorData = passkeyAssertion.rawAuthenticatorData
        let signature = passkeyAssertion.signature
        let userID = passkeyAssertion.credentialID
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
