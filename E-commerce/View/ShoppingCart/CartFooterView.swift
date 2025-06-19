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
    @EnvironmentObject var currencyService: CurrencyService
   
    
    var body: some View {
        VStack(spacing: 15) {
            Divider()
            
            HStack {
                Text("Total:")
                    .font(.system(size: 18, weight: .semibold))
                
                Spacer()
            
                var currSympol = currencyService.getCurrencySymbol(for: currencyService.selectedCurrency)
                
                Text("\(currSympol) \(String(format: "%.2f", total))")
                    .font(.system(size: 18, weight: .bold))
            }
            .padding(.horizontal)
            .padding(.top, 15) // Add top padding after divider
            
            
            Button(action: checkoutAction) {
                Text("Checkout")
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .background(Color("primary"))
            .clipShape(Capsule())
            .padding(.horizontal)
        }
    }
}

struct cartFooter_Previews: PreviewProvider {
    static var previews: some View {
        CartFooterView(total: 10, checkoutAction: {print("")})
    }
}

