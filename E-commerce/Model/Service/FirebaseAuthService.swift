//
//  FirebaseAuthService.swift
//  E-commerce
//
//  Created by Macos on 01/06/2025.
//

import Foundation
import FirebaseAuth

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

}

