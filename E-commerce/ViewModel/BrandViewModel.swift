//
//  EmployeeViewModel.swift
//  SwiftUIDay2Demo
//
//  Created by MacBook on 26/05/2025.
//

import Foundation

class BrandViewModel{
    func getBrands(completion: @escaping (BrandResponse?, Error?) -> Void){
        BrandNetworkService.fetchDataFromAPI{ response, error in
            if let error = error {
                print("\(error.localizedDescription)")
            }
            
            if let response = response {
                completion(response, nil)
            }
        }
    }
}
