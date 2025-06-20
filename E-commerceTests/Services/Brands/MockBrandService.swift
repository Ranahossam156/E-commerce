//
//  MockBrandService.swift
//  E-commerceTests
//
//  Created by MacBook on 21/06/2025.
//

import Foundation
@testable import E_commerce

class MockBrandService: BrandNetworkServiceProtocol {
    
    var shouldReturnError = false

    let mockResponse = BrandResponse(smartCollections: [
        Brand(id: 1, title: "Mock Brand", image: ImageResponse(src: "https://example.com/logo.png", width: 100, height: 100))
    ])
    
    static var shared: MockBrandService = .init()
    
    static func fetchDataFromAPI(completion: @escaping (BrandResponse?, Error?) -> Void) {
        shared.fetch(completion: completion)
    }

    private func fetch(completion: @escaping (BrandResponse?, Error?) -> Void) {
        if shouldReturnError {
            let error = NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
            completion(nil, error)
        } else {
            completion(mockResponse, nil)
        }
    }
}

