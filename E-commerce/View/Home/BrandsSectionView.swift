//
//  BrandsGridView.swift
//  E-commerce
//
//  Created by MacBook on 29/05/2025.
//

import Kingfisher
import SwiftUI

struct BrandsSectionView: View {
    @State private var brands: [Brand] = []
    let viewModel = BrandViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Popular Brands")
                .font(.system(size: 24, weight: .bold, design: .default))
                .foregroundColor(Color("black"))
                .frame(height: 10)
                .padding([.leading, .top], 28)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 42) {
                    ForEach(brands) { brand in
                        NavigationLink(
                            destination: BrandProductsView(brand: brand.title)
                        ) {
                            GeometryReader { geo in
                                let midX = geo.frame(in: .global).midX
                                let screenMidX = UIScreen.main.bounds.width / 2
                                let distance = abs(screenMidX - midX)
                                let minScale: CGFloat = 0.8
                                let maxScale: CGFloat = 1.0
                                let scale = max(
                                    maxScale - distance / screenMidX,
                                    minScale
                                )

                                VStack {
                                    if let url = URL(
                                        string: brand.image?.src ?? ""
                                    ) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.white)
                                                .frame(width: 120, height: 120)
                                                .shadow(
                                                    color: Color.black.opacity(
                                                        0.2
                                                    ),
                                                    radius: 4,
                                                    x: 0,
                                                    y: 2
                                                )

                                            KFImage(url)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 100, height: 100)
                                                .clipShape(Circle())

                                        }
                                        .frame(width: 140, height: 140)
                                    }

                                    Text(brand.title ?? "")
                                        .font(.headline)
                                        .foregroundColor(Color("black"))
                                        .fontWeight(.bold)
                                        .lineLimit(nil)
                                        .fixedSize(
                                            horizontal: false,
                                            vertical: false
                                        )
                                        .frame(width: 150)
                                }
                                .frame(width: 80, height: 160)
                                .scaleEffect(scale)
                            }
                            .frame(width: 80, height: 160)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                Spacer()
            }

        }

        .onAppear {
            self.getBrands()
        }
    }

    func getBrands() {
        viewModel.getBrands { result, error in
            if let error = error {
                print("Error fetching brands: \(error.localizedDescription)")
            }

            if let result = result {
                DispatchQueue.main.async {
                    self.brands = result.smartCollections ?? []
                }
            }
        }
    }
}

struct BrandsSectionView_Previews: PreviewProvider {
    static var previews: some View {
        BrandsSectionView()
    }
}
