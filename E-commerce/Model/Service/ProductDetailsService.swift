//
//  NetworkService.swift
//  E-commerce
//
//  Created by Macos on 27/05/2025.
//

import Foundation
import Alamofire
protocol ProductDetailsServiceProtocol{
    static func fetchProductDetails(productID : Int ,completionHandler:@escaping(SingleProductResponse?)-> Void )
}

class ProductDetailsService : ProductDetailsServiceProtocol{
    private static let session: Session = {
        #if targetEnvironment(simulator)
                let config = URLSessionConfiguration.ephemeral
        #else
                let config = URLSessionConfiguration.default
        #endif
        
        return Session(configuration: config)
    }()
    

    
    static func fetchProductDetails(productID: Int, completionHandler: @escaping (SingleProductResponse?) -> Void) {
        let productURL = "https://ios4-sv.myshopify.com/admin/api/2025-04/products/\(productID).json"
        let headers: HTTPHeaders = [
            "X-Shopify-Access-Token": "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"
        ]

        session.request(productURL,  method: .get, headers: headers)
            .responseDecodable(of: SingleProductResponse.self) { response in
                switch response.result {
                case .success(let productDetails):
                    completionHandler(productDetails)
                    print("employees fetched successfully")
                    
                case .failure(let error):
                    completionHandler(nil)
                    print("Error fetching employees: \(error)")
                }
            }
    }

}
/////////////////////**/////////////////////////
