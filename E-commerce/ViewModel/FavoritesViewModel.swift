import Foundation
import CoreData
import Combine
import FirebaseAuth

class FavoritesViewModel: ObservableObject {
    @Published var favorites: [FavoritesModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let context = CoreDataManager.shared.context

    init() {
        fetchFavorites()
        setupNotifications()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.publisher(for: .favoritesChanged)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.fetchFavorites()
            }
            .store(in: &cancellables)
    }

    @MainActor
    func syncFavorites() async {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        do {
            guard let userId = Auth.auth().currentUser?.uid else {
                throw NSError(domain: "Auth", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
            }
            
            let firestoreFavorites = try await FirestoreService.shared.fetchFavorites(for: userId)
            
            try await clearCoreDataFavorites()
            
            try await saveToCoreData(favorites: firestoreFavorites)
            
            fetchFavorites()
            
        } catch {
            errorMessage = error.localizedDescription
            print("Error syncing favorites: \(error)")
        }
    }
    
    private func clearCoreDataFavorites() async throws {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = FavoritesModel.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        try context.execute(deleteRequest)
        try context.save()
    }
    
    private func saveToCoreData(favorites: [FavoriteProductModel]) async throws {
        for favorite in favorites {
            let newFavorite = FavoritesModel(context: context)
            newFavorite.id = favorite.id
            newFavorite.title = favorite.title
            newFavorite.price = favorite.price
            newFavorite.desc = favorite.bodyHTML
            
            newFavorite.colors = favorite.colors as NSObject
            newFavorite.sizes = favorite.sizes as NSObject
            
            if let imagesData = favorite.imagesData {
                newFavorite.images = imagesData 
            }
        }
        
        try context.save()
    }

    func fetchFavorites() {
        let request: NSFetchRequest<FavoritesModel> = FavoritesModel.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        do {
            favorites = try context.fetch(request)
        } catch {
            errorMessage = error.localizedDescription
            print("Error fetching favorites: \(error)")
        }
    }

    @MainActor
    func removeFavorite(product: FavoritesModel) async {
        do {
            context.delete(product)
            try context.save()
            fetchFavorites()
            print(" Removed from Core Data.")

            guard let userId = Auth.auth().currentUser?.uid else {
                throw NSError(domain: "Auth", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
            }
            
            try await FirestoreService.shared.deleteFavorite(for: userId, productId: product.id)
            print("Removed from Firestore.")
            
        } catch {
            errorMessage = error.localizedDescription
            print(" Error removing favorite: \(error)")
            context.rollback()
            fetchFavorites()
        }
    }

}

extension Notification.Name {
    static let favoritesChanged = Notification.Name("favoritesChanged")
}
