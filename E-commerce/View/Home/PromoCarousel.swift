//
//  PromoCarousel.swift
//  E-commerce
//
//  Created by MacBook on 29/05/2025.
//


import SwiftUI

struct PromoCarousel: View {
    @State private var currentIndex = 0
    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    
    let promotions = [
        Promotion(title: "24% off shipping today\non bag purchases", subtitle: "By Kutuku Store", image: "promo1"),
        Promotion(title: "Buy 1 Get 1 Free", subtitle: "By Fabrix", image: "promo1"),
        Promotion(title: "New Arrivals", subtitle: "By ModeStore", image: "promo1")
    ]

    
    var body: some View {
        VStack {
            TabView(selection: $currentIndex) {
                ForEach(0..<promotions.count, id: \.self) { index in
                    PromoCardView(promo: promotions[index])
                        .tag(index)
                        .padding(.horizontal, 16)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 200)
            .onReceive(timer) { _ in
                withAnimation {
                    currentIndex = (currentIndex + 1) % promotions.count
                }
            }

            HStack(spacing: 8) {
                ForEach(0..<promotions.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentIndex ? Color("primaryColor") : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.top, 4)
        }
    }
}

struct PromoCardView: View {
    let promo : Promotion
    var body: some View {
            ZStack {
               
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.systemGray6))
                    .overlay(
                        HStack {
                            Spacer()
                            Image(promo.image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 180)
                                .clipShape(RoundedCorner(radius: 16, corners: [.topRight, .bottomRight]))
                        }
                    )
                    .clipped()


                
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(promo.title)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)

                        Text(promo.subtitle)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding()
            }
            .frame(height: 180)
            .padding(.top, 16)
//            .padding(.horizontal)
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
        PromoCarousel()
    }
}

