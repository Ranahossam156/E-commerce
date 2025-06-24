//
//  TabViewModel.swift
//  E-commerce
//
//  Created by Kerolos on 24/06/2025.
//


import Foundation
import SwiftUI

class TabViewModel: ObservableObject {
    @Published var selectedTab: Int = 0 // 0 = Home, 1 = Favorites, 2 = Profile
    
    static let shared = TabViewModel()
    
    private init() {}
}