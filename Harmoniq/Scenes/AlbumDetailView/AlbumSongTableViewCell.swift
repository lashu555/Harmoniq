//
//  AlbumSongTableViewCell.swift
//  Harmoniq
//
//  Created by Lasha Tavberidze on 19.02.25.
//

import UIKit

class AlbumSongTableViewCell: UITableViewCell {
    static let identifier = "SongTableViewCell"
    
    private let songNumberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
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
    
    func configure(number: Int, title: String, duration: String) {
        songNumberLabel.text = "\(number)"
        songTitleLabel.text = title
        durationLabel.text = duration
    }
}
