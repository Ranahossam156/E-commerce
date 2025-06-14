//
//  CategoryService.swift
//  E-commerce
//
//  Created by MacBook on 31/05/2025.
//

import Foundation
import Alamofire

protocol CategoryNetworkServiceProtocol {
    static func fetchDataFromAPI(completion: @escaping (CategoryResponse?, Error?) -> Void)
}

class CategoryNetworkService: CategoryNetworkServiceProtocol {
    
    private static let session: Session = {
        #if targetEnvironment(simulator)
                let config = URLSessionConfiguration.ephemeral
        #else
                let config = URLSessionConfiguration.default
        #endif
        
        return Session(configuration: config)
    }()
    
    static func fetchDataFromAPI(completion: @escaping (CategoryResponse?, Error?) -> Void) {
        guard let url = URL(string: "https://ios4-sv.myshopify.com/admin/api/2025-04/custom_collections.json") else {
            print("Invalid URL")
            return
        }
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "X-Shopify-Access-Token": "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"
        ]
        
        
        session.request(url, headers: headers)
            .validate()
            .responseDecodable(of: CategoryResponse.self) { response in
                //debugPrint(response)
                switch response.result {
                case .success(let result):
                    completion(result, nil)
                    print(result.customCollections?.count ?? 0)
                case .failure(let error):
                    completion(nil, error)
                    print("Error: \(error)")
                }
            }
    }
}

