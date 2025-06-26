import SwiftUI
import Kingfisher

struct BrandsSectionView: View {
    @State private var brands: [Brand] = []
    let viewModel = BrandViewModel()

    let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 🔹 Title OUTSIDE the container
            Text("Popular Brands")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.primary)
                .padding(.horizontal)
                .padding(.top, 24)

            // 🔹 Grey container for grid only
            VStack {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(brands) { brand in
                        NavigationLink(destination: BrandProductsView(vendor: brand.title ?? "")) {
                            BrandCardView(brand: brand)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 24)
            }
            .background(Color(UIColor.systemGray5).opacity(0.3))
            .cornerRadius(24)
            .padding(.horizontal)
            
        }
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
