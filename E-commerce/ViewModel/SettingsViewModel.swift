// SettingsViewModel.swift
// E-commerce
// Created by Kerolos on 02/06/2025. (Last updated: 08:14 PM EEST, June 03, 2025)

import Foundation
import Combine
import FirebaseFirestore
import FirebaseAuth

class SettingsViewModel: ObservableObject {
    @Published var countries: [String] = []
    @Published var selectedCurrency: String = "USD" // Track currency locally
    
    weak var currencyService: CurrencyService?
    private var cancellables = Set<AnyCancellable>()
    
    private let db = Firestore.firestore()
    
    init() {
        loadSettings()
        fetchCountries()
    }
    
    func loadSettings() {
            if let userId = Auth.auth().currentUser?.uid {
                db.collection("users").document(userId).collection("settings").document("preferences").getDocument { [weak self] (document, error) in
                    guard let self = self else { return }
                    if let document = document, document.exists {
                        if let data = document.data(), let currency = data["selectedCurrency"] as? String {
                            self.selectedCurrency = currency
                            self.currencyService?.selectedCurrency = currency // Sync with CurrencyService
                            print("Settings loaded: Currency = \(currency)")
                        }
                    } else {
                        print("No settings found, using default currency: USD")
                    }
                }
            } else {
                print("No authenticated user, settings not loaded")
            }
        }
    
    func saveSettings() {
        if let userId = Auth.auth().currentUser?.uid {
            print("Attempting to save settings for user: \(userId)")
            let settingsData: [String: Any] = ["selectedCurrency": selectedCurrency]
            db.collection("users").document(userId).collection("settings").document("preferences").setData(settingsData) { [weak self] error in
                guard let self = self else { return }
                if let error = error {
                    print("Error saving settings: \(error.localizedDescription)")
                } else {
                    print("Settings saved successfully: Currency = \(self.selectedCurrency)")
                    self.currencyService?.selectedCurrency = self.selectedCurrency
                }
            }
        } else {
            print("No authenticated user, settings not saved")
        }
    }
    
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
    
    func logout() {
            print("Logging out ...")
            do {
                try Auth.auth().signOut()
                // Notify authViewModel or reset state as needed
                print("Logged out successfully")
            } catch {
                print("Error logging out: \(error.localizedDescription)")
            }
        }
}

// Models for API responses
struct Country: Codable {
    struct Name: Codable {
        let common: String
    }
    let name: Name
}
