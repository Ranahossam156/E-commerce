//
//  FavoriteManager.swift
//  E-commerce
//
//  Created by Macos on 04/06/2025.
//

import Foundation
import CoreData
import FirebaseAuth

class FavoriteManager {
    static let shared = FavoriteManager()

    private let context = CoreDataManager.shared.context
    func addToFavorites(product: FavoriteProductModel) async {
        
        var downloadedImagesData: [Data] = []
        
        for urlString in product.imageURLs {
            guard let url = URL(string: urlString) else { continue }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                downloadedImagesData.append(data)
            } catch {
                print("Failed to download image from \(urlString): \(error)")
            }
        }
        
        let favorite = FavoritesModel(context: context)
        favorite.id = product.id
        favorite.title = product.title
        favorite.desc = product.bodyHTML
        favorite.price = product.price
        
        favorite.images = downloadedImagesData
        
        favorite.colors = product.colors as NSObject
        favorite.sizes = product.sizes as NSObject
        favorite.setValue(product.imageURLs, forKey: "imageURLs")


        CoreDataManager.shared.save()
        print("Favorite saved with \(downloadedImagesData.count) images.")
    }

    func isFavorited(id: Int64) -> Bool {
        let request: NSFetchRequest<FavoritesModel> = FavoritesModel.fetchRequest()
        request.predicate = NSPredicate(format: "id == %lld", id)
        return (try? context.fetch(request).first) != nil
    }
    func removeFromFavorites(id: Int64) {
        let request: NSFetchRequest<FavoritesModel> = FavoritesModel.fetchRequest()
        request.predicate = NSPredicate(format: "id == %lld", id)

        do {
            if let objectToDelete = try context.fetch(request).first {
                context.delete(objectToDelete)
                CoreDataManager.shared.save()

                // Ensure valid user ID
                guard let userId = Auth.auth().currentUser?.uid else {
                    print("No authenticated user. Cannot delete from Firestore.")
                    return
                }

                Task {
                    do {
                        try await FirestoreService.shared.deleteFavorite(for: userId, productId: id)
                        print("Removed from Firestore.")
                    } catch {
                        print("Failed to remove from Firestore: \(error)")
                    }
                }
            }
        } catch {
            print("Failed to remove favorite with id \(id): \(error.localizedDescription)")
        }
    }

    func getFavoriteById(id: Int64) -> FavoriteProductModel? {
        let request: NSFetchRequest<FavoritesModel> = FavoritesModel.fetchRequest()
        request.predicate = NSPredicate(format: "id == %lld", id)

        do {
            if let result = try context.fetch(request).first {
                return FavoriteProductModel(
                    id: result.id,
                    title: result.title ?? "",
                    bodyHTML: result.desc ?? "",
                    price: result.price ?? "0.00",
                    colors: result.colors as? [String] ?? [],
                    sizes: result.sizes as? [String] ?? [],
                    imageURLs: [],
                    imagesData: result.images as? [Data]
                )
            }
        } catch {
            print("Error fetching favorite by id: \(error)")
        }
        return nil
    }
    func getFavoriteImagesData(id: Int64) -> [Data]? {
        let request: NSFetchRequest<FavoritesModel> = FavoritesModel.fetchRequest()
        request.predicate = NSPredicate(format: "id == %lld", id)
        
        do {
            if let result = try context.fetch(request).first {
                return result.images as? [Data]
            }
        } catch {
            print("Error fetching favorite images data: \(error)")
        }
        return nil
    }

    func printAllFavorites() {
        let request: NSFetchRequest<FavoritesModel> = FavoritesModel.fetchRequest()
        do {
            let favorites = try context.fetch(request)
            print("===== All Favorites =====")
            for fav in favorites {
                print("ID: \(fav.id)")
                print("Title: \(fav.title ?? "No Title")")
                print("Description: \(fav.desc ?? "No Description")")
                print("Price: \(fav.price ?? "0.00")")
                print("Colors: \((fav.colors as? [String]) ?? [])")
                print("Sizes: \((fav.sizes as? [String]) ?? [])")
                print("Images: \((fav.images as? [String]) ?? [])")
                print("--------------------------")
            }
        } catch {
            print("Failed to fetch favorites: \(error.localizedDescription)")
        }
    }
    func getAllFavorites() -> [FavoriteProductModel] {
        let request: NSFetchRequest<FavoritesModel> = FavoritesModel.fetchRequest()
        var favorites: [FavoriteProductModel] = []

        do {
            let results = try context.fetch(request)
            favorites = results.map { coreDataFavorite in
                FavoriteProductModel(
                    id: coreDataFavorite.id,
                    title: coreDataFavorite.title ?? "",
                    bodyHTML: coreDataFavorite.desc ?? "",
                    price: coreDataFavorite.price ?? "0.00",
                    colors: coreDataFavorite.colors as? [String] ?? [],
                    sizes: coreDataFavorite.sizes as? [String] ?? [],
                    imageURLs: coreDataFavorite.value(forKey: "imageURLs") as? [String] ?? [],
                    imagesData: coreDataFavorite.images as? [Data]
                )
            }
            print("Retrieved \(favorites.count) favorites from Core Data.")
        } catch {
        }
        return favorites
    }

    func deleteAllFavorites() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = FavoritesModel.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
            CoreDataManager.shared.save()
            print("All favorites deleted from Core Data.")
        } catch {
        }
    }


    func syncFavoritesToFirestore(for userId: String) async {
        let localFavorites = getAllFavorites()
        
        
        guard !localFavorites.isEmpty else {
            print("No local favorites to sync.")
            return
        }

        do {
            try await FirestoreService.shared.uploadFavorites(localFavorites, for: userId)
            deleteAllFavorites()
        } catch {
        }
    }

    func syncFavoritesFromFirestore(for userId: String) async {
        do {
            let firestoreFavorites = try await FirestoreService.shared.fetchFavorites(for: userId)
            
            deleteAllFavorites()

            for favorite in firestoreFavorites {
                await addToFavorites(product: favorite)
            }
            
        } catch {
        }
    }

}
