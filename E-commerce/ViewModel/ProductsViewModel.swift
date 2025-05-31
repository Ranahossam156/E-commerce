//
//  ProductsViewModel.swift
//  E-commerce
//
//  Created by MacBook on 31/05/2025.
//

import Foundation

class ProductsViewModel{
    func getBrandProducts(vendor: String, completion: @escaping (ProductsResponse?, Error?) -> Void){
        ProductNetworkService.fetchDataFromAPI(vendor: vendor){ response, error in
            if let error = error {
                print("\(error.localizedDescription)")
            }
            
            if let response = response {
                completion(response, nil)
            }
        }
    }
}
