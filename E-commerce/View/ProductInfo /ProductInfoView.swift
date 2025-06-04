//
//  ProductInfo.swift
//  E-commerce
//
//  Created by Macos on 03/06/2025.
//

import SwiftUI
import Kingfisher


struct ProductInfoView: View {

    @Environment(\.presentationMode) var presentationMode
    @State private var quantity = 1
    @State private var selectedColorName: String? = nil
    @State private var selectedSize: String? = nil
    @StateObject private var viewModel = ProductDetailsViewModel()
    @State private var selectedImageIndex = 0

    let productID: Int

    var sizeOptions: [String] {
        viewModel.singleProductResponse?.product.options.first(where: { $0.name.lowercased() == "size" })?.values ?? []
    }

    var colorOptions: [String] {
        viewModel.singleProductResponse?.product.options.first(where: { $0.name.lowercased() == "color" })?.values ?? []
    }

    var body: some View {
        VStack(spacing: 0) {
            if let product = viewModel.singleProductResponse?.product {
                ScrollView {
                    VStack(spacing: 0) {
                        ZStack(alignment: .top) {
                            TabView(selection: $selectedImageIndex) {
                                ForEach(Array(product.images.enumerated()), id: \.element.id) { index, image in
                                    if let url = URL(string: image.src) {
                                        KFImage(url)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .tag(index)
                                            .frame(maxWidth: .infinity)
                                            .clipped()
                                    }
                                }
                            }
                            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                            .frame(height: 350)
                            .indexViewStyle(PageIndexViewStyle())
                        }

                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text(product.title)
                                    .font(.title3.bold())
                                Spacer()
                                HStack(spacing: 20) {
                                    Button(action: {
                                        if quantity > 1 { quantity -= 1 }
                                    }) {
                                        Image(systemName: "minus")
                                            .font(.system(size: 24))
                                            .foregroundColor(.primary)
                                            .frame(width: 30, height: 30)
                                            .background(Color.white)
                                            .clipShape(Circle())
                                            .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 1)
                                    }

                                    Text("\(quantity)")
                                        .font(.headline)
                                        .foregroundColor(.primary)

                                    Button(action: {
                                        quantity += 1
                                    }) {
                                        Image(systemName: "plus")
                                            .font(.system(size: 24))
                                            .foregroundColor(.primary)
                                            .frame(width: 30, height: 30)
                                            .background(Color.white)
                                            .clipShape(Circle())
                                            .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 1)
                                    }
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(Color.gray.opacity(0.1))
                                .clipShape(Capsule())
                            }

                            HStack {
                                Label("4.8", systemImage: "star.fill")
                                    .foregroundColor(.yellow)
                                    .font(.subheadline)
                                Text("(320 Review)")
                                    .foregroundColor(.gray)
                                    .font(.subheadline)
                                Spacer()
                                Text("Available in stock")
                                    .font(.subheadline)
                            }

                            if !colorOptions.isEmpty {
                                Text("Available Colors")
                                    .font(.headline)
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        ForEach(colorOptions, id: \.self) { color in
                                            Circle()
                                                .fill(Color.from(name: color))
                                                .frame(width: 30, height: 30)
                                                .overlay(
                                                    Circle()
                                                        .stroke(selectedColorName == color ? Color("primaryColor") : Color.clear, lineWidth: 3)
                                                )
                                                .onTapGesture {
                                                    selectedColorName = color
                                                }
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                            }


                            Text("Description")
                                .font(.headline)
                            Text(product.bodyHTML.isEmpty ? "No description available." : product.bodyHTML)
                                .font(.subheadline)
                                .foregroundColor(.gray)

                            if !sizeOptions.isEmpty {
                                Text("Available Sizes")
                                    .font(.headline)
                                HStack {
                                    ForEach(sizeOptions, id: \.self) { size in
                                        Text(size)
                                            .font(.system(size: 16, weight:.medium))
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.8)
                                            .padding(.horizontal, 10)
                                            .frame(height: 40)
                                            .background(selectedSize == size ? Color("primaryColor") : Color.gray.opacity(0.2))
                                            .foregroundColor(selectedSize == size ? .white : .black)
                                            .cornerRadius(10)
                                            .onTapGesture {
                                                selectedSize = size
                                            }
                                    }
                                }
                            }

                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color.white)
                                .shadow(color: .gray.opacity(0.2), radius: 10, x: 0, y: -5)
                        )
                    }
                }

                HStack {
                    HStack(spacing: 0) {
                        Text("$")
                            .font(.title.bold())
                            .foregroundColor(Color("primaryColor"))
                        if let priceString = product.variants.first?.price,
                           let price = Double(priceString) {
                            Text(String(format: "%.2f", price))
                                .font(.title2.weight(.bold))
                                .foregroundColor(.black)
                        }
                    }
                    Spacer()
                    Button(action: {
                    }) {
                        HStack {
                            Image(systemName: "cart")
                            Text("Add to Cart").font(.system(size: 14))
                        }
                        .padding()
                        .foregroundColor(.white)
                        .background(Color("primaryColor"))
                        .cornerRadius(30)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 20)
                .background(Color.white.ignoresSafeArea(edges: .bottom))

            } else {
                ProgressView("Loading...")
            }
        }
        .onAppear {
            UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.darkGray
            UIPageControl.appearance().pageIndicatorTintColor = UIColor.lightGray
            viewModel.getProductByID(productID: productID)
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.bottom)
        .navigationTitle("Product Details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                }) {
                    Image(systemName: "heart")
                        .foregroundColor(.black)
                }
            }
        }
    }
}

struct ProductInfo_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProductInfoView(productID: 8696738939189)
        }
    }
}
extension Color {
    static func from(name: String) -> Color {
        switch name.lowercased() {
        case "black": return .black
        case "blue": return .blue
        case "brown": return .brown
        case "cyan": return .cyan
        case "gray", "grey": return .gray
        case "green": return .green
        case "indigo": return .indigo
        case "mint": return .mint
        case "orange": return .orange
        case "pink": return .pink
        case "purple": return .purple
        case "red": return .red
        case "teal": return .teal
        case "white": return .white
        case "yellow": return .yellow
        default: return .gray.opacity(0.5)
        }
    }
}
