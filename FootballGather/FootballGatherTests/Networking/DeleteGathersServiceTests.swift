//
//  DeleteGathersServiceTests.swift
//  FootballGatherTests
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 17/05/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import XCTest
@testable import FootballGather

final class DeleteGatherServiceTests: XCTestCase {
    
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
    
    func test_request_completesSuccessfully() {
        let endpoint = EndpointMockFactory.makeSuccessfulEndpoint(path: resourcePath)
        var service = GatherNetworkService(session: session,
                                           urlRequest: AuthURLRequestFactory(endpoint: endpoint, keychain: appKeychain))
        let exp = expectation(description: "Waiting response expectation")
        
        service.delete(withID: ResourceID.uuid(ModelsMock.gatherUUID)) { result in
            switch result {
            case .success(let resultValue):
                XCTAssertTrue(resultValue)
                exp.fulfill()
            case .failure(_):
                XCTFail("Unexpected failure")
            }
        }
        
        wait(for: [exp], timeout: TestConfigurator.defaultTimeout)
    }
    
    func test_request_completesWithError() {
        let endpoint = EndpointMockFactory.makeErrorEndpoint()
        var service = GatherNetworkService(session: session,
                                           urlRequest: AuthURLRequestFactory(endpoint: endpoint, keychain: appKeychain))
        let exp = expectation(description: "Waiting response expectation")
        
        service.delete(withID: ResourceID.uuid(ModelsMock.gatherUUID)) { result in
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
        let endpoint = EndpointMockFactory.makeUnexpectedStatusCodeCreateEndpoint()
        var service = GatherNetworkService(session: session,
                                           urlRequest: AuthURLRequestFactory(endpoint: endpoint, keychain: appKeychain))
        let exp = expectation(description: "Waiting response expectation")
        
        service.delete(withID: ResourceID.uuid(ModelsMock.gatherUUID)) { result in
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
    
}
