import SwiftUI
import UIKit

extension UIApplication {
    func topMostViewController(base: UIViewController? = UIApplication.shared.connectedScenes
        .compactMap { ($0 as? UIWindowScene)?.keyWindow }
        .first?.rootViewController) -> UIViewController? {

        if let nav = base as? UINavigationController {
            return topMostViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return topMostViewController(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return topMostViewController(base: presented)
        }
        return base
    }
}

struct GoogleSignInButton: View {
    @EnvironmentObject var viewModel: AuthViewModel
    var body: some View {
        Button(action: {
            if let topVC = UIApplication.shared.topMostViewController() {
                viewModel.signInWithGoogle(presentingVC: topVC)
            }
        }){
            HStack(spacing: 12) {
                Image("google")
                    .resizable()
                    .frame(width: 20, height: 20)

                Text("Continue with Google")
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
