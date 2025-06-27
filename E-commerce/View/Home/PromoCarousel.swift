//
//  PromoCarousel.swift
//  E-commerce
//
//  Created by MacBook on 29/05/2025.
//

import SwiftUI

struct PromoCarousel: View {
    @State private var currentIndex = 0
    @State private var showCopiedAlert = false
    @State private var copiedCode = ""
    
    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    
    // Just the coupon codes you want to display
    let couponCodes = ["WELCOME10", "ORDER10", "SAVE10", "WELCOME20"]
    
    var body: some View {
        VStack {
            TabView(selection: $currentIndex) {
                ForEach(0..<couponCodes.count, id: \.self) { index in
                    let code = couponCodes[index]
                    
                    // Your existing TicketCouponView with no changes
                    TicketCouponView(
                        discountText: code,
                        headline: "Special Gift For You",
                        subheadline: "For Next Purchase",
                        description: "Use code \(code) at checkout to save instantly."
                    )
                    .tag(index)
                    .padding(.horizontal, 16)
                    .onTapGesture {
                        UIPasteboard.general.string = code
                        copiedCode = code
                        showCopiedAlert = true
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 180)
            .onReceive(timer) { _ in
                if couponCodes.count > 0 {
                    withAnimation {
                        currentIndex = (currentIndex + 1) % couponCodes.count
                    }
                }
            }

            // Your existing indicator dots
            HStack(spacing: 8) {
                ForEach(0..<couponCodes.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentIndex ? Color("primaryColor") : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.top, 4)
        }
        .alert("Copied!", isPresented: $showCopiedAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Coupon code '\(copiedCode)' has been copied!")
        }
    }
}
struct TicketCouponView: View {
    let discountText: String
    let headline: String
    let subheadline: String
    let description: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)

            HStack(spacing: 0) {
                // Red Vertical Strip
                ZStack {
                    Color("primaryColor")
                    Text("DISCOUNT\nCOUPON")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .rotationEffect(.degrees(-90))
                        .fixedSize()
                }
                .frame(width: 50)
                .cornerRadius(20, corners: [.topLeft, .bottomLeft])

                // Content Area
                VStack(spacing: 8) {
                    Text(headline.uppercased())
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.black)

                    Text(discountText)
                        .font(.system(size: 28, weight: .heavy))
                        .foregroundColor(Color("primaryColor"))

                    Text(subheadline.uppercased())
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)

                    Text(description)
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 12)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 8)
                .frame(maxWidth: .infinity)
                .background(Color.white)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .frame(height: 160)
        .padding(.top, 8)
    }
}



// MARK: - Selective Corner Radius Helper

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
