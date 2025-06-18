import SwiftUI
import Kingfisher

struct BrandsSectionView: View {
    @State private var brands: [Brand] = []
    let viewModel = BrandViewModel()

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Popular Brands")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color("black"))

            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(brands) { brand in
                        NavigationLink(destination: BrandProductsView(vendor: brand.title ?? "")) {
                            BrandCardView(brand: brand)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 32) 
        .onAppear {
            getBrands()
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
