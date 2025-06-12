//
//  CategoryProductService.swift
//  E-commerce
//
//  Created by MacBook on 08/06/2025.
//

import Foundation

import Foundation
import Alamofire

protocol CategoryProductNetworkServiceProtocol {
    static func fetchProducts(for collectionId: Int, completion: @escaping (ProductsResponse?, Error?) -> Void)
}

class CategoryProductNetworkService: CategoryProductNetworkServiceProtocol {
    
    private static let session: Session = {
        #if targetEnvironment(simulator)
        let config = URLSessionConfiguration.ephemeral
        #else
        let config = URLSessionConfiguration.default
        #endif
        return Session(configuration: config)
    }()
    
    private static let baseUrl = "https://ios4-sv.myshopify.com/admin/api/2025-04"
    private static let accessToken = "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"
    
    static func fetchProducts(for collectionId: Int, completion: @escaping (ProductsResponse?, Error?) -> Void) {
        let collectsURL = "\(baseUrl)/collects.json"
        let collectsParams: Parameters = ["collection_id": collectionId]
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "X-Shopify-Access-Token": accessToken
        ]
        
        // Get Collects
        session.request(collectsURL, parameters: collectsParams, headers: headers)
            .validate()
            .responseDecodable(of: CollectsResponse.self) { response in
                switch response.result {
                case .success(let collectsData):
                    let productIds = collectsData.collects.map { String($0.product_id) }
                    guard !productIds.isEmpty else {
                        completion(ProductsResponse(products: []), nil)
                        return
                    }
                    
                    // Fetch Products by IDs
                    let idsString = productIds.joined(separator: ",")
                    let productsURL = "\(baseUrl)/products.json"
                    let productsParams: Parameters = ["ids": idsString]
                    
                    session.request(productsURL, parameters: productsParams, headers: headers)
                        .validate()
                        .responseDecodable(of: ProductsResponse.self) { response in
                            switch response.result {
                            case .success(let productsData):
                                completion(productsData, nil)
                            case .failure(let error):
                                completion(nil, error)
                            }
                        }
                    
                case .failure(let error):
                    completion(nil, error)
                }
            }
    }
}
