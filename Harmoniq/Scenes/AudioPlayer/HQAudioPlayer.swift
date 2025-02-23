//
//  HQAudioPlayer.swift
//  Harmoniq
//
//  Created by Lasha Tavberidze on 23.02.25.
//
import Foundation
import AVFoundation

class HQAudioPlayer {
    static let shared = HQAudioPlayer()
    private var audioPlayer: AVAudioPlayer?
    private var currentURL: URL?
    
    var isPlaying: Bool {
        return audioPlayer?.isPlaying ?? false
    }
    
    private init() {}
    
    func play(url: URL) {
        if currentURL == url {
            // Resume existing track
            audioPlayer?.play()
        } else {
            // Load new track
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
                currentURL = url
            } catch {
                print("Error loading audio: \(error)")
            }
        }
    }
    
    func togglePlayback() {
        guard let player = audioPlayer else { return }
        
        if player.isPlaying {
            pause()
        } else {
            player.play()
        }
    }
    
    func pause() {
        audioPlayer?.pause()
    }
    
    func stop() {
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        currentURL = nil
    }
    
    var currentTime: TimeInterval {
        return audioPlayer?.currentTime ?? 0
    }
    
    var duration: TimeInterval {
        return audioPlayer?.duration ?? 0
    }
}
