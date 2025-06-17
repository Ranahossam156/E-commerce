//
//  SettingsFirestoreService.swift
//  E-commerce
//
//  Created by Kerolos on 17/06/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class SettingsFirestoreService {
    private let db = Firestore.firestore()
    
    // Save settings (e.g., selectedCurrency) to /users/{userId}/settings/preferences
    func saveSettings(selectedCurrency: String, completion: @escaping (Error?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No authenticated user, settings not saved")
            completion(nil)
            return
        }
        let settingsData: [String: Any] = ["selectedCurrency": selectedCurrency]
        db.collection("users").document(userId).collection("settings").document("preferences").setData(settingsData) { error in
            if let error = error {
                print("Error saving settings: \(error.localizedDescription)")
                completion(error)
            } else {
                print("Settings saved successfully: Currency = \(selectedCurrency)")
                completion(nil)
            }
        }
    }
    
    // Load settings from /users/{userId}/settings/preferences
    func loadSettings(completion: @escaping (String?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No authenticated user, settings not loaded")
            completion(nil)
            return
        }
        db.collection("users").document(userId).collection("settings").document("preferences").getDocument { document, error in
            if let document = document, document.exists {
                if let data = document.data(), let currency = data["selectedCurrency"] as? String {
                    print("Settings loaded: Currency = \(currency)")
                    completion(currency)
                } else {
                    print("No currency found in settings, using default")
                    completion(nil)
                }
            } else {
                print("No settings document found")
                completion(nil)
            }
        }
    }
    
    // Save user data to /users/{userId}/
    func saveUserData(name: String, email: String, phoneNumber: String, defaultAddress: String, defaultAddressId: String?, completion: @escaping (Error?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No authenticated user, user data not saved")
            completion(nil)
            return
        }
        let userData: [String: Any] = [
            "name": name,
            "email": email,
            "phoneNumber": phoneNumber,
            "defaultAddress": defaultAddress,
            "defaultAddressId": defaultAddressId ?? ""
        ]
        db.collection("users").document(userId).setData(userData) { error in
            if let error = error {
                print("Error saving user data: \(error.localizedDescription)")
                completion(error)
            } else {
                print("User data saved successfully: \(userData)")
                completion(nil)
            }
        }
    }
    
    // Load user data from /users/{userId}/
    func loadUserData(completion: @escaping (String?, String?, String?, String?, String?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No authenticated user, user data not loaded")
            completion(nil, nil, nil, nil, nil)
            return
        }
        db.collection("users").document(userId).getDocument { document, error in
            if let document = document, document.exists {
                if let data = document.data() {
                    let name = data["name"] as? String ?? ""
                    let email = data["email"] as? String ?? ""
                    let phoneNumber = data["phoneNumber"] as? String ?? ""
                    let defaultAddress = data["defaultAddress"] as? String ?? ""
                    let defaultAddressId = data["defaultAddressId"] as? String
                    print("User data loaded: \(name), \(email), \(phoneNumber), \(defaultAddress)")
                    completion(name, email, phoneNumber, defaultAddress, defaultAddressId)
                }
            } else {
                print("No user data found")
                completion(nil, nil, nil, nil, nil)
            }
        }
    }
    
    // Save address to /users/{userId}/addresses
    func saveAddress(addressText: String, completion: @escaping (String, Error?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No authenticated user, address not saved")
            completion("", nil)
            return
        }
        let addressId = UUID().uuidString
        let addressData: [String: Any] = ["addressText": addressText]
        db.collection("users").document(userId).collection("addresses").document(addressId).setData(addressData) { error in
            if let error = error {
                print("Error saving address: \(error.localizedDescription)")
                completion("", error)
            } else {
                print("Address saved successfully: \(addressText)")
                completion(addressId, nil)
            }
        }
    }
    
    // Load addresses from /users/{userId}/addresses
    func loadAddresses(completion: @escaping ([(id: String, addressText: String)]) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No authenticated user, addresses not loaded")
            completion([])
            return
        }
        db.collection("users").document(userId).collection("addresses").getDocuments { snapshot, error in
            if let snapshot = snapshot {
                let addresses = snapshot.documents.map { doc in
                    let data = doc.data()
                    return (id: doc.documentID, addressText: data["addressText"] as? String ?? "")
                }
                print("Addresses loaded: \(addresses)")
                completion(addresses)
            } else {
                print("Error loading addresses: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
            }
        }
    }
    
    // Delete address from /users/{userId}/addresses
    func deleteAddress(addressId: String, completion: @escaping (Error?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No authenticated user, address not deleted")
            completion(nil)
            return
        }
        db.collection("users").document(userId).collection("addresses").document(addressId).delete { error in
            if let error = error {
                print("Error deleting address: \(error.localizedDescription)")
                completion(error)
            } else {
                print("Address deleted successfully")
                completion(nil)
            }
        }
    }
}
