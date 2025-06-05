//
//  FavoriteManager.swift
//  E-commerce
//
//  Created by Macos on 04/06/2025.
//

import Foundation
import CoreData

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
        
        favorite.images = downloadedImagesData as NSObject
        
        favorite.colors = product.colors as NSObject
        favorite.sizes = product.sizes as NSObject

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

}
