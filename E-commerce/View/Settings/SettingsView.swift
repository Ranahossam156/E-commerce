// SettingsView.swift
// E-commerce
// Created by Kerolos on 02/06/2025. (Last updated: 06:50 PM EEST, June 18, 2025)

import SwiftUI
import MapKit
import Combine
import CoreLocation
import FirebaseAuth
import SwiftUI
import MapKit
import Combine
import CoreLocation
import FirebaseAuth

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @EnvironmentObject var userModel: UserModel
    @EnvironmentObject var currencyService: CurrencyService
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isDataLoaded = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                List {
                    UserInfoHeader()
                        .listRowBackground(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        )
                        .padding(.vertical, 4)
                    
                    SettingsSection(viewModel: viewModel, currencyService: currencyService)
                        .listRowBackground(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        )
                        .padding(.vertical, 4)
                    
                    VersionSection()
                        .listRowBackground(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        )
                        .padding(.vertical, 4)
                    
                    LogoutSection(viewModel: viewModel)
                        .environmentObject(authViewModel)
                        .environmentObject(userModel)
                        .listRowBackground(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        )
                        .padding(.vertical, 4)
                }
                .listStyle(.plain)
                .padding(.top, 20)
                .opacity(isDataLoaded ? 1 : 0)
                .animation(.easeInOut(duration: 0.3), value: isDataLoaded)
                
                if !isDataLoaded {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(Color("primaryColor"))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                        .ignoresSafeArea()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Settings")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color("primaryColor"))
                }
            }
            .onAppear {
                print("SettingsView onAppear called")
                viewModel.loadSettings()
                loadUserDataIfNeeded()
                currencyService.fetchExchangeRates()
                viewModel.currencyService = currencyService
                currencyService.settingsViewModel = viewModel
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isDataLoaded = true
                    print("Data loaded: \(isDataLoaded)")
                }
            }
        }
    }
    
    private func loadUserDataIfNeeded() {
        print("Checking user data load condition")
        if (userModel.addresses.isEmpty || userModel.name.isEmpty || userModel.email.isEmpty || userModel.phoneNumber.isEmpty) && Auth.auth().currentUser?.uid != nil {
            let userId = Auth.auth().currentUser!.uid
            print("Loading user data for userId: \(userId)")
            Task {
                do {
                    try await userModel.loadUserDataFromFirebase()
                    print("User data loaded successfully: \(userModel.name), \(userModel.email)")
                } catch {
                    print("Failed to load user data: \(error.localizedDescription)")
                }
            }
        } else {
            print("User data already loaded or no authenticated user")
        }
    }
}

struct UserInfoHeader: View {
    @EnvironmentObject var userModel: UserModel
    
    var body: some View {
        Section {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 64, height: 64)
                    .foregroundColor(.white)
                    .background(
                        LinearGradient(
                            colors: [Color("primaryColor"), Color("primaryColor").opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Circle())
                    .padding(8)
                    .accessibilityHidden(true)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(userModel.name.isEmpty ? "Guest" : userModel.name)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .accessibilityLabel("Username: \(userModel.name.isEmpty ? "Not set" : userModel.name)")
                    
                    Text(userModel.email.isEmpty ? "Email: email@example.com" : "Email: \(userModel.email)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                        .accessibilityLabel("Email: \(userModel.email.isEmpty ? "Not set" : userModel.email)")
                    
                    Text("Address: \(userModel.defaultAddress)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(3)
                        .accessibilityLabel("Current address: \(userModel.defaultAddress)")
                    
                    Text("Phone: \(userModel.phoneNumber.isEmpty ? "Not Set" : userModel.phoneNumber)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .accessibilityLabel("Phone number: \(userModel.phoneNumber.isEmpty ? "Not set" : userModel.phoneNumber)")
                }
                
                Spacer()
                
                NavigationLink(destination: EditProfileView()) {
                  
                }
                .accessibilityLabel("Edit profile")
                .frame(width: 1)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 12)
        }
    }
}

struct EditProfileView: View {
    @EnvironmentObject var userModel: UserModel
    @Environment(\.dismiss) var dismiss
    @State private var editedName: String
    @State private var editedPhoneNumber: String
    @State private var editedEmail: String
    @State private var errorMessage: String?
    
    init() {
        let currentUser = Auth.auth().currentUser
        _editedName = State(initialValue: currentUser?.displayName ?? "")
        _editedPhoneNumber = State(initialValue: "")
        _editedEmail = State(initialValue: currentUser?.email ?? "")
        print("EditProfileView init: name=\(_editedName.wrappedValue), email=\(_editedEmail.wrappedValue), phoneNumber=\(_editedPhoneNumber.wrappedValue)")
    }
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                if userModel.isLoading {
                    ProgressView("Loading profile...")
                        .tint(Color("primaryColor"))
                        .scaleEffect(1.2)
                } else {
                    VStack(spacing: 16) {
                        if let error = errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.horizontal)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Name")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            TextField("Enter name", text: $editedName)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemGray6))
                                        .shadow(color: .black.opacity(0.05), radius: 2)
                                )
                                .accessibilityLabel("Enter name")
                        }
                        .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            TextField("Enter Email", text: $editedEmail)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemGray6))
                                        .shadow(color: .black.opacity(0.05), radius: 2)
                                )
                                .accessibilityLabel("Enter Email")
                        }
                        .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Phone Number")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            TextField("Enter phone number", text: $editedPhoneNumber)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemGray6))
                                        .shadow(color: .black.opacity(0.05), radius: 2)
                                )
                                .keyboardType(.phonePad)
                                .accessibilityLabel("Enter phone number")
                        }
                        .padding(.horizontal)
                        
                        Button(action: {
                            userModel.name = editedName
                            userModel.phoneNumber = editedPhoneNumber
                            userModel.email = editedEmail
                            userModel.saveUserData()
                        }) {
                            Text("Save Changes")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [Color("primaryColor"), Color("primaryColor").opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(Capsule())
                                .shadow(color: .black.opacity(0.1), radius: 4)
                        }
                        .padding(.horizontal)
                        .disabled(editedName.isEmpty)
                    }
                    .padding(.top, 20)
                }
                
                Spacer()
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                print("Auth email: \(Auth.auth().currentUser?.email ?? "None"), UserModel email: \(userModel.email)")
                
                editedName = userModel.name.isEmpty ? editedName : userModel.name
                editedPhoneNumber = userModel.phoneNumber.isEmpty ? editedPhoneNumber : userModel.phoneNumber
                editedEmail = userModel.email.isEmpty ? editedEmail : userModel.email
                
                print("EditProfileView onAppear: name=\(editedName), email=\(editedEmail), phoneNumber=\(editedPhoneNumber)")
            }
        }
    }
}

