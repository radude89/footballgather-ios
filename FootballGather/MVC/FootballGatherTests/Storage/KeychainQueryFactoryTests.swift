//
//  KeychainQueryFactoryTests.swift
//  FootballGatherTests
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 13/05/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import XCTest
import Security
@testable import FootballGather

final class KeychainQueryFactoryTests: XCTestCase {
    
    func test_makeQueryForService_setService() {
        let expectedService = "com.test"
        
        let queryDictionary = KeychainQueryFactory.makeQuery(forService: expectedService)
        let service = queryDictionary[kSecAttrService as String] as! String
        
        XCTAssertEqual(service, expectedService)
        XCTAssertGreaterThan(queryDictionary.count, 2)
    }
    
    func test_makeQuery_setServiceAndKey() {
        let expectedService = "com.test"
        let expectedKey = "key.test"
        
        let queryDictionary = KeychainQueryFactory.makeQuery(forService: expectedService, key: expectedKey)
        let service = queryDictionary[kSecAttrService as String] as! String
        let key = queryDictionary[kSecAttrAccount as String] as! String
        
        XCTAssertEqual(service, expectedService)
        XCTAssertEqual(key, expectedKey)
        XCTAssertGreaterThan(queryDictionary.count, 2)
    }
    
    func test_makeQuery_setServiceAndKeyValue() {
        let expectedService = "com.test"
        let expectedKey = "key.test"
        let expectedValue = "value.test".data(using: .utf8)!
        
        let queryDictionary = KeychainQueryFactory.makeQuery(forService: expectedService, key: expectedKey, value: expectedValue)
        let service = queryDictionary[kSecAttrService as String] as! String
        let key = queryDictionary[kSecAttrAccount as String] as! String
        let value = queryDictionary[kSecValueData as String] as! Data
        
        XCTAssertEqual(service, expectedService)
        XCTAssertEqual(key, expectedKey)
        XCTAssertEqual(value, expectedValue)
        XCTAssertGreaterThan(queryDictionary.count, 3)
    }
    
}
