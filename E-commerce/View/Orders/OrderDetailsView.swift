//
//  Order.swift
//  E-commerce
//
//  Created by MacBook on 10/06/2025.
//

import SwiftUI

// MARK: - Order Detail View
struct OrderDetailView: View {
    let order: OrderModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Order \(order.orderNumber)")
                        .font(.title2)
                        .bold()
                    
                    Text([
                        order.shippingAddress?.address1,
                        order.shippingAddress?.city,
                        order.shippingAddress?.zip,
                        order.shippingAddress?.countryCode?.rawValue
                    ].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: ", "))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    
                    Text("\(formattedDate(from: order.createdAt))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 8)
                
                ForEach(order.lineItems!) { item in
                    OrderItemView(item: item)
                }
                
                HStack {
                    Text("Total:")
                        .font(.headline)
                    Spacer()
                    Text(order.totalPrice ?? "")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.green)
                }
                .padding(.top, 4)
            }
            .padding(20)
        }
        .navigationTitle("Order Details")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
    }
}

struct OrderItemView: View {
    let item: LineItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            HStack(alignment: .top, spacing: 16) {
                // Product image
//                Image(item.imageName)
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 80, height: 80)
//                    .background(Color(.systemGray6))
//                    .cornerRadius(8)
//                
                // Product details
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.name ?? "")
                        .font(.headline)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                    
//                    Text("Color: \(item.color)")
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
                    
                    Text("Qty: \(item.quantity)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.bottom, 12)
            
            Divider()
            
//            HStack {
//                StatusBadge(status: item.status)
//                Spacer()
//                Text(item.formattedPrice)
//                    .font(.title3)
//                    .bold()
//            }
//            .padding(.vertical, 8)
            
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct StatusBadge: View {
    let status: String
    
    var statusColor: Color {
        switch status {
        case "On Progress": return .orange
        case "Delivered": return .green
        case "Shipped": return .blue
        default: return .gray
        }
    }
    
    var body: some View {
        Text(status)
            .font(.subheadline)
            .bold()
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(statusColor.opacity(0.2))
            .foregroundColor(statusColor)
            .cornerRadius(20)
    }
}

struct DetailRow: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
            Spacer()
            if title == "Tracking" {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Shared Components
struct LabelValueView: View {
    let label: String
    let value: String
    var isBold: Bool = false
    var valueColor: Color = .primary
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text(label)
                .foregroundColor(.secondary)
            if isBold {
                Text(value)
                    .bold()
                    .foregroundColor(valueColor)
            } else {
                Text(value)
                    .foregroundColor(valueColor)
            }
        }
        .font(.subheadline)
    }
}


//struct OrderDetailView_Previews: PreviewProvider {
//    static let sampleOrder = OrderModel(
//        orderNumber: "#1097",
//        itemCount: 1,
//        address: "Ring Road, Ismaila",
//        amountPaid: 24.00,
//        currency: "USD",
//        date: Date(),
//        items: [
//            OrderItem(
//                name: "Bix Bag Limited Edition 229",
//                color: "Brown",
//                quantity: 1,
//                price: 24.00,
//                status: "On Progress",
//                imageName: "bag1"
//            ),
//            
//            OrderItem(
//                name: "Bix Bag Limited Edition 229",
//                color: "Brown",
//                quantity: 1,
//                price: 24.00,
//                status: "Shipped",
//                imageName: "bag1"
//            ),
//            
//            OrderItem(
//                name: "Bix Bag Limited Edition 229",
//                color: "Brown",
//                quantity: 1,
//                price: 24.00,
//                status: "Delivered",
//                imageName: "bag1"
//            )
//        ]
//    )
//    
//    static var previews: some View {
//        NavigationStack {
//            OrderDetailView(order: sampleOrder)
//        }
//    }
//}
