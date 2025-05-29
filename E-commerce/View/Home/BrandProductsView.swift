//
//  BrandProductsView.swift
//  E-commerce
//
//  Created by MacBook on 29/05/2025.
//

import SwiftUI

struct BrandProductsView: View {
    let brand: String?

    var body: some View {
       Text("Products View for \(brand ?? "Unknown Brand")")
        
    }
}

struct BrandProductsView_Previews: PreviewProvider {
    static var previews: some View {
        BrandProductsView(brand: "ADIDAS")
    }
}
