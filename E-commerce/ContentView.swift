import SwiftUI

import SwiftUI
import Firebase

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var currencyService: CurrencyService
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some View {
            if authViewModel.isAuthenticated {
                MainTabView() .task {
                    guard let userId = Auth.auth().currentUser?.uid else {
                        print("User logged in but no UID found.")
                        return
                    }
                    await FavoriteManager.shared.syncFavoritesFromFirestore(for: userId)
                }

            } else {
                NavigationStack{
                    SignupScreen().environmentObject(authViewModel)
                }

            }
        
    }
}
////
////  ContentView.swift
////  E-commerce
////
////  Created by Macos on 25/05/2025.
////
//
//import SwiftUI
//
//struct ContentView: View {
//    var body: some View {
//       /* TabView {
//            NavigationView {
//                HomeView()
//            }
//            .tabItem {
//                Label("Home", systemImage: "house")
//            }
//
//            NavigationView {
//                //CategoriesView()
//            }
//            .tabItem {
//                Label("Categories", systemImage: "square.grid.2x2")
//            }
//
//            NavigationView {
//               // ProfileView()
//            }
//            .tabItem {
//                Label("Me", systemImage: "person")
//            }
//        }*/
//        CartView()
//
//    }
//}
//
//
//// dummy homeView
//struct HomeView: View {
//    @State private var showCart = false
//
//    var body: some View {
//        VStack {
//            Text("Home Content")
//        }
//        .navigationTitle("Home")
//        .navigationBarItems(trailing:
//            NavigationLink(destination: CartView()) {
//                Image(systemName: "cart")
//            }
//        )
//    }
//}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
//
//  ContentView.swift
//  E-commerce
//
//  Created by Macos on 25/05/2025.
//



