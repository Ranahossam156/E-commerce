import FirebaseAuth
import SwiftUI

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
                        NavigationLink(
                            destination: OrderDetailView(order: order)
                        ) {
                            OrderCard(order: order)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Orders")
        }
        .onAppear {
            if let user = Auth.auth().currentUser {
                ordersViewModel.fetchOrders(forEmail: user.email ?? "")
            }
        }
    }
}

struct OrdersView_Previews: PreviewProvider {
    static var previews: some View {
        OrdersView()
            .environmentObject(OrderViewModel())
    }
}
