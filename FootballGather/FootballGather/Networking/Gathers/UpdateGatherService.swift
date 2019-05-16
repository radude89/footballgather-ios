//
//  UpdateGatherService.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 16/05/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - Service
final class UpdateGatherService {
    private let session: NetworkSession
    private var urlRequest: URLRequestFactory
    
    init(session: NetworkSession = URLSession.shared,
         urlRequest: URLRequestFactory = AuthURLRequestFactory(endpoint: Endpoint(path: "api/gathers"))) {
        self.session = session
        self.urlRequest = urlRequest
    }
    
    func updateGather(_ gather: Gather, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let serverUUID = gather.serverId else {
            completion(.failure(ServiceError.invalidRequestData))
            return
        }
        
        let endpoint = Endpoint(path: "\(urlRequest.endpoint.path)/\(serverUUID.uuidString)")
        urlRequest.endpoint = endpoint
        
        let gatherCreateModel = GatherCreateData(score: gather.score, winnerTeam: gather.winnerTeam)
        
        var request = urlRequest.makeURLRequest()
        request.httpMethod = "PUT"
        request.httpBody = try? JSONEncoder().encode(gatherCreateModel)
        
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
