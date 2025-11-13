//
//  SoundManager.swift
//  WorkoutApp
//
//  Created by Jennifer Evelyn on 13/11/25.
//

import AVFoundation

final class SoundManager {
    static let shared = SoundManager()
    private var player: AVAudioPlayer?

    private init() {}

    func playSound(_ name: String, withExtension ext: String = "mp3") {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            print("❌ Sound file not found: \(name).\(ext)")
            return
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.play()
            print("🎵 Playing sound: \(name)")
        } catch {
            print("❌ Error playing sound: \(error.localizedDescription)")
        }
    }

    func stop() {
        player?.stop()
        player = nil
    }
}
