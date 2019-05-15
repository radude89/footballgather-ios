//
//  GetPlayersService.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 14/04/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - Service
final class GetPlayersService {
    private let session: NetworkSession
    private let urlRequest: URLRequestFactory
    
    init(session: NetworkSession = URLSession.shared,
         urlRequest: URLRequestFactory = AuthURLRequestFactory(endpoint: Endpoint(path: "api/players"))) {
        self.session = session
        self.urlRequest = urlRequest
    }
    
    func getPlayers(completion: @escaping (Result<[PlayerResponseModel], Error>) -> Void) {
        var request = urlRequest.makeURLRequest()
        request.httpMethod = "GET"
        
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
struct PlayerResponseModel {
    var id: Int
    var name: String
    var age: Int
    var skill: Player.Skill?
    var preferredPosition: Player.Position?
    var favouriteTeam: String?
}

extension PlayerResponseModel: Decodable {
    enum CodingKeys: String, CodingKey {
        case id, name, age, skill, preferredPosition, favouriteTeam
    }
    
    init(from decoder: Decoder) throws  {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        age = try container.decode(Int.self, forKey: .age)
        favouriteTeam = try container.decodeIfPresent(String.self, forKey: .favouriteTeam)
        
        if let skillDesc = try container.decodeIfPresent(String.self, forKey: .skill) {
            skill = Player.Skill(rawValue: skillDesc)
        }
        
        if let posDesc = try container.decodeIfPresent(String.self, forKey: .preferredPosition) {
            preferredPosition = Player.Position(rawValue: posDesc)
        }
    }
}
