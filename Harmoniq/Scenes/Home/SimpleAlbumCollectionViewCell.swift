//
//  SimpleAlbumCollectionViewCell.swift
//  Harmoniq
//
//  Created by Lasha Tavberidze on 15.02.25.
//

import UIKit

class SimpleAlbumCollectionViewCell: UICollectionViewCell {
    let simpleAlbumTeaser: UISimpleAlbumTeaserView = {
        let view = UISimpleAlbumTeaserView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    //MARK: Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Private Methods
    private func setUpViews() {
        contentView.addSubview(simpleAlbumTeaser)
        NSLayoutConstraint.activate([
            simpleAlbumTeaser.topAnchor.constraint(equalTo: contentView.topAnchor),
            simpleAlbumTeaser.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            simpleAlbumTeaser.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            simpleAlbumTeaser.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    //MARK: Configure Method
    func configure(with albumInfo: AlbumInfo){
        simpleAlbumTeaser.configure(with: albumInfo)
    }
}
