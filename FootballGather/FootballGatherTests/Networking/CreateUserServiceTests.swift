//
//  CreateUserServiceTests.swift
//  FootballGatherTests
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 17/05/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import XCTest
@testable import FootballGather

final class CreateUserServiceTests: XCTestCase {
    
    private let session = URLSessionMockFactory.makeSession()
    private let resourcePath = "/api/users"
    
    func test_request_completesSuccessfully() {
        let endpoint = EndpointMockFactory.makeSuccessfulEndpoint(path: resourcePath)
        let service = CreateUserService(session: session, urlRequest: StandardURLRequestFactory(endpoint: endpoint))
        let user = ModelsMockFactory.makeUser()
        let exp = expectation(description: "Waiting response expectation")
        
        service.createUser(user) { result in
            switch result {
            case .success(let uuid):
                XCTAssertEqual(uuid, ModelsMockFactory.userUUID)
                exp.fulfill()
            case .failure(_):
                XCTFail("Unexpected failure")
            }
        }
        
        wait(for: [exp], timeout: TestConfigurator.defaultTimeout)
    }
    
    func test_request_completesWithError() {
        let endpoint = EndpointMockFactory.makeErrorEndpoint(path: resourcePath)
        let service = CreateUserService(session: session, urlRequest: StandardURLRequestFactory(endpoint: endpoint))
        let user = ModelsMockFactory.makeUser()
        let exp = expectation(description: "Waiting response expectation")
        
        service.createUser(user) { result in
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
    
    func test_request_completesWithUnexpectedResponseStatusCode() {
        let endpoint = EndpointMockFactory.makeUnexpectedStatusCodeCreateEndpoint(path: resourcePath)
        let service = CreateUserService(session: session, urlRequest: StandardURLRequestFactory(endpoint: endpoint))
        let user = ModelsMockFactory.makeUser()
        let exp = expectation(description: "Waiting response expectation")
        
        service.createUser(user) { result in
            switch result {
            case .failure(let error as ServiceError):
                XCTAssertEqual(error, .unexpectedResponse)
                exp.fulfill()
            default:
                XCTFail("Request should have failed with a service error")
            }
        }
        
        wait(for: [exp], timeout: TestConfigurator.defaultTimeout)
    }
    
    func test_request_completesWithoutLocationHeader() {
        let endpoint = EndpointMockFactory.makeLocationHeaderNotFoundEndpoint(path: resourcePath)
        let service = CreateUserService(session: session, urlRequest: StandardURLRequestFactory(endpoint: endpoint))
        let user = ModelsMockFactory.makeUser()
        let exp = expectation(description: "Waiting response expectation")
        
        service.createUser(user) { result in
            switch result {
            case .failure(let error as ServiceError):
                XCTAssertEqual(error, .locationHeaderNotFound)
                exp.fulfill()
            default:
                XCTFail("Request should have failed with a service error")
            }
        }
        
        wait(for: [exp], timeout: TestConfigurator.defaultTimeout)
    }
    
    func test_request_completesWithInvalidResourceId() {
        let endpoint = EndpointMockFactory.makeInvalidResourceIDCreateEndpoint(path: resourcePath)
        let service = CreateUserService(session: session, urlRequest: StandardURLRequestFactory(endpoint: endpoint))
        let user = ModelsMockFactory.makeUser()
        let exp = expectation(description: "Waiting response expectation")
        
        service.createUser(user) { result in
            switch result {
            case .failure(let error as ServiceError):
                XCTAssertEqual(error, .resourceIdNotFound)
                exp.fulfill()
            default:
                XCTFail("Request should have failed with a service error")
            }
        }
        
        wait(for: [exp], timeout: TestConfigurator.defaultTimeout)
    }
    
}
