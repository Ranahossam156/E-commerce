//
//  AuthViewModel.swift
//  E-commerce
//
//  Created by Macos on 01/06/2025.
//
import Foundation
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var username = ""
    @Published var confirmPassword = ""
    @Published var errorMessage: String?
    @Published var isAuthenticated = false
    @Published var showVerificationScreen = false
    @Published var countdownSeconds = 30
    @Published var isLoading = false // Add isLoading property
    private var verificationTimer: Timer?
    
    func startCountdown() {
        countdownSeconds = 30
        verificationTimer?.invalidate()
        verificationTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.countdownSeconds > 0 {
                self.countdownSeconds -= 1
            } else {
                self.verificationTimer?.invalidate()
            }
        }
    }

    func checkEmailVerification(completion: @escaping (Bool) -> Void) {
        Auth.auth().currentUser?.reload(completion: { [weak self] error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                completion(false)
            } else {
                let isVerified = Auth.auth().currentUser?.isEmailVerified ?? false
                completion(isVerified)
            }
        })
    }
    func validateSignup() -> Bool {
        guard !username.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "All fields are required."
            return false
        }

        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return false
        }

        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."
            return false
        }

        return true
    }

    func register() {
        guard validateSignup() else { return }
        
        FirebaseAuthService.shared.register(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.errorMessage = "A verification email has been sent."
                    self?.showVerificationScreen = true
                    self?.startCountdown()
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func login() {
        FirebaseAuthService.shared.login(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    if Auth.auth().currentUser?.isEmailVerified == true {
                        self?.isAuthenticated = true
                        print("Login success!")
                    } else {
                        self?.errorMessage = "Please verify your email first."
                        self?.showVerificationScreen = true
                        self?.startCountdown()
                    }
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    func resendVerificationEmail() {
        FirebaseAuthService.shared.sendVerificationEmail { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.errorMessage = "A new verification email has been sent."
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

}
