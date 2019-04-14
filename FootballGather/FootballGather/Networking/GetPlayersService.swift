//
//  GetPlayersService.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 14/04/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - Service
struct GetPlayersService {
    private let session: NetworkSession
    private let urlRequest: URLRequestFactory
    
    init(session: NetworkSession = URLSession.shared,
         urlRequest: URLRequestFactory = StandardURLRequestFactory(endpoint: Endpoint(path: "api/players"))) {
        self.session = session
        self.urlRequest = urlRequest
    }
    
    func getPlayers(completion: @escaping (Result<[PlayerResponseModel], Error>) -> Void) {
        let request = urlRequest.makeURLRequest()
        
        session.loadData(from: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(ServiceError.unexpectedResponse))
                return
            }
            
            do {
                let players = try JSONDecoder().decode([PlayerResponseModel].self, from: data)
                completion(.success(players))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
}

// MARK: - Model
struct PlayerResponseModel: Decodable {
    var id: Int
    var name: String
    var age: Int
    var skill: Skill?
    var preferredPosition: Position?
    var favouriteTeam: String?
    
    enum Skill: String, Codable {
        case beginner, amateur, professional
    }
    
    enum Position: String, Codable {
        case goalkeeper, defender, midfielder, winger, striker
    }
}