struct SettingsSection: View {
    @ObservedObject var viewModel: SettingsViewModel
    @ObservedObject var currencyService: CurrencyService
    @EnvironmentObject var userModel: UserModel
    
    var body: some View {
        Section(header: Text("Settings").font(.subheadline).foregroundColor(.gray).padding(.leading, 12)) {
            NavigationLink(destination: OrdersView()) {
                HStack {
                    Image(systemName: "list.bullet.rectangle")
                        .foregroundColor(Color("primaryColor"))
                        .frame(width: 24, height: 24)
                    Text("Orders")
                        .font(.body)
                        .foregroundColor(.primary)
                    Spacer()
           
                }
                .padding(.vertical, 8)
            }
            .accessibilityLabel("Go to orders")
            
            NavigationLink(destination: AddressesView(userModel: userModel)) {
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(Color("primaryColor"))
                        .frame(width: 24, height: 24)
                    Text("Addresses")
                        .font(.body)
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding(.vertical, 8)
            }
            .accessibilityLabel("Go to addresses")
            
            HStack {
                Image(systemName: "dollarsign.circle")
                    .foregroundColor(Color("primaryColor"))
                    .frame(width: 24, height: 24)
                Picker("Currency", selection: $currencyService.selectedCurrency) {
                    ForEach(currencyService.supportedCurrencies, id: \.self) { currency in
                        Text(currency)
                            .tag(currency)
                    }
                }
                .pickerStyle(.menu)
                .accentColor(Color("primaryColor"))
                .accessibilityLabel("Select currency")
                .onChange(of: currencyService.selectedCurrency) { _ in
                    viewModel.saveSettings()
                }
            }
            .padding(.vertical, 8)
        }
        .padding(.horizontal, 12)
    }
}

struct VersionSection: View {
    var body: some View {
        Section(header: Text("Policy").font(.subheadline).foregroundColor(.gray).padding(.leading, 12)) {
            HStack {
                Image(systemName: "info.circle")
                    .foregroundColor(Color("primaryColor"))
                    .frame(width: 24, height: 24)
                Text("Version")
                    .font(.body)
                    .foregroundColor(.primary)
                Spacer()
                Text("1.0.0")
                    .font(.body)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .accessibilityLabel("App version 1.0.0")
        }
    }
}


struct MapSubView: View {
    @ObservedObject var mapViewModel: MapViewModel
    @EnvironmentObject var userModel: UserModel
    private let mapSize = CGSize(width: 300, height: 300)
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Map(coordinateRegion: $mapViewModel.region,
                interactionModes: .all,
                showsUserLocation: true,
                annotationItems: mapViewModel.selectedLocation != nil ? [mapViewModel.selectedLocation!] : []) { location in
                MapMarker(coordinate: location.coordinate, tint: Color("primaryColor"))
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onEnded { value in
                        let tapPoint = value.location
                        mapViewModel.handleMapTap(at: tapPoint, in: mapViewModel.region, mapSize: mapSize)
                    }
            )
            .frame(width: mapSize.width, height: mapSize.height)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            
        
        }
        .onAppear {
            print("MapSubView appeared, setting region to Egypt")
        }
    }
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(CurrencyService())
            .environmentObject(UserModel())
            .environmentObject(AuthViewModel())
    }
}
