// CurrencyServiceTests.swift
import XCTest
import Combine
@testable import E_commerce 

class CurrencyServiceTests: XCTestCase {
    var currencyService: CurrencyService!
    var mockSettingsViewModel: MockSettingsViewModel!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockSettingsViewModel = MockSettingsViewModel()
        currencyService = CurrencyService()
        currencyService.settingsViewModel = mockSettingsViewModel
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        currencyService = nil
        mockSettingsViewModel = nil
        cancellables = nil
        super.tearDown()
    }

    func testInitializationWithDefaultCurrency() {
        UserDefaults.standard.removeObject(forKey: "selectedCurrency")
        let service = CurrencyService()
        XCTAssertEqual(service.selectedCurrency, "USD")
    }

    func testInitializationWithSavedCurrency() {
        UserDefaults.standard.set("EUR", forKey: "selectedCurrency")
        let service = CurrencyService()
        XCTAssertEqual(service.selectedCurrency, "EUR" )
    }


    func testConvertPrice() {
        currencyService.exchangeRates = ["USD": 1.0, "EUR": 0.85]
        currencyService.selectedCurrency = "EUR"
        let convertedPrice = currencyService.convert(price: 100.0)
        XCTAssertEqual(convertedPrice, 85.0, accuracy: 0.01)
    }

    

    func testGetCurrencySymbol() {
        let currencyCode = "EUR"
        let symbol = currencyService.getCurrencySymbol(for: currencyCode)
        XCTAssertEqual(symbol, "€")
    }

    

    func testCurrencyChangeTriggersSettingsSave() {
        mockSettingsViewModel.selectedCurrency = "USD"
        currencyService.settingsViewModel = mockSettingsViewModel
        currencyService.selectedCurrency = "EUR"
        XCTAssertEqual(mockSettingsViewModel.selectedCurrency, "EUR", "SettingsViewModel should update currency")
        XCTAssertTrue(mockSettingsViewModel.saveSettingsCalled, "saveSettings should be called")
    }

    func testFetchExchangeRates() {
        let mockRates = ["USD": 1.0, "EUR": 0.85, "GBP": 0.73]
        currencyService.exchangeRates = mockRates
        XCTAssertEqual(currencyService.exchangeRates, mockRates, "Exchange rates should be set correctly")
    }
}

class MockSettingsViewModel: SettingsViewModel {
    var saveSettingsCalled = false
    
    override func saveSettings() {
        saveSettingsCalled = true
    }
}
