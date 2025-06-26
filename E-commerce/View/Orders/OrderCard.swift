import SwiftUI

struct OrderCard: View {
    var order: OrderModel
    @EnvironmentObject var currencyService: CurrencyService

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Order Number
            HStack {
                Text("Order No:")
                    .foregroundColor(.secondary)
                Text("\(order.orderNumber)")
                    .bold()
            }
            .font(.subheadline)

            // Item Count
            HStack {
                Text("No of items:")
                    .foregroundColor(.secondary)
                Text("\(order.lineItems?.reduce(0) { $0 + $1.quantity } ?? 0)")
                    .bold()
            }
            .font(.subheadline)

            // Date
            HStack {
                Text("Date:")
                    .foregroundColor(.secondary)
                Text(formattedDate(from: order.createdAt))
            }
            .font(.subheadline)

            // Money Paid
            HStack {
                Text("Money Paid:")
                    .foregroundColor(.secondary)
                Text(formattedAmount())
                    .bold()
                    .foregroundColor(.green)
            }
            .font(.subheadline)
        }
        .padding(.vertical, 12)
    }

    private func formattedDate(from date: Date?) -> String {
        guard let date = date else { return "N/A" }

        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy 'at' h:mm a" 
        return formatter.string(from: date)
    }


    private func formattedAmount() -> String {
        guard let raw = order.totalPrice, let amount = Double(raw) else {
            return "N/A"
        }
        let symbol = currencyService.getCurrencySymbol(for: currencyService.selectedCurrency)
        let converted = currencyService.convert(price: amount)
        return "\(symbol) \(String(format: "%.2f", converted))"
    }
}
