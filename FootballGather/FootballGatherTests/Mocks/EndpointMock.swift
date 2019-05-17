//
//  EndpointMock.swift
//  FootballGatherTests
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 16/05/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import Foundation
@testable import FootballGather

struct EndpointMock: Endpoint {
    var path: String
    var queryItems: [URLQueryItem]? = nil
    var scheme: String? = "http"
    var host: String? = "localhost"
    var port: Int? = 9999
    
    init(path: String) {
        self.path = path
    }
}

enum URLSessionMockFactory {
    static func makeSession() -> URLSession {
        let urlSession = URLSession(configuration: .ephemeral)
        return urlSession
    }
}

enum EndpointMockFactory {
    static func makeSuccessfulEndpoint(path: String) -> EndpointMock {
        let routePath = "\(path)/success"
        return EndpointMock(path: routePath)
    }
    
    static func makeErrorEndpoint() -> EndpointMock {
        let routePath = "/api/server-error"
        return EndpointMock(path: routePath)
    }
    
    static func makeEmptyReÔsponseEndpoint() -> EndpointMock {
        let routePath = "/api/empty"
        return EndpointMock(path: routePath)
    }
    
    static func makeInvalidModelTansformEndpoint() -> EndpointMock {
        let routePath = "/api/model-transform-error"
        return EndpointMock(path: routePath)
    }
    
    static func makeUnexpectedStatusCodeCreateEndpoint() -> EndpointMock {
        let routePath = "/api/invalid-status-code"
        return EndpointMock(path: routePath)
    }
    
    static func makeLocationHeaderNotFoundEndpoint() -> EndpointMock {
        let routePath = "/api/location-not-found"
        return EndpointMock(path: routePath)
    }
    
    static func makeInvalidResourceIDCreateEndpoint() -> EndpointMock {
        let routePath = "/api/invalid-uuid"
        return EndpointMock(path: routePath)
    }
}
