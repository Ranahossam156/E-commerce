//import SwiftUI
//
//struct VerificationView: View {
//    @State private var code: [String] = Array(repeating: "", count: 6)
//    @FocusState private var focusedField: Int?
//
//    var body: some View {
//        VStack(spacing: 24) {
//            HStack {
//                Button(action: {
//                }) {
//                    Image(systemName: "chevron.left")
//                        .foregroundColor(Color("myBlack"))
//                        .font(.title3)
//                }
//                Spacer()
//                Text("Verification")
//                    .font(.headline)
//                    .foregroundColor(Color("myBlack"))
//                Spacer()
//                Spacer().frame(width: 24)
//            }
//            .padding(.horizontal)
//            .padding(.top, 16)
//
//            Spacer()
//
//            ZStack {
//                Circle()
//                    .fill(Color.purple.opacity(0.1))
//                    .frame(width: 100, height: 100)
//
//                Image(systemName: "envelope.fill")
//                    .foregroundColor(Color("primary"))
//                    .font(.system(size: 32))
//            }
//
//            Text("Verification Code")
//                .font(.title2)
//                .fontWeight(.semibold)
//                .foregroundColor(Color("myBlack"))
//
//            Text("We have sent the code verification to")
//                .font(.subheadline)
//                .foregroundColor(Color("myGray"))
//
//            Text("magdalena83@email.com")
//                .font(.subheadline)
//                .foregroundColor(Color("myBlack"))
//
//            HStack(spacing: 12) {
//                ForEach(0..<6, id: \.self) { index in
//                    TextField("", text: $code[index])
//                        .keyboardType(.numberPad)
//                        .multilineTextAlignment(.center)
//                        .frame(width: 48, height: 56)
//                        .background(
//                            RoundedRectangle(cornerRadius: 8)
//                                .stroke(
//                                    // This is where we check if the field is focused
//                                    focusedField == index ? Color("primary") : Color.gray.opacity(0.3),
//                                    lineWidth: 2
//                                )
//                        )
//                        .focused($focusedField, equals: index)
//                        .onChange(of: code[index]) { newValue in
//                            if newValue.count > 1 {
//                                code[index] = String(newValue.prefix(1))
//                            }
//                            if newValue.count == 1 {
//                                if index < 5 {
//                                    focusedField = index + 1
//                                } else {
//                                    focusedField = nil
//                                }
//                            }
//                        }
//                }
//            }
//
//            Button(action: {
//                print("Submit tapped")
//            }) {
//                Text("Submit")
//                    .foregroundColor(.white)
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color("primary"))
//                    .cornerRadius(32)
//                    .padding(.horizontal)
//            }
//            .padding(.top, 20)
//
//            HStack {
//                Text("Didn't receive the code?")
//                    .foregroundColor(.gray)
//                Button("Resend") {
//                    print("Resend tapped")
//                }
//                .foregroundColor(Color("primary"))
//                .fontWeight(.medium)
//            }
//
//            Spacer()
//        }
//        .onAppear {
//            focusedField = 0
//        }
//    }
//}
//
//struct VerificationView_Previews: PreviewProvider {
//    static var previews: some View {
//        VerificationView()
//    }
//}

import SwiftUI

struct VerificationScreen: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: AuthViewModel
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 24) {
                Image(systemName: "envelope")
                    .font(.system(size: 60))
                    .foregroundColor(Color("primary"))
                
                Text("Verify Your Email")
                    .font(.title)
                    .fontWeight(.bold)
                
                VStack(spacing: 8) {
                    Text("We sent a verification email to:")
                        .foregroundColor(.secondary)
                    
                    Text(viewModel.email)
                        .font(.headline)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                }
                
                Text("Please click the verification link to activate your account.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 24)
            }
            .frame(maxWidth: .infinity)
            
            Spacer().frame(height: 24)

            VStack(spacing: 16) {
//                Button(action: {
//                    if let url = URL(string: "mailto:") {
//                        UIApplication.shared.open(url)
//                    }
//                }) {
//                    HStack {
//                        Image(systemName: "envelope")
//                        Text("Open Mail App")
//                    }
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color("primary"))
//                    .foregroundColor(.white)
//                    .cornerRadius(10)
//                }
                
//                Button(action: {
//                    viewModel.resendVerificationEmail()
//                    viewModel.startCountdown()
//                }) {
//                    if viewModel.countdownSeconds > 0 {
//                        Text("Resend in \(viewModel.countdownSeconds)s")
//                           // .foregroundColor(.gray)
//                    } else {
//                        Text("Resend Verification Email")
//                            //.foregroundColor(Color("primary"))
//                    }
//                }
//                                    .frame(maxWidth: .infinity)
//                                    .padding()
//                                    .background(Color("primary"))
//                                    .foregroundColor(.white)
//                                    .cornerRadius(10)
//                .disabled(viewModel.countdownSeconds > 0)
                
                Button(action: {
                    viewModel.checkEmailVerification { isVerified in
                        if isVerified {
                            dismiss()
                            viewModel.isAuthenticated = true
                        }
                    }
                }) {
                    Text("I've Verified My Email")
                }
                                                    .frame(maxWidth: .infinity)
                                                    .padding()
                                                    .background(Color("primary"))
                                                    .foregroundColor(.white)
                                                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            viewModel.startCountdown()
        }
    }
}
//struct VerificationScreen_Previews: PreviewProvider {
//    static var previews: some View {
//      //  VerificationScreen()
//    }
//}
