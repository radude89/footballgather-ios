//
//  PersistentStore.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 06/08/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import Foundation

protocol PersistentStore {
    associatedtype PersistentModel
    
    func setup(completion: (() -> Void)?)
    func commitChanges(inBackground background: Bool)
    func createQueue(_ block: @escaping () -> Void)
    
    func makePersistentModel(inBackground background: Bool) -> PersistentModel
    func fetch(inBackground: Bool, predicate: NSPredicate?) -> [PersistentModel]
    func fetchAll(inBackground background: Bool) -> [PersistentModel]
    
    func clear()
    func deleteAll(_ entity: PersistentModel.Type, background: Bool)
    func delete(persistentObject: PersistentModel, background: Bool)
}
