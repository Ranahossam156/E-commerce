//
//  CurrencyService.swift
//  E-commerce
//
//  Created by Kerolos on 03/06/2025.
//

import Foundation
import Combine

class CurrencyService:ObservableObject{
    
    @Published var selectedCurrency: String = "USD" // Default currency
    @Published var exchangeRates: [String: Double] = [:] // Exchange rates relative to USD
    
    private var cancellables = Set<AnyCancellable>()
    
    // Predefined list of 10 currencies
     let supportedCurrencies: [String] = ["USD", "EUR", "GBP", "JPY", "CAD", "AUD", "CHF", "CNY", "INR", "BRL"]
    
    // Hardcoded currency symbols
    private let currencySymbols: [String: String] = [
        "USD": "$",
        "EUR": "€",
        "GBP": "£",
        "JPY": "¥",
        "CAD": "CA$",
        "AUD": "AU$",
        "CHF": "CHF",
        "CNY": "CN¥",
        "INR": "Rs",
        "BRL": "R$"
    ]
    private let apiKey: String = "fca_live_Ao03oTRD4jjg7dSVpytiiqja06ivyygwDuo3TNyP"
    
    // Load selected currency from UserDefaults
    func loadSelectedCurrency() {
        selectedCurrency = UserDefaults.standard.string(forKey: "selectedCurrency") ?? "USD"
    }
    
    // Save selected currency to UserDefaults
    func saveSelectedCurrency() {
        UserDefaults.standard.set(selectedCurrency, forKey: "selectedCurrency")
    }
    
    func fetchExchangeRates() {
        
        var components = URLComponents(string: "https://api.freecurrencyapi.com/v1/latest")!
        components.queryItems = [
            URLQueryItem(name: "apikey", value: apiKey),
            URLQueryItem(name: "base_currency", value: "USD"),
            URLQueryItem(name: "currencies", value: supportedCurrencies.joined(separator: ","))
        ]
    
        guard let url = components.url else {
                    print("Invalid URL for exchange rates API")
                   // exchangeRates = ["USD": 1.0] // Fallback
                    return
                }
        URLSession.shared.dataTaskPublisher(for: url)
                    .map { $0.data }
                    .decode(type: FreeCurrencyRateResponse.self, decoder: JSONDecoder())
                    .receive(on: DispatchQueue.main)
                    .sink { completion in
                        if case .failure(let error) = completion {
                            print("Failed to fetch exchange rates: \(error.localizedDescription)")
                        }
                    } receiveValue: { [weak self] response in
                        self?.exchangeRates = response.data
                        if self?.exchangeRates.isEmpty ?? true {
                            self?.exchangeRates = ["USD": 1.0] // Fallback
                        }
                    }
                    .store(in: &cancellables)
            }
    
    // Convert price to the selected currency
        func convert(price: Double, fromCurrency: String = "USD") -> Double {
            guard let rate = exchangeRates[selectedCurrency], let baseRate = exchangeRates[fromCurrency] else {
                return price // Return original price if rates are unavailable
            }
            return price * (rate / baseRate)
        }
    
    // Get currency symbol
        func getCurrencySymbol(for code: String) -> String {
            return currencySymbols[code] ?? code
        }
    
}
