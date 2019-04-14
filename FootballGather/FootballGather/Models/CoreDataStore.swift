//
//  CoreDataStore.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 13/04/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import CoreData

final class CoreDataStore {
    
    // MARK: - Variables
    private let persistentContainer: NSPersistentContainer
    private lazy var backgroundContext = makeContext(background: true)
    private lazy var mainContext = makeContext()

    // MARK: - Init
    init(persistentContainer: NSPersistentContainer = NSPersistentContainer(name: "FootballGather")) {
        self.persistentContainer = persistentContainer
    }
    
    func setup(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                fatalError("Unable to load the persistent stores \(storeDescription) error \(error!)")
            }
            
            completion?()
        }
    }
    
    // MARK: - Context
    private func makeContext(background: Bool = false) -> NSManagedObjectContext {
        if !background {
            let context = persistentContainer.viewContext
            context.automaticallyMergesChangesFromParent = true
            return context
        } else {
            let context = persistentContainer.newBackgroundContext()
            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            return context
        }
    }
    
    private func loadContext(background: Bool = false) -> NSManagedObjectContext {
        if background {
            return backgroundContext
        } else {
            return mainContext
        }
    }
    
    func saveContext(background: Bool = false) {
        let context = loadContext(background: background)
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                fatalError("Error saving \(error)")
            }
        }
    }
    
    // MARK: - CRUD
    func createBackgroundQueue(_ block: @escaping () -> Void) {
        backgroundContext.perform(block)
    }
    
    func insert<T: NSManagedObject>(background: Bool = false) -> T {
        let context = loadContext(background: background)
        return NSEntityDescription.insertNewObject(forEntityName: String(describing: T.self), into: context) as! T
    }
    
    func managedObject<T: NSManagedObject>(withId id: NSManagedObjectID, background: Bool = false) -> T? {
        let context = loadContext(background: background)
        return context.object(with: id) as? T
    }
    
    func fetch<T: NSManagedObject>(predicate: NSPredicate? = nil, background: Bool = false) -> [T] {
        let context = loadContext(background: background)
        let fetchRequest = NSFetchRequest<T>(entityName: String(describing: T.self))
        
        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            assertionFailure("Fetch data failed in \(T.self) error : \(error))")
        }
        
        return []
    }
    
    func fetchAll<T: NSManagedObject>(background: Bool = false) -> [T] {
        let context = loadContext(background: background)
        let fetchRequest = NSFetchRequest<T>(entityName: String(describing: T.self))

        do {
            return try context.fetch(fetchRequest)
        } catch {
            assertionFailure("Unable to fetch \(T.self) error: \(error)")
        }
        
        return []
    }
    
    func clear() {
        deleteAll(User.self)
        deleteAll(Player.self)
        deleteAll(Gather.self)
    }
    
    func deleteAll<T: NSManagedObject>(_ entity: T.Type, background: Bool = false) {
        let context = loadContext(background: background)
        let objects: [T] = fetchAll(background: background)
        
        objects.forEach {
            context.delete($0)
            saveContext(background: background)
        }
    }
    
    func delete(managedObject: NSManagedObject, background: Bool = false) {
        let context = loadContext(background: background)
        
        context.delete(managedObject)
        saveContext()
    }
    
}
