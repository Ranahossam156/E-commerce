import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseFirestoreSwift

class FirestoreService {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()

    private func favoritesCollection(for userId: String) -> CollectionReference {
        return db.collection("users").document(userId).collection("favorites")
    }

    func uploadFavorites(_ favorites: [FavoriteProductModel], for userId: String) async throws {
        let collection = favoritesCollection(for: userId)
        let batch = db.batch()

        for favorite in favorites {
            let docRef = collection.document("\(favorite.id)")
            try batch.setData(from: favorite, forDocument: docRef)
        }
        
        try await batch.commit()
    }

    func deleteFavorite(for userId: String, productId: Int64) async throws {
        let docRef = favoritesCollection(for: userId).document("\(productId)")
        try await docRef.delete()
    }

    func fetchFavorites(for userId: String) async throws -> [FavoriteProductModel] {
        let snapshot = try await favoritesCollection(for: userId).getDocuments()
        
        let favorites = try snapshot.documents.compactMap { document -> FavoriteProductModel? in
            do {
                return try document.data(as: FavoriteProductModel.self)
            } catch {
                print("Failed to decode favorite with ID \(document.documentID): \(error)")
                return nil
            }
        }
        
        return favorites
    }
}
