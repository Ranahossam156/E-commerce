import XCTest

class MockCartFirestoreServiceTests: XCTestCase {
    
    var mockService: MockCartFirestoreService!
    let testUserId = "test_user_123"
    let testProduct = Product(id: "prod_1", title: "Test Product", price: 9.99)
    let testVariant = Variant(id: "var_1", option1: "Large", option2: "Blue", price: 9.99)
    
    override func setUp() {
        super.setUp()
        mockService = MockCartFirestoreService()
    }
    
    func testLoadEmptyCart() {
        let expectation = XCTestExpectation(description: "Load empty cart")
        
        mockService.loadCartItems(for: testUserId) { result in
            switch result {
            case .success(let items):
                XCTAssertTrue(items.isEmpty)
            case .failure(let error):
                XCTFail("Unexpected error: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testSaveAndLoadCartItem() {
        let expectation = XCTestExpectation(description: "Save and load item")
        let testItem = CartItem(product: testProduct, selectedVariant: testVariant, quantity: 2)
        
        mockService.saveCartItem(testItem, for: testUserId) { saveResult in
            switch saveResult {
            case .success:
                self.mockService.loadCartItems(for: self.testUserId) { loadResult in
                    switch loadResult {
                    case .success(let items):
                        XCTAssertEqual(items.count, 1)
                        XCTAssertEqual(items[0].product.id, self.testProduct.id)
                        XCTAssertEqual(items[0].selectedVariant.id, self.testVariant.id)
                        XCTAssertEqual(items[0].quantity, 2)
                    case .failure(let error):
                        XCTFail("Unexpected error: \(error)")
                    }
                    expectation.fulfill()
                }
            case .failure(let error):
                XCTFail("Save failed: \(error)")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testUpdateCartItem() {
        let expectation = XCTestExpectation(description: "Update item")
        var testItem = CartItem(product: testProduct, selectedVariant: testVariant, quantity: 1)
        
        mockService.saveCartItem(testItem, for: testUserId) { _ in
            testItem.quantity = 3
            self.mockService.updateCartItem(testItem, for: self.testUserId) { updateResult in
                switch updateResult {
                case .success:
                    
                    self.mockService.loadCartItems(for: self.testUserId) { loadResult in
                        switch loadResult {
                        case .success(let items):
                            XCTAssertEqual(items[0].quantity, 3)
                        case .failure(let error):
                            XCTFail("Unexpected error: \(error)")
                        }
                        expectation.fulfill()
                    }
                case .failure(let error):
                    XCTFail("Update failed: \(error)")
                    expectation.fulfill()
                }
            }
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testDeleteCartItem() {
        let expectation = XCTestExpectation(description: "Delete item")
        let testItem = CartItem(product: testProduct, selectedVariant: testVariant, quantity: 1)
        
        mockService.saveCartItem(testItem, for: testUserId) { _ in
            self.mockService.deleteCartItem(testItem, for: self.testUserId) { deleteResult in
                switch deleteResult {
                case .success:
                    self.mockService.loadCartItems(for: self.testUserId) { loadResult in
                        switch loadResult {
                        case .success(let items):
                            XCTAssertTrue(items.isEmpty)
                        case .failure(let error):
                            XCTFail("Unexpected error: \(error)")
                        }
                        expectation.fulfill()
                    }
                case .failure(let error):
                    XCTFail("Delete failed: \(error)")
                    expectation.fulfill()
                }
            }
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testClearCart() {
        let expectation = XCTestExpectation(description: "Clear cart")
        let testItem = CartItem(product: testProduct, selectedVariant: testVariant, quantity: 1)
        
        mockService.saveCartItem(testItem, for: testUserId) { _ in
            self.mockService.clearCart(for: self.testUserId) { clearResult in
                switch clearResult {
                case .success:
                    self.mockService.loadCartItems(for: self.testUserId) { loadResult in
                        switch loadResult {
                        case .success(let items):
                            XCTAssertTrue(items.isEmpty)
                        case .failure(let error):
                            XCTFail("Unexpected error: \(error)")
                        }
                        expectation.fulfill()
                    }
                case .failure(let error):
                    XCTFail("Clear failed: \(error)")
                    expectation.fulfill()
                }
            }
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testErrorHandling() {
        let expectation = XCTestExpectation(description: "Error handling")
        mockService.shouldFail = true
        
        mockService.loadCartItems(for: testUserId) { result in
            switch result {
            case .success:
                XCTFail("Should have failed")
            case .failure(let error):
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
}
