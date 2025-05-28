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
    
    @State private var showDeleteAlert = false
    @State private var itemToDelete: CartItem?
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                CartHeaderView(dismissAction: {
                    presentationMode.wrappedValue.dismiss()
                })
                
                if viewModel.cartItems.isEmpty {
                    Spacer()
                    EmptyCartView()
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(viewModel.cartItems) { item in
                                CartItemRow(
                                    item: item,
                                    updateQuantity: { quantity in
                                        viewModel.updateQuantity(for: item, quantity: quantity)
                                    },
                                    removeItem: {
                                        itemToDelete = item
                                        showDeleteAlert = true
                                    }
                                )
                                .padding(.vertical, 10)
                                
                                if item.id != viewModel.cartItems.last?.id {
                                    Divider()
                                        .padding(.leading, 80)
                                }
                            }
                            
                           
                            Color.clear
                                .frame(height: 120) // Height of footer
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
        .alert("Remove Item", isPresented: $showDeleteAlert, actions: {
            Button("Cancel",role: .cancel) {}
            Button("Remove",role:.destructive){
                if let item = itemToDelete {
                    viewModel.removeFromCart(variantId: item.selectedVariant.id)
                }
            }
        }, message: {
            Text("Are you sure you want to remove \(itemToDelete?.product.title ?? "this item") from your cart?")

        })
    }
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView()
    }
}
