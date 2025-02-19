//
//  AlbumCollectionViewCell.swift
//  Harmoniq
//
//  Created by Lasha Tavberidze on 14.02.25.
//
import UIKit

class AlbumCollectionViewCell: UICollectionViewCell {
    private let caption: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = UIColor(red: 0.24, green: 0.24, blue: 0.26, alpha: 0.6)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var albumTeaser: UIAlbumTeaserView = {
        let atv = UIAlbumTeaserView()
        atv.translatesAutoresizingMaskIntoConstraints = false
        return atv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(caption)
        contentView.addSubview(albumTeaser)
        
        NSLayoutConstraint.activate([
            caption.topAnchor.constraint(equalTo: contentView.topAnchor),
            caption.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            caption.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            albumTeaser.topAnchor.constraint(equalTo: caption.bottomAnchor, constant: 8),
            albumTeaser.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            albumTeaser.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant:0),
            albumTeaser.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func configure(with topPick: TopPick) {
        caption.text = topPick.caption
        albumTeaser.configure(with: topPick.albumInfo)
    }
}

struct TopPick {
    let caption: String?
    let title: String
    let artist: String
    let releaseYear: String
    let imageURL: String
    
    var albumInfo: AlbumInfo {
        return AlbumInfo(
            title: title,
            artist: artist,
            imageURLString: imageURL,
            releaseYear: releaseYear
        )
    }
}
