import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

struct Address: Identifiable, Codable {
    let id: String
    var addressText: String
}

class UserModel: ObservableObject {
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var addresses: [Address] = []
    @Published var defaultAddressId: String?
    @Published var phoneNumber: String = ""
    @Published var isLoading: Bool = false
    
    private let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Initialize with Firebase Auth data if available
        if let user = Auth.auth().currentUser {
            DispatchQueue.main.async { [weak self] in
                self?.email = user.email ?? ""
                self?.name = user.displayName ?? ""
                print("Initialized UserModel with Auth data: email=\(self?.email ?? ""), name=\(self?.name ?? "")")
            }
            // Load Firestore data asynchronously
            Task {
                do {
                    try await loadUserDataFromFirebase()
                } catch {
                    print("Failed to load Firestore data on init: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func loadUserDataFromFirebase() async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No authenticated user, user data not loaded")
            return
        }
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = true
        }
        print("Fetching user data for \(userId)")
        do {
            let document = try await db.collection("users").document(userId).getDocument()
            DispatchQueue.main.async { [weak self] in
                if document.exists, let data = document.data() {
                    print("Data fetched, processing...")
                    self?.name = data["name"] as? String ?? self?.name ?? ""
                    self?.email = data["email"] as? String ?? self?.email ?? Auth.auth().currentUser?.email ?? ""
                    self?.phoneNumber = data["phoneNumber"] as? String ?? self?.phoneNumber ?? ""
                    self?.defaultAddressId = data["defaultAddressId"] as? String
                    
                    if let addressesData = data["addresses"] as? [[String: String]] {
                        self?.addresses = addressesData.compactMap { dict in
                            guard let id = dict["id"], let addressText = dict["addressText"] else { return nil }
                            return Address(id: id, addressText: addressText)
                        }
                    }
                    print("User data loaded: \(self?.name ?? ""), \(self?.email ?? "")")
                    
                    // Save to Firestore if Auth data was used as fallback
                    if data["email"] == nil || data["name"] == nil {
                        self?.saveUserData()
                    }
                } else {
                    print("No user data found, saving defaults from Auth")
                    self?.email = Auth.auth().currentUser?.email ?? self?.email ?? ""
                    self?.name = Auth.auth().currentUser?.displayName ?? self?.name ?? ""
                    self?.saveUserData()
                }
            }
        } catch {
            print("Error loading user data: \(error.localizedDescription)")
            DispatchQueue.main.async { [weak self] in
                self?.isLoading = false
            }
            throw error
        }
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false
        }
    }
    
    func saveUserData() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No authenticated user, user data not saved")
            return
        }
        let addressesData = addresses.map { ["id": $0.id, "addressText": $0.addressText] }
        let userData: [String: Any] = [
            "name": name,
            "email": email,
            "phoneNumber": phoneNumber,
            "defaultAddressId": defaultAddressId ?? "",
            "addresses": addressesData
        ]
        db.collection("users").document(userId).setData(userData) { error in
            DispatchQueue.main.async { [weak self] in
                if let error = error {
                    print("Error saving user data: \(error.localizedDescription)")
                } else {
                    print("User data saved successfully: \(userData)")
                }
            }
        }
    }
    
    func addAddress(addressText: String) {
        let newAddress = Address(id: UUID().uuidString, addressText: addressText)
        DispatchQueue.main.async { [weak self] in
            self?.addresses.append(newAddress)
            if self?.addresses.count == 1 {
                self?.defaultAddressId = newAddress.id
            }
            self?.saveUserData()
        }
    }
    
    func deleteAddress(id: String) {
        DispatchQueue.main.async { [weak self] in
            self?.addresses.removeAll { $0.id == id }
            if self?.defaultAddressId == id {
                self?.defaultAddressId = self?.addresses.first?.id
            }
            self?.saveUserData()
        }
    }
    
    func setDefaultAddress(id: String) {
        DispatchQueue.main.async { [weak self] in
            if self?.addresses.contains(where: { $0.id == id }) ?? false {
                self?.defaultAddressId = id
                self?.saveUserData()
            }
        }
    }
    
    var defaultAddress: String {
        if let defaultId = defaultAddressId,
           let address = addresses.first(where: { $0.id == defaultId }) {
            return address.addressText
        }
        return addresses.first?.addressText ?? "Not Set"
    }
}
