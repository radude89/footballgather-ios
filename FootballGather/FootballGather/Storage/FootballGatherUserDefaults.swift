//
//  FootballGatherUserDefaults.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 13/05/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import Foundation

final class FootballGatherUserDefaults {
    
    private enum Keys {
        static let rememberMe = "footballgather_remember"
    }
    
    let storage: KeyValueStorage
    static let shared: FootballGatherUserDefaults = .init()
    
    init(storage: KeyValueStorage = UserDefaultsWrapper()) {
        self.storage = storage
    }
    
    var rememberUsername: Bool? {
        get {
            return storage.bool(forKey: Keys.rememberMe)
        }
        set {
            if let newValue = newValue {
                storage.set(newValue, key: Keys.rememberMe)
            } else {
                storage.removeValue(forKey: Keys.rememberMe)
            }
            
        }
    }
    
}
