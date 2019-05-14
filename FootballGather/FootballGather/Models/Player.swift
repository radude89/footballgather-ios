//
//  Player.swift
//  FootballGatherTests
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 13/05/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//
//

import Foundation
import CoreData

final class Player: NSManagedObject {
    @nonobjc class func fetchRequest() -> NSFetchRequest<Player> {
        return NSFetchRequest<Player>(entityName: "Player")
    }
    
    @NSManaged var age: Int32
    @NSManaged var favouriteTeam: String?
    @NSManaged var name: String?
    @NSManaged var preferredPosition: String?
    @NSManaged var serverId: UUID?
    @NSManaged var skill: String?
    @NSManaged var gathers: NSSet?
    @NSManaged var user: User?
    
}

// MARK: Generated accessors for gathers
extension Player {
    @objc(addGathersObject:)
    @NSManaged func addToGathers(_ value: Gather)
    
    @objc(removeGathersObject:)
    @NSManaged func removeFromGathers(_ value: Gather)
    
    @objc(addGathers:)
    @NSManaged func addToGathers(_ values: NSSet)
    
    @objc(removeGathers:)
    @NSManaged func removeFromGathers(_ values: NSSet)
}
