//
//  Player.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 13/04/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import CoreData

final class Player: NSManagedObject {
    
    @NSManaged var age: Int32
    @NSManaged var favouriteTeam: String?
    @NSManaged var serverId: Int32
    @NSManaged var name: String?
    @NSManaged var preferredPosition: String?
    @NSManaged var skill: String?
    @NSManaged var gathers: NSSet?
    
    @objc(addGathersObject:)
    @NSManaged func addToGathers(_ value: Gather)
    
    @objc(removeGathersObject:)
    @NSManaged func removeFromGathers(_ value: Gather)
    
    @objc(addGathers:)
    @NSManaged func addToGathers(_ values: NSSet)
    
    @objc(removeGathers:)
    @NSManaged func removeFromGathers(_ values: NSSet)
    
}
