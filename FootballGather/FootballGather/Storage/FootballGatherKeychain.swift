//
//  FootballGatherKeychain.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 15/04/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import Foundation

protocol ApplicationKeychain {
    var username: String? { get set }
    var password: String? { get set }
    var token: String? { get set }
}


final class FootbalGatherKeychain {
    
    private enum Keys {
        static let username = "footballgather_username"
        static let password = "footballgather_password"
        static let token = "footballgather_token"
    }
    
    let storage: KeyValueStorage
    static let shared: FootbalGatherKeychain = .init()
    
    init(storage: KeyValueStorage = KeychainWrapper()) {
        self.storage = storage
    }
    
}

extension FootbalGatherKeychain: ApplicationKeychain {
    
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
    
    var token: String? {
        get {
            return storage.string(forKey: Keys.token)
        }
        set {
            if let newValue = newValue {
                storage.set(newValue, key: Keys.token)
            } else {
                storage.removeValue(forKey: Keys.token)
            }
        }
    }
    
}
