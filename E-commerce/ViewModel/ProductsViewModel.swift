//
//  ProductsViewModel.swift
//  E-commerce
//
//  Created by MacBook on 31/05/2025.
//

import Foundation

class ProductsViewModel : ObservableObject{
    func getBrandProducts(vendor: String, completion: @escaping (ProductsResponse?, Error?) -> Void){
        BrandProductNetworkService.fetchDataFromAPI(vendor: vendor){ response, error in
            if let error = error {
                print("\(error.localizedDescription)")
            }
            
            if let response = response {
                completion(response, nil)
            }
        }
    }
    
    func getCategoryProducts(collectionId: Int, completion: @escaping (ProductsResponse?, Error?) -> Void){
        CategoryProductNetworkService.fetchProducts(for: collectionId) { response, error in
            if let error = error {
                print("\(error.localizedDescription)")
            }
            
            if let response = response {
                completion(response, nil)
            }
        }
        
    }
}
