import SwiftUI
import FirebaseAuth

struct CustomHeaderView: View {
    @EnvironmentObject var userModel: UserModel
    @ObservedObject var cartModel = CartViewModel.shared
    @State private var hasLoadedData = false // Prevent multiple Task invocations
    
    var body: some View {
        if userModel.isLoading && userModel.name.isEmpty {
            ProgressView()
                .padding()
                .background(Color.white)
        } else {
            HStack {
                // MARK: - User Info
                HStack(spacing: 12) {
                    Image("user_avatar")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Hi, \(userModel.name.isEmpty ? "User" : userModel.name)")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                        
                        Text("Let's go shopping")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                // MARK: - Action Icons
                HStack(spacing: 8) {
                    NavigationLink(destination: SearchScreen().navigationBarBackButtonHidden().environmentObject(FavoritesViewModel())) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 20))
                            .foregroundColor(.black)
                    }
                    
                    NavigationLink(destination: CartView()) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "cart")
                                .font(.system(size: 20))
                                .foregroundColor(.black)
                            
                            if(!cartModel.cartItems.isEmpty){
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 10, height: 10)
                                    .offset(x: 6, y: -6)
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color.white)
            .onAppear {
                if !hasLoadedData && userModel.name.isEmpty && Auth.auth().currentUser != nil {
                    print("CustomHeaderView: Triggering loadUserDataFromFirebase")
                    Task {
                        do {
                            try await userModel.loadUserDataFromFirebase()
                            print("CustomHeaderView: loadUserDataFromFirebase completed")
                            if userModel.name.isEmpty, let email = Auth.auth().currentUser?.email {
                                userModel.name = email.components(separatedBy: "@").first ?? ""
                                print("Setting username to email prefix: \(userModel.name)")
                                userModel.saveUserData()
                                print("Username saved to userModel")
                            }
                            await MainActor.run {
                                hasLoadedData = true
                            }
                        } catch {
                            print("CustomHeaderView: Failed to load user data: \(error.localizedDescription)")
                            await MainActor.run {
                                hasLoadedData = true
                            }
                        }
                    }
                } else {
                    print("CustomHeaderView: Skipping load (hasLoadedData: \(hasLoadedData), name: \(userModel.name), isAuthenticated: \(Auth.auth().currentUser != nil))")
                }
            }
        }
    }
}

struct CustomHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        CustomHeaderView()
            .environmentObject(UserModel())
    }
}
