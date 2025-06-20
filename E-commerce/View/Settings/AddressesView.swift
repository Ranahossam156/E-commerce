//
//  AddressesView.swift
//  E-commerce
//
//  Created by Kerolos on 17/06/2025.
//

import SwiftUI

struct AddressesView: View {
    @ObservedObject var userModel: UserModel
    @StateObject private var mapViewModel = MapViewModel()
    @State private var showDeleteAlert = false
    @State private var addressToDelete : IndexSet? // Store the IndexSet for deletion
    
    var body: some View {
        Form {
            Section(header: Text("Your Addresses").font(.headline)) {
                if userModel.addresses.isEmpty {
                    Text("No addresses added")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                } else {
                    ForEach(userModel.addresses) { address in
                        HStack {
                            Text(address.addressText)
                            Spacer()
                            if userModel.defaultAddressId == address.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                        .onTapGesture {
                            userModel.setDefaultAddress(id: address.id)
                        }
                    }
                    .onDelete(perform:{ offsets in
                        addressToDelete = offsets
                        showDeleteAlert = true
                    })
                }
            }
            
            Section(header: Text("Add New Address").font(.headline)) {
                MapSubView(mapViewModel: mapViewModel)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Address")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(mapViewModel.selectedAddress ?? "Select a location on the map")
                        .font(.body)
                        .foregroundColor(mapViewModel.selectedAddress == nil ? .gray : .primary)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading) // Fixed width
                        .fixedSize(horizontal: false, vertical: true) // Allow vertical expansion
                        .cornerRadius(8)
                    
                        .multilineTextAlignment(.leading) // Align text to leading edge
                }
                
                Button(action: {
                    if let selectedAddress = mapViewModel.selectedAddress {
                        userModel.addAddress(addressText: selectedAddress)
                        mapViewModel.resetSelectedLocation()
                    }
                }) {
                    Text("Add Address")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .clipShape(Capsule())
                        .background(mapViewModel.selectedAddress == nil ? Color.gray : Color("primary"))
                        .cornerRadius(8)
                }
                .disabled(mapViewModel.selectedAddress == nil)
            }
        }
        .navigationTitle("Addresses")
        .toolbar {
            EditButton()
        }
        .alert(isPresented: $showDeleteAlert){
            Alert (
                title: Text("Delete Address"),
                message: Text("Are you sure you want to delete this address?"),
                primaryButton: .destructive(Text ("Delete"), action: {
                    if let offsets = addressToDelete {
                        deleteAddresses(at: offsets)
                        addressToDelete = nil
                    }
                }), secondaryButton: .cancel{
                    addressToDelete = nil
                }
            )
        }
    }
    
    private func deleteAddresses(at offsets: IndexSet) {
        offsets.forEach{ index in
            let addressId = userModel.addresses[index].id
            userModel.deleteAddress(id: addressId)
            
        }
    }
}
