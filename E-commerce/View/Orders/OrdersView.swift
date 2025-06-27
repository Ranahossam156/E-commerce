import FirebaseAuth
import SwiftUI

struct OrdersView: View {
    @EnvironmentObject var ordersViewModel: OrderViewModel
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
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
            } else {
                Spacer()
                VStack(spacing: 10) {
                    Image("lock2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundColor(Color("primaryColor"))

                    Text("Please log in to view your orders.")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    NavigationLink(destination: LoginScreen()) {
                        Text("Go to Login")
                            .font(.body)
                            .fontWeight(.medium)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 15)
                            .background(Capsule().fill(Color("primaryColor")))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 10)
                }
                Spacer()
            }
        }
        .navigationTitle("Orders")
        .onAppear {
            if let user = Auth.auth().currentUser {
                ordersViewModel.fetchOrders(forEmail: user.email ?? "")
            }
        }
    }
}

struct OrdersView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OrdersView()
                .environmentObject(OrderViewModel())
                .environmentObject(AuthViewModel())
        }
    }
}
