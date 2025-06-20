//
//  MockCategoryNetworkService.swift
//  E-commerceTests
//
//  Created by MacBook on 21/06/2025.
//

import Foundation
@testable import E_commerce

class MockCategoryService: CategoryNetworkServiceProtocol {
    
    var shouldReturnError = false

    let mockResponse = CategoryResponse(customCollections: [
        Category(id: 1, title: "Mock Category", image: ImageResponse(src: "https://example.com/cat.png", width: 100, height: 100))
    ])
    
    static var shared: MockCategoryService = .init()
    
    static func fetchDataFromAPI(completion: @escaping (CategoryResponse?, Error?) -> Void) {
        shared.fetch(completion: completion)
    }

    private func fetch(completion: @escaping (CategoryResponse?, Error?) -> Void) {
        if shouldReturnError {
            let error = NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mock category error"])
            completion(nil, error)
        } else {
            completion(mockResponse, nil)
        }
    }
}
