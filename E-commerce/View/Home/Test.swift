////
////  Test.swift
////  E-commerce
////
////  Created by MacBook on 29/05/2025.
////
//
//import SwiftUI
//
//struct Test: View {
//    var body: some View {
//        NavigationView {
//            Text("Hello, SwiftUI!")
//                .toolbar {
//                    ToolbarItem(placement: .navigationBarLeading) {
//                        HStack(spacing: 12) {
//                            Image("user_avatar")
//                                .resizable()
//                                .frame(width: 50, height: 50)
//                                .clipShape(Circle())
//                            
//                            VStack(alignment: .leading, spacing: 4) {
//                                Text("Hi, Jonathan")
//                                    .font(.headline)
//                                    .fontWeight(.semibold)
//                                    .foregroundColor(.black)
//                                
//                                Text("Let's go shopping")
//                                    .font(.subheadline)
//                                    .foregroundColor(.gray)
//                            }
//                        }
//                    }
//                    ToolbarItem(placement: .navigationBarTrailing) {
//                        HStack(spacing: 8) {
//                            NavigationLink(destination: SearchView()) {
//                                Image(systemName: "magnifyingglass")
//                                    .font(.system(size: 20))
//                                    .foregroundColor(.black)
//                            }
//                            
//                            NavigationLink(destination: CartView()) {
//                                ZStack(alignment: .topTrailing) {
//                                    Image(systemName: "cart")
//                                        .font(.system(size: 20))
//                                        .foregroundColor(.black)
//
//                                    Circle()
//                                        .fill(Color.red)
//                                        .frame(width: 10, height: 10)
//                                        .offset(x: 6, y: -6)
//                                }
//                            }
//                        }
//                    }
//                  
//                }
//        }
//    }
//}
//
//#Preview {
//    Test()
//}
