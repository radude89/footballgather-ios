//
//  PlayerNetworkService.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 02/06/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - Service
struct PlayerNetworkService: NetworkService {
    var session: NetworkSession
    var urlRequest: URLRequestFactory
    
    init(session: NetworkSession = URLSession.shared,
         urlRequest: URLRequestFactory = AuthURLRequestFactory(endpoint: StandardEndpoint(path: "/api/players"))) {
        self.session = session
        self.urlRequest = urlRequest
    }
    
}

// MARK - Create RequestModel
struct PlayerCreateModel: Encodable {
    let name: String
    let age: Int?
    let skill: Player.Skill?
    let preferredPosition: Player.Position?
    let favouriteTeam: String?
}

// MARK: - ResponseModel
struct PlayerResponseModel {
    let id: Int
    let name: String
    let age: Int?
    let skill: Player.Skill?
    let preferredPosition: Player.Position?
    let favouriteTeam: String?
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
        favouriteTeam = try container.decodeIfPresent(String.self, forKey: .favouriteTeam) ?? nil
        
        if let skillDesc = try container.decodeIfPresent(String.self, forKey: .skill) {
            skill = Player.Skill(rawValue: skillDesc)
        } else {
            skill = nil
        }
        
        if let posDesc = try container.decodeIfPresent(String.self, forKey: .preferredPosition) {
            preferredPosition = Player.Position(rawValue: posDesc)
        } else {
            preferredPosition = nil
        }
    }
}
