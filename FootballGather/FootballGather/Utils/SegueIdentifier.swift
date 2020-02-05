//
//  SegueIdentifier.swift
//  FootballGather
//
//  Created by Radu Dan on 23/01/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

enum SegueIdentifier: String {
    case confirmPlayers
    case playerDetails = "showPlayerDetails"
    case addPlayer
    case editPlayer
    case gather = "startGather"
    case playerList = "showPlayerList"
}
