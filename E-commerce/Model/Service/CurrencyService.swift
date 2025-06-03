// CurrencyService.swift
// E-commerce
// Created by Kerolos on 02/06/2025. (Last updated: 09:50 PM EEST, June 03, 2025)

import Foundation
import Combine

class CurrencyService: ObservableObject {
    @Published var selectedCurrency: String {
        didSet {
            saveSelectedCurrency()
            fetchExchangeRates() // Fetch new rates when currency changes
        }
    }
    @Published var exchangeRates: [String: Double] = [:]
    
   // let supportedCurrencies = ["USD", "EGP", "EUR", "GBP"]
    private var cancellables = Set<AnyCancellable>()
    private let baseCurrency = "USD" // Fixed base currency for API
    
    // Predefined list of 10 currencies
    let supportedCurrencies: [String] = ["USD", "EUR","EGP", "GBP", "JPY", "CAD", "AUD", "CHF", "CNY", "INR", "BRL"]
    
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
    
    init() {
        if let savedCurrency = UserDefaults.standard.string(forKey: "selectedCurrency"),
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
                print("Updated exchange rates: \(self?.exchangeRates ?? [:])") // Debug log
            }
            .store(in: &cancellables)
    }
    
    func convert(price: Double) -> Double {
        guard !exchangeRates.isEmpty, let baseRate = exchangeRates[baseCurrency],
              let targetRate = exchangeRates[selectedCurrency] else {
            print("Exchange rates not available, using 1.0 as fallback")
            return price // Fallback to original price if rates are missing
        }
        // Convert from baseCurrency to selectedCurrency: (price / baseRate) * targetRate
        return (price / baseRate) * targetRate
    }
    
    func getCurrencySymbol(for code: String) -> String {
        return currencySymbols[code] ?? code
    }
    
    func saveSelectedCurrency() {
        UserDefaults.standard.set(selectedCurrency, forKey: "selectedCurrency")
        print("Saved currency: \(selectedCurrency)")
    }
}

struct ExchangeRateResponse: Codable {
    let rates: [String: Double]
}
