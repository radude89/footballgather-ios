//
//  CreateGatherServiceTests.swift
//  FootballGatherTests
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 17/05/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import XCTest
@testable import FootballGather

final class CreateGatherServiceTests: XCTestCase {
    
    private let session = URLSessionMockFactory.makeSession()
    private let resourcePath = "/api/gathers"
    private let appKeychain = AppKeychainMockFactory.makeKeychain()
    
    override func setUp() {
        super.setUp()
        appKeychain.token = ModelsMock.token
    }
    
    override func tearDown() {
        appKeychain.storage.removeAll()
        super.tearDown()
    }
    
    func test_request_completesSuccessfully_withoutGatherDetails() {
        let endpoint = EndpointMockFactory.makeSuccessfulEndpoint(path: resourcePath)
        let service = StandardNetworkService(session: session, urlRequest: AuthURLRequestFactory(endpoint: endpoint, keychain: appKeychain))
        let gather = ModelsMockFactory.makeGather()
        let exp = expectation(description: "Waiting response expectation")
        
        service.create(gather) { result in
            if case let .success(ResourceID.uuid(uuid)) = result {
                XCTAssertEqual(uuid, ModelsMock.gatherUUID)
                exp.fulfill()
            } else {
                XCTFail("Unexpected failure")
            }
        }
        
        wait(for: [exp], timeout: TestConfigurator.defaultTimeout)
    }
    
    func test_request_completesSuccessfully_withGatherDetails() {
        let endpoint = EndpointMockFactory.makeSuccessfulEndpoint(path: resourcePath)
        let service = StandardNetworkService(session: session, urlRequest: AuthURLRequestFactory(endpoint: endpoint, keychain: appKeychain))
        let gather = ModelsMockFactory.makeGather()
        let exp = expectation(description: "Waiting response expectation")
        
        service.create(gather) { result in
            if case let .success(ResourceID.uuid(uuid)) = result {
                XCTAssertEqual(uuid, ModelsMock.gatherUUID)
                exp.fulfill()
            } else {
                XCTFail("Unexpected failure")
            }
        }
        
        wait(for: [exp], timeout: TestConfigurator.defaultTimeout)
    }
    
    func test_request_completesWithError() {
        let endpoint = EndpointMockFactory.makeErrorEndpoint()
        let service = StandardNetworkService(session: session, urlRequest: AuthURLRequestFactory(endpoint: endpoint, keychain: appKeychain))
        let gather = ModelsMockFactory.makeGather()
        let exp = expectation(description: "Waiting response expectation")
        
        service.create(gather) { result in
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
        let service = StandardNetworkService(session: session, urlRequest: AuthURLRequestFactory(endpoint: endpoint, keychain: appKeychain))
        let gather = ModelsMockFactory.makeGather()
        let exp = expectation(description: "Waiting response expectation")
        
        service.create(gather) { result in
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
        let service = StandardNetworkService(session: session, urlRequest: AuthURLRequestFactory(endpoint: endpoint, keychain: appKeychain))
        let gather = ModelsMockFactory.makeGather()
        let exp = expectation(description: "Waiting response expectation")
        
        service.create(gather) { result in
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
        let service = StandardNetworkService(session: session, urlRequest: AuthURLRequestFactory(endpoint: endpoint, keychain: appKeychain))
        let gather = ModelsMockFactory.makeGather()
        let exp = expectation(description: "Waiting response expectation")
        
        service.create(gather) { result in
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
