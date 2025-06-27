import Foundation
import Combine
import FirebaseAuth

class FavoritesViewModel: ObservableObject {
    @Published var favorites: [FavoriteProductModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?


    @MainActor
    func fetchFavorites() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "User not authenticated"
            return
        }
        
        if favorites.isEmpty {
            isLoading = true
        }
        
        do {
            favorites = try await FirestoreService.shared.fetchFavorites(for: uid)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }


    @MainActor
    func removeFavorite(id: Int64) async {
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "User not authenticated"
            return
        }


        favorites.removeAll { $0.id == id }


        do {
            try await FirestoreService.shared.deleteFavorite(for: uid, productId: id)
        } catch {

            errorMessage = "Failed to remove favorite: \(error.localizedDescription)"
            await fetchFavorites()
        }
    }
    @MainActor
    func addFavorite(_ product: FavoriteProductModel) async {
         guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "User not authenticated"
            return
        }
        
        favorites.append(product)
        
        do {
            try await FirestoreService.shared.uploadFavorites([product], for: uid)
        } catch {
            errorMessage = error.localizedDescription
            favorites.removeAll { $0.id == product.id }
        }
    }
}
