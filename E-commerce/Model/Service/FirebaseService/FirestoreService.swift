//
//  FirestoreService.swift
//  E-commerce
//
//  Created by Macos on 14/06/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
class FirestoreService {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()

    private func favoritesCollection(for userId: String) -> CollectionReference {
        return db.collection("users").document(userId).collection("favorites")
    }

    func uploadFavorites(_ favorites: [FavoriteProductModel], for userId: String) {
        let collection = favoritesCollection(for: userId)

        for favorite in favorites {
            let encodedImages = favorite.imagesData?.map { $0.base64EncodedString() } ?? []

            let data: [String: Any] = [
                "id": favorite.id,
                "title": favorite.title,
                "bodyHTML": favorite.bodyHTML,
                "price": favorite.price,
                "colors": favorite.colors,
                "sizes": favorite.sizes,
                "imageURLs": favorite.imageURLs,
                "imagesData": encodedImages
            ]

            collection.document("\(favorite.id)").setData(data)
        }
    }

    func deleteFavorite(for userId: String, productId: Int64) async throws {
        let docRef = favoritesCollection(for: userId).document("\(productId)")
        try await docRef.delete()
    }

    func fetchFavorites(for userId: String) async throws -> [FavoriteProductModel] {
        let snapshot = try await favoritesCollection(for: userId).getDocuments()
        
        let favorites = try snapshot.documents.compactMap { document in
            try document.data(as: FavoriteProductModel.self)
        }
        
        return favorites
    }
}
