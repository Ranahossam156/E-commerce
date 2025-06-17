//
//  LogoutSection.swift
//  E-commerce
//
//  Created by Kerolos on 17/06/2025.
//

import SwiftUICore
import Foundation
import SwiftUI
import FirebaseAuth

struct LogoutSection: View {
    @ObservedObject var viewModel: SettingsViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var userModel = UserModel() // Ensure UserModel is accessible
    @State private var navigateToSignIn = false
    @State private var navigateToHome = false
    @State private var showLogoutAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Button Container
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                if Auth.auth().currentUser != nil {
                    // Log Out Button
                    Button(action: {
                        showLogoutAlert = true
                    }) {
                        Text("Log Out")
                            .font(.headline)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .buttonStyle(.plain)
                } else {
                    // Sign In Button with Navigation
                    NavigationLink(destination: LoginScreen(), isActive: $navigateToSignIn) {
                        EmptyView()
                    }
                    .hidden()
                    
                    Button(action: {
                        withAnimation {
                            navigateToSignIn = true
                        }
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
                        try Auth.auth().signOut()
                        authViewModel.isAuthenticated = false
                        userModel.name = ""
                        userModel.email = ""
                        userModel.phoneNumber = ""
                        userModel.addresses = []
                        userModel.defaultAddressId = nil                    }
                    catch {
                        print("Error logging out: \(error.localizedDescription)")
                    }
                }
            }
        } message: {
            Text("Are you sure you want to log out?")
        }
        
        .listRowInsets(EdgeInsets()) // Ensures no separators if used in a List
    }
}
