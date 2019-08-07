//
//  CoreDataStore.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 13/04/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import CoreData

// MARK: - CoreDataStore
final class CoreDataStore {
    typealias PersistentModel = NSManagedObject
    
    // MARK: - Variables
    private let persistentContainer: NSPersistentContainer
    private lazy var backgroundContext = makeContext(background: true)
    private lazy var mainContext = makeContext()

    // MARK: - Init
    init(persistentContainer: NSPersistentContainer = NSPersistentContainer(name: "FootballGather")) {
        self.persistentContainer = persistentContainer
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

    func managedObject<T: NSManagedObject>(withId id: NSManagedObjectID, background: Bool = false) -> T? {
        let context = loadContext(background: background)
        return context.object(with: id) as? T
    }
    
}

// MARK: - PersistentStore
extension CoreDataStore: PersistentStore {
    
    // MARK: - Methods
    func setup(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                fatalError("Unable to load the persistent stores \(storeDescription) error \(error!)")
            }
            
            completion?()
        }
    }
    
    // MARK: - Create
    func createQueue(_ block: @escaping () -> Void) {
        backgroundContext.perform(block)
    }
    
    func makePersistentModel<T: NSManagedObject>(inBackground background: Bool = false) -> T {
        let context = loadContext(background: background)
        return NSEntityDescription.insertNewObject(forEntityName: String(describing: T.self), into: context) as! T
    }
    
    func commitChanges(inBackground background: Bool = false) {
        let context = loadContext(background: background)
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                fatalError("Error saving \(error)")
            }
        }
    }
    
    // MARK: - Read
    func fetch<T: NSManagedObject>(inBackground background: Bool = false, predicate: NSPredicate? = nil) -> [T] {
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
    
    func fetchAll<T: NSManagedObject>(inBackground background: Bool = false) -> [T] {
        let context = loadContext(background: background)
        let fetchRequest = NSFetchRequest<T>(entityName: String(describing: T.self))
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            assertionFailure("Unable to fetch \(T.self) error: \(error)")
        }
        
        return []
    }
    
    // MARK: - Delete
    func clear() {
        deleteAll(User.self)
        deleteAll(Player.self)
        deleteAll(Gather.self)
    }
    
    func deleteAll<T: NSManagedObject>(_ entity: T.Type, background: Bool = false) {
        let context = loadContext(background: background)
        let objects: [T] = fetchAll(inBackground: background)
        
        objects.forEach {
            context.delete($0)
            commitChanges(inBackground: background)
        }
    }
    
    func delete(persistentObject: NSManagedObject, background: Bool = false) {
        let context = loadContext(background: background)
        
        context.delete(persistentObject)
        commitChanges(inBackground: background)
    }
}
