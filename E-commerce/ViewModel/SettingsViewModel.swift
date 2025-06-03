//
//  SettingsViewModel.swift
//  E-commerce
//
//  Created by Kerolos on 02/06/2025.
//

import Foundation
import Combine

class SettingsViewModel: ObservableObject {
    @Published var selectedCurrency: String = "USD" // Default currency
    @Published var currencies: [String] = []
    @Published var countries: [String] = []
    @Published var address: String = ""
    @Published var recipientName: String = ""
    @Published var mobileNumber: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    // Fetch currencies from an API (e.g., exchangeratesapi.io)
    func fetchCurrencies() {
        isLoading = true
        let url = URL(string: "https://api.exchangeratesapi.io/v1/symbols?access_key=f8dd7cf41e4ce36c3e5ec786faa2c95b")!
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: CurrencyResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] response in
                self?.currencies = response.symbols.keys.sorted()
            }
            .store(in: &cancellables)
    }

    // Fetch countries from a web service (e.g., restcountries.com)
    func fetchCountries() {
        isLoading = true
        let url = URL(string: "https://restcountries.com/v3.1/all")!
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [Country].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] countries in
                self?.countries = countries.map { $0.name.common }.sorted()
            }
            .store(in: &cancellables)
    }

    // Logout user
    func logout() {
        do {
            print("Logging out ...")
            //try Auth.auth().signOut()
        } catch {
            errorMessage = "Failed to log out: \(error.localizedDescription)"
        }
    }
    
    // Load settings from UserDefaults
    func loadSettings() {
        selectedCurrency = UserDefaults.standard.string(forKey: "selectedCurrency") ?? "USD"
       
    }

    // Save settings to UserDefaults
    func saveSettings() {
        UserDefaults.standard.set(selectedCurrency, forKey: "selectedCurrency")
       
    }

}

// Models for API responses
struct CurrencyResponse: Codable {
    let symbols: [String: String]
}

struct Country: Codable {
    struct Name: Codable {
        let common: String
    }
    let name: Name
}
