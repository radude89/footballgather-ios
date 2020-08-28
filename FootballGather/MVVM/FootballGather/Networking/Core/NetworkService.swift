//
//  NetworkService.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 02/06/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - NetworkService
protocol NetworkService {
    var session: NetworkSession { get set }
    var urlRequest: URLRequestFactory { get set }
    
    func create<Resource: Encodable>(_ resource: Resource, completion: @escaping (Result<ResourceID, Error>) -> Void)
    func get<Resource: Decodable>(completion: @escaping (Result<[Resource], Error>) -> Void)
    mutating func delete(withID resourceID: ResourceID, completion: @escaping (Result<Bool, Error>) -> Void)
    mutating func update<Resource: Encodable>(_ resource: Resource, resourceID: ResourceID, completion: @escaping (Result<Bool, Error>) -> Void)
}

// MARK: - ID model
enum ResourceID {
    case integer(Int)
    case uuid(UUID)
}

// MARK: - Basic implementation
struct StandardNetworkService: NetworkService {
    var session: NetworkSession
    var urlRequest: URLRequestFactory
    private var appKeychain: ApplicationKeychain
    
    init(session: NetworkSession = URLSession.shared,
         urlRequest: URLRequestFactory,
         appKeychain: ApplicationKeychain = FootbalGatherKeychain.shared) {
        self.session = session
        self.urlRequest = urlRequest
        self.appKeychain = appKeychain
    }
    
    init(resourcePath: String, authenticated: Bool = false) {
        let endpoint = StandardEndpoint(path: resourcePath)
        if authenticated == false {
            self.init(urlRequest: StandardURLRequestFactory(endpoint: endpoint))
        } else {
            self.init(urlRequest: AuthURLRequestFactory(endpoint: endpoint))
        }
    }
}
