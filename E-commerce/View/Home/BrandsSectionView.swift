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
                HStack(spacing: 32) {
                    ForEach(brands) { brand in
                        NavigationLink(
                            destination: BrandProductsView(vendor: brand.title ?? "Nike")
                        ) {
                            GeometryReader { geo in
                                let midX = geo.frame(in: .global).midX
                                let screenMidX = UIScreen.main.bounds.width / 2
                                let distance = abs(screenMidX - midX)
                                let minScale: CGFloat = 0.9
                                let maxScale: CGFloat = 1.0
                                let scale = max(maxScale - distance / screenMidX, minScale)

                                VStack(spacing: 6) {
                                    if let url = URL(string: brand.image?.src ?? "") {
                                        ZStack {
                                            Circle()
                                                .fill(Color.white)
                                                .frame(width: 85, height: 85)
                                                .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 1)

                                            KFImage(url)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 72, height: 72)
                                                .clipShape(Circle())
                                        }
                                        .frame(width: 95, height: 95)
                                    }

                                    Text(brand.title ?? "")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(Color("black"))
                                        .multilineTextAlignment(.center)
                                        .frame(width: 90)
   
                                }
                                .frame(width: 85, height: 140)
                                .scaleEffect(scale)
                            }
                            .frame(width: 85, height: 140)
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
