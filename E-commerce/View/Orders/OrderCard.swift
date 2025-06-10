//
//  OrderCard.swift
//  E-commerce
//
//  Created by MacBook on 10/06/2025.
//

import SwiftUI

struct OrderCard: View {
    var order: Order
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Order Number
            HStack(alignment: .top) {
                Text("Order No:")
                    .foregroundColor(.secondary)
                Text(order.orderNumber)
                    .bold()
            }
            .font(.subheadline)
            
            // Item Count
            HStack(alignment: .top) {
                Text("No of items:")
                    .foregroundColor(.secondary)
                Text("\(order.itemCount)")
                    .bold()
            }
            .font(.subheadline)
            
            // Address
            HStack(alignment: .top) {
                Text("Address:")
                    .foregroundColor(.secondary)
                Text(order.address)
            }
            .font(.subheadline)
            
            // Date
            HStack(alignment: .top) {
                Text("Date:")
                    .foregroundColor(.secondary)
                Text(order.formattedDate)
                    .foregroundColor(.primary)
            }
            .font(.subheadline)
            
            // Payment
            HStack(alignment: .top) {
                Text("Money Paid:")
                    .foregroundColor(.secondary)
                Text(order.formattedAmount)
                    .bold()
                    .foregroundColor(.green)
            }
            .font(.subheadline)
            
           
        }
        .padding(.vertical, 12)
    }
}
