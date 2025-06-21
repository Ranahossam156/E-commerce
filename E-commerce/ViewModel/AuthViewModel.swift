//
//  AuthViewModel.swift
//  E-commerce
//
//  Created by Macos on 01/06/2025.
//
import Foundation
import FirebaseAuth
import UIKit

class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var username = ""
    @Published var confirmPassword = ""
    @Published var errorMessage: String?
    @Published var isAuthenticated = false
    @Published var showVerificationScreen = false
    @Published var countdownSeconds = 30
    @Published var registrationComplete = false
    @Published var navigateToLogin = false
    private var verificationTimer: Timer?
    @Published var isLoading = false

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
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                } else {
                    let isVerified = Auth.auth().currentUser?.isEmailVerified ?? false
                    if isVerified {
                        self?.navigateToLogin = true
                        self?.errorMessage = nil
                    }
                    completion(isVerified)
                }
            }
        })
    }
    func validateSignup() -> Bool {
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedConfirmPassword = confirmPassword.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedUsername.isEmpty, !trimmedEmail.isEmpty, !trimmedPassword.isEmpty, !trimmedConfirmPassword.isEmpty else {
            errorMessage = "All fields are required."
            return false
        }

        guard trimmedUsername.count >= 3 else {
            errorMessage = "Username must be at least 3 characters long."
            return false
        }

        guard isValidEmail(trimmedEmail) else {
            errorMessage = "Please enter a valid email address."
            return false
        }

        guard trimmedPassword == trimmedConfirmPassword else {
            errorMessage = "Passwords do not match."
            return false
        }

        guard trimmedPassword.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."
            return false
        }

        guard isStrongPassword(trimmedPassword) else {
            errorMessage = "Password must contain uppercase, lowercase, and a number."
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
                    self?.errorMessage = ""
                    self?.showVerificationScreen = true
                    self?.startCountdown()
                case .failure(let error):
                    self?.errorMessage = AuthErrorHelper.getErrorMessage(error: error)
                }
            }
        }
    }
    func validateLogin() -> Bool {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedEmail.isEmpty, !trimmedPassword.isEmpty else {
            errorMessage = "Email and password are required."
            return false
        }

        guard isValidEmail(trimmedEmail) else {
            errorMessage = "Please enter a valid email address."
            return false
        }

        guard trimmedPassword.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."
            return false
        }

        return true
    }

    func login() {
        guard validateLogin() else { return }

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
                    self?.errorMessage = AuthErrorHelper.getErrorMessage(error: error)
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
                    self?.errorMessage = AuthErrorHelper.getErrorMessage(error: error)
                }
            }
        }
    }
    func signInWithGoogle(presentingVC: UIViewController) {
        isLoading = true
        FirebaseAuthService.shared.signInWithGoogle(presenting: presentingVC) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success:
                    self?.isAuthenticated = true
                    print("Google Sign-In success")
                    self?.showVerificationScreen = false
                    self?.navigateToLogin = false
                case .failure(let error):
                    self?.errorMessage = AuthErrorHelper.getErrorMessage(error: error)
                }
            }
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: email)
    }

    private func isStrongPassword(_ password: String) -> Bool {
        let passwordRegEx = #"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{6,}$"#
        return NSPredicate(format: "SELF MATCHES %@", passwordRegEx).evaluate(with: password)
    }
    func checkIfUserIsAuthenticated() {
        if let user = Auth.auth().currentUser {
            isAuthenticated = user.isEmailVerified
        } else {
            isAuthenticated = false
        }
    }


}
