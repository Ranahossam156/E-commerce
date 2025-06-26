import FirebaseFirestore
import FirebaseFirestoreSwift

class OrderFireStoreService {
    private let db = Firestore.firestore()

    func saveOrder(_ order: OrderModel, for userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try db.collection("orders")
                .document(userId)
                .collection("user_orders")
                .document("\(order.id)")
                .setData(from: order, merge: true) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
        } catch {
            completion(.failure(error))
        }
    }

    func loadOrders(for userId: String, completion: @escaping (Result<[OrderModel], Error>) -> Void) {
        db.collection("orders")
            .document(userId)
            .collection("user_orders")
            .order(by: "created_at", descending: true) 
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    let orders = snapshot?.documents.compactMap {
                        try? $0.data(as: OrderModel.self)
                    } ?? []
                    completion(.success(orders))
                }
            }
    }
}
