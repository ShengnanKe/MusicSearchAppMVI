//
//  HttpClient.swift
//  MusicSearchAppMVI
//
//  Created by KKNANXX on 7/4/24.
//

// 需要看一看 future and promise
// https://developer.apple.com/documentation/combine/future

import Foundation
import Combine
import SwiftUI

enum AppError: Error {
    case badURL
    case badResponse
    case badData
    case decoderError
    case serverError(Error?)
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

protocol RequestBuilder {
    var baseUrl: String { get }
    var path: String? { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var queryParam: [String: String]? { get }
    var bodyParam: [String: Any]? { get }
    
    func buildRequest() throws -> URLRequest
}

extension RequestBuilder {
    var baseUrl: String { "" }
    var headers: [String: String]? { nil }
    var queryParam: [String: String]? { nil }
    var bodyParam: [String: Any]? { nil }
    
    func buildRequest() throws -> URLRequest {
        // Get the url components
        guard var urlComponents = URLComponents(string: baseUrl) else {
            throw AppError.badURL
        }
        
        // Adding path to url component
        if let path = path {
            urlComponents.path = urlComponents.path.appending(path)
        }
        
        // Add query param
        if let queryParam = queryParam {
            let encodedQuery = encodeParam(queryParam)
            urlComponents.query = encodedQuery
        }
        
        guard let url = urlComponents.url else {
            throw AppError.badURL
        }
        
        // Method type
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        // Adding Headers
        if let headers = headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        // Add body params
        if let bodyParam = bodyParam {
            request.httpBody = try JSONSerialization.data(withJSONObject: bodyParam)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        return request
    }
    
    private func encodeParam(_ params: [String: String]) -> String? {
        var components = URLComponents()
        components.queryItems = params.map { URLQueryItem(name: $0, value: $1) }
        return components.percentEncodedQuery
    }
}



class HttpClient {
    func fetchDataPublisher<T: Decodable>(from requestBuilder: RequestBuilder) -> AnyPublisher<T, Error> {
        do {
            let request = try requestBuilder.buildRequest()
            return URLSession.shared.dataTaskPublisher(for: request)
                .tryMap { data, response in
                    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                        throw URLError(.badServerResponse)
                    }
                    return data
                }
                .decode(type: T.self, decoder: JSONDecoder())
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
    
    func downloadPublisher(from requestBuilder: RequestBuilder) -> AnyPublisher<URL, Error> {
        do {
            let request = try requestBuilder.buildRequest()
            return Future<URL, Error> { promise in
                let task = URLSession.shared.downloadTask(with: request) { tempURL, response, error in
                    if let error = error {
                        promise(.failure(error))
                    } else if let tempURL = tempURL, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                        promise(.success(tempURL))
                    } else {
                        promise(.failure(URLError(.badServerResponse)))
                    }
                }
                task.resume()
            }
            .eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
    
    func fetchImagePublisher(from url: URL) -> AnyPublisher<UIImage?, Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return UIImage(data: data)
            }
            .eraseToAnyPublisher()
    }
    
    func fetchDataPublisher(from url: URL) -> AnyPublisher<Data, Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .eraseToAnyPublisher()
    }
}
