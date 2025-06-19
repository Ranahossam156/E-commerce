// LogoutSection.swift
import SwiftUI
import FirebaseAuth

struct LogoutSection: View {
    @ObservedObject var viewModel: SettingsViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var userModel: UserModel
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToLogin = false
    @State private var showLogoutAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                if Auth.auth().currentUser != nil {
                    Button(action: {
                        showLogoutAlert = true
                    }) {
                        Text("Log Out")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("primary"))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                } else {
                    Button(action: {
                        navigateToLogin = true
                    }) {
                        Text("Sign In")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("primary"))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
            )
        }
        .background(Color(.systemBackground))
        .alert("Confirm Logout", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Log Out", role: .destructive) {
                Task {
                    guard let userId = Auth.auth().currentUser?.uid else { return }
                    await FavoriteManager.shared.syncFavoritesToFirestore(for: userId)
                    do {
                        print("Before sign out")
                        try Auth.auth().signOut()
                        print("After sign out")
                        authViewModel.isAuthenticated = false
                        userModel.name = ""
                        userModel.email = ""
                        userModel.phoneNumber = ""
                        userModel.addresses = []
                        userModel.defaultAddressId = nil
                        navigateToLogin = true
                    } catch {
                        print("Error logging out: \(error.localizedDescription)")
                    }
                }
            }
        } message: {
            Text("Are you sure you want to log out?")
        }
        .background(
            NavigationLink(destination: LoginScreen().navigationBarBackButtonHidden(true), isActive: $navigateToLogin) {
                EmptyView()
            }
            .hidden()
        )
        .listRowInsets(EdgeInsets())
    }
}

// Assuming LoginView exists or replace with your actual login view
struct LoginView: View {
    var body: some View {
        Text("Login Screen")
            .navigationTitle("Login")
            .navigationBarBackButtonHidden(true)
    }
}
