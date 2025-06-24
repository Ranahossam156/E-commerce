import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    var animationName: String
    var loopMode: LottieLoopMode = .playOnce
    var onAnimationCompleted: (() -> Void)? = nil

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let animationView = LottieAnimationView(name: animationName)
        animationView.loopMode = loopMode
        animationView.contentMode = .scaleAspectFit
        animationView.play { finished in
            if finished {
                onAnimationCompleted?()
            }
        }

        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
