//
//  UISimpleAlbumTeaserView.swift
//  Harmoniq
//
//  Created by Lasha Tavberidze on 15.02.25.
//

import UIKit

class UISimpleAlbumTeaserView: UIView {
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 8 
        return view
    }()
    
    private let infoStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        return stack
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 15)
        label.numberOfLines = 1
        return label
    }()
    
    private let artistLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(imageView)
        addSubview(infoStackView)
        
        infoStackView.addArrangedSubview(titleLabel)
        infoStackView.addArrangedSubview(artistLabel)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            
            infoStackView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 6),
            infoStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            infoStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            infoStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
        ])
    }
    
    func configure(with albumInfo: AlbumInfo) {
        titleLabel.text = albumInfo.title
        artistLabel.text = albumInfo.artist
        
        if let url = URL(string: albumInfo.imageURLString) {
            downloadImage(from: url) { [weak self] image in
                DispatchQueue.main.async {
                    self?.imageView.image = image
                }
            }
        }
    }
    
    private func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            completion(image)
        }.resume()
    }
}
