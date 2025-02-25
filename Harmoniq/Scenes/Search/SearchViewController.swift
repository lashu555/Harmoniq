//
//  SearchViewController.swift
//  Harmoniq
//
//  Created by Lasha Tavberidze on 12.02.25.
//

import UIKit
import AVFoundation

class SearchViewController: UIViewController {

    var player: AVPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()

        // 1. Get the correct URL (from inspecting the Internet Archive website)
        let correctURLString = "https://archive.org/download/crazy-over-you-mp-3-160-k/Crazy%20Over%20You(MP3_160K).mp3" // Example URL - REPLACE with your actual URL
        guard let url = URL(string: correctURLString) else {
            print("Invalid URL")
            return // Or handle the error as needed
        }

        // 2. Create AVPlayerItem
        let playerItem = AVPlayerItem(url: url)

        // 3. Create AVPlayer
        player = AVPlayer(playerItem: playerItem)

        // 4. Set up a playback finished notification (optional but recommended)
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerItem, queue: .main) { [weak self] _ in
            print("Audio playback finished.")
            // Do something, e.g., update UI, play next track
            DispatchQueue.main.async {
                self?.player?.seek(to: .zero) // Reset to beginning
                self?.player?.play()
            }
        }

        // 5. Play the audio
        player?.play()


        // Add a button to control playback (optional)
        let playPauseButton = UIButton(type: .system)
        playPauseButton.setTitle("Pause", for: .normal)
        playPauseButton.addTarget(self, action: #selector(togglePlayPause), for: .touchUpInside)
        playPauseButton.frame = CGRect(x: 100, y: 200, width: 100, height: 50) // Adjust position as needed
        view.addSubview(playPauseButton)
    }

    @objc func togglePlayPause() {
        if let player = player {
            if player.isPlaying {
                player.pause()
                (self.view.subviews.first as? UIButton)?.setTitle("Play", for: .normal)
            } else {
                player.play()
                (self.view.subviews.first as? UIButton)?.setTitle("Pause", for: .normal)

            }
        }
    }


    deinit {
        // Important: Remove the observer when the view controller is deallocated
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: self)
    }
}

extension AVPlayer {
    var isPlaying: Bool {
        return rate > 0
    }
}
