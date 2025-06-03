// SettingsView.swift
// E-commerce
// Created by Kerolos on 02/06/2025. (Last updated: 08:42 PM EEST, June 03, 2025)

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel = SettingsViewModel()
    @StateObject private var userModel: UserModel = UserModel()
    @EnvironmentObject var currencyService: CurrencyService // Use EnvironmentObject

   

    var body: some View {
        NavigationView {
            List {
                UserInfoHeader(userModel: userModel)
                SettingsSection(viewModel: viewModel, currencyService: currencyService, userModel: userModel)
                VersionSection()
                LogoutSection(viewModel: viewModel)
            }
            .navigationTitle("Settings")
            .navigationBarHidden(true)
            .onAppear {
                viewModel.loadSettings()
                userModel.loadUserData()
                currencyService.fetchExchangeRates() // Correct method call
                viewModel.currencyService = currencyService // Assuming you add this property
            }
        }
    }
}

// Subview for User Info Header
struct UserInfoHeader: View {
    @ObservedObject var userModel: UserModel

    var body: some View {
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

                    Text("Phone: \(userModel.phoneNumber.isEmpty ? "Not Set" : userModel.phoneNumber)")
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
    }
}

// Subview for Settings Section
struct SettingsSection: View {
    @ObservedObject var viewModel: SettingsViewModel
    @ObservedObject var currencyService: CurrencyService
    @ObservedObject var userModel: UserModel

    var body: some View {
        Section(header: Text("Settings").font(.caption).foregroundColor(.gray)) {
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

            Picker("Currency", selection: $currencyService.selectedCurrency) {
                ForEach(currencyService.supportedCurrencies, id: \.self) { currency in
                    let symbol = currencyService.getCurrencySymbol(for: currency) // Break up expression
                    Text("\(symbol) \(currency)")
                        .tag(currency)
                }
            }
            .pickerStyle(.menu)
            .accessibilityLabel("Select currency")
            .onChange(of: currencyService.selectedCurrency) { _ in 
                viewModel.saveSettings()
            }
        }
    }
}

// Subview for Version Section
struct VersionSection: View {
    var body: some View {
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
    }
}

// Subview for Logout Section
struct LogoutSection: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
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

//struct SettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingsView(viewModel: <#SettingsViewModel#>)
//            .environmentObject(CurrencyService()) // Required for previews
//    }
//}
