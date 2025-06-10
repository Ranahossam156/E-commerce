//
//  FavoritesModel+CoreDataProperties.swift
//  E-commerce
//
//  Created by Macos on 04/06/2025.
//
//

import Foundation
import CoreData


extension FavoritesModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoritesModel> {
        return NSFetchRequest<FavoritesModel>(entityName: "FavoritesModel")
    }

    @NSManaged public var id: Int64
    @NSManaged public var title: String?
    @NSManaged public var desc: String?
    @NSManaged public var price: String?
    @NSManaged public var colors: NSObject?
    @NSManaged public var sizes: NSObject?
    @NSManaged public var images: NSObject?

}

extension FavoritesModel : Identifiable {

}
