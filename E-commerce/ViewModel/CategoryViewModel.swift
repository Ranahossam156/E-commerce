//
//  CategoryViewModel.swift
//  E-commerce
//
//  Created by MacBook on 31/05/2025.
//

import Foundation

class CategoryViewModel{
    func getCategories(completion: @escaping (CategoryResponse?, Error?) -> Void){
        CategoryNetworkService.fetchDataFromAPI{ response, error in
            if let error = error {
                print("\(error.localizedDescription)")
            }
            
            if let response = response {
                completion(response, nil)
            }
        }
    }
}
