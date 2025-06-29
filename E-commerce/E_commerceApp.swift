import SwiftUI
import Firebase
import PayPalCheckout
import CorePayments

@main
struct E_commerceApp: App {
    @StateObject private var currencyService = CurrencyService()
    @StateObject private var orderViewModel = OrderViewModel()
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var userModel = UserModel()
    @StateObject private var settingsViewModel = SettingsViewModel()
    @StateObject private var cartViewModel = CartViewModel.shared // Add CartViewModel
    
    
    init() {
        print("Initializing Firebase")
        FirebaseApp.configure()
        print("Firebase initialized successfully")
        
        let config = CheckoutConfig(
            clientID: Config.paypalClientId,
            environment: .sandbox // or .live for production
        )
        Checkout.set(config: config)
        
        // Enable Firestore offline support
        //Firestore.firestore().settings.isPersistenceEnabled = true
    }

    var body: some Scene {
        WindowGroup {

            SplashScreen()
                .environmentObject(authViewModel)
                .environmentObject(userModel)
                .environmentObject(orderViewModel)
                .environmentObject(currencyService)
                .environmentObject(settingsViewModel)
                .environmentObject(cartViewModel)
        }
    }
}
