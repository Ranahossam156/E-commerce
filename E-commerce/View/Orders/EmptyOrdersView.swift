//
//  EmptyOrdersView.swift
//  E-commerce
//
//  Created by MacBook on 21/06/2025.
//

import SwiftUI

struct EmptyOrdersView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "shippingbox")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Orders Yet")
                .font(.title2)
            
            Text("You haven't placed any orders yet. Once you make a purchase, you'll see your orders here.")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
}



