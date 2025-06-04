// SettingsViewModel.swift
// E-commerce
// Created by Kerolos on 02/06/2025. (Last updated: 08:14 PM EEST, June 03, 2025)

import Foundation
import Combine


class SettingsViewModel: ObservableObject {
    @Published var countries: [String] = []
    @Published var isDarkMode: Bool = false

    weak var currencyService: CurrencyService? // Weak reference to avoid retain cycles
    private var cancellables = Set<AnyCancellable>()

    init() {
        loadSettings()
    }

    // Load settings from UserDefaults
    func loadSettings() {
        isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
    }

    // Save settings to UserDefaults
    func saveSettings() {
        UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        // Safely unwrap currencyService
        guard let currencyService = currencyService else {
            print("CurrencyService not set in SettingsViewModel")
            return
        }
        currencyService.saveSelectedCurrency()
    }

    // Fetch countries from a web service (e.g., restcountries.com)
    func fetchCountries() {
        guard let url = URL(string: "https://restcountries.com/v3.1/all") else {
            print("Invalid URL for countries API")
            return
        }
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [Country].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Failed to fetch countries: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] countries in
                self?.countries = countries.map { $0.name.common }.sorted()
            }
            .store(in: &cancellables)
    }

    // Logout user
    func logout() {
        print("Logging out ...")
        // Placeholder for Firebase logout
        // try Auth.auth().signOut()
    }
}

// Models for API responses
struct Country: Codable {
    struct Name: Codable {
        let common: String
    }
    let name: Name
}
