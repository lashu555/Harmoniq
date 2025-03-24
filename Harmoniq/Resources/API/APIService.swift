//
//  APIService.swift
//  Harmoniq
//
//  Created by Lasha Tavberidze on 24.02.25.
//

import Foundation

class APIService {
    static let shared = APIService()
    private init() {}
    
    func fetchAlbums(completion: @escaping (Result<Albums, Error>) -> Void) {
        let urlString = "https://67b8ebe251192bd378dc38ba.mockapi.io/HQ/albums"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let albums = try JSONDecoder().decode(Albums.self, from: data)
                completion(.success(albums))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    func fetchAlbumsFromAPI(completion: @escaping (Result<Albums, Error>) -> Void) {
        let urlString = "https://67b8ebe251192bd378dc38ba.mockapi.io/HQ/albums"
        print("Attempting to fetch from: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network error: \(error)")
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("No data received")
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            print("Received data size: \(data.count) bytes")
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("Raw response: \(responseString)")
            }
            
            do {
                let albums = try JSONDecoder().decode(Albums.self, from: data)
                print("Successfully decoded \(albums.count) albums")
                completion(.success(albums))
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
  
}
