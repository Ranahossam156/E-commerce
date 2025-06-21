// CurrencyService.swift
// E-commerce
// Created by Kerolos on 02/06/2025. (Last updated: 10:15 PM EEST, June 16, 2025)

import Foundation
import Combine

class CurrencyService: ObservableObject {
    @Published var selectedCurrency: String {
        didSet {
            fetchExchangeRates() // Fetch new rates when currency changes
            saveSettingsIfPossible() // Notify SettingsViewModel to save to Firestore
        }
    }
    @Published var exchangeRates: [String: Double] = [:]
    
    private var cancellables = Set<AnyCancellable>()
    private let baseCurrency = "USD"
    
    let supportedCurrencies: [String] = ["USD", "EUR", "EGP", "GBP", "JPY", "CHF", "CNY", "INR", "BRL"]
    
    private let currencySymbols: [String: String] = [
        "USD": "$",
        "EUR": "€",
        "GBP": "£",
        "JPY": "¥",
        "CHF": "CHF",
        "CNY": "CN¥",
        "INR": "Rs",
        "BRL": "R$",
        "EGP": "EGP"
    ]
    
    weak var settingsViewModel: SettingsViewModel? // Reference to SettingsViewModel for sync
    
    init() {
        // Initialize with default or load from SettingsViewModel
        if let settingsViewModel = settingsViewModel, !settingsViewModel.selectedCurrency.isEmpty {
            self.selectedCurrency = settingsViewModel.selectedCurrency
        } else if let savedCurrency = UserDefaults.standard.string(forKey: "selectedCurrency"),
                  supportedCurrencies.contains(savedCurrency) {
            self.selectedCurrency = savedCurrency
        } else {
            self.selectedCurrency = "USD"
        }
        fetchExchangeRates()
    }
    
    func fetchExchangeRates() {
        guard let url = URL(string: "https://api.exchangerate-api.com/v4/latest/\(baseCurrency)") else {
            print("Invalid exchange rate URL")
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: ExchangeRateResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Error fetching exchange rates: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] response in
                self?.exchangeRates = response.rates
            }
            .store(in: &cancellables)
    }
    
    func convert(price: Double) -> Double {
        guard !exchangeRates.isEmpty, let baseRate = exchangeRates[baseCurrency],
              let targetRate = exchangeRates[selectedCurrency] else {
            return price // Fallback to original price if rates are missing
        }
        // Convert from baseCurrency to selectedCurrency: (price / baseRate) * targetRate
        return (price / baseRate) * targetRate
    }
    
    func getCurrencySymbol(for code: String) -> String {
        return currencySymbols[code] ?? code
    }
    
    private func saveSettingsIfPossible() {
        if let settingsViewModel = settingsViewModel {
            settingsViewModel.selectedCurrency = selectedCurrency
            settingsViewModel.saveSettings() // Trigger Firestore save
        } else {
            print("SettingsViewModel not set, currency change not saved to Firestore")
        }
    }
}

struct ExchangeRateResponse: Codable {
    let rates: [String: Double]
}
