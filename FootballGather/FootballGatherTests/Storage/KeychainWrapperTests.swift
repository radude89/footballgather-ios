//
//  KeychainWrapperTests.swift
//  FootballGatherTests
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 13/05/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import XCTest
import Security
@testable import FootballGather

final class KeychainWrapperTests: XCTestCase {
    
    var sut: KeychainWrapper!
    private let service = "com.test.service"
    private let key = "test.key"
    
    override func setUp() {
        super.setUp()
        sut = KeychainWrapper(service: service)
    }
    
    override func tearDown() {
        sut.removeAll()
        super.tearDown()
    }
    
    func test_keychainWrapper_init() {
        XCTAssertNotNil(sut)
    }
    
    func test_keychainWrapper_stringForKey() {
        let expectedValue = "test.value"
        sut.set(expectedValue, key: key)
        
        let actualValue = sut.string(forKey: key)
        
        XCTAssertEqual(actualValue, expectedValue)
    }
    
    func test_keychainWrapper_stringForKey_isNil() {
        XCTAssertNil(sut.string(forKey: key))
    }
    
    func test_keychainWrapper_boolForKey() {
        let expectedValue = true
        sut.set(expectedValue, key: key)
        
        let actualValue = sut.bool(forKey: key)
        
        XCTAssertEqual(actualValue, expectedValue)
    }

    func test_keychainWrapper_boolForKey_isNil() {
        XCTAssertNil(sut.bool(forKey: key))
    }
    
    func test_keychainWrapper_removesStringValue() {
        let expectedValue = "test.value"
        sut.set(expectedValue, key: key)
        
        sut.removeValue(forKey: key)
        
        XCTAssertNil(sut.string(forKey: key))
    }
    
    func test_keychainWrapper_removesBoolValue() {
        let expectedValue = false
        sut.set(expectedValue, key: key)
        
        sut.removeValue(forKey: key)
        
        XCTAssertNil(sut.bool(forKey: key))
    }
    
    func test_keychainWrapper_overWritesStringValue() {
        let initialValue = "initial.test.value"
        sut.set(initialValue, key: key)
        
        let expectedValue = "test.value"
        sut.set(expectedValue, key: key)
        
        let actualValue = sut.string(forKey: key)
        
        XCTAssertEqual(actualValue, expectedValue)
    }
    
    func test_keychainWrapper_overwritesBoolValue() {
        let initialValue = false
        sut.set(initialValue, key: key)
        
        let expectedValue = true
        sut.set(expectedValue, key: key)
        
        let actualValue = sut.bool(forKey: key)
        
        XCTAssertEqual(actualValue, expectedValue)
    }
    
    func test_keychainWrapper_removesValuesByService() {
        let expectedValue = "test.value"
        let keychainWrapper = KeychainWrapper(service: "\(service).two")
        
        sut.set(expectedValue, key: key)
        keychainWrapper.set(expectedValue, key: key)
        sut.removeAll()
        let actualValue = keychainWrapper.string(forKey: key)
        
        XCTAssertNil(sut.string(forKey: key))
        XCTAssertEqual(actualValue, expectedValue)
        
        keychainWrapper.removeAll()
    }

}
