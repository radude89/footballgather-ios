//
//  UpdateNetworkService.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 02/06/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import Foundation

extension NetworkService {
    mutating func update<Resource: Encodable>(_ resource: Resource, resourceID: ResourceID, completion: @escaping (Result<Bool, Error>) -> Void) {
        var updatedEndpoint = urlRequest.endpoint
        
        switch resourceID {
        case .uuid(let uuid):
            updatedEndpoint.path = "\(updatedEndpoint.path)/\(uuid.uuidString)"
        case .integer(let serverID):
            updatedEndpoint.path = "\(updatedEndpoint.path)/\(serverID)"
        }
        
        urlRequest.endpoint = updatedEndpoint
        
        var request = urlRequest.makeURLRequest()
        request.httpMethod = "PUT"
        request.httpBody = try? JSONEncoder().encode(resource)
        
        session.loadData(from: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 204 else {
                completion(.failure(ServiceError.unexpectedResponse))
                return
            }
            
            completion(.success(true))
        }
    }
}
