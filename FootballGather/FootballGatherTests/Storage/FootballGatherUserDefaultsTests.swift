//
//  FootballGatherUserDefaultsTests.swift
//  FootballGatherTests
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 14/05/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import XCTest
@testable import FootballGather

final class FootballGatherUserDefaultsTests: XCTestCase {

    var sut: FootballGatherUserDefaults!
    
    private let domain = "test.userdefaults"
    private lazy var storage: UserDefaultsWrapper = {
        let defs = UserDefaults(suiteName: domain)!
        defs.setPersistentDomain([:], forName: domain)
        
        let userDefaultsWrapper = UserDefaultsWrapper(userDefaults: defs)
        return userDefaultsWrapper
    }()
    
    override func setUp() {
        super.setUp()
        
        sut = FootballGatherUserDefaults(storage: storage)
    }
    
    override func tearDown() {
        sut.storage.removeAll()
        storage.userDefaults.removePersistentDomain(forName: domain)
        
        super.tearDown()
    }
    
    func test_userDefaults_init() {
        XCTAssertNotNil(sut)
    }
    
    func test_userDefaults_rememberUsernameIsNil() {
        XCTAssertNil(sut.rememberUsername)
    }
    
    func test_userDefaults_passwordIsNil() {
        XCTAssertNil(sut.rememberUsername)
    }
    
    func test_userDefaults_rememberUsernameIsNotNil() {
        let expectedRememberUsername = true
        sut.rememberUsername = expectedRememberUsername
        
        XCTAssertEqual(sut.rememberUsername, expectedRememberUsername)
    }
    
}
