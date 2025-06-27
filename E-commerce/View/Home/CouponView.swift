import Foundation
import SwiftUI

import SwiftUI

struct StyledCoupon: Identifiable {
    let id = UUID()
    let storeName: String
    let title: String
    let discount: String
    let code: String
    let conditions: [String]
    let expiry: String
    let barcode: String
}

struct StyledCouponCarousel: View {
    let coupons: [StyledCoupon] = [
        StyledCoupon(storeName: "THE STORE", title: "GIFT VOUCHER", discount: "100$", code: "SUMMER100", conditions: [
            "Valid on all items over $300",
            "Single use only"
        ], expiry: "VALID UNTIL DECEMBER 2025", barcode: "0000012340"),

        StyledCoupon(storeName: "GLOBE MART", title: "SPECIAL DEAL", discount: "75$", code: "GLOBE75", conditions: [
            "On electronics only",
            "Cannot be combined"
        ], expiry: "VALID UNTIL NOVEMBER 2025", barcode: "0000012341"),

        StyledCoupon(storeName: "FASHION HUB", title: "CASH COUPON", discount: "50$", code: "FASHION50", conditions: [
            "Minimum spend $200"
        ], expiry: "VALID UNTIL SEPTEMBER 2025", barcode: "0000012342"),

        StyledCoupon(storeName: "E-STORE", title: "GIFT VOUCHER", discount: "25$", code: "ESTORE25", conditions: [
            "Valid online only"
        ], expiry: "VALID UNTIL OCTOBER 2025", barcode: "0000012343"),

        StyledCoupon(storeName: "TECH WORLD", title: "GIFT VOUCHER", discount: "200$", code: "TECH200", conditions: [
            "Valid on new arrivals"
        ], expiry: "VALID UNTIL AUGUST 2025", barcode: "0000012344")
    ]

    @State private var currentPage = 0

    var body: some View {
        TabView(selection: $currentPage) {
            ForEach(coupons.indices, id: \.self) { i in
                StyledCouponCard(coupon: coupons[i])
                    .padding(.horizontal)
                    .tag(i)
            }
        }
        .frame(height: 250)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
    }
}

struct StyledCouponCard: View {
    let coupon: StyledCoupon

    var body: some View {
        HStack(spacing: 0) {
            // Left section (white)
            VStack(alignment: .leading, spacing: 12) {
                Text(coupon.storeName)
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(4)

                Text(coupon.title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.red)

                VStack(alignment: .leading, spacing: 4) {
                    Text("TERMS AND CONDITIONS")
                        .font(.caption)
                        .foregroundColor(.gray)

                    ForEach(coupon.conditions, id: \.self) { condition in
                        Text("• \(condition)")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }

                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)

            // Right section (red)
            VStack(alignment: .center, spacing: 12) {
                Text("DISCOUNT OFF")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))

                Text(coupon.discount)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                Text(coupon.expiry)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))

                HStack(spacing: 4) {
                    Text(coupon.barcode)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                    Image(systemName: "barcode")
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding()
            .frame(width: 150)
            .background(Color.red)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    StyledCouponCarousel()
}
