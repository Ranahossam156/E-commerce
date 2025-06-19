// FavoritesViewModel.swift

import Foundation
import Combine
import FirebaseAuth

class FavoritesViewModel: ObservableObject {
    @Published var favorites: [FavoriteProductModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    init() {
        Task { @MainActor in await fetchFavorites() }
    }

    @MainActor
    func fetchFavorites() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "User not authenticated"
            return
        }
        isLoading = true
        do {
            favorites = try await FirestoreService.shared.fetchFavorites(for: uid)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    @MainActor
    func addFavorite(_ product: FavoriteProductModel) async {
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "User not authenticated"
            return
        }
        do {
            // upload single favorite as a batch or directly:
            try await FirestoreService.shared.uploadFavorites([product], for: uid)
            // refresh local array
            await fetchFavorites()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    func removeFavorite(id: Int64) async {
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "User not authenticated"
            return
        }
        do {
            try await FirestoreService.shared.deleteFavorite(for: uid, productId: id)
            await fetchFavorites()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
