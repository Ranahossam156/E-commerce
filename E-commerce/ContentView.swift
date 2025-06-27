import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var currencyService: CurrencyService
    @EnvironmentObject var orderViewModel: OrderViewModel

    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainTabView()
                    .task {
                        guard let userId = Auth.auth().currentUser?.uid else {
                            print("User logged in but no UID found.")
                            return
                        }
                        await FavoriteManager.shared.syncFavoritesFromFirestore(for: userId)
                    }
            } else {
                LoginScreen()
            }
        }
    }
}
