//
//  HomeTableViewCell.swift
//  Harmoniq
//
//  Created by Lasha Tavberidze on 14.02.25.
//
import UIKit

class HomeTableViewCell: UITableViewCell {
    
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
    
    private var topPs = [TopPick]()
    
    weak var delegate: HomeTableViewCellDelegate?
    
    //MARK: Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setUpHeaderLabel()
        setUpCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK: Private Methods
    private func setUpHeaderLabel(){
        contentView.addSubview(headerLabel)
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            headerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    private func setUpCollectionView(){
        albumCollectionView.delegate = self
        albumCollectionView.dataSource = self
        albumCollectionView.showsHorizontalScrollIndicator = false
        albumCollectionView.register(AlbumCollectionViewCell.self, forCellWithReuseIdentifier: "albumCollectionCell")
        contentView.addSubview(albumCollectionView)
        NSLayoutConstraint.activate([
            albumCollectionView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor),
            albumCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            albumCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            albumCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            albumCollectionView.heightAnchor.constraint(equalToConstant: 393)
        ])
    }
    
    func configure(with header: String, topPicks: [TopPick]){
        self.headerLabel.text = header
        self.topPs = topPicks
        self.albumCollectionView.reloadData()
    }
}

//MARK: - Extensions
extension HomeTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return topPs.count
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedTopPick = topPs[indexPath.row]
        delegate?.didSelectItem(topPick: selectedTopPick)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "albumCollectionCell", for: indexPath) as! AlbumCollectionViewCell
        cell.configure(with: topPs[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 278, height: 393)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        12
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    }
    
}

protocol HomeTableViewCellDelegate: AnyObject {
    func didSelectItem(topPick: TopPick)
}
