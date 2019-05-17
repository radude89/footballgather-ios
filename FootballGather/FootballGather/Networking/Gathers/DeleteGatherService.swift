//
//  DeleteGatherService.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 16/05/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - Service
final class DeleteGatherService {
    private let session: NetworkSession
    private var urlRequest: URLRequestFactory
    
    init(session: NetworkSession = URLSession.shared,
         urlRequest: URLRequestFactory = AuthURLRequestFactory(endpoint: StandardEndpoint(path: "/api/gathers"))) {
        self.session = session
        self.urlRequest = urlRequest
    }
    
    func deleteGather(havingServerId serverId: UUID, completion: @escaping (Result<Bool, Error>) -> Void) {
        var updatedEndpoint = urlRequest.endpoint
        updatedEndpoint.path = "\(updatedEndpoint.path)/\(serverId.uuidString)"
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
    
}
