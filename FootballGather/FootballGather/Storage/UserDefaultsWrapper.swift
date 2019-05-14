//
//  UserDefaultsWrapper.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 13/05/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import Foundation

final class UserDefaultsWrapper {
    
    let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
}

extension UserDefaultsWrapper: KeyValueStorage {
    func set(_ value: Data, key: String) {
        userDefaults.setValue(value, forKey: key)
    }
    
    func set(_ value: String, key: String) {
        userDefaults.setValue(value, forKey: key)
    }
    
    func set(_ value: Bool, key: String) {
        userDefaults.setValue(value, forKey: key)
    }
    
    func string(forKey key: String) -> String? {
        return userDefaults.string(forKey: key)
    }
    
    func data(forKey key: String) -> Data? {
        return userDefaults.data(forKey: key)
    }
    
    func bool(forKey key: String) -> Bool? {
        return userDefaults.bool(forKey: key)
    }
    
    func removeValue(forKey key: String) {
        userDefaults.removeObject(forKey: key)
    }
    
    func removeAll() {
        userDefaults.dictionaryRepresentation().keys.forEach {
            userDefaults.removeObject(forKey: $0)
        }
    }
}
