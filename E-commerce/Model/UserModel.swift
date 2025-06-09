//
//  File.swift
//  E-commerce
//
//  Created by Kerolos on 03/06/2025.
//

import Foundation
import Combine

struct Address: Identifiable, Codable {
    let id: String // Unique identifier for each address
    var recipientName: String
    var phoneNumber: String
    var addressText: String
}

class UserModel: ObservableObject
{
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var addresses: [Address] = []
    @Published var defaultAddressId: String? // Tracks the default address
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
        
        // Load addresses from UserDefaults
        if let data = UserDefaults.standard.data(forKey: addressesKey),
           let savedAddresses = try? JSONDecoder().decode([Address].self, from: data) {
            addresses = savedAddresses
        }
        
        // Load default address ID
        defaultAddressId = UserDefaults.standard.string(forKey: defaultAddressIdKey)
    }
    
    // Save user data to UserDefaults
    func saveUserData() {
        UserDefaults.standard.set(name, forKey: "userName")
        UserDefaults.standard.set(email, forKey: "userEmail")
        UserDefaults.standard.set(address, forKey: "userAddress")
        UserDefaults.standard.set(phoneNumber, forKey: "userPhoneNumber")
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
