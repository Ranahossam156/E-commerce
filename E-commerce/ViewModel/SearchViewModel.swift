//
//  SearchViewModel.swift
//  E-commerce
//
//  Created by Macos on 09/06/2025.
//

import Foundation
import Combine

class SearchViewModel: ObservableObject {
    @Published var allProductsResponse: AllProductsResponse?


    func getAllProducts(productID: Int) {
        GetAllProducts.fetchAllProductDetails{ res in
            DispatchQueue.main.async {
                self.allProductsResponse = res
            }
        }
    }

}
