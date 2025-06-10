//
//  CollectsResponse.swift
//  E-commerce
//
//  Created by MacBook on 08/06/2025.
//

import Foundation

struct CollectsResponse: Decodable {
    let collects: [Collect]
}

struct Collect: Decodable {
    let id: Int
    let collection_id: Int
    let product_id: Int
}
