//
//  PlayerDetailSection.swift
//  FootballGather
//
//  Created by Radu Dan on 21/04/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

struct PlayerDetailSection {
    let title: String
    let rows: [PlayerDetailRow]
}

struct PlayerDetailRow {
    let title: String
    let value: String
    let editableField: PlayerEditableFieldOption
}

enum PlayerEditableFieldOption {
    case name, age, skill, position, favouriteTeam
}

enum PlayerDetailSectionFactory {
    static func makeSections(from player: PlayerResponseModel) -> [PlayerDetailSection] {
        [
            PlayerDetailSection(
                title: "Personal",
                rows: [
                    PlayerDetailRow(title: "Name",
                                    value: player.name,
                                    editableField: .name),
                    PlayerDetailRow(title: "Age",
                                    value: player.age != nil ? "\(player.age!)" : "",
                                    editableField: .age)
                ]
            ),
            PlayerDetailSection(
                title: "Play",
                rows: [
                    PlayerDetailRow(title: "Preferred position",
                                    value: player.preferredPosition?.rawValue.capitalized ?? "",
                                    editableField: .position),
                    PlayerDetailRow(title: "Skill",
                                    value: player.skill?.rawValue.capitalized ?? "",
                                    editableField: .skill)
                ]
            ),
            PlayerDetailSection(
                title: "Likes",
                rows: [
                    PlayerDetailRow(title: "Favourite team",
                                    value: player.favouriteTeam ?? "",
                                    editableField: .favouriteTeam)
                ]
            )
        ]
    }
}
