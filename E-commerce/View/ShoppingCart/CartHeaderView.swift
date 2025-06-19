//
//  CartHeaderView.swift
//  E-commerce
//
//  Created by Kerolos on 26/05/2025.
//

import Foundation

import SwiftUI

struct CartHeaderView: View {
    let dismissAction: () -> Void
    
    var body: some View {
        HStack {
            Button(action: dismissAction) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            Text("My Cart")
                .font(.system(size: 18, weight: .semibold))
            
            Spacer()
            
         
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color.white)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.gray.opacity(0.3)),
            alignment: .bottom
        )
    }
}
