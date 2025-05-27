//
//  CartFooterView.swift
//  E-commerce
//
//  Created by Kerolos on 26/05/2025.
//

import Foundation


import SwiftUI

struct CartFooterView: View {
    let total: Double
    let checkoutAction: () -> Void
    
    var body: some View {
        VStack(spacing: 15) {
            Divider()
            
            HStack {
                Text("Total:")
                    .font(.system(size: 18, weight: .semibold))
                
                Spacer()
                
                Text("$\(String(format: "%.2f", total))")
                    .font(.system(size: 18, weight: .bold))
            }
            .padding(.horizontal)
            
            Button(action: checkoutAction) {
                Text("Checkout")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .background(Color.white)
    }
}
