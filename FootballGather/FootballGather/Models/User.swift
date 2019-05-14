//
//  User.swift
//  FootballGatherTests
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 13/05/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//
//

import Foundation
import CoreData

final class User: NSManagedObject {
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }
    
    @NSManaged var serverId: UUID?
    @NSManaged var gathers: NSSet?
    @NSManaged var players: NSSet?

}

// MARK: Generated accessors for gathers
extension User {
    
    @objc(addGathersObject:)
    @NSManaged func addToGathers(_ value: Gather)
    
    @objc(removeGathersObject:)
    @NSManaged func removeFromGathers(_ value: Gather)
    
    @objc(addGathers:)
    @NSManaged func addToGathers(_ values: NSSet)
    
    @objc(removeGathers:)
    @NSManaged func removeFromGathers(_ values: NSSet)
    
}

// MARK: Generated accessors for players
extension User {
    
    @objc(addPlayersObject:)
    @NSManaged func addToPlayers(_ value: Player)
    
    @objc(removePlayersObject:)
    @NSManaged func removeFromPlayers(_ value: Player)
    
    @objc(addPlayers:)
    @NSManaged func addToPlayers(_ values: NSSet)
    
    @objc(removePlayers:)
    @NSManaged func removeFromPlayers(_ values: NSSet)
    
}
