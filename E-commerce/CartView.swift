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
            Color(.systemBackground)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header with navigation
                CartHeaderView(dismissAction: {
                    presentationMode.wrappedValue.dismiss()
                })
                
                if viewModel.cartItems.isEmpty {
                    EmptyCartView()
                } else {
                    // Cart items list
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(viewModel.cartItems) { item in
                                CartItemRow(
                                    item: item,
                                    isSelected: viewModel.isItemSelected(itemId: item.id),
                                    toggleSelection: {
                                        viewModel.toggleItemSelection(itemId: item.id)
                                    },
                                    updateQuantity: { quantity in
                                        viewModel.updateQuantity(for: item, quantity: quantity)
                                    }
                                )
                                .padding(.vertical, 10)
                                
                                if item.id != viewModel.cartItems.last?.id {
                                    Divider()
                                        .padding(.leading, 100)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Bottom area with total and checkout button
                    CartFooterView(
                        total: viewModel.total,
                        checkoutAction: {
                            // Navigate to checkout
                        }
                    )
                }
            }
        }
        .navigationBarHidden(true)
    }
}


