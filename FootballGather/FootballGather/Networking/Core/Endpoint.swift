//
//  Endpoint.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 02/06/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - Endpoint
protocol Endpoint {
    var path: String { get set }
    var queryItems: [URLQueryItem]? { get set }
    
    var scheme: String? { get }
    var host: String? { get }
    var port: Int? { get }
    var url: URL? { get }
}

extension Endpoint {
    var url: URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        components.queryItems = queryItems
        components.port = port
        
        return components.url
    }
}

// MARK: - Basic implementation
struct StandardEndpoint: Endpoint {
    var path: String
    var queryItems: [URLQueryItem]? = nil
    var scheme: String? = "http"
    var host: String? = "localhost"
    var port: Int? = 8080
    
    init(path: String) {
        self.path = path
    }
}

extension StandardEndpoint: ExpressibleByStringLiteral {
    init(stringLiteral value: StringLiteralType) {
        path = value
    }
}
