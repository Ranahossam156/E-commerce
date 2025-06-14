import SwiftUI

struct VerificationScreen: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var shouldNavigateToLogin = false
    @State private var checkingVerification = false

    var body: some View {
        VStack {
            Spacer()

            VStack(spacing: 24) {
                Image(systemName: "envelope.badge")
                    .font(.system(size: 60))
                    .foregroundColor(Color("primary"))

                Text("Verify Your Email")
                    .font(.title2)
                    .fontWeight(.bold)

                VStack(spacing: 8) {
                    Text("We sent a verification email to:")
                        .foregroundColor(.secondary)

                    Text(viewModel.email)
                   // Text("ranahossam156@gmail.com")

                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                }

                Text("Please check your inbox and click the link to verify your account.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 24)

                if checkingVerification {
                    ProgressView("Checking verification...")
                        .padding(.top)
                }
            }

            Spacer().frame(height: 32)

            VStack(spacing: 16) {
                Button(action: {
                    checkingVerification = true
                    viewModel.checkEmailVerification { isVerified in
                        checkingVerification = false
                        if isVerified {
                            shouldNavigateToLogin = true
                        } else {
                            viewModel.errorMessage = "Your email is not verified yet. Please check your inbox and try again."
                        }
                    }
                }) {
                    Text("I've Verified My Email")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("primary"))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                if viewModel.countdownSeconds > 0 {
                    Text("You can resend the email in \(viewModel.countdownSeconds) seconds")
                        //.font(.caption)
                        .foregroundColor(.gray)
                } else {
                    Button(action: {
                        viewModel.resendVerificationEmail()
                        viewModel.startCountdown()
                    }) {
                        Text("Resend Verification Email")
                            .font(.callout)
                            .underline()
                            .foregroundColor(Color("primary"))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)

            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding(.top, 12)
                    .padding(.horizontal)
            }

            Spacer()

            NavigationLink(
                destination: LoginScreen().environmentObject(viewModel),
                isActive: $shouldNavigateToLogin
            ) {
                EmptyView()
            }
            .hidden()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .navigationBarBackButtonHidden(true)
        .onAppear {
            viewModel.startCountdown()
        }
    }
}
