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
         urlRequest: URLRequestFactory = AuthURLRequestFactory(endpoint: Endpoint(path: "api/players"))) {
        self.session = session
        self.urlRequest = urlRequest
    }
    
    func update(player: Player, completion: @escaping (Result<Bool, Error>) -> Void) {
        let endpoint = Endpoint(path: "\(urlRequest.endpoint.path)/\(player.serverId)")
        urlRequest.endpoint = endpoint
  
        let playerCreateModel = PlayerCreateData(name: player.name,
                                                 age: Int(player.age),
                                                 skill: player.skillOption,
                                                 preferredPosition: player.positionOption,
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
