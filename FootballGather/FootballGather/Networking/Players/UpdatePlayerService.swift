//
//  UpdatePlayerService.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 15/05/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - Service
final class UpdatePlayerService {
    private let session: NetworkSession
    private var urlRequest: URLRequestFactory
    
    init(session: NetworkSession = URLSession.shared,
         urlRequest: URLRequestFactory = AuthURLRequestFactory(endpoint: StandardEndpoint(path: "/api/players"))) {
        self.session = session
        self.urlRequest = urlRequest
    }
    
    func updatePlayer(_ player: PlayerUpdateModel, completion: @escaping (Result<Bool, Error>) -> Void) {
        var updatedEndpoint = urlRequest.endpoint
        updatedEndpoint.path = "\(updatedEndpoint.path)/\(player.serverId)"
        urlRequest.endpoint = updatedEndpoint
        
        let playerCreateModel = PlayerCreateModel(name: player.name,
                                                  age: player.age,
                                                  skill: player.skill,
                                                  preferredPosition: player.preferredPosition,
                                                  favouriteTeam: player.favouriteTeam)
        
        var request = urlRequest.makeURLRequest()
        request.httpMethod = "PUT"
        request.httpBody = try? JSONEncoder().encode(playerCreateModel)
        
        session.loadData(from: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 204 else {
                completion(.failure(ServiceError.unexpectedResponse))
                return
            }
            
            completion(.success(true))
        }
    }
    
}

// MARK: - Model
struct PlayerUpdateModel: Encodable {
    let serverId: Int
    var name: String
    var age: Int?
    var skill: Player.Skill?
    var preferredPosition: Player.Position?
    var favouriteTeam: String?
    
    init(serverId: Int,
         name: String,
         age: Int? = nil,
         skill: Player.Skill? = nil,
         preferredPosition: Player.Position? = nil,
         favouriteTeam: String? = nil) {
        self.serverId = serverId
        self.name = name
        self.age = age
        self.skill = skill
        self.preferredPosition = preferredPosition
        self.favouriteTeam = favouriteTeam
    }
}
