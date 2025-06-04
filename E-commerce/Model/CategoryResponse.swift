//
//  Category.swift
//  E-commerce
//
//  Created by MacBook on 31/05/2025.
//

import Foundation

struct CategoryResponse : Decodable{
    let customCollections: [Category]?

       private enum CodingKeys: String, CodingKey {
           case customCollections = "custom_collections"
       }
}


struct Category : Decodable, Identifiable{
    var id : Int?
    var title : String?
    var image : ImageResponse?
}

