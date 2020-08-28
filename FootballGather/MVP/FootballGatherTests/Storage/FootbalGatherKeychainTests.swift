//
//  FootbalGatherKeychainTests.swift
//  FootballGatherTests
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 14/05/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import XCTest
@testable import FootballGather

final class FootbalGatherKeychainTests: XCTestCase {
    
    var sut: FootbalGatherKeychain!
    let storage = KeychainWrapper(service: "com.test.service")
    
    override func setUp() {
        super.setUp()
        sut = FootbalGatherKeychain(storage: storage)
    }
    
    override func tearDown() {
        storage.removeAll()
        super.tearDown()
    }
    
    func test_keychain_init() {
        XCTAssertNotNil(sut)
    }
    
    func test_keychain_usernameIsNil() {
        XCTAssertNil(sut.username)
    }
    
    func test_keychain_passwordIsNil() {
        XCTAssertNil(sut.password)
    }
    
    func test_keychain_usernameIsNotNil() {
        let expectedUsername = "test.user"
        sut.username = expectedUsername
        
        XCTAssertEqual(sut.username, expectedUsername)
    }
    
    func test_keychain_usernameIsRemoved() {
        sut.username = "test.user"
        XCTAssertNotNil(sut.username)
        
        sut.username = nil
        XCTAssertNil(sut.username)
    }
    
    func test_keychain_passwordIsNotNil() {
        let expectedPass = "test.pass"
        sut.password = expectedPass
        
        XCTAssertEqual(sut.password, expectedPass)
    }
    
    func test_keychain_passwordIsRemoved() {
        sut.password = "test.pass"
        XCTAssertNotNil(sut.password)
        
        sut.password = nil
        XCTAssertNil(sut.password)
    }
    
    func test_keychain_tokenIsNil() {
        XCTAssertNil(sut.token)
    }
    
    func test_keychain_tokenIsNotNil() {
        let expectedtoken = "test.token"
        sut.token = expectedtoken
        
        XCTAssertEqual(sut.token, expectedtoken)
    }
    
    func test_keychain_tokenIsRemoved() {
        sut.token = "test.token"
        XCTAssertNotNil(sut.token)
        
        sut.token = nil
        XCTAssertNil(sut.token)
    }

}
