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
    
     func fetchPriceRules() {
          PriceRuleNetworkService.fetchDataFromAPI { response, error in
              if let response = response {
                  DispatchQueue.main.async {
                      self.priceRules = response.priceRules
                  }
              }
          }
      }
}
