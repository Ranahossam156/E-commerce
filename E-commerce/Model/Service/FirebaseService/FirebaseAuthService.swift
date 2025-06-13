//
//  FirebaseAuthService.swift
//  E-commerce
//
//  Created by Macos on 01/06/2025.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import GoogleSignInSwift
import UIKit
import GoogleSignIn


class FirebaseAuthService {
    static let shared = FirebaseAuthService()

    func register(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
            } else {
                result?.user.sendEmailVerification(completion: nil)
                completion(.success(()))
            }
        }
    }

    func login(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let user = result?.user, !user.isEmailVerified {
                completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Please verify your email."])))
            } else {
                completion(.success(()))
            }
        }
    }
    func sendVerificationEmail(completion: @escaping (Result<Void, Error>) -> Void) {
        if let user = Auth.auth().currentUser {
            user.sendEmailVerification { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } else {
            completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "No user is logged in."])))
        }
    }
    func signInWithGoogle(presenting: UIViewController, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion(.failure(NSError(domain: "Client ID not found", code: 0)))
            return
        }

        let config = GIDConfiguration(clientID: clientID)

        GIDSignIn.sharedInstance.signIn(with: config, presenting: presenting) { user, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else {
                completion(.failure(NSError(domain: "Google Sign-In Error", code: 0)))
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken)

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }

}

enum AuthErrorHelper {
    static func getErrorMessage(error: Error) -> String {
        let nsError = error as NSError

        guard let errorCode = AuthErrorCode.Code(rawValue: nsError.code) else {
            return error.localizedDescription
        }

        switch errorCode {
        case .invalidEmail:
            return "The email address is badly formatted."
        case .userDisabled:
            return "Your account has been disabled."
        case .userNotFound:
            return "No user found with this email."
        case .wrongPassword:
            return "Incorrect password. Please try again."
        case .networkError:
            return "Network error. Please check your internet connection."
        case .tooManyRequests:
            return "Too many login attempts. Try again later."
        case .emailAlreadyInUse:
            return "This email is already in use."
        case .weakPassword:
            return "Password should be at least 6 characters."
        case .invalidCredential:
            return "Invalid username or password. Please try again."
        case .accountExistsWithDifferentCredential:
            return "Account already exists with a different sign-in method."
        case .credentialAlreadyInUse:
            return "This credential is already associated with another user."
        default:
            print("Unhandled Firebase Auth error code: \(nsError.code), message: \(nsError.localizedDescription)")
            return "Something went wrong. Please try again."

        }
    }


}
