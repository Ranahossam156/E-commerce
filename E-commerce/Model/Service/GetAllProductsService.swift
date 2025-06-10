//
//  getAllProductsService.swift
//  E-commerce
//
//  Created by Macos on 08/06/2025.
//

import Foundation
import Alamofire

protocol GetAllProductsProtocol{
    static func fetchAllProductDetails(completionHandler:@escaping(AllProductsResponse?)-> Void )
    
}

class GetAllProducts : GetAllProductsProtocol{
    private static let session: Session = {
        #if targetEnvironment(simulator)
                let config = URLSessionConfiguration.ephemeral
        #else
                let config = URLSessionConfiguration.default
        #endif
        
        return Session(configuration: config)
    }()
    static func fetchAllProductDetails(completionHandler: @escaping (AllProductsResponse?) -> Void) {
        let productURL = "https://ios4-sv.myshopify.com/admin/api/2025-04/products.json"
        let headers: HTTPHeaders = [
            "X-Shopify-Access-Token": "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"
        ]

        session.request(productURL,  method: .get, headers: headers)
            .responseDecodable(of: AllProductsResponse.self) { response in
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
