//
//  Models.swift
//  FootballGatherTests
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 17/05/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import Foundation
@testable import FootballGather

enum ModelsMockFactory {
    static func makeUser(withUsername username: String = ModelsMock.DefaultUser.username,
                         password: String = ModelsMock.DefaultUser.password) -> UserRequestModel {
        return UserRequestModel(username: username, password: password)
    }
    
    static func makeGather(score: String? = ModelsMock.DefaultGather.score,
                           winnerTeam: String? = ModelsMock.DefaultGather.winnerTeam) -> GatherCreateModel {
        return GatherCreateModel(score: score, winnerTeam: winnerTeam)
    }
    
    static func makePlayer(name: String = ModelsMock.DefaultPlayer.name,
                           age: Int? = ModelsMock.DefaultPlayer.age,
                           favouriteTeam: String? = ModelsMock.DefaultPlayer.favouriteTeam,
                           skill: PlayerSkill = ModelsMock.DefaultPlayer.skill,
                           preferredPosition: PlayerPosition = ModelsMock.DefaultPlayer.preferredPosition) -> PlayerCreateModel {
        return PlayerCreateModel(name: name, age: age, skill: skill, preferredPosition: preferredPosition, favouriteTeam: favouriteTeam)
    }
    
    static func makePlayerResponseModel(id: Int,
                                        name: String = ModelsMock.DefaultPlayer.name,
                                        age: Int? = ModelsMock.DefaultPlayer.age,
                                        favouriteTeam: String? = ModelsMock.DefaultPlayer.favouriteTeam,
                                        skill: PlayerSkill = ModelsMock.DefaultPlayer.skill,
                                        preferredPosition: PlayerPosition = ModelsMock.DefaultPlayer.preferredPosition) -> PlayerResponseModel {
        return PlayerResponseModel(id: id, name: name, age: age, skill: skill, preferredPosition: preferredPosition, favouriteTeam: favouriteTeam)
    }
    
    static func makeGatherModel(numberOfPlayers: Int, gatherUUID: UUID = ModelsMock.gatherUUID) -> GatherModel {
        let allSkills = PlayerSkill.allCases
        let allPositions = PlayerPosition.allCases
        
        var playerTeams: [PlayerTeamModel] = []
        
        (1...numberOfPlayers).forEach { index in
            let skill = allSkills[Int.random(in: 0..<allSkills.count)]
            let position = allPositions[Int.random(in: 0..<allPositions.count)]
            let team: TeamSection = index % 2 == 0 ? .teamA : .teamB
            
            let playerResponseModel = makePlayerResponseModel(id: index, name: "Player \(index)", age: 20 + index, favouriteTeam: "Fav team \(index)", skill: skill, preferredPosition: position)
            let playerTeamModel = PlayerTeamModel(team: team, player: playerResponseModel)
            
            playerTeams.append(playerTeamModel)
        }
        
        return GatherModel(players: playerTeams, gatherUUID: gatherUUID)
    }
}

enum ModelsMock {
    enum DefaultUser {
        static let username = "demo-user"
        static let password = "demo-password"
    }
    
    enum DefaultPlayer {
        static let serverId = 4
        static let name = "John"
        static let age = 18
        static let skill: PlayerSkill = .beginner
        static let preferredPosition: PlayerPosition = .goalkeeper
        static let favouriteTeam = "FC Team United"
    }
    
    enum DefaultGather {
        static let score = "1-1"
        static let winnerTeam = "None"
    }
    
    static let userUUID = UUID(uuidString: "939C0E30-7C25-436D-9AC6-571C2E339AB7")!
    static let gatherUUID = UUID(uuidString: "E88FE54F-AEE4-4160-8410-CB538BC04E9F")!
    static let playerId = 4
    static let token = "v2s4o0XcRgDHF/VojbAmGQ=="
}
