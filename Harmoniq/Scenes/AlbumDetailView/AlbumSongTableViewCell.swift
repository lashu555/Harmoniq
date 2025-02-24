//
//  AlbumSongTableViewCell.swift
//  Harmoniq
//
//  Created by Lasha Tavberidze on 19.02.25.
//

import UIKit

class AlbumSongTableViewCell: UITableViewCell {
    static let identifier = "SongTableViewCell"
    
    private let songNumberLabel: UIButton = {
        let label = UIButton()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setImage(UIImage(systemName: "play.fill"), for: .normal)
        label.tintColor = UIColor(red: 0.0, green: 0.6, blue: 0.6, alpha: 1.0)
        label.setTitleColor(.secondaryLabel, for: .normal)
        return label
    }()
    
    private let songTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        [songNumberLabel, songTitleLabel, durationLabel].forEach { contentView.addSubview($0) }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            songNumberLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            songNumberLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            songNumberLabel.widthAnchor.constraint(equalToConstant: 30),
            
            songTitleLabel.leadingAnchor.constraint(equalTo: songNumberLabel.trailingAnchor, constant: 12),
            songTitleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            songTitleLabel.trailingAnchor.constraint(equalTo: durationLabel.leadingAnchor, constant: -12),
            
            durationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            durationLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            durationLabel.widthAnchor.constraint(equalToConstant: 50)
        ])
    }
    func configure(with song: Song){
        songTitleLabel.text = song.title
        var formattedDuration = ""
        if let totalSeconds = Double(song.duration) {
            let minutes = Int(totalSeconds) / 60
            let seconds = Int(totalSeconds) % 60
            formattedDuration = String(format: "%d:%02d", minutes, seconds)
        }
        durationLabel.text = formattedDuration
    }
}
