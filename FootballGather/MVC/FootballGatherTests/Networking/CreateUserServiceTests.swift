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
        let service = StandardNetworkService(session: session, urlRequest: StandardURLRequestFactory(endpoint: endpoint))
        let exp = expectation(description: "Waiting response expectation")
        
        var user = ModelsMockFactory.makeUser()
        user.hashPassword()
        
        service.create(user) { result in
            if case let .success(ResourceID.uuid(uuid)) = result {
                XCTAssertEqual(uuid, ModelsMock.userUUID)
                exp.fulfill()
            } else {
                XCTFail("Unexpected failure")
            }
        }
        
        wait(for: [exp], timeout: TestConfigurator.defaultTimeout)
    }
    
    func test_request_completesWithError() {
        let endpoint = EndpointMockFactory.makeErrorEndpoint()
        let service = StandardNetworkService(session: session, urlRequest: StandardURLRequestFactory(endpoint: endpoint))
        let exp = expectation(description: "Waiting response expectation")
        
        var user = ModelsMockFactory.makeUser()
        user.hashPassword()
        
        service.create(user) { result in
            if case .failure(_) = result {
                XCTAssertTrue(true)
                exp.fulfill()
            } else {
                XCTFail("Request should have failed")
            }
        }
        
        wait(for: [exp], timeout: TestConfigurator.defaultTimeout)
    }
    
    func test_request_completesWithUnexpectedResponseStatusCode() {
        let endpoint = EndpointMockFactory.makeUnexpectedStatusCodeCreateEndpoint()
        let service = StandardNetworkService(session: session, urlRequest: StandardURLRequestFactory(endpoint: endpoint))
        let exp = expectation(description: "Waiting response expectation")
        
        var user = ModelsMockFactory.makeUser()
        user.hashPassword()
        
        service.create(user) { result in
            if case .failure(let error as ServiceError) = result {
                XCTAssertEqual(error, .unexpectedResponse)
                exp.fulfill()
            } else {
                XCTFail("Request should have failed with a service error")
            }
        }
        
        wait(for: [exp], timeout: TestConfigurator.defaultTimeout)
    }
    
    func test_request_completesWithoutLocationHeader() {
        let endpoint = EndpointMockFactory.makeLocationHeaderNotFoundEndpoint()
        let service = StandardNetworkService(session: session, urlRequest: StandardURLRequestFactory(endpoint: endpoint))
        let exp = expectation(description: "Waiting response expectation")
        
        var user = ModelsMockFactory.makeUser()
        user.hashPassword()
        
        service.create(user) { result in
            if case .failure(let error as ServiceError) = result {
                XCTAssertEqual(error, .locationHeaderNotFound)
                exp.fulfill()
            } else {
                XCTFail("Request should have failed with a service error")
            }
        }
        
        wait(for: [exp], timeout: TestConfigurator.defaultTimeout)
    }
    
    func test_request_completesWithInvalidResourceId() {
        let endpoint = EndpointMockFactory.makeInvalidResourceIDCreateEndpoint()
        let service = StandardNetworkService(session: session, urlRequest: StandardURLRequestFactory(endpoint: endpoint))
        let exp = expectation(description: "Waiting response expectation")
        
        var user = ModelsMockFactory.makeUser()
        user.hashPassword()
        
        service.create(user) { result in
            if case .failure(let error as ServiceError) = result {
                XCTAssertEqual(error, .unexpectedResourceIDType)
                exp.fulfill()
            } else {
                XCTFail("Request should have failed with a service error")
            }
        }
        
        wait(for: [exp], timeout: TestConfigurator.defaultTimeout)
    }
    
}
