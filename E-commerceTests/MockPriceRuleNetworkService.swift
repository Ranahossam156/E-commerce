//
//  MockPriceRuleNetworkService.swift
//  E-commerce
//
//  Created by Kerolos on 18/06/2025.
//


// MockPriceRuleNetworkService.swift
import Foundation

class MockPriceRuleNetworkService: PriceRuleNetworkServiceProtocol {
    var fetchDataFromAPICalled = false
    var fetchDiscountCodesCalled = false
    var mockPriceRulesResponse: PriceRulesResponse?
    var mockDiscountCodes: [DiscountCode]?
    var mockError: Error?
    
    static func fetchDataFromAPI(completion: @escaping (PriceRulesResponse?, Error?) -> Void) {
        let instance = MockPriceRuleNetworkService()
        instance.fetchDataFromAPICalled = true
        DispatchQueue.main.async {
            completion(instance.mockPriceRulesResponse, instance.mockError)
        }
    }
    
    static func fetchDiscountCodes(for priceRuleId: Int, completion: @escaping ([DiscountCode]?, Error?) -> Void) {
        let instance = MockPriceRuleNetworkService()
        instance.fetchDiscountCodesCalled = true
        DispatchQueue.main.async {
            completion(instance.mockDiscountCodes, instance.mockError)
        }
    }
}