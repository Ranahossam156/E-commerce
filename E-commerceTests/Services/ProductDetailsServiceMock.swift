//
//  ProductDetailsServiceMock.swift
//  E-commerceTests
//
//  Created by Macos on 18/06/2025.
//
import Foundation
import Alamofire
import XCTest
@testable import E_commerce
final class ProductDetailsServiceMock: ProductDetailsServiceProtocol {
    static var shouldReturnError = false
    static var mockProductResponse: SingleProductResponse?

    static func fetchProductDetails(productID: Int, completionHandler: @escaping (SingleProductResponse?) -> Void) {
        if shouldReturnError {
            completionHandler(nil)
        } else {
            completionHandler(mockProductResponse)
        }
    }
}
