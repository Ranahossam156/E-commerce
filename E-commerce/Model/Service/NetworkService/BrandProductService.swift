//
//  ProductService.swift
//  E-commerce
//
//  Created by MacBook on 31/05/2025.
//

import Foundation
import Alamofire

protocol BrandProductNetworkServiceProtocol {
    static func fetchDataFromAPI(vendor : String, completion: @escaping (ProductsResponse?, Error?) -> Void)
}

class BrandProductNetworkService: BrandProductNetworkServiceProtocol {
    
    private static let session: Session = {
        #if targetEnvironment(simulator)
                let config = URLSessionConfiguration.ephemeral
        #else
                let config = URLSessionConfiguration.default
        #endif
        
        return Session(configuration: config)
    }()
    
    static func fetchDataFromAPI(vendor : String, completion: @escaping (ProductsResponse?, Error?) -> Void) {
        guard let url = URL(string: "https://ios4-sv.myshopify.com/admin/api/2025-04/products.json") else {
            print("Invalid URL")
            return
        }
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "X-Shopify-Access-Token": "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"
        ]
        
        let parameters = [
            "vendor" : vendor
        ]
        
        
        session.request(url, parameters: parameters, headers: headers)
            .validate()
            .responseDecodable(of: ProductsResponse.self) { response in
                debugPrint(response)
                switch response.result {
                case .success(let result):
                    completion(result, nil)
                    print(result.products?.count ?? 0)
                case .failure(let error):
                    completion(nil, error)
                    print("Error: \(error)")
                }
            }
    }
}
