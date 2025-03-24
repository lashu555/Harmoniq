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
    var currentURL: URL?
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
            if let playerItem = playerItem {
                playerItem.removeObserver(self, forKeyPath: "status")
                NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
            }
        
            currentURL = url
            playerItem = AVPlayerItem(url: url)
            player = AVPlayer(playerItem: playerItem)
            
            NotificationCenter.default.addObserver(self, selector: #selector(audioDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
            playerItem?.addObserver(self, forKeyPath: "status", options: [.old, .new], context: nil)
            
            player?.play()
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
        if let playerItem = playerItem {
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
            playerItem.removeObserver(self, forKeyPath: "status")
        }
        playerItem = nil
        player = nil
    }

    var currentTime: TimeInterval {
        return player?.currentTime().seconds ?? 0
    }

    var duration: TimeInterval {
        guard let currentItem = player?.currentItem else { return 0 }
        let duration = CMTimeGetSeconds(currentItem.duration)
        return duration.isFinite ? duration : 0
    }

    @objc private func audioDidFinishPlaying() {
        delegate?.audioPlayerDidFinishPlaying(successfully: true, error: nil)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status", let playerItem = object as? AVPlayerItem {
            switch playerItem.status {
            case .readyToPlay:
                delegate?.audioPlayerDidStartPlaying()
            case .failed:
                delegate?.audioPlayerDidFailWithError(error: playerItem.error!)
            default:
                break
            }
        }
    }

    deinit {
        if let playerItem = playerItem {
            playerItem.removeObserver(self, forKeyPath: "status")
        }
        NotificationCenter.default.removeObserver(self)
    }
}
