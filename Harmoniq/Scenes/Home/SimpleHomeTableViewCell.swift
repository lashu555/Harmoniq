//
//  SimpleHomeTableViewCell.swift
//  Harmoniq
//
//  Created by Lasha Tavberidze on 15.02.25.
//

import UIKit

class SimpleHomeTableViewCell: UITableViewCell {
    // MARK: Properties
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let albumCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let acv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        acv.translatesAutoresizingMaskIntoConstraints = false
        return acv
    }()
    
    weak var delegate: SimpleTableViewCellDelegate?
    private var albums: [AlbumInfo] = []
    // MARK: Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        selectionStyle = .none
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setUpHeaderLabel()
        setUpCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Private methods
    private func setUpHeaderLabel() {
        contentView.addSubview(headerLabel)
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            headerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    private func setUpCollectionView() {
        albumCollectionView.delegate = self
        albumCollectionView.dataSource = self
        albumCollectionView.showsHorizontalScrollIndicator = false
        albumCollectionView.register(SimpleAlbumCollectionViewCell.self, forCellWithReuseIdentifier: "SimpleAlbumCollectionCell")
        contentView.addSubview(albumCollectionView)
        NSLayoutConstraint.activate([
            albumCollectionView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 10),
            albumCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            albumCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            albumCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            albumCollectionView.heightAnchor.constraint(equalToConstant: 206)
        ])
    }
    
    //MARK: Configure
    func configure(with title: String, albums: [AlbumInfo]){
        self.headerLabel.text = title
        self.albums = albums
        self.albumCollectionView.reloadData()
    }
}

extension SimpleHomeTableViewCell: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        albums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = albumCollectionView.dequeueReusableCell(withReuseIdentifier: "SimpleAlbumCollectionCell", for: indexPath) as! SimpleAlbumCollectionViewCell
        guard !albums.isEmpty, albums.count > indexPath.row else {
            cell.configure(with: AlbumInfo(
                title: "No Album",
                artist: "Unknown Artist",
                imageURLString: "",
                releaseYear: ""
            ))
            return cell
        }
        
        cell.configure(with: albums[indexPath.row])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: 160, height: 206)
        }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectItem()
    }
}
protocol SimpleTableViewCellDelegate: AnyObject{
    func didSelectItem()
}
