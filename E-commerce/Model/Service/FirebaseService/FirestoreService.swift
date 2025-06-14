//
//  FirestoreService.swift
//  E-commerce
//
//  Created by Macos on 14/06/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

class FirestoreService {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()

    private func favoritesCollection(for userId: String) -> CollectionReference {
        return db.collection("users").document(userId).collection("favorites")
    }

    func uploadFavorites(_ favorites: [FavoriteProductModel], for userId: String) async throws {
        let batch = db.batch()
        for favorite in favorites {
            let docRef = favoritesCollection(for: userId).document("\(favorite.id)")
            try batch.setData(from: favorite, forDocument: docRef)
        }
        try await batch.commit()
    }

    func fetchFavorites(for userId: String) async throws -> [FavoriteProductModel] {
        let snapshot = try await favoritesCollection(for: userId).getDocuments()
        
        let favorites = try snapshot.documents.compactMap { document in
            try document.data(as: FavoriteProductModel.self)
        }
        
        return favorites
    }
}
