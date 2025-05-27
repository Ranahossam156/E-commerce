//
//  EmptyCartView.swift
//  E-commerce
//
//  Created by Kerolos on 26/05/2025.
//

import Foundation

import SwiftUI

struct EmptyCartView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "cart")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Your cart is empty")
                .font(.title2)
            
            Text("Looks like you haven't added anything to your cart yet.")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                // Action to go back to shopping
            }) {
                Text("Continue Shopping")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top)
            
            Spacer()
        }
        .padding()
    }
}
