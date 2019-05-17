//
//  DeletePlayerService.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 15/05/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - Service
final class DeletePlayerService {
    private let session: NetworkSession
    private var urlRequest: URLRequestFactory
    
    init(session: NetworkSession = URLSession.shared,
         urlRequest: URLRequestFactory = AuthURLRequestFactory(endpoint: StandardEndpoint(path: "api/players"))) {
        self.session = session
        self.urlRequest = urlRequest
    }
    
    func deletePlayer(havingServerId serverId: Int, completion: @escaping (Result<Bool, Error>) -> Void) {
        let endpoint = StandardEndpoint(path: "\(urlRequest.endpoint.path)/\(serverId)")
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
