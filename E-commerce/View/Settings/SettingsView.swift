// SettingsView.swift
// E-commerce
// Created by Kerolos on 02/06/2025

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel = SettingsViewModel()
    @StateObject private var userModel: UserModel = UserModel()

    var body: some View {
        NavigationView {
            List {
                // User Info Header
                Section {
                    HStack(alignment: .center, spacing: 12) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.gray)
                            .accessibilityHidden(true)

                        VStack(alignment: .leading, spacing: 6) {
                            Text(userModel.name.isEmpty ? "User Name" : userModel.name)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                                .accessibilityLabel("User name: \(userModel.name.isEmpty ? "Not set" : userModel.name)")

                            Text(userModel.email.isEmpty ? "email@example.com" : userModel.email)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .accessibilityLabel("Email: \(userModel.email.isEmpty ? "Not set" : userModel.email)")

                            Text("Address: \(userModel.address.isEmpty ? "Not Set" : userModel.address)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .accessibilityLabel("Current address: \(userModel.address.isEmpty ? "Not set" : userModel.address)")

                            Text("Phone : \(userModel.phoneNumber.isEmpty ? "Not Set" : userModel.phoneNumber)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .accessibilityLabel("Phone number: \(userModel.phoneNumber.isEmpty ? "Not set" : userModel.phoneNumber)")
                        }
                        Spacer()
                        Image(systemName: "pencil.circle.fill")
                            .foregroundColor(.gray)
                            .accessibilityLabel("Edit profile")
                    }
                    .padding(.vertical, 12)
                }

                // Settings Section
                Section(header:Text("Settings").font(.caption).foregroundColor(.gray)) {
                    NavigationLink(destination: Text("Orders View")) {
                        Text("Orders")
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                    .accessibilityLabel("Go to orders")

                    NavigationLink(destination: AddressesView(userModel: userModel)) {
                        Text("Addresses")
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                    .accessibilityLabel("Go to addresses")

                    Picker("Currency", selection: $viewModel.selectedCurrency) {
                        ForEach(viewModel.currencies, id: \.self) { currency in
                            Text(currency).tag(currency)
                        }
                    }
                    .pickerStyle(.menu)
                    .accessibilityLabel("Select currency")
                    .onChange(of: viewModel.selectedCurrency) { _ in
                        viewModel.saveSettings()
                    }

                  
                }

//                // Support Section
//                Section(header: Text("SUPPORT").font(.caption).foregroundColor(.gray)) {
//                    NavigationLink(destination: Text("About Us View")) {
//                        Text("About Us")
//                            .font(.body)
//                            .foregroundColor(.primary)
//                    }
//                    .accessibilityLabel("Go to about us")
//                }

                // Version Section
                Section(header: Text("POLICY").font(.caption).foregroundColor(.gray)) {
                    HStack {
                        Text("Version")
                            .font(.body)
                            .foregroundColor(.primary)
                        Spacer()
                        Text("1.0.0")
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                    .accessibilityLabel("App version 1.0.0")
                }

                // Logout Section
                Section(header: Text("ACCOUNT").font(.caption).foregroundColor(.gray)) {
                    Button(action: {
                        viewModel.logout()
                    }) {
                        Text("Log Out")
                            .font(.body)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .accessibilityLabel("Log out")
                }
            }
            .navigationTitle("Settings")
            .navigationBarHidden(true)
            .onAppear {
                viewModel.loadSettings()
                userModel.loadUserData()
            }
        }
    }
}

struct AddressesView: View {
    @ObservedObject var userModel: UserModel

    var body: some View {
        Form {
            Section(header: Text("Edit Address").font(.headline).foregroundColor(.primary)) {
                // Recipient Name
                VStack(alignment: .leading, spacing: 4) {
                    Text("Recipient Name")
                        .font(.caption)
                        .foregroundColor(.gray)
                    TextField("Enter your name", text: $userModel.name)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .accessibilityLabel("Enter recipient name")
                }

                // Mobile Number
                VStack(alignment: .leading, spacing: 4) {
                    Text("Mobile Number")
                        .font(.caption)
                        .foregroundColor(.gray)
                    TextField("Enter your phone number", text: $userModel.phoneNumber)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .keyboardType(.phonePad)
                        .accessibilityLabel("Enter mobile number")
                }

                // Address
                VStack(alignment: .leading, spacing: 4) {
                    Text("Address")
                        .font(.caption)
                        .foregroundColor(.gray)
                    TextField("Enter your address", text: $userModel.address)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .accessibilityLabel("Enter address")
                }
            }
        }
        .navigationTitle("Addresses")
        .onChange(of: userModel.name) { _ in
            userModel.saveUserData()
        }
        .onChange(of: userModel.phoneNumber) { _ in
            userModel.saveUserData()
        }
        .onChange(of: userModel.address) { _ in
            userModel.saveUserData()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
