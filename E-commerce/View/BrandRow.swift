//
//  BrandRow.swift
//  ShopifyDemo
//
//  Created by MacBook on 26/05/2025.
//

import SwiftUI
import Kingfisher

struct BrandRow: View {
    let brand: Brand
    var body: some View {
        HStack {

            if let url = URL(string: brand.image?.src ?? "") {
                KFImage(url)
                    .placeholder {
                        ProgressView()
                    }
                    .resizable()
                    .onFailure{ error in
                        print("Failed to load image:\(error.localizedDescription)")
                    }
                    .frame(width: 100, height: 100)
            }
//            
            
//            AsyncImage(url: URL(string: brand.image?.src ?? "")) { phase in
//                switch phase {
//                case .empty:
//                    ProgressView()
//                case .success(let image):
//                    image.resizable()
//                case .failure(_):
//                    Image(systemName: "xmark.circle.fill")
//                        .foregroundColor(.red)
//                @unknown default:
//                    EmptyView()
//                }
//            }
//         placeholder: {
//            ProgressView()
//        }
        
        
//                    .frame(width: 100, height: 100)
        //            .clipShape(Circle())
        
        VStack(alignment: .leading) {
            Text(brand.title ?? "title")
                .font(.headline)
            
            Text(brand.handle ?? "handle")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        
        Spacer()
    }.padding()
}
}

#Preview {
    BrandRow(brand: Brand(id: 1, handle: "adidas", title: "Adidas"))
}
