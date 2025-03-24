//
//  Album.swift
//  Harmoniq
//
//  Created by Lasha Tavberidze on 24.02.25.
//

import Foundation

struct AlbumElement: Codable {
    let releaseYear, name, artist: String
    let songs: [Song]
    let image: String
    let id: String

    enum CodingKeys: String, CodingKey {
        case releaseYear = "release_year"
        case name, artist, songs, image, id
    }
}

struct Song: Codable {
    let title: String
    let url: String
    let duration, id, albumID: String

    enum CodingKeys: String, CodingKey {
        case title, url, duration, id
        case albumID = "albumId"
    }
}

typealias Albums = [AlbumElement]
