//
//  Brand.swift
//  ShopifyDemo
//
//  Created by MacBook on 26/05/2025.
//

import Foundation

struct BrandResponse : Decodable{
    let smartCollections: [Brand]?

       private enum CodingKeys: String, CodingKey {
           case smartCollections = "smart_collections"
       }
}


struct Brand : Decodable, Identifiable{
    var id : Int
    var handle :  String?
    var title : String?
    var image : ImageResponse?
}

struct ImageResponse : Decodable{
    var src : String?
    var width : Int?
    var height : Int?
}
