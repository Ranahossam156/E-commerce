//
//  Lottie.swift
//  E-commerce
//
//  Created by Macos on 26/06/2025.
//

import Foundation
import SwiftUI
import Lottie

struct Lottie: UIViewRepresentable {
    var animationName: String
    var loopMode: LottieLoopMode = .playOnce

    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: .zero)

        let animationView = LottieAnimationView(name: animationName)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        animationView.play()

        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])

        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
}
