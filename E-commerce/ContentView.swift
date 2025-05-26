//
//  ContentView.swift
//  E-commerce
//
//  Created by Macos on 25/05/2025.
//

import SwiftUI

import SwiftUI

struct ContentView: View {
    var body: some View {
        CartView()
        TabView {
            NavigationView {
                //HomeView()
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
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
