//
//  NowPlayingViewController.swift
//  Harmoniq
//
//  Created by Lasha Tavberidze on 23.02.25.
//
import UIKit
import AVFoundation
import Kingfisher

class NowPlayingViewController: UIViewController {
    
    let audioPlayer = HQAudioPlayer.shared
    var audioURL: URL?
    var song: Song? {
        didSet { updateUI() }
    }
    private var timer: Timer?
    private let backgroundView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemMaterial)
        return UIVisualEffectView(effect: blur)
    }()
    
    private let artworkImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 12
        iv.clipsToBounds = true
        return iv
    }()
    
    private let songLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    private let artistLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .lightGray
        label.textAlignment = .center
        return label
    }()
    
    private let progressSlider: UISlider = {
        let slider = UISlider()
        slider.tintColor = .systemPink
        slider.setThumbImage(UIImage(systemName: "circle.fill"), for: .normal)
        return slider
    }()
    
    private let currentTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedDigitSystemFont(ofSize: 14, weight: .regular)
        label.textColor = .lightGray
        label.text = "0:00"
        return label
    }()
    
    private let remainingTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedDigitSystemFont(ofSize: 14, weight: .regular)
        label.textColor = .lightGray
        label.text = "-0:00"
        return label
    }()
    
    private lazy var playPauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setPreferredSymbolConfiguration(.init(pointSize: 44), forImageIn: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(playPauseTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var previousButton: UIButton = createControlButton(systemName: "backward.fill")
    private lazy var nextButton: UIButton = createControlButton(systemName: "forward.fill")
    
    private let volumeSlider: UISlider = {
        let slider = UISlider()
        slider.tintColor = .systemPink
        slider.setValue(0.8, animated: false)
        slider.setThumbImage(UIImage(systemName: "circle.fill"), for: .normal)
        return slider
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        audioPlayer.delegate = self
        setupViews()
        setupLayout()
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        previousButton.addTarget(self, action: #selector(previousTapped), for: .touchUpInside)
           if let url = audioURL, url != audioPlayer.currentURL {
               audioPlayer.play(url: url)
           }
           updatePlayPauseButton(isPlaying: audioPlayer.isPlaying)
        
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        }catch{
            print(error.localizedDescription)
        }
    }
    
    private func setupViews() {
        view.addSubview(backgroundView)
        view.addSubview(artworkImageView)
        view.addSubview(songLabel)
        view.addSubview(artistLabel)
        view.addSubview(progressSlider)
        view.addSubview(currentTimeLabel)
        view.addSubview(remainingTimeLabel)
        view.addSubview(playPauseButton)
        view.addSubview(previousButton)
        view.addSubview(nextButton)
        view.addSubview(volumeSlider)
    }
    
    private func createControlButton(systemName: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: systemName), for: .normal)
        button.tintColor = .white
        return button
    }
    
    private func setupLayout() {
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        artworkImageView.translatesAutoresizingMaskIntoConstraints = false
        songLabel.translatesAutoresizingMaskIntoConstraints = false
        artistLabel.translatesAutoresizingMaskIntoConstraints = false
        progressSlider.translatesAutoresizingMaskIntoConstraints = false
        currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        remainingTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        previousButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        volumeSlider.translatesAutoresizingMaskIntoConstraints = false
        playPauseButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        playPauseButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            artworkImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            artworkImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            artworkImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            artworkImageView.widthAnchor.constraint(equalTo: artworkImageView.heightAnchor, multiplier: 1),
            
            songLabel.topAnchor.constraint(equalTo: artworkImageView.bottomAnchor, constant: 20),
            songLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            songLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            artistLabel.topAnchor.constraint(equalTo: songLabel.bottomAnchor, constant: 8),
            artistLabel.leadingAnchor.constraint(equalTo: songLabel.leadingAnchor),
            artistLabel.trailingAnchor.constraint(equalTo: songLabel.trailingAnchor),
            
            progressSlider.topAnchor.constraint(equalTo: artistLabel.bottomAnchor, constant: 20),
            progressSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            progressSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            currentTimeLabel.leadingAnchor.constraint(equalTo: progressSlider.leadingAnchor),
            currentTimeLabel.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 5),
            
            remainingTimeLabel.trailingAnchor.constraint(equalTo: progressSlider.trailingAnchor),
            remainingTimeLabel.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 5),
            
            playPauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playPauseButton.topAnchor.constraint(equalTo: currentTimeLabel.bottomAnchor, constant: 20),
            previousButton.trailingAnchor.constraint(equalTo: playPauseButton.leadingAnchor, constant: -40),
            previousButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            
            nextButton.leadingAnchor.constraint(equalTo: playPauseButton.trailingAnchor, constant: 40),
            nextButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            
            volumeSlider.topAnchor.constraint(equalTo: playPauseButton.bottomAnchor, constant: 40),
            volumeSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            volumeSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
    
    private func updateUI() {
        guard let song, let album = HomeViewModel.shared.getAlbumForSong(song, from: HomeViewModel.shared.albums), let imageURL = URL(string: album.image) else {return}
        progressSlider.maximumValue = Float(audioPlayer.duration)
        artworkImageView.kf.setImage(with: imageURL)
        songLabel.text = song.title
        artistLabel.text = album.artist
        progressSlider.value = Float(audioPlayer.currentTime)
        updatePlayPauseButton(isPlaying: audioPlayer.isPlaying)
    }
    
    private func updatePlayPauseButton(isPlaying: Bool) {
        let icon = isPlaying ? "pause.fill" : "play.fill"
        playPauseButton.setImage(UIImage(systemName: icon), for: .normal)
    }
    
    @objc private func playPauseTapped() {
        if audioPlayer.isPlaying {
            audioPlayer.togglePlayback()
            updatePlayPauseButton(isPlaying: false)
        } else {
            audioPlayer.togglePlayback()
            updatePlayPauseButton(isPlaying: true)
        }
    }
    
    @objc private func updateProgress() {
        let currentTime = audioPlayer.currentTime
        let duration = audioPlayer.duration
        let timeRemaining = duration - currentTime
        
        progressSlider.value = Float(currentTime)
        
        currentTimeLabel.text = formatTime(currentTime)
        remainingTimeLabel.text = "-\(formatTime(timeRemaining))"
    }

    private func formatTime(_ time: TimeInterval) -> String {
        guard time.isFinite, !time.isNaN else {
            return "0:00"
        }
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    @objc private func previousTapped() {
        let previousSong = HomeViewModel.shared.getPreviousSong(from: song!, in: HomeViewModel.shared.albums)
        song = previousSong
        if let url = previousSong?.url, URL(string: url) != audioPlayer.currentURL {
            audioPlayer.play(url: URL(string: url)!)
        }
    }
    
    @objc private func nextTapped() {
        print("tapped")
        let nextSong = HomeViewModel.shared.getNextSong(from: song!, in: HomeViewModel.shared.albums)
        song = nextSong
        if let url = nextSong?.url, URL(string: url) != audioPlayer.currentURL {
            audioPlayer.play(url: URL(string: url)!)
        }
    }
}

extension NowPlayingViewController: HQAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        nextTapped()
    }
    func audioPlayerDidStartPlaying() {
        DispatchQueue.main.async {
            self.progressSlider.maximumValue = Float(self.audioPlayer.duration)
            self.updateProgress()
        }
    }

    func audioPlayerDidFinishPlaying(successfully: Bool, error: Error?) {
        // Handle playback finish (e.g., play next track)
    }

    func audioPlayerDidFailWithError(error: Error) {
        // Handle errors (e.g., show alert)
    }
}
