//
//  PlayerServiceModels.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 02/06/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import Foundation

// MARK - Create RequestModel
struct PlayerCreateModel: Encodable {
    let name: String
    let age: Int?
    let skill: PlayerSkill?
    let preferredPosition: PlayerPosition?
    let favouriteTeam: String?
}

extension PlayerCreateModel {
    init(name: String) {
        self.name = name
        age = nil
        skill = nil
        preferredPosition = nil
        favouriteTeam = nil
    }
}

extension PlayerCreateModel {
    init(_ responseModel: PlayerResponseModel) {
        name = responseModel.name
        age = responseModel.age
        skill = responseModel.skill
        preferredPosition = responseModel.preferredPosition
        favouriteTeam = responseModel.favouriteTeam
    }
}

// MARK: - ResponseModel
struct PlayerResponseModel {
    let id: Int
    var name: String
    var age: Int?
    var skill: PlayerSkill?
    var preferredPosition: PlayerPosition?
    var favouriteTeam: String?
}

extension PlayerResponseModel: Equatable {
    static func ==(lhs: PlayerResponseModel, rhs: PlayerResponseModel) -> Bool {
        return lhs.id == rhs.id
    }
}

extension PlayerResponseModel: Hashable {}

extension PlayerResponseModel: Decodable {
    enum CodingKeys: String, CodingKey {
        case id, name, age, skill, preferredPosition, favouriteTeam
    }
    
    init(from decoder: Decoder) throws  {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        age = try container.decodeIfPresent(Int.self, forKey: .age)
        favouriteTeam = try container.decodeIfPresent(String.self, forKey: .favouriteTeam) ?? nil
        
        if let skillDesc = try container.decodeIfPresent(String.self, forKey: .skill) {
            skill = PlayerSkill(rawValue: skillDesc)
        } else {
            skill = nil
        }
        
        if let posDesc = try container.decodeIfPresent(String.self, forKey: .preferredPosition) {
            preferredPosition = PlayerPosition(rawValue: posDesc)
        } else {
            preferredPosition = nil
        }
    }
}

enum PlayerSkill: String, Codable, CaseIterable {
    case beginner, amateur, professional
}

enum PlayerPosition: String, Codable, CaseIterable {
    case goalkeeper, defender, midfielder, winger, striker
    
    var acronym: String {
        switch self {
        case .goalkeeper: return "GK"
        case .winger: return "W"
        case .striker: return "ST"
        default: return rawValue.prefix(3).uppercased()
        }
    }
}
