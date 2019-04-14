//
//  Gather.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 13/04/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import CoreData

final class Gather: NSManagedObject {
    
    @NSManaged var serverId: UUID?
    @NSManaged var score: String?
    @NSManaged var winnerTeam: String?
    @NSManaged var players: NSSet?
    @NSManaged var user: User?
    
    @objc(addPlayersObject:)
    @NSManaged func addToPlayers(_ value: Player)
    
    @objc(removePlayersObject:)
    @NSManaged func removeFromPlayers(_ value: Player)
    
    @objc(addPlayers:)
    @NSManaged func addToPlayers(_ values: NSSet)
    
    @objc(removePlayers:)
    @NSManaged func removeFromPlayers(_ values: NSSet)
    
}
