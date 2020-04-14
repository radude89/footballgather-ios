//
//  PlayerEditable.swift
//  FootballGather
//
//  Created by Radu Dan on 21/04/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

struct PlayerEditable {
    var player: PlayerResponseModel
    var items: [String]
    var selectedItemIndex: Int?
    let rowDetails: PlayerDetailRow?
    
    init(player: PlayerResponseModel,
         items: [String] = [],
         selectedItemIndex: Int? = nil,
         rowDetails: PlayerDetailRow? = nil) {
        self.player = player
        self.items = items
        self.selectedItemIndex = selectedItemIndex
        self.rowDetails = rowDetails
    }
}
