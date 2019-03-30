//
//  UserDefaultsWrapperTests.swift
//  FootballGatherTests
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 14/05/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import XCTest
@testable import FootballGather

final class UserDefaultsWrapperTests: XCTestCase {
    
    var sut: UserDefaultsWrapper!
    
    private let domain = "test.userdefaults"
    private let key = "test.key"
    
    private lazy var storage: UserDefaults = {
        let defs = UserDefaults(suiteName: domain)!
        defs.setPersistentDomain([:], forName: domain)
        return defs
    }()
    
    override func setUp() {
        super.setUp()
        sut = UserDefaultsWrapper(userDefaults: storage)
    }
    
    override func tearDown() {
        sut.removeAll()
        storage.removePersistentDomain(forName: domain)
        super.tearDown()
    }
    
    func test_userdefaults_setsData() {
        let expectedData = "testData".data(using: .utf8)!
        sut.set(expectedData, key: key)
        
        let actualData = sut.data(forKey: key)
        
        XCTAssertEqual(expectedData, actualData)
    }
    
    func test_userdefaults_setsString() {
        let expectedString = "testData"
        sut.set(expectedString, key: key)
        
        let actualString = sut.string(forKey: key)
        
        XCTAssertEqual(expectedString, actualString)
    }
    
    func test_userdefaults_setsBool() {
        let expectedBool = true
        sut.set(expectedBool, key: key)
        
        let actualBool = sut.bool(forKey: key)
        
        XCTAssertEqual(expectedBool, actualBool)
    }
    
    func test_userdefaults_overwritesData() {
        let data = "testData".data(using: .utf8)!
        sut.set(data, key: key)
        
        let expectedData = "testData2".data(using: .utf8)!
        sut.set(expectedData, key: key)
        
        let actualData = sut.data(forKey: key)
        
        XCTAssertEqual(expectedData, actualData)
    }
    
    func test_userdefaults_overwritesString() {
        let data = "testData"
        sut.set(data, key: key)
        
        let expectedData = "testData2"
        sut.set(expectedData, key: key)
        
        let actualData = sut.string(forKey: key)
        
        XCTAssertEqual(expectedData, actualData)
    }
    
    func test_userdefaults_overwritesBool() {
        let data = true
        sut.set(data, key: key)
        
        let expectedData = false
        sut.set(expectedData, key: key)
        
        let actualData = sut.bool(forKey: key)
        
        XCTAssertEqual(expectedData, actualData)
    }
    
    func test_userdefaults_removesData() {
        let expectedData = "testData".data(using: .utf8)!
        sut.set(expectedData, key: key)
        
        XCTAssertNotNil(sut.data(forKey: key))
        
        sut.removeValue(forKey: key)
        
        XCTAssertNil(sut.data(forKey: key))
    }
    
    func test_userdefaults_removesString() {
        let expectedData = "testData"
        sut.set(expectedData, key: key)
        
        XCTAssertNotNil(sut.string(forKey: key))
        
        sut.removeValue(forKey: key)
        
        XCTAssertNil(sut.string(forKey: key))
    }
    
    func test_userdefaults_removesBool() {
        let expectedData = true
        sut.set(expectedData, key: key)
        
        XCTAssertNotNil(sut.bool(forKey: key))
        
        sut.removeValue(forKey: key)
        
        XCTAssertNil(sut.bool(forKey: key))
    }
    
    func test_userdefaults_removesAllValues() {
        let boolKey = key
        let boolValue = true
        
        let stringKey = "\(key)2"
        let stringValue = "test"
        
        let dataKey = "\(key)3"
        let dataValue = stringValue.data(using: .utf8)!
        
        sut.set(boolValue, key: boolKey)
        sut.set(stringValue, key: stringKey)
        sut.set(dataValue, key: dataKey)
        
        XCTAssertNotNil(sut.bool(forKey: boolKey))
        XCTAssertNotNil(sut.string(forKey: stringKey))
        XCTAssertNotNil(sut.data(forKey: dataKey))
        
        sut.removeAll()
        
        XCTAssertNil(sut.bool(forKey: boolKey))
        XCTAssertNil(sut.string(forKey: stringKey))
        XCTAssertNil(sut.data(forKey: dataKey))
    }

}
