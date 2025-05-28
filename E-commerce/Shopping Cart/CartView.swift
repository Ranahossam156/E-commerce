//
//  CartView.swift
//  E-commerce
//
//  Created by Kerolos on 26/05/2025.
//

import Foundation
import SwiftUI
import Kingfisher

struct CartView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = CartViewModel()
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            // Main content
            VStack(spacing: 0) {
                // Header with navigation
                CartHeaderView(dismissAction: {
                    presentationMode.wrappedValue.dismiss()
                })
                
                if viewModel.cartItems.isEmpty {
                    Spacer()
                    EmptyCartView()
                    Spacer()
                } else {
                    // Cart items list
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(viewModel.cartItems) { item in
                                CartItemRow(
                                    item: item,
                                    updateQuantity: { quantity in
                                        viewModel.updateQuantity(for: item, quantity: quantity)
                                    },
                                    removeItem: {
                                        viewModel.removeFromCart(variantId: item.selectedVariant.id)
                                    }
                                )
                                .padding(.vertical, 10)
                                
                                if item.id != viewModel.cartItems.last?.id {
                                    Divider()
                                        .padding(.leading, 80)
                                }
                            }
                            
                            // Add padding at bottom to prevent content from hiding behind footer
                            Color.clear
                                .frame(height: 120) // Height of footer approximately
                        }
                        .padding(.horizontal)
                    }
                }
            }
            
            // Footer pinned to bottom
            if !viewModel.cartItems.isEmpty {
                VStack {
                    Spacer()
                    
                    VStack(spacing: 0) {
                        Divider()
                        
                        CartFooterView(
                            total: viewModel.total,
                            checkoutAction: {
                                // Navigate to checkout
                            }
                        )
                    }
                    .background(Color(.systemBackground))
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView()
    }
}
