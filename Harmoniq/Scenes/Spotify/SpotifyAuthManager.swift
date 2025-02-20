//
//  SpotifyAuthManager.swift
//  Harmoniq
//
//  Created by Lasha Tavberidze on 21.02.25.
//
import Foundation
import SpotifyiOS

protocol SpotifyAuthManagerDelegate: AnyObject {
    func authManagerDidInitiateSession(accessToken: String)
    func authManagerDidFailWithError(_ error: Error)
    func authManagerDidRenewSession(accessToken: String)
}

class SpotifyAuthManager: NSObject {
    static let shared = SpotifyAuthManager()
    
    private let clientID = "7c7ac544f56c4683a2ba3fb7dd314e4d"
    private let redirectURI = URL(string: "harmoniq://callback")!
    
    private var sessionManager: SPTSessionManager?
    weak var delegate: SpotifyAuthManagerDelegate?
    
    private override init() {
        super.init()
        configureSpotify()
    }
    
    private func configureSpotify() {
        let configuration = SPTConfiguration(clientID: clientID, redirectURL: redirectURI)
        sessionManager = SPTSessionManager(configuration: configuration, delegate: self)
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.sessionManager = sessionManager
        }
    }
    
    func authenticateSpotify() {
        let scopes: SPTScope = [
            .userReadPrivate,
            .userReadEmail,
            .playlistReadPrivate,
            .userLibraryRead,
            .streaming
        ]
        
        sessionManager?.initiateSession(with: scopes, campaign: nil)
    }
}

extension SpotifyAuthManager: SPTSessionManagerDelegate {
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        UserDefaults.standard.set(session.accessToken, forKey: "spotify_access_token")
        UserDefaults.standard.set(session.refreshToken, forKey: "spotify_refresh_token")
        UserDefaults.standard.set(session.expirationDate.timeIntervalSince1970, forKey: "token_expiration_date")
        
        delegate?.authManagerDidInitiateSession(accessToken: session.accessToken)
    }
    
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        delegate?.authManagerDidFailWithError(error)
    }
    
    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
        UserDefaults.standard.set(session.accessToken, forKey: "spotify_access_token")
        UserDefaults.standard.set(session.expirationDate.timeIntervalSince1970, forKey: "token_expiration_date")
        
        delegate?.authManagerDidRenewSession(accessToken: session.accessToken)
    }
}
