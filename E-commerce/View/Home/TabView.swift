//
//  TabView.swift
//  E-commerce
//
//  Created by MacBook on 29/05/2025.
//

import SwiftUI

struct TabSelectorView: View {
    @State private var selectedTab: Tab = .home

    enum Tab {
        case home, category
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab Switcher Header
                HStack(spacing: 80) {
                    tabButton(title: "Home", tab: .home)
                    tabButton(title: "Category", tab: .category)
                }
                .padding(.top, 8)
                .padding(.bottom, 4)
                
                
                // View Content Area
                ScrollView{
                    Group {
                        switch selectedTab {
                        case .home:
                            HomeContentView()
                        case .category:
                            CategoriesView()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
    }
    
    @ViewBuilder
    private func tabButton(title: String, tab: Tab) -> some View {
        VStack(spacing: 12) {
            Button(action: {
                selectedTab = tab
            }) {
                Text(title)
                    .fontWeight(selectedTab == tab ? .semibold : .regular)
                    .foregroundColor(selectedTab == tab ? Color("black") : Color("gray").opacity(0.6))
            }

            Rectangle()
                .frame(height: 2)
                .frame(width: 100)
                .foregroundColor(selectedTab == tab ? Color("primaryColor"): Color.clear)
                .cornerRadius(1)
        }
    }
}


struct TabSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        TabSelectorView()
    }
}

