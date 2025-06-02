//
//  SettingsView.swift
//  E-commerce
//
//  Created by Kerolos on 02/06/2025.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showingAddressPicker = false
 
    var body: some View {
        NavigationView {
            Form {
                
                // Address Section
                Section(header: Text("Address")) {
                    TextField("Recipient Name", text: $viewModel.recipientName)
                    TextField("Mobile Number", text: $viewModel.mobileNumber)
                    TextField("Address", text: $viewModel.address)
                        .disabled(true) // Prevent manual editing
                        .overlay(
                            Button(action: { showingAddressPicker = true }) {
                                Text("Select Address")
                                    .foregroundColor(.blue)
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        )
                }
                
                // Currency Section
                Section(header: Text("Currency")) {
                    Picker("Select Currency", selection: $viewModel.selectedCurrency) {
                        ForEach(viewModel.currencies, id: \.self) { currency in
                            Text(currency).tag(currency)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }

            

                // Logout Section
                if (true){//authViewModel.isLoggedIn {
                    Section {
                        Button(action: {
                            viewModel.logout()
                        }) {
                            Text("Log Out")
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                viewModel.fetchCurrencies()
                viewModel.fetchCountries()
            }
//            .sheet(isPresented: $showingAddressPicker) {
//                AddressPickerView(address: $viewModel.address)
//            }
//            .alert(item: Binding<IdentifiableError?>(
//                get: { viewModel.errorMessage.map { IdentifiableError(message: $0) } },
//                set: { _ in viewModel.errorMessage = nil }
//            )) { error in
//                Alert(title: Text("Error"), message: Text(error.message), dismissButton: .default(Text("OK")))
//            }
            .overlay(
                Group {
                    if viewModel.isLoading {
                        ProgressView()
                    }
                }
            )
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
