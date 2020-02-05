//
//  TeamSection.swift
//  FootballGather
//
//  Created by Radu Dan on 26/02/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - TeamSection
enum TeamSection: Int, CaseIterable {
    case bench = 0, teamA, teamB
    
    var headerTitle: String {
        switch self {
        case .bench: return "Bench"
        case .teamA: return "Team A"
        case .teamB: return "Team B"
        }
    }
}

// MARK: - PlayerTeamModel
struct PlayerTeamModel {
    let team: TeamSection
    let player: PlayerResponseModel
}

extension PlayerTeamModel: Equatable {
    static func ==(lhs: PlayerTeamModel, rhs: PlayerTeamModel) -> Bool {
        return lhs.team == rhs.team && lhs.player == rhs.player
    }
}

extension PlayerTeamModel: Hashable {}

// MARK: - GatherModel
struct GatherModel {
    let players: [PlayerTeamModel]
    let gatherUUID: UUID
}

extension GatherModel: Hashable {}

extension GatherModel: Equatable {
    static func ==(lhs: GatherModel, rhs: GatherModel) -> Bool {
        return lhs.gatherUUID == rhs.gatherUUID && lhs.players == rhs.players
    }
}
