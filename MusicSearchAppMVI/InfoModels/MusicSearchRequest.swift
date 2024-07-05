//
//  MusicSearchRequest.swift
//  MusicSearchAppMVI
//
//  Created by KKNANXX on 7/4/24.
//

import Foundation

struct MusicSearchRequest: RequestBuilder {
    var baseUrl: String { "https://deezerdevs-deezer.p.rapidapi.com" }
    var path: String? { "/search" }
    var method: HTTPMethod { .get }
    var headers: [String: String]? {
        ["x-rapidapi-host": "deezerdevs-deezer.p.rapidapi.com",
         "x-rapidapi-key": "cf4863382emsh660b0a010bd400dp1de074jsn26d3499ba6e2"]
    }
    var queryParam: [String: String]?
    
    init(query: String) {
        self.queryParam = ["q": query]
    }
}
