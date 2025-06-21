//
//  OrdersView.swift
//  E-commerce
//
//  Created by MacBook on 10/06/2025.
//

import SwiftUI
import FirebaseAuth

struct OrdersView: View {
    @EnvironmentObject var ordersViewModel: OrderViewModel

    var body: some View {
        NavigationView {
            Group {
                if ordersViewModel.isLoading {
                    ProgressView("Loading Orders...")
                } else if ordersViewModel.userOrders.isEmpty {
                    EmptyOrdersView()
                } else {
                    List(ordersViewModel.userOrders) { order in
                        NavigationLink(destination: OrderDetailView(order: order)) {
                            OrderCard(order: order)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Orders")
        }
        .onAppear {
            if let email = Auth.auth().currentUser?.email {
                ordersViewModel.fetchOrders(forEmail: email)
            }
        }
    }
}


struct OrdersView_Previews: PreviewProvider {
    static var previews: some View {
        OrdersView()
    }
}

