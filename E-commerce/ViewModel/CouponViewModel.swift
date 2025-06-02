//
//  CouponViewModel.swift
//  E-commerce
//
//  Created by Kerolos on 02/06/2025.
//

import Foundation
import Combine

class CouponViewModel: ObservableObject {
    @Published var priceRules: [PriceRule] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var appliedPriceRule: PriceRule?
    
    init() {
        fetchPriceRules()
    }
    
    func fetchPriceRules() {
        isLoading = true
        errorMessage = nil
        
        PriceRuleNetworkService.fetchDataFromAPI { [weak self] response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    print("Failed to fetch price rules: \(error)")
                } else if let response = response {
                    self?.priceRules = response.priceRules
                    print("Fetched \(response.priceRules.count) price rules")
                }
            }
        }
    }
    
    func applyPriceRule(_ priceRule: PriceRule, to total: Double) -> Double {
        appliedPriceRule = priceRule
        
        if priceRule.valueType == "percentage" {
            let percentage = abs(Double(priceRule.value) ?? 0) / 100
            return total * (1 - percentage)
        } else {
            let discount = abs(Double(priceRule.value) ?? 0)
            return max(0, total - discount)
        }
    }
    
    func removePriceRule() {
        appliedPriceRule = nil
    }
    
    func validateCouponCode(_ code: String) -> PriceRule? {
        return priceRules.first { $0.couponCode == code.uppercased() }
    }
}
