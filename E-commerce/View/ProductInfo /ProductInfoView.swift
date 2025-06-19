import SwiftUI
import Kingfisher
import FirebaseAuth
struct ProductInfoView: View {

    @Environment(\.presentationMode) var presentationMode
    @State private var isFavorited = false
    @State private var localImagesData: [Data]? = nil
    @State private var isOfflineMode = false
    @State private var imageLoadTrigger = false

    @State private var quantity = 1
    @State private var selectedColorName: String? = nil
    @State private var selectedSize: String? = nil
    @StateObject private var viewModel = ProductDetailsViewModel()
    @State private var selectedImageIndex = 0

    @State private var showAddedToCartAlert = false
    @State private var showSelectOptionsAlert = false
    @State private var navigateToCart = false

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
                                if isOfflineMode, let localImagesData = localImagesData {
                                    ForEach(Array(localImagesData.enumerated()), id: \.offset) { index, imageData in
                                        if let uiImage = UIImage(data: imageData) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .tag(index)
                                                .frame(maxWidth: .infinity)
                                                .clipped()
                                        }
                                    }
                                } else {
                                    ForEach(Array(product.images.enumerated()), id: \.element.id) { index, image in
                                        if let url = URL(string: image.src) {
                                            KFImage(url)
                                                .placeholder { ProgressView() }
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .tag(index)
                                                .frame(maxWidth: .infinity)
                                                .clipped()
                                        }
                                    }
                                }
                            }
                            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                            .frame(height: 350)
                        }

                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text(product.title).font(.title3.bold())
                                Spacer()
                                HStack(spacing: 20) {
                                    Button(action: { if quantity > 1 { quantity -= 1 } }) {
                                        Image(systemName: "minus")
                                            .font(.system(size: 24))
                                            .frame(width: 30, height: 30)
                                            .background(Color.white)
                                            .clipShape(Circle())
                                            .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 1)
                                    }
                                    Text("\(quantity)")
                                        .font(.headline)
                                    Button(action: { quantity += 1 }) {
                                        Image(systemName: "plus")
                                            .font(.system(size: 24))
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
                                Text("\(product.vendor)")
                                    .foregroundColor(.gray)
                                    .font(.subheadline)
                                Spacer()
                                Text("Available in stock")
                                    .font(.subheadline)
                            }

                            if !colorOptions.isEmpty {
                                VStack(alignment: .leading) {
                                    Text("Available Colors").font(.headline)
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack {
                                            ForEach(colorOptions, id: \.self) { color in
                                                Circle()
                                                    .fill(Color.from(name: color))
                                                    .frame(width: 30, height: 30)
                                                    .overlay(
                                                        Circle()
                                                            .stroke(selectedColorName == color ? Color("primaryColor") : .clear, lineWidth: 3)
                                                    )
                                                    .shadow(color: .black.opacity(0.6), radius: 2, x: 0, y: 1)
                                                    .onTapGesture {
                                                        selectedColorName = color
                                                    }
                                            }
                                        }
                                    }
                                }
                            }

                            VStack(alignment: .leading) {
                                Text("Description").font(.headline)
                                Text(product.bodyHTML.isEmpty ? "No description available." : product.bodyHTML)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }

                            if !sizeOptions.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Available Sizes")
                                        .font(.headline)
                                        .padding(.horizontal)
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            ForEach(sizeOptions, id: \.self) { size in
                                                Text(size)
                                                    .font(.system(size: 16, weight: .medium))
                                                    .padding(.vertical, 8)
                                                    .padding(.horizontal, 16)
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .fill(selectedSize == size
                                                                  ? Color("primaryColor")
                                                                  : Color.gray.opacity(0.2))
                                                    )
                                                    .foregroundColor(selectedSize == size ? .white : .black)
                                                    .onTapGesture { selectedSize = size }
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                                .padding(.bottom, 16)
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

                VStack {
                    Divider()
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
                            guard let product = viewModel.singleProductResponse?.product else { return }

                            if !sizeOptions.isEmpty && selectedSize == nil {
                                showSelectOptionsAlert = true
                                return
                            }

                            if !colorOptions.isEmpty && selectedColorName == nil {
                                showSelectOptionsAlert = true
                                return
                            }

                            let variant: Variant = findMatchingVariant(product: product) ?? product.variants.first!
                            CartViewModel.shared.addToCart(product: product, variant: variant, quantity: quantity)
                            showAddedToCartAlert = true
                            quantity = 1
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
                    .padding()
                    .background(Color.white.ignoresSafeArea(edges: .bottom))
                }
            } else {
                ProgressView("Loading...")
            }
        }
        .alert("Select Options", isPresented: $showSelectOptionsAlert) {
            Button("OK"){}
        } message: {
            Text("Please select all available options before adding to cart.")
        }
        .alert("Added to Cart!", isPresented: $showAddedToCartAlert) {
            Button("Continue Shopping") {
                presentationMode.wrappedValue.dismiss()
            }
            Button("View Cart") {
                navigateToCart = true
            }
        } message: {
            Text("\(quantity) × \(viewModel.singleProductResponse?.product.title ?? "Item") added to cart")
        }
        .background(
            NavigationLink(destination: CartView(), isActive: $navigateToCart) {
                EmptyView()
            }
        )
       // .toolbar(.hidden, for: .tabBar)
        .onAppear {
            setupInitialState()
            setupPageControlAppearance()

        }
        .safeAreaInset(edge: .top) {
          Color.clear.frame(height: 0)
        }        .background(Color.white)
        .navigationTitle("Product Details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { presentationMode.wrappedValue.dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { toggleFavorite() } label: {
                    Image(systemName: isFavorited ? "heart.fill" : "heart")
                        .foregroundColor(isFavorited ? .red : .black)
                }
            }
        }
    }

    private func toggleFavorite() {
        guard let product = viewModel.singleProductResponse?.product else { return }
        let productId = Int64(product.id)

        if isFavorited {
            FavoriteManager.shared.removeFromFavorites(id: productId)
            isFavorited = false
        } else {
            let sizes = sizeOptions
            let colors = colorOptions
            let imageURLs = product.images.map { $0.src }

            let model = FavoriteProductModel(
                id: productId,
                title: product.title,
                bodyHTML: product.bodyHTML,
                price: product.variants.first?.price ?? "0.00",
                colors: colors,
                sizes: sizes,
                imageURLs: imageURLs
            )
            Task {
              await FavoriteManager.shared.addToFavorites(product: model)
              guard let userId = Auth.auth().currentUser?.uid else { return }
              do {
                try await FirestoreService.shared.uploadFavorites([model], for: userId)
                print(" Uploaded new favorite to Firestore")
              } catch {
                print("Failed to upload favorite:", error)
              }
              isFavorited = true
              //NotificationCenter.default.post(name: .favoritesChanged, object: nil)
            }

        }
            //   NotificationCenter.default.post(name: .favoritesChanged, object: nil)

    }

    private func setupInitialState() {
        isFavorited = FavoriteManager.shared.isFavorited(id: Int64(productID))
        if NetworkMonitor.shared.isConnected {
            isOfflineMode = false
            viewModel.getProductByID(productID: productID)
        } else {
            isOfflineMode = true
            if let savedProduct = FavoriteManager.shared.getFavoriteById(id: Int64(productID)) {
                self.localImagesData = savedProduct.imagesData
                let product = savedProduct.toProduct()
                DispatchQueue.main.async {
                    viewModel.singleProductResponse = SingleProductResponse(product: product)
                    imageLoadTrigger.toggle()
                }
            } else {
                DispatchQueue.main.async {
                    viewModel.singleProductResponse = nil
                }
            }
        }
    }

    private func findMatchingVariant(product: Product) -> Variant? {
        return product.variants.first { variant in
            var matches = true
            if let size = selectedSize {
                matches = matches && (variant.option1 == size || variant.option2 == size || variant.option3 == size)
            }
            if let color = selectedColorName {
                matches = matches && (variant.option1 == color || variant.option2 == color || variant.option3 == color)
            }
            return matches
        }
    }
}

struct ProductInfo_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
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
private func setupPageControlAppearance() {
    UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.darkGray
    UIPageControl.appearance().pageIndicatorTintColor = UIColor.lightGray
}
