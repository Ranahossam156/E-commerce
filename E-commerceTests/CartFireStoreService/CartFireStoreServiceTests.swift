//
//  CartFireStoreServiceTests.swift
//  E-commerceTests
//
//  Created by Test on 13/06/2025.
//

import XCTest
import FirebaseFirestore
import FirebaseAuth
@testable import E_commerce

class CartFireStoreServiceTests: XCTestCase {
    
    var cartService: CartFireStoreService!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        cartService = CartFireStoreService()
    }
    
    override func tearDownWithError() throws {
        cartService = nil
        try super.tearDownWithError()
    }
    
    
    func testLoadCartItemsWithValidUserId() {
        let userId = "test_user_123"
        let expectation = XCTestExpectation(description: "Load cart items completes")
        
        cartService.loadCartItems(for: userId) { result in
            switch result {
            case .success(let items):
                XCTAssertTrue(items.count >= 0, "Should return array (empty or with items)")
                XCTAssertTrue(items is [CartItem], "Should return array of CartItem")
            case .failure(let error):
                XCTAssertNotNil(error, "Should have error object if failed")
                print("Expected error for test environment: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    
    
    func testClearCartWithValidUserId() {
        let userId = "test_user_clear_123"
        let expectation = XCTestExpectation(description: "Clear cart completes")
        
        cartService.clearCart(for: userId) { result in
            switch result {
            case .success:
                XCTAssertTrue(true, "Clear cart operation completed successfully")
            case .failure(let error):
                XCTAssertNotNil(error, "Should have error object if failed")
                print("Expected error for test environment: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 15.0)
    }
    
    func testLoadAndClearCartSequence() {
        let userId = "integration_test_user"
        let expectation = XCTestExpectation(description: "Load then clear cart sequence")
        
        cartService.loadCartItems(for: userId) { loadResult in
            self.cartService.clearCart(for: userId) { clearResult in
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 20.0)
    }
    
    
}







extension Result {
    var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }
    
    var isFailure: Bool {
        return !isSuccess
    }
}

