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
