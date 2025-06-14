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
    private var cancellable: AnyCancellable?


    private let context = CoreDataManager.shared.context

    init() {
        fetchFavorites()
        cancellable = NotificationCenter.default.publisher(for: .favoritesChanged)
            .sink { [weak self] _ in
                self?.fetchFavorites()
            }
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
extension Notification.Name {
    static let favoritesChanged = Notification.Name("favoritesChanged")
}
