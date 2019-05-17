//
//  AddPlayerToGatherService.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 16/05/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - Service
final class AddPlayerToGatherService {
    private let session: NetworkSession
    private var urlRequest: URLRequestFactory
    
    init(session: NetworkSession = URLSession.shared,
         urlRequest: URLRequestFactory = AuthURLRequestFactory(endpoint: StandardEndpoint(path: "api/gathers"))) {
        self.session = session
        self.urlRequest = urlRequest
    }
    
    func addPlayer(_ player: Player, to gather: Gather, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let gatherUUID = gather.serverId else {
            completion(.failure(ServiceError.invalidRequestData))
            return
        }
        
        let endpoint = StandardEndpoint(path: "\(urlRequest.endpoint.path)/\(gatherUUID.uuidString)/players/\(Int(player.serverId))")
        urlRequest.endpoint = endpoint
        
        var request = urlRequest.makeURLRequest()
        request.httpMethod = "POST"
        
        session.loadData(from: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(ServiceError.unexpectedResponse))
                return
            }
            
            completion(.success(true))
        }
    }
        
}
