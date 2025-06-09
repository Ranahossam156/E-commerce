import SwiftUI

struct GoogleSignInButton: View {
    var body: some View {
        Button(action: {
            print("Google Sign-In tapped")
        }) {
            HStack(spacing: 12) {
                Image("google")
                    .resizable()
                    .frame(width: 20, height: 20)

                Text("Sign In with Google")
                    .foregroundColor(Color("myBlack"))
                    .fontWeight(.medium)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 40)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .clipShape(Capsule())
        }
        .padding(.horizontal)
    }
}
struct GoogleSignInButton_Previews: PreviewProvider {
    static var previews: some View {
        GoogleSignInButton()
    }
}
