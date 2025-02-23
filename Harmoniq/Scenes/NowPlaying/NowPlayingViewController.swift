//
//  NowPlayingViewController.swift
//  Harmoniq
//
//  Created by Lasha Tavberidze on 23.02.25.
//
import UIKit
import AVFoundation

class NowPlayingViewController: UIViewController {
    
    let audioPlayer = HQAudioPlayer.shared
    var audioURL: URL?
    var song: HQSong? {
        didSet { updateUI() }
    }
    
    // MARK: - UI Components
    private let backgroundView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemThickMaterialDark)
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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupLayout()
        setupObservers()
        
        if let url = audioURL {
            audioPlayer.play(url: url)
            updatePlayPauseButton(isPlaying: true)
        }
    }
    
    // MARK: - Setup Methods
    private func setupViews() {
        view.backgroundColor = .black
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
            
            artworkImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            artworkImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            artworkImageView.widthAnchor.constraint(equalToConstant: 250),
            artworkImageView.heightAnchor.constraint(equalToConstant: 250),
            
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
        ])    }
    
    private func setupObservers() {
        remainingTimeLabel.text = String(audioPlayer.duration/60)
    }
    
    private func updateUI() {
        songLabel.text = song?.title
        artistLabel.text = song?.title
        artworkImageView.image = song?.artwork
    }
    
    private func updatePlayPauseButton(isPlaying: Bool) {
        let icon = isPlaying ? "pause.fill" : "play.fill"
        playPauseButton.setImage(UIImage(systemName: icon), for: .normal)
    }
    
    // MARK: - Actions
    @objc private func playPauseTapped() {
        if audioPlayer.isPlaying {
            audioPlayer.togglePlayback()
            updatePlayPauseButton(isPlaying: false)
        } else {
            audioPlayer.togglePlayback()
            updatePlayPauseButton(isPlaying: true)
        }
    }
    
    @objc private func previousTapped() {
        // Previous track logic (to be implemented)
    }
    
    @objc private func nextTapped() {
        // Next track logic (to be implemented)
    }
}
