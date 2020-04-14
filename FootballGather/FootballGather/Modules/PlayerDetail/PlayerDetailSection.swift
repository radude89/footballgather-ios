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
