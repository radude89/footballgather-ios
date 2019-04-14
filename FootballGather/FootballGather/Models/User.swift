//
//  User.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 13/04/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import CoreData

final class User: NSManagedObject {
    
    @NSManaged var serverId: UUID?
    @NSManaged var gather: NSSet?
    
    @objc(addGatherObject:)
    @NSManaged func addToGather(_ value: Gather)
    
    @objc(removeGatherObject:)
    @NSManaged func removeFromGather(_ value: Gather)
    
    @objc(addGather:)
    @NSManaged func addToGather(_ values: NSSet)
    
    @objc(removeGather:)
    @NSManaged func removeFromGather(_ values: NSSet)
}
