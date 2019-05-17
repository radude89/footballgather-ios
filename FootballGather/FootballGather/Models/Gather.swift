//
//  Gather.swift
//  FootballGatherTests
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 13/05/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//
//

import Foundation
import CoreData

final class Gather: NSManagedObject {

    @nonobjc class func fetchRequest() -> NSFetchRequest<Gather> {
        return NSFetchRequest<Gather>(entityName: "Gather")
    }
    
    @NSManaged var score: String?
    @NSManaged var serverId: UUID?
    @NSManaged var winnerTeam: String?
    @NSManaged var players: NSSet?
    @NSManaged var user: User?
    
}

// MARK: Generated accessors for players
extension Gather {
    
    @objc(addPlayersObject:)
    @NSManaged func addToPlayers(_ value: Player)
    
    @objc(removePlayersObject:)
    @NSManaged func removeFromPlayers(_ value: Player)
    
    @objc(addPlayers:)
    @NSManaged func addToPlayers(_ values: NSSet)
    
    @objc(removePlayers:)
    @NSManaged func removeFromPlayers(_ values: NSSet)
}
