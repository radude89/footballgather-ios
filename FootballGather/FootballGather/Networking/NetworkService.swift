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
extension NetworkService {
    func create<Resource: Encodable>(_ resource: Resource, completion: @escaping (Result<ResourceID, Error>) -> Void) {
        var request = urlRequest.makeURLRequest()
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(resource)
        
        session.loadData(from: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
                completion(.failure(ServiceError.unexpectedResponse))
                return
            }
            
            guard let resourceIdLocation = httpResponse.allHeaderFields["Location"] as? String else {
                completion(.failure(ServiceError.locationHeaderNotFound))
                return
            }
            
            guard let resourceId = resourceIdLocation.components(separatedBy: "/").last else {
                completion(.failure(ServiceError.resourceIDNotFound))
                return
            }
            
            if let resourceUUID = UUID(uuidString: resourceId) {
                completion(.success(ResourceID.uuid(resourceUUID)))
            } else if let resourceIntID = Int(resourceId) {
                completion(.success(ResourceID.integer(resourceIntID)))
            } else {
                completion(.failure(ServiceError.unexpectedResourceIDType))
            }
        }
    }
    
    func get<Resource: Decodable>(completion: @escaping (Result<[Resource], Error>) -> Void) {
        var request = urlRequest.makeURLRequest()
        request.httpMethod = "GET"
        
        session.loadData(from: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, data.isEmpty == false else {
                completion(.failure(ServiceError.unexpectedResponse))
                return
            }
            
            do {
                let gathers = try JSONDecoder().decode([Resource].self, from: data)
                completion(.success(gathers))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    mutating func delete(withID resourceID: ResourceID, completion: @escaping (Result<Bool, Error>) -> Void) {
        var updatedEndpoint = urlRequest.endpoint
        
        switch resourceID {
        case .uuid(let uuid):
            updatedEndpoint.path = "\(updatedEndpoint.path)/\(uuid.uuidString)"
        case .integer(let serverID):
            updatedEndpoint.path = "\(updatedEndpoint.path)/\(serverID)"
        }
        
        urlRequest.endpoint = updatedEndpoint
        
        var request = urlRequest.makeURLRequest()
        request.httpMethod = "DELETE"
        
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
