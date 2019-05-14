//
//  FootballGatherKeychain.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 15/04/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import Foundation

final class FootbalGatherKeychain {
    
    private enum Keys {
        static let username = "footballgather_username"
        static let password = "footballgather_password"
    }
    
    let storage: KeyValueStorage
    static let shared: FootbalGatherKeychain = .init()
    
    init(storage: KeyValueStorage = KeychainWrapper()) {
        self.storage = storage
    }
    
    var username: String? {
        get {
            return storage.string(forKey: Keys.username)
        }
        set {
            if let newValue = newValue {
                storage.set(newValue, key: Keys.username)
            } else {
                storage.removeValue(forKey: Keys.username)
            }
        }
    }
    
    var password: String? {
        get {
            return storage.string(forKey: Keys.password)
        }
        set {
            if let newValue = newValue {
                storage.set(newValue, key: Keys.password)
            } else {
                storage.removeValue(forKey: Keys.password)
            }
        }
    }
    
}

