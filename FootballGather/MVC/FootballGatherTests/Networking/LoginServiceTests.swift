//
//  LoginServiceTests.swift
//  FootballGatherTests
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 17/05/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import XCTest
@testable import FootballGather

final class LoginServiceTests: XCTestCase {
    
    private let session = URLSessionMockFactory.makeSession()
    private let resourcePath = "/api/users/login"
    private let appKeychain = AppKeychainMockFactory.makeKeychain()
    
    override func tearDown() {
        appKeychain.storage.removeAll()
        super.tearDown()
    }
    
    func test_request_completesSuccessfully() {
        let endpoint = EndpointMockFactory.makeSuccessfulEndpoint(path: resourcePath)
        let service = LoginService(session: session,
                                   urlRequest: StandardURLRequestFactory(endpoint: endpoint),
                                   appKeychain: appKeychain)
        let user = ModelsMockFactory.makeUser()
        let exp = expectation(description: "Waiting response expectation")
        
        service.login(user: user) { [weak self] result in
            switch result {
            case .success(let success):
                XCTAssertTrue(success)
                XCTAssertEqual(self?.appKeychain.token!, ModelsMock.token)
                exp.fulfill()
            case .failure(_):
                XCTFail("Unexpected failure")
            }
        }
        
        wait(for: [exp], timeout: TestConfigurator.defaultTimeout)
    }
    
    func test_request_completesWithError() {
        let endpoint = EndpointMockFactory.makeErrorEndpoint()
        let service = LoginService(session: session,
                                   urlRequest: StandardURLRequestFactory(endpoint: endpoint),
                                   appKeychain: appKeychain)
        let user = ModelsMockFactory.makeUser()
        let exp = expectation(description: "Waiting response expectation")
        
        service.login(user: user) { result in
            switch result {
            case .success(_):
                XCTFail("Request should have failed")
            case .failure(_):
                XCTAssertTrue(true)
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: TestConfigurator.defaultTimeout)
    }
    
    func test_request_completesWithEmtpyDataError() {
        let endpoint = EndpointMockFactory.makeEmptyResponseEndpoint()
        let service = LoginService(session: session,
                                   urlRequest: StandardURLRequestFactory(endpoint: endpoint),
                                   appKeychain: appKeychain)
        let user = ModelsMockFactory.makeUser()
        let exp = expectation(description: "Waiting response expectation")
        
        service.login(user: user) { result in
            switch result {
            case .success(_):
                XCTFail("Request should have failed")
            case .failure(_):
                XCTAssertTrue(true)
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: TestConfigurator.defaultTimeout)
    }
    
    func test_request_completesWithTransformModelError() {
        let endpoint = EndpointMockFactory.makeInvalidModelTansformEndpoint()
        let service = LoginService(session: session,
                                   urlRequest: StandardURLRequestFactory(endpoint: endpoint),
                                   appKeychain: appKeychain)
        let user = ModelsMockFactory.makeUser()
        let exp = expectation(description: "Waiting response expectation")
        
        service.login(user: user) { result in
            switch result {
            case .success(_):
                XCTFail("Request should have failed")
            case .failure(_):
                XCTAssertTrue(true)
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: TestConfigurator.defaultTimeout)
    }

}
