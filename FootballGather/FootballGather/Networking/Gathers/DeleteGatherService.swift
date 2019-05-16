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
         urlRequest: URLRequestFactory = AuthURLRequestFactory(endpoint: Endpoint(path: "api/gathers"))) {
        self.session = session
        self.urlRequest = urlRequest
    }
    
    func deleteGather(havingServerId serverId: UUID, completion: @escaping (Result<Bool, Error>) -> Void) {
        let endpoint = Endpoint(path: "\(urlRequest.endpoint.path)/\(serverId.uuidString)")
        urlRequest.endpoint = endpoint
        
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
