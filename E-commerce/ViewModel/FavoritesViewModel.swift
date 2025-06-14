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
                self?.objectWillChange.send()

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

    func removeFavorite(product: FavoritesModel) {
        FavoriteManager.shared.removeFromFavorites(id: product.id)
        favorites.removeAll { $0.id == product.id }
    }
}

extension Notification.Name {
    static let favoritesChanged = Notification.Name("favoritesChanged")
}
