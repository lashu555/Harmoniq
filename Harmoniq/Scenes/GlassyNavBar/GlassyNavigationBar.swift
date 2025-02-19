//
//  GlassyNavigationBar.swift
//  Harmoniq
//
//  Created by Lasha Tavberidze on 15.02.25.
//

import UIKit

class GlassyNavigationController: UINavigationController {

    private lazy var blurEffect: UIBlurEffect = {
        return UIBlurEffect(style: .systemThinMaterial)
    }()
    
    private lazy var blurView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: blurEffect)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor(white: 1.0, alpha: 0.05)
        appearance.backgroundEffect = UIBlurEffect(style: .systemThinMaterial)
        appearance.shadowColor = .clear
        
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
        
        if let backgroundView = navigationBar.subviews.first {
            backgroundView.insertSubview(blurView, at: 0)
            
            NSLayoutConstraint.activate([
                blurView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor),
                blurView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor),
                blurView.topAnchor.constraint(equalTo: backgroundView.topAnchor),
                blurView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor)
            ])
        }
    }
}
