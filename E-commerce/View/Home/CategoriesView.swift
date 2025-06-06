//
//  CategoriesView.swift
//  E-commerce
//
//  Created by MacBook on 29/05/2025.
//

import SwiftUI

struct CategoriesView: View {
    @State private var categories: [Category] = []
    @State private var selectedCategory: Category?
    let viewModel = CategoryViewModel()
    
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories) { category in
                    Button(action: {
                        selectedCategory = category
                    }) {
                        Text(category.title ?? "Untitled")
                            .font(.system(size: 16, weight: .medium))
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(
                                selectedCategory?.id == category.id ? Color("primaryColor").opacity(0.1) : Color.white
                            )
                            .foregroundColor(
                                selectedCategory?.id == category.id ? Color("primaryColor") : Color("black")
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color("gray").opacity(0.3), lineWidth: 1)
                            )
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 16)
        }
        
        .onAppear() {
            self.getCategories()
        }
    }
    
    func getCategories() {
        viewModel.getCategories { result, error in
            if let error = error {
                print("Error fetching categories: \(error.localizedDescription)")
            }

            if let result = result {
                DispatchQueue.main.async {
                    self.categories = result.customCollections ?? []
                    if var first = self.categories.first, first.title == "Home page" {
                        first.title = "All"
                        self.categories[0] = first
                    }
                    self.selectedCategory = self.categories.first
                }
            }
        }
    }
}

struct CategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        CategoriesView()
    }
}
