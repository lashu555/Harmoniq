//
//  SearchResultTableViewCell.swift
//  Harmoniq
//
//  Created by Lasha Tavberidze on 25.03.25.
//

import UIKit

class SearchResultTableViewCell: UITableViewCell {
    
    static let identifier = "SearchResultCell"
    var onTap: (() -> Void)?
    var song: Song? {
        didSet{
            guard let song else { return }
            configure(with: song)
        }
    }
    
    let songNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let artistNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let albumCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    let songStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setUpUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        onTap?()
    }
    
    private func setUpUI(){
        songStackView.addArrangedSubview(songNameLabel)
        songStackView.addArrangedSubview(artistNameLabel)
        [albumCoverImageView, songStackView].forEach({ uiView in
            contentView.addSubview(uiView)
        })
        NSLayoutConstraint.activate([
            albumCoverImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            albumCoverImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            albumCoverImageView.widthAnchor.constraint(equalToConstant: 48),
            albumCoverImageView.heightAnchor.constraint(equalToConstant: 48),
            songStackView.leadingAnchor.constraint(equalTo: albumCoverImageView.trailingAnchor, constant: 12),
            songStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            songStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 4),
            songStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
        ])
    }
    
    private func configure(with song: Song) {
        albumCoverImageView.image = UIImage(systemName: "apple.haptics.and.music.note")
        artistNameLabel.text = song.title
        songNameLabel.text = song.title
    }
}
