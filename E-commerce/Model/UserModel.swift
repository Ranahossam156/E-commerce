//
//  File.swift
//  E-commerce
//
//  Created by Kerolos on 03/06/2025.
//

import Foundation
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
    
    private let addressesKey = "userAddresses"
    private let defaultAddressIdKey = "defaultAddressId"
    
    init() {
        loadUserData()
    }
    
    func loadUserData() {
        name = UserDefaults.standard.string(forKey: "userName") ?? ""
        email = UserDefaults.standard.string(forKey: "userEmail") ?? ""
        phoneNumber = UserDefaults.standard.string(forKey: "userPhoneNumber") ?? ""
        
        if let data = UserDefaults.standard.data(forKey: addressesKey),
           let savedAddresses = try? JSONDecoder().decode([Address].self, from: data) {
            addresses = savedAddresses
        }
        
        defaultAddressId = UserDefaults.standard.string(forKey: defaultAddressIdKey)
    }
    
    func saveUserData() {
        UserDefaults.standard.set(name, forKey: "userName")
        UserDefaults.standard.set(email, forKey: "userEmail")
        UserDefaults.standard.set(phoneNumber, forKey: "userPhoneNumber")
        
        if let encoded = try? JSONEncoder().encode(addresses) {
            UserDefaults.standard.set(encoded, forKey: addressesKey) // Fixed key
        }
        UserDefaults.standard.set(defaultAddressId, forKey: defaultAddressIdKey)
    }
    
    func addAddress(addressText: String) {
        let newAddress = Address(
            id: UUID().uuidString,
            addressText: addressText
        )
        addresses.append(newAddress)
        
        if addresses.count == 1 {
            defaultAddressId = newAddress.id
        }
        saveUserData()
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
    /*import FirebaseAuth
     import FirebaseFirestore
     
     class UserModel: ObservableObject {
     @Published var name: String = ""
     @Published var email: String = ""
     @Published var address: String = ""
     @Published var phoneNumber: String = ""
     
     init() {
     loadUserDataFromFirebase()
     }
     
     func loadUserDataFromFirebase() {
     if let user = Auth.auth().currentUser {
     email = user.email ?? ""
     let db = Firestore.firestore()
     db.collection("users").document(user.uid).getDocument { (document, error) in
     if let document = document, document.exists {
     self.name = document.get("name") as? String ?? ""
     self.address = document.get("address") as? String ?? ""
     self.phoneNumber = document.get("phoneNumber") as? String ?? ""
     }
     }
     }
     }
     
     func saveUserData() {
     if let user = Auth.auth().currentUser {
     let db = Firestore.firestore()
     db.collection("users").document(user.uid).setData([
     "name": name,
     "email": email,
     "address": address,
     "phoneNumber": phoneNumber
     ]) { error in
     if let error = error {
     print("Error saving user data: \(error)")
     }
     }
     }
     }
     }*/
