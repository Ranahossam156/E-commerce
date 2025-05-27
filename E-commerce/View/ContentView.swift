//
//  ContentView.swift
//  ShopifyDemo
//
//  Created by MacBook on 26/05/2025.
//

import SwiftUI

struct ContentView: View {
    
    @State private var brandsList: [Brand] = []
    let viewModel = BrandViewModel()
    
    var body: some View {
        NavigationView{
            
            List {
                ForEach(brandsList) { brand in
                    NavigationLink{
//                        EmployeeDetails(employee: employee)
                    } label: {
                        BrandRow(brand: brand)
                    }
                    
                    .navigationTitle("Brands")
                }
                
                .onDelete(perform: deleteBrand)
                
            }
        }
        
        .onAppear() {
            getBrands()
        }
    }
    
    
    func getBrands() {
        viewModel.getBrands { result, error in
            if let error = error {
                print("Error fetching brands: \(error.localizedDescription)")
            }

            if let result = result {
                DispatchQueue.main.async {
                    self.brandsList = result.smartCollections ?? []
                }
            }
        }
    }

    
    func deleteBrand(_ offsets: IndexSet){
        brandsList.remove(atOffsets: offsets)
        print("Delete \(offsets)")
    }
}

#Preview {
    ContentView()
}
