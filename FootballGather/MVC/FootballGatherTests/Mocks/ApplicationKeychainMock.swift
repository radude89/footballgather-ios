//
//  ApplicationKeychainMock.swift
//  FootballGatherTests
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 17/05/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import Foundation
@testable import FootballGather

// MARK: - Storage Wrapper
enum AppKeychainMockFactory {
    static func makeKeychain(withStorage storage: KeyValueStorage = KeyValueStorageMock()) -> FootbalGatherKeychain {
        return FootbalGatherKeychain(storage: storage)
    }
}

// MARK: - Storage
final class KeyValueStorageMock: KeyValueStorage {
    var cacheDictionary: [String: Any] = [:]
    
    func string(forKey key: String) -> String? {
        return cacheDictionary[key] as? String
    }
    
    func data(forKey key: String) -> Data? {
        return cacheDictionary[key] as? Data
    }
    
    func bool(forKey key: String) -> Bool? {
        return cacheDictionary[key] as? Bool
    }
    
    func set(_ value: String, key: String) {
        cacheDictionary[key] = value
    }
    
    func set(_ value: Data, key: String) {
        cacheDictionary[key] = value
    }
    
    func set(_ value: Bool, key: String) {
        cacheDictionary[key] = value
    }
    
    func removeValue(forKey key: String) {
        cacheDictionary[key] = nil
    }
    
    func removeAll() {
        cacheDictionary.removeAll()
    }
}

