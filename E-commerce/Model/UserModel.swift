// UserModel.swift
// E-commerce
// Created by Kerolos on 03/06/2025. (Last updated: 06:50 PM EEST, June 18, 2025)

import Foundation
import FirebaseAuth
import FirebaseFirestore

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
    
    init() {
        // Do not call loadUserDataFromFirebase() here to avoid blocking
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
            if document.exists {
                if let data = document.data() {
                    print("Data fetched, processing...")
                    DispatchQueue.main.async { [weak self] in
                        self?.name = data["name"] as? String ?? ""
                        self?.email = data["email"] as? String ?? ""
                        self?.phoneNumber = data["phoneNumber"] as? String ?? ""
                        self?.defaultAddressId = data["defaultAddressId"] as? String
                        
                        if let addressesData = data["addresses"] as? [[String: String]] {
                            self?.addresses = addressesData.compactMap { dict in
                                guard let id = dict["id"], let addressText = dict["addressText"] else { return nil }
                                return Address(id: id, addressText: addressText)
                            }
                        }
                        print("User data loaded: \(self?.name ?? ""), \(self?.email ?? "")")
                    }
                }
            } else {
                print("No user data found, initializing with defaults")
            }
        } catch {
            print("Error loading user data: \(error.localizedDescription)")
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
            if let error = error {
                print("Error saving user data: \(error.localizedDescription)")
            } else {
                print("User data saved successfully: \(userData)")
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
        addresses.removeAll { $0.id == id }
        
        if defaultAddressId == id {
            defaultAddressId = addresses.first?.id
        }
        saveUserData()
    }
    
    func setDefaultAddress(id: String) {
        if addresses.contains(where: { $0.id == id }) {
            defaultAddressId = id
            saveUserData()
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
