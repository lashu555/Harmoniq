//
//  HomeViewModel.swift
//  Harmoniq
//
//  Created by Lasha Tavberidze on 24.02.25.
//

import Foundation

class HomeViewModel {
    static let shared = HomeViewModel()
    var albums: Albums = [] {
        didSet{
            DispatchQueue.main.async {
                self.onSet?()
            }
        }
    }
    var onSet: (()->())?
    init() {}
    
    func fetchAlbums() {
        APIService.shared.fetchAlbumsFromAPI { result in
            switch result {
            case .success(let fetchedAlbums):
                print(fetchedAlbums.count)
                self.albums = fetchedAlbums
                print( self.albums.count)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func getAlbumForSong(_ song: Song, from albums: Albums) -> AlbumElement? {
        return albums.first { $0.id == song.albumID }
    }

    func getNextSong(from currentSong: Song, in albums: Albums) -> Song? {
        guard let album = getAlbumForSong(currentSong, from: albums) else { return nil }
        
        guard let currentIndex = album.songs.firstIndex(where: { $0.id == currentSong.id }) else {
            return nil
        }

        let nextIndex = currentIndex + 1
        return nextIndex < album.songs.count ? album.songs[nextIndex] : album.songs.first
    }

}
