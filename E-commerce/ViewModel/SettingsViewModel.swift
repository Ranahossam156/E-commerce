// SettingsViewModel.swift
// E-commerce
// Created by Kerolos on 02/06/2025. (Last updated: 08:14 PM EEST, June 03, 2025)

import Foundation
import Combine

class SettingsViewModel: ObservableObject {
    @Published var countries: [String] = []
    @Published var isDarkMode: Bool = false

    private let currencyService: CurrencyService // Inject CurrencyService
    private var cancellables = Set<AnyCancellable>()

    init(currencyService: CurrencyService = CurrencyService()) {
        self.currencyService = currencyService
        loadSettings()
    }

    // Load settings from UserDefaults
    func loadSettings() {
    }

    // Save settings to UserDefaults
    func saveSettings() {
        currencyService.saveSelectedCurrency() // Delegate to CurrencyService
    }



    // Logout user
    func logout() {
        print("Logging out ...")
        // Placeholder for Firebase logout
        // try Auth.auth().signOut()
    }
}


