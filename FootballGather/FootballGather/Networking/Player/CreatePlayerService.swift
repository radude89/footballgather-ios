//
//  CreatePlayerService.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 15/05/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - Service
struct CreatePlayerService {
    private let session: NetworkSession
    private let urlRequest: URLRequestFactory
    
    init(session: NetworkSession = URLSession.shared,
         urlRequest: URLRequestFactory = AuthURLRequestFactory(endpoint: Endpoint(path: "api/players"))) {
        self.session = session
        self.urlRequest = urlRequest
    }
    
    func create(player: PlayerCreateData, completion: @escaping (Result<Int, Error>) -> Void) {
        var request = urlRequest.makeURLRequest()
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(player)
        
        session.loadData(from: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
                completion(.failure(ServiceError.unexpectedResponse))
                return
            }
            
            guard let playerIdLocation = httpResponse.allHeaderFields["Location"] as? String else {
                completion(.failure(ServiceError.locationHeaderNotFound))
                return
            }
            
            guard let playerIdValue = playerIdLocation.components(separatedBy: "/").last,
                let playerId = Int(playerIdValue) else {
                    completion(.failure(ServiceError.resourceIdNotFound))
                    return
            }
            
            completion(.success(playerId))
        }
    }
    
}

// MARK - Model
struct PlayerCreateData: Encodable {
    var name: String
    var age: Int
    var skill: Player.Skill?
    var preferredPosition: Player.Position?
    var favouriteTeam: String?
}
