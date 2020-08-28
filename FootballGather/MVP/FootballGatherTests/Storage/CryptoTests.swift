//
//  CryptoTests.swift
//  FootballGatherTests
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 14/05/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import XCTest
@testable import FootballGather

final class CryptoTests: XCTestCase {
    
    func test_hashMessage() {
        let message = "test"
        
        let digest = Crypto.hash(message: message)
        
        XCTAssertNotNil(digest)
    }

    func test_hashMessage_hasSameHashes() {
        let message = "test"
        let anotherMessage = "test"
        
        let digest = Crypto.hash(message: message)
        let anotherDigest = Crypto.hash(message: anotherMessage)
        
        XCTAssertNotNil(digest)
        XCTAssertNotNil(anotherDigest)
        
        XCTAssertEqual(digest, anotherDigest)
    }
    
    func test_hashMessage_hasDifferentHashes() {
        let message = "test"
        let anotherMessage = "test2"
        
        let digest = Crypto.hash(message: message)
        let anotherDigest = Crypto.hash(message: anotherMessage)
        
        XCTAssertNotNil(digest)
        XCTAssertNotNil(anotherDigest)
        
        XCTAssertNotEqual(digest, anotherDigest)
    }
    
}
