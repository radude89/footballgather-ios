//
//  KeychainQueryFactory.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 06/05/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import Foundation
import Security

// MARK: - KeychainQueryConfig
struct KeychainQueryConfig {
    let secClass: String
    let matchLimit: String
    let returnData: Bool
    let returnAttributes: Bool
    
    init(secClass: String = kSecClassGenericPassword as String,
         matchLimit: String = kSecMatchLimitOne as String,
         returnData: Bool = true,
         returnAttributes: Bool = true) {
        self.secClass = secClass
        self.matchLimit = matchLimit
        self.returnData = returnData
        self.returnAttributes = returnAttributes
    }
}

// MARK: - KeychainQueryFactory
enum KeychainQueryFactory {
    static func makeQuery(forService service: String,
                          key: String? = nil,
                          value: Data? = nil,
                          withConfiguration config: KeychainQueryConfig = KeychainQueryConfig()) -> [String: Any] {
        var queryDictionary: [String: Any] = [:]
        queryDictionary[kSecAttrService as String] = service
        queryDictionary[kSecClass as String] = config.secClass
        
        if let key = key {
            queryDictionary[kSecAttrAccount as String] = key
        }
        
        if let value = value {
            queryDictionary[kSecValueData as String] = value
        } else {
            queryDictionary[kSecMatchLimit as String] = config.matchLimit
            queryDictionary[kSecReturnData as String] = config.returnData
            queryDictionary[kSecReturnAttributes as String] = config.returnAttributes
        }
        
        return queryDictionary
    }
}
