//
//  PlaySound.swift
//  Slot Machine
//
//  Created by Kelvin Reid on 7/2/23.
//

import AVFoundation

var audioPlayer: AVAudioPlayer?

func playSound(sound: String, type: String) {
    do {
        // Configure audio session to play even in silent mode
        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
        try AVAudioSession.sharedInstance().setActive(true)
    } catch {
        print("ERROR: Audio session configuration failed\n\(error)")
    }

    if let path = Bundle.main.path(forResource: sound, ofType: type) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            audioPlayer?.play()
        } catch {
            print("ERROR: Could not find and play the sound file!\n\(error)")
        }
    }
}
