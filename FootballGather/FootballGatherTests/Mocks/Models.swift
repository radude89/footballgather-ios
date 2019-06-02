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
                           skill: Player.Skill = ModelsMock.DefaultPlayer.skill,
                           preferredPosition: Player.Position = ModelsMock.DefaultPlayer.preferredPosition) -> PlayerCreateModel {
        return PlayerCreateModel(name: name, age: age, skill: skill, preferredPosition: preferredPosition, favouriteTeam: favouriteTeam)
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
        static let skill: Player.Skill = .beginner
        static let preferredPosition: Player.Position = .goalkeeper
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
