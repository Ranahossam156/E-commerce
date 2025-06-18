//
//  PriceRuleNetworkServiceProtocol.swift
//  E-commerce
//
//  Created by Kerolos on 18/06/2025.
//


protocol PriceRuleNetworkServiceProtocol {
    static func fetchDataFromAPI(completion: @escaping (PriceRulesResponse?, Error?) -> Void)
}