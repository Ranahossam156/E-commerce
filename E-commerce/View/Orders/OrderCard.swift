//
//  OrderCard.swift
//  E-commerce
//
//  Created by MacBook on 10/06/2025.
//

import SwiftUI

struct OrderCard: View {
    var order: OrderModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Order Number
            HStack(alignment: .top) {
                Text("Order No:")
                    .foregroundColor(.secondary)
                Text("\(order.orderNumber)")
                    .bold()
            }
            .font(.subheadline)
            
            // Item Count
            HStack(alignment: .top) {
                Text("No of items:")
                    .foregroundColor(.secondary)
                Text("\(order.lineItems?.count ?? 0)")
                    .bold()
            }
            .font(.subheadline)
            
//            // Address
//            HStack(alignment: .top) {
//                Text("Address:")
//                    .foregroundColor(.secondary)
//                Text("\(order.shippingAddress?.address1 ?? "N/A")")
//            }
//            .font(.subheadline)
            
            // Date
            HStack(alignment: .top) {
                Text("Date:")
                    .foregroundColor(.secondary)
                Text("\(formattedDate(from: order.createdAt))")
                    .foregroundColor(.primary)
            }
            .font(.subheadline)
            
            // Payment
            HStack(alignment: .top) {
                Text("Money Paid:")
                    .foregroundColor(.secondary)
                Text(order.totalPrice ?? "")
                    .bold()
                    .foregroundColor(.green)
            }
            .font(.subheadline)
            
           
        }
        .padding(.vertical, 12)
    }
}


