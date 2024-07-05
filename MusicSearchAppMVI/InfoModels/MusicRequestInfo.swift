//
//  MusicRequestInfo.swift
//  MusicSearchAppMVI
//
//  Created by KKNANXX on 7/4/24.
//

import Foundation

struct MusicRequestInfo: Codable {
    
    let data: [SongInfo]
    let total: Int
    let next: String

    enum CodingKeys: String, CodingKey {
        case data
        case total
        case next
    }
}

struct SongInfo: Codable {
    let title: String
    let preview: String
    let artist: ArtistInfo
    let album: AlbumInfo
    
    enum CodingKeys: String, CodingKey{
        case title
        case preview
        case artist
        case album
    }
}

struct ArtistInfo: Codable {
    let name: String
    let artistPicture: String
    let artistPictureSmall: String
    let type: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case artistPicture = "picture_big"
        case artistPictureSmall = "picture_small"
        case type
    }
    
    var effectiveArtistPicture: String {
        return artistPicture.isEmpty ? artistPictureSmall : artistPicture
    }
}

struct AlbumInfo: Codable {
    let title: String
    let songCover: String
    let songCoverSmall: String
    let type: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case songCover = "cover_big"
        case songCoverSmall = "cover_small"
        case type
    }
    
    var effectiveSongCover: String {
        return songCover.isEmpty ? songCoverSmall : songCover
    }
}
