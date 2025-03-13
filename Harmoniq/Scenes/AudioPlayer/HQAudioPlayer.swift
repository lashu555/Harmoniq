//
//  HQAudioPlayer.swift
//  Harmoniq
//
//  Created by Lasha Tavberidze on 23.02.25.
//
import Foundation
import AVFoundation

protocol HQAudioPlayerDelegate: AnyObject {
    func audioPlayerDidStartPlaying()
    func audioPlayerDidFinishPlaying(successfully: Bool, error: Error?)
    func audioPlayerDidFailWithError(error: Error)
}

class HQAudioPlayer: NSObject {
    static let shared = HQAudioPlayer()
    
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var currentURL: URL?
    weak var delegate: HQAudioPlayerDelegate?

    var isPlaying: Bool {
        return player?.rate != 0
    }

    private override init() {
        super.init()
    }

    func play(url: URL) {
        if currentURL == url, let player = player {
            player.seek(to: .zero)
            player.play()
            delegate?.audioPlayerDidStartPlaying()
        } else {
            currentURL = url
            playerItem = AVPlayerItem(url: url)
            player = AVPlayer(playerItem: playerItem)
            
            NotificationCenter.default.addObserver(self, selector: #selector(audioDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)

            player?.play()
            delegate?.audioPlayerDidStartPlaying()
        }
    }

    func togglePlayback() {
        guard let player = player else { return }

        if player.rate > 0 {
            pause()
        } else {
            player.play()
            delegate?.audioPlayerDidStartPlaying()
        }
    }

    func pause() {
        player?.pause()
    }

    func stop() {
        player?.pause()
        player?.seek(to: .zero)
        currentURL = nil
    }

    var currentTime: TimeInterval {
        return player?.currentTime().seconds ?? 0
    }

    var duration: TimeInterval {
        return player?.currentItem?.duration.seconds ?? 0
    }

    @objc private func audioDidFinishPlaying() {
        delegate?.audioPlayerDidFinishPlaying(successfully: true, error: nil)
    }
}

