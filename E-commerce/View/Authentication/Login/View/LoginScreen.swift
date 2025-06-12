import SwiftUI

struct LoginScreen: View {
   // @StateObject private var viewModel = AuthViewModel()
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                       ProgressView("Signing in...")
                   } else if viewModel.isAuthenticated {
                       MainTabView()
                   } else {
                       loginForm
                   }
            }
        }
    }

    var loginForm: some View {
        VStack(alignment: .leading) {
            Text("Login Account")
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(Color("myBlack"))
                .padding(.top, 14)

            Spacer().frame(height: 12)

            Text("Please login with registered account")
                .foregroundColor(Color("myGray"))

            Spacer().frame(height: 34)

            CustomTextField(label: "Email", placeholder: "Enter your email", iconName: "mail2", text: $viewModel.email)

            Spacer().frame(height: 24)

            CustomPasswordField(label: "Password", placeholder: "Enter your password", iconName: "lock2", text: $viewModel.password)
                .padding(.bottom, 12)

//            HStack {
//                Spacer()
//                Button("Forgot Password?") {
//                    print("Forgot password tapped")
//                }
//                .foregroundColor(Color("primary"))
//            }
//            .padding(.bottom, 28)

            Button(action: {
                viewModel.login()
            }) {
                Text("Sign In")
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .background(Color("primary"))
            .clipShape(Capsule())
            .padding(.horizontal)

            Group {
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                Spacer().frame(height: 24)

                Text("Or using other method")
                    .foregroundColor(Color("myGray"))
                    .frame(maxWidth: .infinity, alignment: .center)

                Spacer().frame(height: 24)

                GoogleSignInButton()

                Spacer().frame(height: 32)

                HStack {
                    Text("Don't have an account?")
                        .foregroundColor(Color("myBlack"))
                    NavigationLink(destination: SignupScreen().environmentObject(viewModel)) {
                        Text("Sign up")
                            .foregroundColor(Color("primary"))
                            .fontWeight(.medium)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .onAppear {
            viewModel.email = ""
            viewModel.password = ""
            viewModel.errorMessage = nil
        }

        .navigationBarBackButtonHidden(true)
        .padding(.horizontal, 24)
        .padding(.vertical)
        .frame(maxHeight: .infinity, alignment: .top)
    }
}


struct LoginScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            LoginScreen()
        }    }
}
