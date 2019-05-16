//
//  Networking.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 13/04/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - ServiceError
enum ServiceError: Error {
    case unexpectedResponse
    case locationHeaderNotFound
    case resourceIdNotFound
    case expectedDataInResponse
    case invalidRequestData
}

// MARK: - Network Session
protocol NetworkSession {
    func loadData(from urlRequest: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
}

extension URLSession: NetworkSession {
    func loadData(from urlRequest: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let task  = dataTask(with: urlRequest) { (data, response, error) in
            completionHandler(data, response, error)
        }
        
        task.resume()
    }
}

// MARK: - Endpoint
/// https://www.swiftbysundell.com/posts/constructing-urls-in-swift
struct Endpoint {
    let path: String
    let queryItems: [URLQueryItem]? = nil
    
    var url: URL? {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "localhost.com:8080"
        components.path = path
        components.queryItems = queryItems
        
        return components.url
    }
}

