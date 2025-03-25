//
//  SearchViewController.swift
//  Harmoniq
//
//  Created by Lasha Tavberidze on 12.02.25.
//

import UIKit
import AVFoundation

class SearchViewController: UIViewController {
    
    let albumsViewModel = HomeViewModel.shared
    let searchController = UISearchController(searchResultsController: SearchResultViewController())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        if let searchResultsVC = searchController.searchResultsController as? SearchResultViewController {
            var albums = albumsViewModel.albums
            var songs: [Song] = []
            for album in albums {
                for song in album.songs {
                    songs.append(song)
                }
            }
            searchResultsVC.songs = songs
        }
        
    }
    
    
}
extension SearchViewController: UISearchBarDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        let vc = searchController.searchResultsController as? SearchResultViewController
        vc?.updateSearchResults(for: text)
    }
    
}

//
//class SearchViewController: UIViewController {
//
//    var player: AVPlayer?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        let correctURLString = "https://archive.org/download/crazy-over-you-mp-3-160-k/Crazy%20Over%20You(MP3_160K).mp3"
//        guard let url = URL(string: correctURLString) else {
//            print("Invalid URL")
//            return
//        }
//        let playerItem = AVPlayerItem(url: url)
//        player = AVPlayer(playerItem: playerItem)
//        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerItem, queue: .main) { [weak self] _ in
//            print("Audio playback finished.")
//            DispatchQueue.main.async {
//                self?.player?.seek(to: .zero)
//                self?.player?.play()
//            }
//        }
//
//        player?.play()
//
//        let playPauseButton = UIButton(type: .system)
//        playPauseButton.setTitle("Pause", for: .normal)
//        playPauseButton.addTarget(self, action: #selector(togglePlayPause), for: .touchUpInside)
//        playPauseButton.frame = CGRect(x: 100, y: 200, width: 100, height: 50)
//        view.addSubview(playPauseButton)
//    }
//
//    @objc func togglePlayPause() {
//        if let player = player {
//            if player.isPlaying {
//                player.pause()
//                (self.view.subviews.first as? UIButton)?.setTitle("Play", for: .normal)
//            } else {
//                player.play()
//                (self.view.subviews.first as? UIButton)?.setTitle("Pause", for: .normal)
//
//            }
//        }
//    }
//
//
//    deinit {
//        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: self)
//    }
//}
//
//extension AVPlayer {
//    var isPlaying: Bool {
//        return rate > 0
//    }
//}
