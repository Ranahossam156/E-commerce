//
//  SignupScreen.swift
//  E-commerce
//
//  Created by Macos on 28/05/2025.
//

import SwiftUI

struct SignupScreen: View {
    @State private var email: String = ""
    @State private var userName: String = ""
    @State private var password: String = ""
    @StateObject private var viewModel = AuthViewModel()


    var body: some View {
        ScrollView{
            VStack(alignment: .leading) {
                Text("Create Account")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("myBlack"))
                    .padding(.top, 14)
                
                Spacer().frame(height: 12)
                
                Text("Start shopping with create your account")
                    .foregroundColor(Color("myGray"))
                
                Spacer().frame(height: 34)
                Group{
                    CustomTextField(label: "Username", placeholder: "Create your username", iconName: "user", text: $viewModel.username)
                    
                    Spacer().frame(height: 18)
                    CustomTextField(label: "Email", placeholder: "Enter your email", iconName: "mail2", text: $viewModel.email)
                    
                    Spacer().frame(height: 18)
                    
                    CustomPasswordField(label: "Password", placeholder: "Enter your password", iconName: "lock2", text: $viewModel.password)
                    Spacer().frame(height: 18)
                    
                    CustomPasswordField(label: "Confirm password", placeholder: "Confirm your password", iconName: "ConfirmLock", text: $viewModel.confirmPassword)                    .padding(.bottom, 12)
                    
                }
                
                Button(action: {
                    print("Sign In tapped")
                    viewModel.register()
                }) {
                    Text("Sign Up")
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .background(Color("primary"))
                .clipShape(Capsule())
                .padding(.horizontal)
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)

                    if error.contains("verify your email") {
                        Button("Resend Verification Email") {
                            viewModel.resendVerificationEmail()
                        }
                        .foregroundColor(.blue)
                        .font(.caption)
                    }
                }

                Group{
                    Spacer().frame(height: 24)
                    Text("Or using other method")
                        .foregroundColor(Color("myGray"))
                        .frame(maxWidth: .infinity, alignment: .center)
                    Spacer().frame(height: 24)
                    
                    GoogleSignInButton()
                    Spacer().frame(height: 14)
                    HStack{
                        Text("Already have an account?")
                            .foregroundColor(Color("myBlack"))
                        
                        NavigationLink(destination: LoginScreen()) {
                            Text("Sign in")
                                .foregroundColor(Color("primary"))
                                .fontWeight(.medium)
                        }

                        
                    }.frame(maxWidth: .infinity, alignment: .center)
                }
                
            }
            
        }.fullScreenCover(isPresented: $viewModel.showVerificationScreen) {
            VerificationScreen(viewModel: viewModel)
        }.navigationBarBackButtonHidden(true)
        .padding(.horizontal, 24)
        .padding(.vertical)
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

struct SignupScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SignupScreen()
        }    }
}
