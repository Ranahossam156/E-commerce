//
//  OrdersView.swift
//  E-commerce
//
//  Created by MacBook on 10/06/2025.
//

import SwiftUI

struct OrdersView: View {
    let orders: [Order] = [
        Order(
            orderNumber: "#1097",
            itemCount: 2,
            address: "Ring Road, Ismaila",
            amountPaid: 328.32,
            currency: "EUR",
            date: DateFormatter.iso8601.date(from: "2024-06-24T05:18:33-04:00") ?? Date(),
            items: [
                OrderItem(
                    name: "Bix Bag Limited Edition 229",
                    color: "Brown",
                    quantity: 1,
                    price: 24.00,
                    status: "On Progress",
                    imageName: "bag1"
                ),
                
                OrderItem(
                    name: "Bix Bag Limited Edition 229",
                    color: "Brown",
                    quantity: 1,
                    price: 24.00,
                    status: "Shipped",
                    imageName: "bag1"
                ),
                
                OrderItem(
                    name: "Bix Bag Limited Edition 229",
                    color: "Brown",
                    quantity: 1,
                    price: 24.00,
                    status: "Delivered",
                    imageName: "bag1"
                )
            ]
        ),
        Order(
            orderNumber: "#1093",
            itemCount: 1,
            address: "Stockton St, San Francisco",
            amountPaid: 79.80,
            currency: "EUR",
            date: DateFormatter.iso8601.date(from: "2024-06-23T08:06:56-04:00") ?? Date(),
            items: [
                OrderItem(
                    name: "Bix Bag Limited Edition 229",
                    color: "Brown",
                    quantity: 1,
                    price: 24.00,
                    status: "On Progress",
                    imageName: "bag1"
                ),
                
                OrderItem(
                    name: "Bix Bag Limited Edition 229",
                    color: "Brown",
                    quantity: 1,
                    price: 24.00,
                    status: "Shipped",
                    imageName: "bag1"
                ),
                
                OrderItem(
                    name: "Bix Bag Limited Edition 229",
                    color: "Brown",
                    quantity: 1,
                    price: 24.00,
                    status: "Delivered",
                    imageName: "bag1"
                )
            ]
        ),
        Order(
            orderNumber: "#1092",
            itemCount: 1,
            address: "Stockton St, San Francisco",
            amountPaid: 29.07,
            currency: "EUR",
            date: DateFormatter.iso8601.date(from: "2024-06-23T08:06:56-04:00") ?? Date(),
            items: [
                OrderItem(
                    name: "Bix Bag Limited Edition 229",
                    color: "Brown",
                    quantity: 1,
                    price: 24.00,
                    status: "On Progress",
                    imageName: "bag1"
                ),
                
                OrderItem(
                    name: "Bix Bag Limited Edition 229",
                    color: "Brown",
                    quantity: 1,
                    price: 24.00,
                    status: "Shipped",
                    imageName: "bag1"
                ),
                
                OrderItem(
                    name: "Bix Bag Limited Edition 229",
                    color: "Brown",
                    quantity: 1,
                    price: 24.00,
                    status: "Delivered",
                    imageName: "bag1"
                )
            ]
        )
    ]
    
    var body: some View {
        NavigationView {
            List(orders) { order in
                NavigationLink(destination: OrderDetailView(order: order)){
                    OrderCard(order: order)
                }
            }
            .navigationTitle("Orders")
            .listStyle(.plain)
        }
    }
}

extension DateFormatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

struct OrdersView_Previews: PreviewProvider {
    static var previews: some View {
        OrdersView()
    }
}

