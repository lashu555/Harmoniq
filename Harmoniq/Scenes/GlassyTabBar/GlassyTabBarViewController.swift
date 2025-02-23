//
//  GlassyTabBarViewController.swift
//  Harmoniq
//
//  Created by Lasha Tavberidze on 14.02.25.
//
import UIKit
import Combine

public final class GlassyTabBarViewController: UITabBarController {
    // MARK: - Properties
    private var toolbarView: PlayerToolBarView?
    private let backdropView = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
    private let fadeMask = CAGradientLayer()
    private var cancellables = Set<AnyCancellable>()
    private let colorProcessor: ColorProcessing = DefaultColorProcessor()
    
    private var isPlayerToolbarActive: Bool = false
    
    
    // MARK: Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        showPlayerToolbar()
        setupView()
        updateVisuals()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateBackdropLayout()
    }
    public func showPlayerToolbar() {
        isPlayerToolbarActive = true
        setupToolbar()
        updateBackdropLayout()
    }
    
    public func hidePlayerToolbar() {
        isPlayerToolbarActive = false
        removeToolbar()
        updateBackdropLayout()
    }
    // MARK: Setup
    private func setupView() {
        setupTabBarAppearance()
        setupViewControllers()
        setupBackdrop()
        if isPlayerToolbarActive {
            setupToolbar()
        }
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
        tabBar.standardAppearance = appearance
    }
    
    private func setupBackdrop() {
        backdropView.clipsToBounds = true
        backdropView.isUserInteractionEnabled = false
        view.insertSubview(backdropView, belowSubview: tabBar)
    }
    
    private func setupToolbar() {
        // If toolbar already exists, do nothing
        guard toolbarView == nil else { return }
        toolbarView = PlayerToolBarView()
        guard let toolbarView = toolbarView else { return }
        toolbarView.delegate = self
        toolbarView.translatesAutoresizingMaskIntoConstraints = false
        toolbarView.song = HQSong(artwork: UIImage(systemName: "music.note")!, title: "Song Title")
        view.addSubview(toolbarView)
        setupToolbarConstraints()
    }
    
    private func removeToolbar() {
        toolbarView?.removeFromSuperview()
        toolbarView = nil
    }
    
    private func setupToolbarConstraints() {
        guard let toolbarView = toolbarView else { return }
        
        NSLayoutConstraint.activate([
            toolbarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            toolbarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            toolbarView.bottomAnchor.constraint(equalTo: tabBar.topAnchor, constant: -6)
        ])
    }
    
    // MARK: - Layout
    private func updateBackdropLayout() {
        let toolbarHeight = toolbarView?.frame.height ?? 0
        let backdropHeight = tabBar.frame.height + toolbarHeight + (isPlayerToolbarActive ? 12 : 0)
        let backdropFrame = CGRect(
            x: 0,
            y: view.bounds.maxY - backdropHeight,
            width: view.bounds.width,
            height: backdropHeight
        )
        
        UIView.animate(withDuration: 0.3) {
            self.backdropView.frame = backdropFrame
        }
        
        updateContentInsets()
        updateVisuals()
    }
    
    private func updateContentInsets() {
        let toolbarHeight = toolbarView?.frame.height ?? 0
        let bottomInset = tabBar.frame.height + toolbarHeight + (isPlayerToolbarActive ? 24 : 0)
        viewControllers?.forEach {
            $0.additionalSafeAreaInsets.bottom = bottomInset
        }
    }
    
    private func setupViewControllers() {
        viewControllers = [
            createNavController(HomeViewController(), title: "Home", icon: "house"),
            createNavController(SearchViewController(), title: "Search", icon: "magnifyingglass")
        ]
    }
    
    private func createNavController(_ root: UIViewController, title: String, icon: String) -> UIViewController {
        let nav = UINavigationController(rootViewController: root)
        nav.tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(systemName: icon),
            selectedImage: UIImage(systemName: "\(icon).fill")
        )
        return nav
    }
    
    // MARK: - Color Processing
    private func updateVisuals() {
        guard let image = captureBackground() else { return }
        
        Task {
            if let color = await colorProcessor.processImageColor(image) {
                await MainActor.run {
                    self.updateTabBarColors(with: color)
                }
            }
        }
    }
    
    private func updateTabBarColors(with color: UIColor) {
        let invertedColor = color.inverted()
        UIView.animate(withDuration: 0.3) {
            self.tabBar.tintColor = invertedColor
            self.tabBar.unselectedItemTintColor = invertedColor.withAlphaComponent(0.6)
        }
    }
    
    private func captureBackground() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        return renderer.image { context in
            view.layer.render(in: context.cgContext)
        }
    }
}
extension GlassyTabBarViewController: HQPlayerToolBarViewDelegate {
    func toolbarView(_ toolbarView: PlayerToolBarView, didTapPlayPause button: UIButton) {
        print("play tapped")
        let nowPlayingVC = NowPlayingViewController()
        guard let audioURL = Bundle.main.url(forResource: "02. CRAZY", withExtension: "m4a") else {
            fatalError("Could not find audio file!")
        }
        nowPlayingVC.audioURL = audioURL
        navigationController?.pushViewController(nowPlayingVC, animated: true)
    }
    
    func toolbarView(_ toolbarView: PlayerToolBarView, tapGestureRecognised tapGestureRecogniser: UITapGestureRecognizer) {
        print("Toolbar tapped")
        let nowPlayingVC = NowPlayingViewController()
        guard let audioURL = Bundle.main.url(forResource: "02. CRAZY", withExtension: "m4a") else {
            fatalError("Could not find audio file!")
        }
        nowPlayingVC.audioURL = audioURL
        navigationController?.pushViewController(nowPlayingVC, animated: true)
    }
}


// MARK: - Color Processing Protocol

public protocol ColorProcessing {
    func processImageColor(_ image: UIImage) async -> UIColor?
}

public final class DefaultColorProcessor: ColorProcessing {
    
    public init() {}
    
    public func processImageColor(_ image: UIImage) async -> UIColor? {
        guard let inputImage = CIImage(image: image) else { return nil }
        
        let parameters = [
            kCIInputImageKey: inputImage,
            kCIInputExtentKey: CIVector(cgRect: inputImage.extent)
        ]
        
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: parameters),
              let outputImage = filter.outputImage else { return nil }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: CGColorSpaceCreateDeviceRGB()])
        
        context.render(
            outputImage,
            toBitmap: &bitmap,
            rowBytes: 4,
            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
            format: .RGBA8,
            colorSpace: nil
        )
        
        return UIColor(
            red: CGFloat(bitmap[0]) / 255.0,
            green: CGFloat(bitmap[1]) / 255.0,
            blue: CGFloat(bitmap[2]) / 255.0,
            alpha: 1.0
        )
    }
}


// MARK: - UIColor Extension
extension UIColor {
    func inverted() -> UIColor {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return UIColor(red: 1.0 - red, green: 1.0 - green, blue: 1.0 - blue, alpha: alpha)
    }
}

