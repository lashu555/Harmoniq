//
//  UIAlbumTeaserView.swift
//  Harmoniq
//
//  Created by Lasha Tavberidze on 14.02.25.
//
import UIKit

struct AlbumInfo {
    let title: String
    let artist: String
    let imageURLString: String
    let releaseYear: String
}

class UIAlbumTeaserView: UIView {
    let imageView: UIImageView
    let titleLabel: UILabel
    let artistLabel: UILabel
    let yearLabel: UILabel
    let imageAverageColorView: UIView
    var albumInfo: AlbumInfo?
    
    // MARK: Lifecycle
    override init(frame: CGRect) {
        self.imageView = UIImageView()
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel = UILabel()
        self.titleLabel.font = .boldSystemFont(ofSize: 15)
        self.titleLabel.textAlignment = .center
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.artistLabel = UILabel()
        self.artistLabel.textAlignment = .center
        self.artistLabel.translatesAutoresizingMaskIntoConstraints = false
        self.yearLabel = UILabel()
        self.yearLabel.textAlignment = .center
        self.yearLabel.translatesAutoresizingMaskIntoConstraints = false
        self.imageAverageColorView = UIView()
        self.imageAverageColorView.translatesAutoresizingMaskIntoConstraints = false
        super.init(frame: frame)
        
        self.setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        applyCornerRadius()
    }
    
    private func setupSubviews() {
        addSubview(imageView)
        addSubview(imageAverageColorView)
        imageAverageColorView.addSubview(titleLabel)
        imageAverageColorView.addSubview(artistLabel)
        imageAverageColorView.addSubview(yearLabel)
        [titleLabel,artistLabel,yearLabel].forEach { $0.textColor = .label
            $0.font = .systemFont(ofSize: 15)
        }
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
        ])
        
        NSLayoutConstraint.activate([
            imageAverageColorView.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            imageAverageColorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageAverageColorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageAverageColorView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: imageAverageColorView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: imageAverageColorView.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: imageAverageColorView.trailingAnchor, constant: -10),
            
            artistLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            artistLabel.leadingAnchor.constraint(equalTo: imageAverageColorView.leadingAnchor, constant: 10),
            artistLabel.trailingAnchor.constraint(equalTo: imageAverageColorView.trailingAnchor, constant: -10),
            
            yearLabel.topAnchor.constraint(equalTo: artistLabel.bottomAnchor, constant: 4),
            yearLabel.leadingAnchor.constraint(equalTo: imageAverageColorView.leadingAnchor, constant: 10),
            yearLabel.trailingAnchor.constraint(equalTo: imageAverageColorView.trailingAnchor, constant: -10)
        ])
    }
    
    // MARK: Configure Method
    func configure(with albumInfo: AlbumInfo) {
        self.albumInfo = albumInfo
        titleLabel.text = albumInfo.title
        artistLabel.text = albumInfo.artist
        yearLabel.text = albumInfo.releaseYear
        
        if let url = URL(string: albumInfo.imageURLString) {
            downloadImage(from: url) { [weak self] image in
                DispatchQueue.main.async {
                    self?.imageView.image = image
                    if let averageColor = image?.averageColor {
                        self?.imageAverageColorView.backgroundColor = averageColor
                    }
                }
            }
        }
    }
    
    // MARK: Private Methods
    private func applyCornerRadius() {
        let imageViewPath = UIBezierPath(roundedRect: imageView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 10, height: 10))
        let imageViewMask = CAShapeLayer()
        imageViewMask.path = imageViewPath.cgPath
        imageView.layer.mask = imageViewMask
        
        let colorViewPath = UIBezierPath(roundedRect: imageAverageColorView.bounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 10, height: 10))
        let colorViewMask = CAShapeLayer()
        colorViewMask.path = colorViewPath.cgPath
        imageAverageColorView.layer.mask = colorViewMask
    }
    
    private func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            completion(image)
        }
        task.resume()
    }
}

extension UIImage {
    var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)
        
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull!])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
        
        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
}
