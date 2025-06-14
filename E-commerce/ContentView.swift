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

import SwiftUI

struct ContentView: View {
    @StateObject private var productDetailsViewModel = ProductDetailsViewModel()
    var body: some View {
        NavigationStack {
            SignupScreen()
        }
        VStack {
 
        }.onAppear{
           // productDetailsViewModel.getDataFromModel(productID: 9712148218153)
          //  productDetailsViewModel.bindResultToViewController
           // productDetailsViewModel.getProductByID(productID: 9712148218153)
            productDetailsViewModel.getProductImages(productID: 9712148218153)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
