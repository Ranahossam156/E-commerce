//
//  PriceRuleService.swift
//  E-commerce
//
//  Created by Kerolos on 02/06/2025.
//

import Foundation
import Alamofire

protocol PriceRuleNetworkServiceProtocol {
    static func fetchDataFromAPI(completion: @escaping (PriceRulesResponse?, Error?) -> Void)
}

class PriceRuleNetworkService: PriceRuleNetworkServiceProtocol {
    
    private static let session: Session = {
        #if targetEnvironment(simulator)
                let config = URLSessionConfiguration.ephemeral
        #else
                let config = URLSessionConfiguration.default
        #endif
        
        return Session(configuration: config)
    }()
    
    static func fetchDataFromAPI(completion: @escaping (PriceRulesResponse?, Error?) -> Void) {
        guard let url = URL(string: "https://ios4-sv.myshopify.com/admin/api/2025-04/price_rules.json") else {
            print("Invalid URL")
            return
        }
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "X-Shopify-Access-Token": "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"
        ]
        
        session.request(url, headers: headers)
            .validate()
            .responseDecodable(of: PriceRulesResponse.self) { response in
               // debugPrint(response)
                switch response.result {
                case .success(let result):
                    completion(result, nil)
                    print("Price rules count: \(result.priceRules.count)")
                case .failure(let error):
                    completion(nil, error)
                    print("Error: \(error)")
                }
            }
    }
    
    static func fetchDiscountCodes(for priceRuleId: Int, completion: @escaping ([DiscountCode]?, Error?) -> Void) {
        guard let url = URL(string: "https://ios4-sv.myshopify.com/admin/api/2025-04/price_rules/\(priceRuleId)/discount_codes.json") else {
            print("Invalid URL")
            return
        }
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "X-Shopify-Access-Token": "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"
        ]
        
        session.request(url, headers: headers)
            .validate()
            .responseDecodable(of: DiscountCodesResponse.self) { response in
                switch response.result {
                case .success(let result):
                    completion(result.discountCodes, nil)
                case .failure(let error):
                    completion(nil, error)
                }
            }
    }
}
