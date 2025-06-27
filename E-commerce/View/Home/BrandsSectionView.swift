import SwiftUI
import Kingfisher

struct BrandsSectionView: View {
    @State private var brands: [Brand] = []
    @State private var isLoading = true
    let viewModel = BrandViewModel()

    let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Popular Brands")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.primary)
                .padding(.horizontal)
                .padding(.top, 24)

            VStack {
                LazyVGrid(columns: columns, spacing: 20) {
                    if isLoading {
                        ForEach(0..<6) { _ in
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 100)
                                .shimmer()
                        }
                    } else {
                        ForEach(brands) { brand in
                            NavigationLink(destination: BrandProductsView(vendor: brand.title ?? "").navigationBarBackButtonHidden()) {
                                BrandCardView(brand: brand)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 24)
            }
            .background(Color(UIColor.systemGray5).opacity(0.2))
            .cornerRadius(24)
            .padding(.horizontal)
        }
        .onAppear {
            getBrands()
        }
    }

    func getBrands() {
        isLoading = true
        viewModel.getBrands { result, error in
            if let error = error {
                print("Error fetching brands: \(error.localizedDescription)")
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.isLoading = false
                if let result = result {
                    self.brands = result.smartCollections ?? []
                }
            }
        }
    }
}
