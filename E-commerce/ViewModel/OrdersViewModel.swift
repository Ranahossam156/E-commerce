//
//  OrdersViewModel.swift
//  E-commerce
//
//  Created by MacBook on 12/06/2025.
//

import Foundation
import Combine

class OrdersViewModel: ObservableObject {
    @Published var orders: [Order] = []
    @Published var newOrderPlaced = false
    
    func addOrder(_ order: Order) {
        orders.insert(order, at: 0)
        newOrderPlaced = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.newOrderPlaced = false
        }
    }
}
