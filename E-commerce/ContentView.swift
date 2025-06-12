import SwiftUI

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var currencyService: CurrencyService
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some View {
        NavigationStack {
            if authViewModel.isAuthenticated {
                MainTabView()

            } else {
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



