//
//  ViewModel.swift
//  MVVM Final
//
//  Created by Macos on 12/05/2025.
//

import Foundation
class ProductDetailsViewModel: ObservableObject{
    var bindResultToViewController : (()->()) = {}
    var singleProductResponse : SingleProductResponse!{
        didSet{
            bindResultToViewController()
        }
    }
    var variantsResponse : VariantsResponse!{
        didSet{
            bindResultToViewController()
        }
    }
    var productImagesResponse : ProductImagesResponse!{
        didSet{
            bindResultToViewController()
        }
    }
    func getProductByID(productID : Int){
        NetworkService.fetchProductDetails(productID: productID){
            res in
            guard let res = res else {return}
            self.singleProductResponse = res
            print(res)
        }
    }
    func getProductVariants(productID : Int){
        NetworkService.fetchProductVariants(productID: productID){
            res in
            guard let res = res else {return}
            self.variantsResponse = res
            print(res)
        }
    }
    func getProductImages(productID : Int){
        NetworkService.fetchProductImages(productID: productID){
            res in
            guard let res = res else {return}
            self.productImagesResponse = res
            print(res)
        }
    }
}
