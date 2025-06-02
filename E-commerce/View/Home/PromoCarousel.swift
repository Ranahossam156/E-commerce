//
//  PromoCarousel.swift
//  E-commerce
//
//  Created by MacBook on 29/05/2025.
//


import SwiftUI

struct PromoCarousel: View {
    
    @ObservedObject var viewModel: CouponViewModel
    @State private var currentIndex = 0
    @State private var showCopiedAlert = false
    @State private var copiedCode = ""
    
    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            TabView(selection: $currentIndex) {
                ForEach(Array(viewModel.priceRules.prefix(3).enumerated()), id: \.element.id) { index, priceRule in
                    PromoCardView(
                        title: priceRule.title,
                        subtitle: "Tap to copy code",
                        image: "promo1"
                    )
                    .tag(index)
                    .padding(.horizontal, 16)
                    .onTapGesture {
                        let code = priceRule.couponCode
                        UIPasteboard.general.string = code
                        copiedCode = code
                        showCopiedAlert = true
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 200)
            .onReceive(timer) { _ in
                if viewModel.priceRules.count > 0 {
                    withAnimation {
                        currentIndex = (currentIndex + 1) % min(viewModel.priceRules.count, 3)
                    }
                }
            }

            HStack(spacing: 8) {
                ForEach(0..<min(viewModel.priceRules.count, 3), id: \.self) { index in
                    Circle()
                        .fill(index == currentIndex ? Color("primaryColor") : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.top, 4)
        }
        .onAppear {
            viewModel.fetchPriceRules()
        }
        .alert("Copied!", isPresented: $showCopiedAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Coupon code '\(copiedCode)' has been copied!")
        }
    }
}

struct PromoCardView: View {
    let title: String
    let subtitle: String
    let image: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.systemGray6))
                .overlay(
                    HStack {
                        Spacer()
                        Image(image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 180)
                            .clipShape(RoundedCorner(radius: 16, corners: [.topRight, .bottomRight]))
                    }
                )
                .clipped()
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                        .lineLimit(2)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            .padding()
        }
        .frame(height: 180)
        .padding(.top, 16)
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

struct PromoCarousel_Previews: PreviewProvider {
    static var previews: some View {
        PromoCarousel(viewModel: CouponViewModel())
    }
}
