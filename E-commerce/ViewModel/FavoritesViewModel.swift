//
//  FavoritesViewModel.swift
//  E-commerce
//
//  Created by Macos on 05/06/2025.
//

import Foundation
import CoreData
import Combine

class FavoritesViewModel: ObservableObject {
    @Published var favorites: [FavoritesModel] = []

    private let context = CoreDataManager.shared.context

    init() {
        fetchFavorites()
    }

    func fetchFavorites() {
        let request: NSFetchRequest<FavoritesModel> = FavoritesModel.fetchRequest()
        do {
            favorites = try context.fetch(request)
        } catch {
            print("Error fetching favorites: \(error.localizedDescription)")
        }
    }
}
