//
//  CoreDataStoreMock.swift
//  FootballGatherTests
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 13/04/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import CoreData

struct CoreDataStoreMock {
    
    static let persistentContainer = makePersistentContainer()

    private static func makeManagedObjectModel() -> NSManagedObjectModel {
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle.main])
        return managedObjectModel!
    }
    
    private static func makePersistentContainer() -> NSPersistentContainer {
        let container = NSPersistentContainer(name: "FootballGather", managedObjectModel: makeManagedObjectModel())
        
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false
        
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { (description, error) in
            precondition(description.type == NSInMemoryStoreType)
            
            if let error = error {
                fatalError("Mocked coordinator failed \(error)")
            }
        }
        
        return container
    }
    
}
