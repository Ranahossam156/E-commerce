//
//  NetworkService.swift
//  E-commerce
//
//  Created by Macos on 27/05/2025.
//

import Foundation
import Alamofire
protocol NetworkSProtocol{
    static func fetchProductDetails(productID : Int ,completionHandler:@escaping(SingleProductResponse?)-> Void )
    
    static func fetchProductVariants(productID : Int ,completionHandler:@escaping(VariantsResponse?)-> Void )
    static func fetchProductImages(productID : Int ,completionHandler:@escaping(ProductImagesResponse?)-> Void )
}

class NetworkService : NetworkSProtocol{
    static func fetchProductImages(productID: Int, completionHandler: @escaping (ProductImagesResponse?) -> Void) {
        let productURL = "https://ios4-sv.myshopify.com/admin/api/2025-04/products/\(productID)/images.json"
        let headers: HTTPHeaders = [
            "X-Shopify-Access-Token": "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"
        ]

        AF.request(productURL,  method: .get, headers: headers)
            .responseDecodable(of: ProductImagesResponse.self) { response in
                switch response.result {
                case .success(let productImages):
                    completionHandler(productImages)
                    print("employees fetched successfully")
                    
                case .failure(let error):
                    completionHandler(nil)
                    print("Error fetching employees: \(error)")
                }
            }
    }
    


    
    static func fetchProductVariants(productID: Int, completionHandler: @escaping (VariantsResponse?) -> Void) {
        let productURL = "https://ios4-sv.myshopify.com/admin/api/2025-04/products/\(productID)/variants.json"
        let headers: HTTPHeaders = [
            "X-Shopify-Access-Token": "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"
        ]

        AF.request(productURL,  method: .get, headers: headers)
            .responseDecodable(of: VariantsResponse.self) { response in
                switch response.result {
                case .success(let productVariants):
                    completionHandler(productVariants)
                    print("employees fetched successfully")
                    
                case .failure(let error):
                    completionHandler(nil)
                    print("Error fetching employees: \(error)")
                }
            }
    }
    

    
    static func fetchProductDetails(productID: Int, completionHandler: @escaping (SingleProductResponse?) -> Void) {
        let productURL = "https://ios4-sv.myshopify.com/admin/api/2025-04/products/\(productID).json"
        let headers: HTTPHeaders = [
            "X-Shopify-Access-Token": "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"
        ]

        AF.request(productURL,  method: .get, headers: headers)
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
