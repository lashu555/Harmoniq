//
//  AlbumDetailViewController.swift
//  Harmoniq
//
//  Created by Lasha Tavberidze on 18.02.25.
//

import UIKit

class AlbumDetailViewController: UIViewController {
    var albumInfo: AlbumInfo?
    private var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var albumCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        return imageView
    }()
    
    
    private var albumNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private var artistNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private var releaseYearLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private var genreLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .right
        return label
    }()
    
    private var bulletLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "•"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private var playButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 0.0, green: 0.6, blue: 0.6, alpha: 1.0)
        button.setTitle("Play", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    private var shuffleButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Shuffle", for: .normal)
        button.setTitleColor(UIColor(red: 0.0, green: 0.6, blue: 0.6, alpha: 1.0), for: .normal)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(red: 0.0, green: 0.6, blue: 0.6, alpha: 1.0).cgColor
        return button
    }()
    
    private var songsTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupTableView()
    }
    func configure(with albumInfo: AlbumInfo){
        self.albumInfo = albumInfo
        albumCoverImageView.image = UIImage(named: "cover")
        albumNameLabel.text = albumInfo.title
        artistNameLabel.text = albumInfo.artist
        releaseYearLabel.text = albumInfo.releaseYear
        genreLabel.text = "genre"
    }
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [albumCoverImageView, albumNameLabel, artistNameLabel,
         genreLabel, bulletLabel, releaseYearLabel, playButton, shuffleButton,
         songsTableView].forEach { contentView.addSubview($0) }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            albumCoverImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            albumCoverImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            albumCoverImageView.widthAnchor.constraint(equalToConstant: 300),
            albumCoverImageView.heightAnchor.constraint(equalToConstant: 300),
            
            albumNameLabel.topAnchor.constraint(equalTo: albumCoverImageView.bottomAnchor, constant: 20),
            albumNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            albumNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            artistNameLabel.topAnchor.constraint(equalTo: albumNameLabel.bottomAnchor, constant: 8),
            artistNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            artistNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            genreLabel.topAnchor.constraint(equalTo: artistNameLabel.bottomAnchor, constant: 8),
            genreLabel.trailingAnchor.constraint(equalTo: bulletLabel.leadingAnchor, constant: -8),
            
            bulletLabel.topAnchor.constraint(equalTo: artistNameLabel.bottomAnchor, constant: 8),
            bulletLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            bulletLabel.widthAnchor.constraint(equalToConstant: 10),
            
            releaseYearLabel.topAnchor.constraint(equalTo: artistNameLabel.bottomAnchor, constant: 8),
            releaseYearLabel.leadingAnchor.constraint(equalTo: bulletLabel.trailingAnchor, constant: 8),
            
            playButton.topAnchor.constraint(equalTo: genreLabel.bottomAnchor, constant: 20),
            playButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            playButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.43),
            playButton.heightAnchor.constraint(equalToConstant: 44),
            
            shuffleButton.topAnchor.constraint(equalTo: genreLabel.bottomAnchor, constant: 20),
            shuffleButton.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 16),
            shuffleButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            shuffleButton.widthAnchor.constraint(equalTo: playButton.widthAnchor),
            shuffleButton.heightAnchor.constraint(equalToConstant: 44),
            
            songsTableView.topAnchor.constraint(equalTo: shuffleButton.bottomAnchor, constant: 20),
            songsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            songsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            songsTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            songsTableView.heightAnchor.constraint(greaterThanOrEqualToConstant: 200)
        ])
        
        let contentViewHeight = contentView.heightAnchor.constraint(greaterThanOrEqualTo: view.heightAnchor)
        contentViewHeight.priority = .defaultLow
        contentViewHeight.isActive = true
    }
    
    private func setupTableView() {
        songsTableView.delegate = self
        songsTableView.dataSource = self
        songsTableView.register(AlbumSongTableViewCell.self, forCellReuseIdentifier: AlbumSongTableViewCell.identifier)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension AlbumDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: AlbumSongTableViewCell.identifier,
            for: indexPath
        ) as? AlbumSongTableViewCell else {
            return UITableViewCell()
        }
        
       
        cell.configure(number: indexPath.row + 1, title: "Song Title", duration: "3:45")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
