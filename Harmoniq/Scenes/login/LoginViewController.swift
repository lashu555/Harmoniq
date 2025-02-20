//
//  LoginViewController.swift
//  Harmoniq
//
//  Created by Lasha Tavberidze on 20.02.25.
//

import UIKit

class LoginViewController: UIViewController {
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Login with Spotify", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.widthAnchor.constraint(equalToConstant: 220).isActive = true
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        SpotifyAuthManager.shared.delegate = self
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(loginButton)
        
        NSLayoutConstraint.activate([
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    }
    
    @objc private func loginButtonTapped() {
        loginButton.setTitle("Connecting...", for: .normal)
        loginButton.isEnabled = false
        SpotifyAuthManager.shared.authenticateSpotify()
    }
}

extension LoginViewController: SpotifyAuthManagerDelegate {
    func authManagerDidInitiateSession(accessToken: String) {
        DispatchQueue.main.async {
            self.loginButton.setTitle("Login with Spotify", for: .normal)
            self.loginButton.isEnabled = true
            // Navigate to main app interface
        }
    }
    
    func authManagerDidFailWithError(_ error: Error) {
        DispatchQueue.main.async {
            self.loginButton.setTitle("Login with Spotify", for: .normal)
            self.loginButton.isEnabled = true
            
            let alert = UIAlertController(
                title: "Login Failed",
                message: "Could not connect to Spotify. Please try again.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    func authManagerDidRenewSession(accessToken: String) {
        // Handle session renewal if needed in UI
    }
}
