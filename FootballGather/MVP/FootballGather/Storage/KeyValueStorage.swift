//
//  KeyValueStorage.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 05/05/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import Foundation

protocol KeyValueStorage {
    func string(forKey key: String) -> String?
    func data(forKey key: String) -> Data?
    func bool(forKey key: String) -> Bool?
    
    func set(_ value: String, key: String)
    func set(_ value: Data, key: String)
    func set(_ value: Bool, key: String)
    
    func removeValue(forKey key: String)
    func removeAll()
}
