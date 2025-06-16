import SwiftUI

struct SignupScreen: View {
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        ZStack {
            signupForm
                .opacity(viewModel.isLoading ? 0 : 1)

            if viewModel.isLoading {
                ProgressView("Please wait...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                    .scaleEffect(1.5)
            }
        }
        .navigationBarBackButtonHidden(true)
        .background(
            Group {
                NavigationLink(destination: MainTabView(), isActive: $viewModel.isAuthenticated) { EmptyView() }
                
                NavigationLink(destination: VerificationScreen(viewModel: viewModel), isActive: $viewModel.showVerificationScreen) { EmptyView() }
            }
        )
    }

    var signupForm: some View {
        ScrollViewReader { proxy in

        ScrollView {
            LazyVStack(alignment: .leading) {
                HStack{
                    Text("Create Account")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("myBlack"))
                        .padding(.top, 14)
                    Spacer()
                    NavigationLink {
                        MainTabView().navigationBarBackButtonHidden()
                    } label: {
                        Text("Skip")
                            .foregroundColor(Color.black)
                            .fontWeight(.medium)
                    }
                }
                Spacer().frame(height: 12)

                Text("Start shopping with create your account")
                    .foregroundColor(Color("myGray"))

                Spacer().frame(height: 34)

                Group {
                    CustomTextField(label: "Username", placeholder: "Create your username", iconName: "user", text: $viewModel.username)
                    Spacer().frame(height: 18)
                    CustomTextField(label: "Email", placeholder: "Enter your email", iconName: "mail2", text: $viewModel.email)
                    Spacer().frame(height: 18)
                    CustomPasswordField(label: "Password", placeholder: "Enter your password", iconName: "lock2", text: $viewModel.password)
                    Spacer().frame(height: 18)
                    CustomPasswordField(label: "Confirm password", placeholder: "Confirm your password", iconName: "ConfirmLock", text: $viewModel.confirmPassword)
                        .padding(.bottom, 12)
                }

                Button(action: {
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
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 5)

                    if error.contains("verify your email") {
                        Button("Resend Verification Email") {
                            viewModel.resendVerificationEmail()
                        }
                        .foregroundColor(.blue)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }

                Group {
                    Spacer().frame(height: 24)
                    Text("Or using other method")
                        .foregroundColor(Color("myGray"))
                        .frame(maxWidth: .infinity, alignment: .center)

                    Spacer().frame(height: 24)
                    GoogleSignInButton()

                    Spacer().frame(height: 14)
                    HStack {
                        Text("Already have an account?")
                            .foregroundColor(Color("myBlack"))

                        NavigationLink {
                            LoginScreen()
                                .environmentObject(viewModel)
                        } label: {
                            Text("Sign in")
                                .foregroundColor(Color("primary"))
                                .fontWeight(.medium)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .onAppear {
            if !viewModel.showVerificationScreen {
                viewModel.email = ""
                viewModel.password = ""
                viewModel.username = ""
                viewModel.confirmPassword = ""
                viewModel.errorMessage = nil
            }
        }
        .scrollDismissesKeyboard(.interactively)
        }
        
    }
}
