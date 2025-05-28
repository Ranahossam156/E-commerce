//
//  ContentView.swift
//  E-commerce
//
//  Created by Macos on 25/05/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationView {
                HomeView()
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            
            NavigationView {
                //CategoriesView()
            }
            .tabItem {
                Label("Categories", systemImage: "square.grid.2x2")
            }
            
            NavigationView {
               // ProfileView()
            }
            .tabItem {
                Label("Me", systemImage: "person")
            }
        }
    }
}


// dummy homeView
struct HomeView: View {
    @State private var showCart = false
    
    var body: some View {
        VStack {
            Text("Home Content")
        }
        .navigationTitle("Home")
        .navigationBarItems(trailing:
            NavigationLink(destination: CartView()) {
                Image(systemName: "cart")
            }
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
