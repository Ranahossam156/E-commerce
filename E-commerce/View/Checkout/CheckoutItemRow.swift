//
//  CheckoutItemRow.swift
//  E-commerce
//
//  Created by Kerolos on 26/05/2025.
//

import Kingfisher
import SwiftUI

struct CheckoutItemRow: View {
    let item: CartItem
    let updateQuantity: (Int) -> Void
    let currencyService: CurrencyService

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            KFImage(URL(string: item.product.image.src))
                .resizable()
                .placeholder {
                    ProgressView()
                        .frame(width: 100, height: 100)
                }
                .onFailure { _ in
                    Image("xmark.circle.fill")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipped()
                        .cornerRadius(12)
                }
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100)
                .cornerRadius(12)
                .clipped()

            VStack(alignment: .leading, spacing: 8) {
                Text(item.product.title)
                    .font(.headline)

                Text(item.product.vendor)
                    .font(.subheadline)
                    .foregroundColor(.gray)

                HStack(spacing: 16) {
                    if !item.color.isEmpty {
                        HStack {
                            Text("Color:")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                            Text(item.color)
                        }
                    }

                    if !item.size.isEmpty {
                        HStack {
                            Text("Size:")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                            Text(item.size)
                        }
                    }
                }

                HStack {
                    Text("Units:")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                    Text("\(item.quantity)")
                        .bold()

                    Spacer()

                    let originalPrice = Double(item.selectedVariant.price) ?? 0
                    let convertedPrice = currencyService.convert(price: originalPrice)
                    let symbol = currencyService.getCurrencySymbol(for: currencyService.selectedCurrency)

                    Text("\(symbol) \(String(format: "%.2f", convertedPrice))")
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
