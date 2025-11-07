//
//  LottieView.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 15/10/25.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    let name: String
    var loopMode: LottieLoopMode = .loop

    func makeUIView(context: Context) -> LottieAnimationView {
        // Gunakan bundle animation yang benar
        let animationView = LottieAnimationView(name: name)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        animationView.play() // ⏯️ mulai otomatis
        return animationView
    }

    func updateUIView(_ uiView: LottieAnimationView, context: Context) {
        // Pastikan tetap loop dan play jika view di-update
        if uiView.isAnimationPlaying == false {
            uiView.play()
        }
    }
}
