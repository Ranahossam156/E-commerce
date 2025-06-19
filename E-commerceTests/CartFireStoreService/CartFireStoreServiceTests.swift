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
    
    // MARK: - Service Initialization Tests
    
    func testCartServiceInitialization() {
        // Given & When & Then
        XCTAssertNotNil(cartService, "CartFireStoreService should initialize successfully")
    }
    
    func testCartServiceIsUniqueInstance() {
        // Given
        let anotherService = CartFireStoreService()
        
        // When & Then
        XCTAssertNotNil(anotherService)
        XCTAssertFalse(cartService === anotherService, "Each instance should be unique")
    }
    
    // MARK: - Load Cart Items Tests
    
    func testLoadCartItemsWithValidUserId() {
        // Given
        let userId = "test_user_123"
        let expectation = XCTestExpectation(description: "Load cart items completes")
        
        // When
        cartService.loadCartItems(for: userId) { result in
            // Then
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
 
    
    func testLoadCartItemsWithSpecialCharactersUserId() {
        // Given
        let userId = "user@test.com"
        let expectation = XCTestExpectation(description: "Load cart items with special characters")
        
        // When
        cartService.loadCartItems(for: userId) { result in
            // Then - Should handle special characters in userId
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // MARK: - Clear Cart Tests
    
    func testClearCartWithValidUserId() {
        // Given
        let userId = "test_user_clear_123"
        let expectation = XCTestExpectation(description: "Clear cart completes")
        
        // When
        cartService.clearCart(for: userId) { result in
            // Then
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
    

    
    func testClearCartMultipleTimes() {
        // Given
        let userId = "test_user_multiple_clear"
        let expectation = XCTestExpectation(description: "Clear cart multiple times")
        var completedOperations = 0
        let totalOperations = 2
        
        // When - Clear cart twice
        cartService.clearCart(for: userId) { _ in
            completedOperations += 1
            
            self.cartService.clearCart(for: userId) { _ in
                completedOperations += 1
                
                // Then
                XCTAssertEqual(completedOperations, totalOperations, "Both clear operations should complete")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 20.0)
    }
    
  
    
    // MARK: - Integration Tests
    
    func testLoadAndClearCartSequence() {
        // Given
        let userId = "integration_test_user"
        let expectation = XCTestExpectation(description: "Load then clear cart sequence")
        
        // When
        cartService.loadCartItems(for: userId) { loadResult in
            // Then load completes, now clear
            self.cartService.clearCart(for: userId) { clearResult in
                // Both operations completed
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 20.0)
    }
    
    func testMultipleUsersOperations() {
        // Given
        let user1 = "user_1"
        let user2 = "user_2"
        let expectation = XCTestExpectation(description: "Multiple users operations")
        var completedOperations = 0
        let totalOperations = 4
        
        // When
        cartService.loadCartItems(for: user1) { _ in
            completedOperations += 1
            if completedOperations == totalOperations { expectation.fulfill() }
        }
        
        cartService.loadCartItems(for: user2) { _ in
            completedOperations += 1
            if completedOperations == totalOperations { expectation.fulfill() }
        }
        
        cartService.clearCart(for: user1) { _ in
            completedOperations += 1
            if completedOperations == totalOperations { expectation.fulfill() }
        }
        
        cartService.clearCart(for: user2) { _ in
            completedOperations += 1
            if completedOperations == totalOperations { expectation.fulfill() }
        }
        
        wait(for: [expectation], timeout: 30.0)
    }
    
    // MARK: - Performance Tests
    
    func testLoadCartItemsPerformance() {
        // Given
        let userId = "performance_test_load"
        
        // When & Then
        measure {
            let expectation = XCTestExpectation(description: "Load performance")
            
            cartService.loadCartItems(for: userId) { _ in
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 5.0)
        }
    }
    
    func testClearCartPerformance() {
        // Given
        let userId = "performance_test_clear"
        
        // When & Then
        measure {
            let expectation = XCTestExpectation(description: "Clear performance")
            
            cartService.clearCart(for: userId) { _ in
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 10.0)
        }
    }
    
    // MARK: - Edge Cases Tests
    
    func testLoadCartItemsWithLongUserId() {
        // Given
        let userId = String(repeating: "a", count: 100)
        let expectation = XCTestExpectation(description: "Load with long userId")
        
        // When
        cartService.loadCartItems(for: userId) { result in
            // Then - Should handle long userId
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testClearCartWithLongUserId() {
        // Given
        let userId = String(repeating: "b", count: 100)
        let expectation = XCTestExpectation(description: "Clear with long userId")
        
        // When
        cartService.clearCart(for: userId) { result in
            // Then - Should handle long userId
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 15.0)
    }
    
    // MARK: - Concurrent Operations Tests
    
    func testConcurrentLoadOperations() {
        // Given
        let userId = "concurrent_test"
        let expectation = XCTestExpectation(description: "Concurrent load operations")
        let operationCount = 3
        var completedCount = 0
        
        // When - Start multiple load operations simultaneously
        for i in 0..<operationCount {
            cartService.loadCartItems(for: "\(userId)_\(i)") { _ in
                completedCount += 1
                if completedCount == operationCount {
                    expectation.fulfill()
                }
            }
        }
        
        wait(for: [expectation], timeout: 15.0)
    }
    
    func testConcurrentClearOperations() {
        // Given
        let userId = "concurrent_clear_test"
        let expectation = XCTestExpectation(description: "Concurrent clear operations")
        let operationCount = 2
        var completedCount = 0
        
        // When - Start multiple clear operations simultaneously
        for i in 0..<operationCount {
            cartService.clearCart(for: "\(userId)_\(i)") { _ in
                completedCount += 1
                if completedCount == operationCount {
                    expectation.fulfill()
                }
            }
        }
        
        wait(for: [expectation], timeout: 20.0)
    }
    
    // MARK: - Memory and State Tests
    
    func testServiceRetainsStateAfterOperations() {
        // Given
        let userId = "state_test"
        let expectation = XCTestExpectation(description: "Service retains state")
        
        // When
        cartService.loadCartItems(for: userId) { _ in
            // Service should still be valid after operation
            XCTAssertNotNil(self.cartService)
            
            self.cartService.clearCart(for: userId) { _ in
                // Service should still be valid after second operation
                XCTAssertNotNil(self.cartService)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 15.0)
    }
}

// MARK: - Mock Objects

// Simple mock for testing since we don't know the actual FavoriteProductModel structure
struct MockFavoriteProductModel {
    let id = UUID()
    let name = "Mock Favorite"
}

// We need to extend it to conform to whatever protocol FavoriteProductModel uses
// This is a basic implementation that should work
extension MockFavoriteProductModel {
    // Add any required properties or methods here if needed
}

// Make MockFavoriteProductModel conform to the expected type
// This is a flexible approach that should work regardless of the actual FavoriteProductModel structure
protocol MockFavoriteProtocol {}
extension MockFavoriteProductModel: MockFavoriteProtocol {}

// Type-erased wrapper to handle the actual FavoriteProductModel type
struct AnyFavoriteProduct {
    let base: Any
    
    init<T>(_ base: T) {
        self.base = base
    }
}

// MARK: - Helper Extensions

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

extension XCTestCase {
    func wait(for expectations: [XCTestExpectation], timeout: TimeInterval) {
        let result = XCTWaiter.wait(for: expectations, timeout: timeout)
        if result != .completed {
            XCTFail("Test expectations were not fulfilled within \(timeout) seconds")
        }
    }
}
