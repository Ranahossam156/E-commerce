import SwiftUI
import Kingfisher

struct FavoriteItemView: View {
    let productModel: FavoriteProductModel
    let onRemove: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                if let firstURL = productModel.imageURLs.first,
                   let url = URL(string: firstURL) {
                    KFImage(url)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(16)
                        .frame(height: 120)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .cornerRadius(16)
                        .frame(height: 120)
                }

//                Button(action: onRemove) {
//                    Image(systemName: "heart.fill")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 16, height: 16)
//                        .padding(10)
//                        .background(Color.white)
//                        .clipShape(Circle())
//                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
//                        .foregroundColor(.red)
//                }
//                .padding([.top, .trailing], 8)
            }

            Text(productModel.title)
                .font(.subheadline.bold())
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .center)

            Text(productModel.bodyHTML)
                .font(.caption)
                .foregroundColor(.gray)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .center)

            Text("$\(productModel.price)")
                .font(.subheadline.bold())
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.gray.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
