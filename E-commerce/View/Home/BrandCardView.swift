import SwiftUI
import Kingfisher

struct BrandCardView: View {
    let brand: Brand

    var body: some View {
        VStack(spacing: 12) {
            // Logo container
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)

                if let url = URL(string: brand.image?.src ?? "") {
                    KFImage(url)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60) // Increased logo size
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.gray)
                }
            }
            .frame(width: 90, height: 90) // Increased box size

            // Brand name
            Text(brand.title?.capitalized ?? "")
                .font(.system(size: 14, weight: .semibold)) // Slightly larger
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }
}
