//
//  CoreDataStoreTests.swift
//  FootballGatherTests
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 13/04/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import XCTest
import CoreData
@testable import FootballGather

final class CoreDataStoreTests: XCTestCase {
    
    var sut: CoreDataStore!
    
    override func setUp() {
        super.setUp()
        
        sut = CoreDataStore(persistentContainer: CoreDataStoreMock.persistentContainer)
    }

    override func tearDown() {
        sut.clear()
        super.tearDown()
    }
    
    func test_init() {
        XCTAssertNotNil(sut)
    }
    
    func test_setup_notThrowsErrors() {
        let exp = expectation(description: "Set up completion called")
        let coreDataStore = CoreDataStore()
        
        coreDataStore.setup() {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: TestConfigurator.defaultTimeout)
    }

    func test_saveObject() {
        let user: User = sut.makePersistentModel()
        sut.commitChanges()
        XCTAssertNotNil(user)
        
        let expectedUser: User = sut.fetch().first!
        XCTAssertEqual(user, expectedUser)
    }
    
    func test_saveObject_inBackground() {
        let user: User = sut.makePersistentModel()
        
        let exp = expectation(description: "Save in background expectation")
        
        sut.createQueue { [weak self] in
            guard let self = self else {
                XCTFail("Deallocation occured too early in \(CoreDataStoreTests.self)")
                return
            }
            
            self.sut.commitChanges(inBackground: true)
            
            let expectedUser: User = self.sut.fetch().first!
            XCTAssertEqual(user, expectedUser)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: TestConfigurator.defaultTimeout)
    }
    
    func retrieveAndCheckObjectsCountIsZero(inBackground background: Bool = false) {
        let users: [User] = sut.fetchAll()
        XCTAssertEqual(users.count, 0)
        
        let players: [Player] = sut.fetchAll()
        XCTAssertEqual(players.count, 0)
        
        let gathers: [Gather] = sut.fetchAll()
        XCTAssertEqual(gathers.count, 0)
    }
    
    func test_retrieveManagedObjectsInBackground_hasZeroElements() {
        let exp = expectation(description: "Fetch objects in background expectation.")
        
        sut.createQueue { [weak self] in
            self?.retrieveAndCheckObjectsCountIsZero(inBackground: true)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: TestConfigurator.defaultTimeout)
    }
    
    func test_retrieveManagedObjects_hasZeroElements() {
        retrieveAndCheckObjectsCountIsZero()
    }
    
    func test_managedObject_isNotNil() {
        let user: User = sut.makePersistentModel()
        let managedObject = sut.managedObject(withId: user.objectID)
        
        XCTAssertNotNil(managedObject)
    }
    
    func test_managedObject_isNil() {
        let user: User = sut.makePersistentModel()
        sut.commitChanges()
        sut.delete(persistentObject: user)
        
        let users: [User] = sut.fetchAll()
        XCTAssertEqual(users.count, 0)
    }
    
    func test_managedObjectInBackground_isNotNil() {
        let exp = expectation(description: "Managed object in background expectation")
        
        sut.createQueue { [weak self] in
            guard let self = self else {
                XCTFail("Deallocation occured too early in \(CoreDataStoreTests.self)")
                return
            }
            
            let user: User = self.sut.makePersistentModel(inBackground: true)
            let managedObject = self.sut.managedObject(withId: user.objectID, background: true)
            
            XCTAssertNotNil(managedObject)
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: TestConfigurator.defaultTimeout)
    }
    
    func test_managedObjectInBackground_isNil() {
        let exp = expectation(description: "Managed object in background expectation")
        
        sut.createQueue { [weak self] in
            guard let self = self else {
                XCTFail("Deallocation occured too early in \(CoreDataStoreTests.self)")
                return
            }
            
            let user: User = self.sut.makePersistentModel(inBackground: true)
            self.sut.commitChanges(inBackground: true)
            self.sut.delete(persistentObject: user, background: true)
            
            let users: [User] = self.sut.fetchAll(inBackground: true)
            XCTAssertEqual(users.count, 0)
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: TestConfigurator.defaultTimeout)
    }
    
    func test_fetchWithPredicate_returnsObjects() {
        let user: User = sut.makePersistentModel()
        let uuid = UUID()
        user.serverId = uuid
        sut.commitChanges()
        
        let predicate = NSPredicate(format: "serverId == %@", argumentArray: [uuid])
        let users: [User] = sut.fetch(predicate: predicate)
        
        XCTAssertGreaterThan(users.count, 0)
    }
    
    func test_fetchWithPredicateInBackground_returnsObjects() {
        let exp = expectation(description: "Managed object in background expectation")
        
        sut.createQueue { [weak self] in
            guard let self = self else {
                XCTFail("Deallocation occured too early in \(CoreDataStoreTests.self)")
                return
            }
            
            let user: User = self.sut.makePersistentModel(inBackground: true)
            let uuid = UUID()
            user.serverId = uuid
            self.sut.commitChanges(inBackground: true)
            
            let predicate = NSPredicate(format: "serverId == %@", argumentArray: [uuid])
            let users: [User] = self.sut.fetch(inBackground: true, predicate: predicate)
            
            XCTAssertGreaterThan(users.count, 0)
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: TestConfigurator.defaultTimeout)
    }

}
