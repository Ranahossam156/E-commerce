import SwiftUI
import Kingfisher

struct CartItemRow: View {
    let item: CartItem
    let updateQuantity: (Int) -> Void
    let removeItem: () -> Void
    @EnvironmentObject var currencyService: CurrencyService
    
    var body: some View {
        HStack(spacing: 12) {
            // Product image
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 70, height: 70)
                
                KFImage(URL(string: item.product.image.src))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 70, height: 70)
                    .clipped()
                    .cornerRadius(8)
            }
            
            // Product details
            VStack(alignment: .leading, spacing: 4) {
                Text(item.product.title)
                    .font(.system(size: 14, weight: .medium))
                    .lineLimit(1)
                
                // Show variant details (size/color)
                HStack(spacing: 8) {
                    if !item.size.isEmpty {
                        Text("Size: \(item.size)")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    
                    if !item.color.isEmpty && item.color != item.size {
                        Text("Color: \(item.color)")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
                
                // Quantity controls
                HStack(spacing: 15) {
                    Button(action: {
                        if item.quantity > 1 {
                            updateQuantity(item.quantity - 1)
                        }
                    }) {
                        Image(systemName: "minus")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.black)
                            .frame(width: 22, height: 22)
                            .background(Color.gray.opacity(0.15))
                            .cornerRadius(11)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Text("\(item.quantity)")
                        .font(.system(size: 14, weight: .medium))
                    
                    Button(action: {
                        updateQuantity(item.quantity + 1)
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.black)
                            .frame(width: 22, height: 22)
                            .background(Color.gray.opacity(0.15))
                            .cornerRadius(11)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(item.quantity >= item.selectedVariant.inventoryQuantity)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                // Price
                let convertedPrice = currencyService.convert(price: Double(item.selectedVariant.price) ?? 0.0)
                let symbolCurrency = currencyService.getCurrencySymbol(for: currencyService.selectedCurrency)
                
                Text("\(symbolCurrency) \(String(format: "%.2f", convertedPrice))")
                    .font(.system(size: 16, weight: .semibold))
                
                // Delete button
                Button(action: removeItem) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.red)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}
