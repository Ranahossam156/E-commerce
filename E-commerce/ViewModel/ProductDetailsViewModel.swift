//
//  ViewModel.swift
//  MVVM Final
//
//  Created by Macos on 12/05/2025.
//
//
//  ViewModel.swift
//  MVVM Final
//
//  Created by Macos on 12/05/2025.
//

import Foundation
import Combine

class ProductDetailsViewModel: ObservableObject {
    @Published var singleProductResponse: SingleProductResponse?
    @Published var variantsResponse: VariantsResponse?
    @Published var productImagesResponse: ProductImagesResponse?

    func getProductByID(productID: Int) {
        NetworkService.fetchProductDetails(productID: productID) { res in
            DispatchQueue.main.async {
                self.singleProductResponse = res
            }
        }
    }

    func getProductVariants(productID: Int) {
        NetworkService.fetchProductVariants(productID: productID) { res in
            DispatchQueue.main.async {
                self.variantsResponse = res
            }
        }
    }

    func getProductImages(productID: Int) {
        NetworkService.fetchProductImages(productID: productID) { res in
            DispatchQueue.main.async {
                self.productImagesResponse = res
            }
        }
    }
}
