//
//  GatherNetworkService.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 02/06/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - Service
struct GatherNetworkService: NetworkService {
    var session: NetworkSession
    var urlRequest: URLRequestFactory
    
    init(session: NetworkSession = URLSession.shared,
         urlRequest: URLRequestFactory = AuthURLRequestFactory(endpoint: StandardEndpoint(path: "/api/gathers"))) {
        self.session = session
        self.urlRequest = urlRequest
    }
}

// MARK: - RequestModel
struct GatherCreateModel: Encodable {
    let score: String?
    let winnerTeam: String?
    
    init(score: String? = nil, winnerTeam: String? = nil) {
        self.score = score
        self.winnerTeam = winnerTeam
    }
}

// MARK: - ResponseModel
struct GatherResponseModel: Decodable {
    let id: UUID
    let userId: UUID
    let score: String?
    let winnerTeam: String?
}
