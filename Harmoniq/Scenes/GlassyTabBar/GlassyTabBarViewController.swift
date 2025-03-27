//
//  GlassyTabBarViewController.swift
//  Harmoniq
//
//  Created by Lasha Tavberidze on 14.02.25.
//
import UIKit
import Combine

public final class GlassyTabBarViewController: UITabBarController {
    // MARK: Properties
    private var toolbarView: PlayerToolBarView?
    private var overlayView: HQGradient!
    // let audioPlayer = HQAudioPlayer.shared
    private let backdropView = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
    private let fadeMask = CAGradientLayer()
    var currentlyPlayedSong: Song? {
        didSet{
            showPlayerToolbar()
            toolbarView?.song = currentlyPlayedSong
        }
    }
    private var cancellables = Set<AnyCancellable>()
    private let colorProcessor: ColorProcessing = DefaultColorProcessor()
    
    private var isPlayerToolbarActive: Bool = false
    
    // MARK: Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        updateVisuals()
    }
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateBackdropLayout()
    }
    
    public func showPlayerToolbar() {
        isPlayerToolbarActive = true
        if toolbarView == nil {
            setupToolbar()
        }
        updateToolbarPlayButton()
        updateBackdropLayout()
        setupOverlayView()
        animateToolbarAppearance(show: true)
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
    
    private func setupOverlayView() {
        overlayView = HQGradient()
        overlayView.locations = [0, 0.4, 1]
        overlayView.colours = [.white.withAlphaComponent(0), .white.withAlphaComponent(1), .white.withAlphaComponent(0.2)]
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        
        view.insertSubview(overlayView, aboveSubview: backdropView)
        
        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: toolbarView!.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
        tabBar.standardAppearance = appearance
    }
    //    private func updatePlayPauseButton(isPlaying: Bool) {
    //        let icon = isPlaying ? "pause.fill" : "play.fill"
    //        toolbarView?.playButton.setImage(UIImage(systemName: icon), for: .normal)
    //    }
    private func setupBackdrop() {
        backdropView.clipsToBounds = true
        backdropView.isUserInteractionEnabled = false
        view.insertSubview(backdropView, belowSubview: tabBar)
    }
    
    private func setupToolbar() {
        guard toolbarView == nil else { return }
        toolbarView = PlayerToolBarView()
        guard let toolbarView = toolbarView else { return }
        toolbarView.delegate = self
        toolbarView.translatesAutoresizingMaskIntoConstraints = false
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
    private func animateToolbarAppearance(show: Bool, completion: ((Bool) -> Void)? = nil) {
        guard let toolbarView = toolbarView else { return }
        toolbarView.isHidden = false
        toolbarView.transform = show ? CGAffineTransform(translationX: 0, y: toolbarView.frame.height) : .identity
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            toolbarView.transform = show ? .identity : CGAffineTransform(translationX: 0, y: toolbarView.frame.height)
        }, completion: { finished in
            if !show {
                toolbarView.isHidden = true
            }
            completion?(finished)
        })
    }
    // MARK: Layout
    private func updateBackdropLayout() {
        let toolbarHeight = toolbarView?.frame.height ?? 0
        let backdropHeight = tabBar.frame.height
        //+ toolbarHeight + (isPlayerToolbarActive ? 12 : 0)
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
    
    // MARK: Color Processing
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
        let invertedColor = color.enhancedInverted()
        UIView.animate(withDuration: 0.3) {
            self.tabBar.tintColor = invertedColor
            self.tabBar.unselectedItemTintColor = invertedColor.withAlphaComponent(1)
        }
    }
    
    func animateToNowPlaying() {
        guard let toolbarView = self.toolbarView else {
            print("toolbar not initialized")
            return
        }

        if let heightConstraint = toolbarView.constraints.first(where: { $0.firstAttribute == .height }) {
            heightConstraint.constant *= 1.4

            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
                toolbarView.alpha = 1
            })
        } else {
            let originalFrame = toolbarView.frame
            let newHeight = originalFrame.height * 1.4
            let heightDifference = newHeight - originalFrame.height

            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                toolbarView.frame = CGRect(x: originalFrame.origin.x,
                                           y: originalFrame.origin.y - heightDifference, 
                                           width: originalFrame.width,
                                           height: newHeight)
                toolbarView.alpha = 1
            })
        }
    }


    
    private func captureBackground() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        return renderer.image { context in
            view.layer.render(in: context.cgContext)
        }
    }
    private func setupPlayerObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerStateChanged),
            name: .AVPlayerItemDidPlayToEndTime,
            object: nil
        )
    }
    
    @objc private func playerStateChanged() {
        updateToolbarPlayButton()
    }
}
extension GlassyTabBarViewController: HQPlayerToolBarViewDelegate {
    
    func toolbarView(_ toolbarView: PlayerToolBarView, didTapPlayPause button: UIButton) {
        HQAudioPlayer.shared.togglePlayback()
        updateToolbarPlayButton()
    }
    
    func updateToolbarPlayButton() {
        let isPlaying = HQAudioPlayer.shared.isPlaying
        toolbarView?.playButton.configuration?.image = isPlaying ? UIImage(systemName: "pause.fill")
        : UIImage(systemName: "play.fill")
    }
    
    func toolbarView(_ toolbarView: PlayerToolBarView, didTapForwardButton button: UIButton) {
        currentlyPlayedSong = HomeViewModel.shared.getNextSong(from: currentlyPlayedSong!, in: HomeViewModel.shared.albums)
    }
    
    func toolbarView(_ toolbarView: PlayerToolBarView, tapGestureRecognised tapGestureRecogniser: UITapGestureRecognizer) {
        guard let song = currentlyPlayedSong else {return}
        let nowPlayingVC = NowPlayingViewController()
        nowPlayingVC.audioURL = URL(string: song.url)
        nowPlayingVC.song = song
        nowPlayingVC.onTap = { song in
            self.currentlyPlayedSong = song
        }
        nowPlayingVC.onDismiss = {
            self.updateToolbarPlayButton()
        }
        toolbarView.layoutIfNeeded()
        animateToNowPlaying()
        nowPlayingVC.modalPresentationStyle = .custom
        nowPlayingVC.transitioningDelegate = nowPlayingVC
        present(nowPlayingVC, animated: true)
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

extension UIColor {
    func enhancedInverted() -> UIColor {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // Enhance the inversion by increasing the contrast
        let invertedRed = 1.0 - red
        let invertedGreen = 1.0 - green
        let invertedBlue = 1.0 - blue
        
        // Ensure the colors are more prominent
        let enhancedRed = min(max(invertedRed * 1.2, 0), 1)
        let enhancedGreen = min(max(invertedGreen * 1.2, 0), 1)
        let enhancedBlue = min(max(invertedBlue * 1.2, 0), 1)
        
        return UIColor(red: enhancedRed, green: enhancedGreen, blue: enhancedBlue, alpha: alpha)
    }
}
extension GlassyTabBarViewController: AlbumDetailViewControllerDelegate{
    func didPlaySong(_ song: Song) {
        toolbarView?.song = song
    }
    
}
