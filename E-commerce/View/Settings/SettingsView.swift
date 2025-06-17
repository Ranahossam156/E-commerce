// SettingsView.swift
// E-commerce
// Created by Kerolos on 02/06/2025. (Last updated: 08:42 PM EEST, June 03, 2025)


import SwiftUI
import MapKit
import Combine
import CoreLocation
import FirebaseAuth

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @StateObject private var userModel = UserModel()
    @EnvironmentObject var currencyService: CurrencyService
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isDataLoaded = false
    
    var body: some View {
        NavigationView {
            List {
                UserInfoHeader(userModel: userModel)
                SettingsSection(viewModel: viewModel, currencyService: currencyService, userModel: userModel)
                VersionSection()
                LogoutSection(viewModel: viewModel).environmentObject(authViewModel)
            }
            .navigationTitle("Settings")
            .navigationBarHidden(true)
            .onAppear {
                viewModel.loadSettings()
                if userModel.addresses.isEmpty && Auth.auth().currentUser?.uid != nil {
                    userModel.loadUserDataFromFirebase()
                }
                currencyService.fetchExchangeRates()
                viewModel.currencyService = currencyService
                currencyService.settingsViewModel = viewModel
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isDataLoaded = true
                }
            }
        }
    }
}

// [Rest of the subviews (UserInfoHeader, EditProfileView, SettingsSection, VersionSection, LogoutSection, MapSubView) remain unchanged]
// Subview for User Info Header
struct UserInfoHeader: View {
    @ObservedObject var userModel: UserModel
    
    var body: some View {
        Section {
            HStack(alignment: .center, spacing: 6) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.gray)
                    .accessibilityHidden(true)
                    .padding(6)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(userModel.name.isEmpty ? "Guest" : userModel.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .accessibilityLabel("Username: \(userModel.name.isEmpty ? "Not set" : userModel.name)")
                    
                    Text(userModel.email.isEmpty ? "Email: email@example.com" : "Email: \(userModel.email)")
                        .lineLimit(2)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .accessibilityLabel("Email: \(userModel.email.isEmpty ? "Not set" : userModel.email)")
                    
                    Text("Address: \(userModel.defaultAddress)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .accessibilityLabel("Current address: \(userModel.defaultAddress)")
                        .lineLimit(6) // Allow multiple lines for long addresses
                    
                    Text("Phone: \(userModel.phoneNumber.isEmpty ? "Not Set" : userModel.phoneNumber)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .accessibilityLabel("Phone number: \(userModel.phoneNumber.isEmpty ? "Not set" : userModel.phoneNumber)")
                }
                
                
                Spacer()
                
                NavigationLink(destination: EditProfileView(userModel: userModel)) {
                    
                }.frame(width: 1)
            }
            .padding(.vertical, 12)
        }
    }
}

// Subview for Editing Profile
struct EditProfileView: View {
    @ObservedObject var userModel: UserModel
    @Environment(\.dismiss) var dismiss
    @State private var editedName: String
    @State private var editedPhoneNumber: String
    @State private var editedEmail: String
    
    
    init(userModel: UserModel) {
        self.userModel = userModel
        _editedName = State(initialValue: userModel.name)
        _editedPhoneNumber = State(initialValue: userModel.phoneNumber)
        _editedEmail = State(initialValue: userModel.email)
    }
    
    var body: some View {
        Form {
            Section(header: Text("Edit Profile").font(.headline)) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Name")
                        .font(.caption)
                        .foregroundColor(.gray)
                    TextField("Enter name", text: $editedName)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .accessibilityLabel("Enter name")
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Email")
                        .font(.caption)
                        .foregroundColor(.gray)
                    TextField("Enter Email", text: $editedEmail)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .accessibilityLabel("Enter Email")
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Phone Number")
                        .font(.caption)
                        .foregroundColor(.gray)
                    TextField("Enter phone number", text: $editedPhoneNumber)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .keyboardType(.phonePad)
                        .accessibilityLabel("Enter phone number")
                }
            }
            
            Button(action: {
                userModel.name = editedName
                userModel.phoneNumber = editedPhoneNumber
                userModel.email = editedEmail
                userModel.saveUserData()
                dismiss()
            }) {
                Text("Save Changes")
                    .font(.body)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(editedName.isEmpty ? Color.gray : Color.blue)
                    .cornerRadius(8)
            }
            .disabled(editedName.isEmpty)
            .accessibilityLabel("Save profile changes")
        }
        .navigationTitle("Edit Profile")
    }
}

// Subview for Settings Section
struct SettingsSection: View {
    @ObservedObject var viewModel: SettingsViewModel
    @ObservedObject var currencyService: CurrencyService
    @ObservedObject var userModel: UserModel
    
    var body: some View {
        Section(header: Text("Settings").font(.caption).foregroundColor(.gray)) {
            NavigationLink(destination: OrdersView()) {
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
                    Text(currency)
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


struct LogoutSection: View {
    @ObservedObject var viewModel: SettingsViewModel
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        Section(header: Text("ACCOUNT").font(.caption).foregroundColor(.gray)) {
            Button(action: {
                Task {
                    guard let userId = Auth.auth().currentUser?.uid else {
                        return
                    }
                    
                    await FavoriteManager.shared.syncFavoritesToFirestore(for: userId)
                    
                    do {
                        try Auth.auth().signOut()
                        authViewModel.isAuthenticated = false
                    } catch {
                    }
                }
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

struct MapSubView: View {
    @ObservedObject var mapViewModel: MapViewModel
    private let mapSize = CGSize(width: 270, height: 250)
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Map(coordinateRegion: $mapViewModel.region,
                interactionModes: .all,
                showsUserLocation: true,
                annotationItems: mapViewModel.selectedLocation != nil ? [mapViewModel.selectedLocation!] : []) { location in
                MapMarker(coordinate: location.coordinate, tint: .red)
            }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onEnded { value in
                            let tapPoint = value.location
                            mapViewModel.handleMapTap(at: tapPoint, in: mapViewModel.region, mapSize: mapSize)
                        }
                )
                .frame(width:300,height: 300)
                .cornerRadius(8)
            
            //            Button(action: {
            //                mapViewModel.centerOnUserLocation()
            //            }) {
            //                Image(systemName: "location.fill")
            //                    .padding(10)
            //                    .background(Color.white)
            //                    .clipShape(Circle())
            //                    .shadow(radius: 2)
            //            }
                .padding(16)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(CurrencyService()) // Required for previews
    }
}
