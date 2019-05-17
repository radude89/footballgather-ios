//
//  GetPlayersForGatherService.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 16/05/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - Service
final class GetPlayersForGatherService {
    private let session: NetworkSession
    private var urlRequest: URLRequestFactory
    
    init(session: NetworkSession = URLSession.shared,
         urlRequest: URLRequestFactory = AuthURLRequestFactory(endpoint: StandardEndpoint(path: "/api/gathers"))) {
        self.session = session
        self.urlRequest = urlRequest
    }
    
    func getPlayers(forGather gather: Gather, completion: @escaping (Result<[PlayerResponseModel], Error>) -> Void) {
        guard let gatherUUID = gather.serverId else {
            completion(.failure(ServiceError.invalidRequestData))
            return
        }
        
        let endpoint = StandardEndpoint(path: "\(urlRequest.endpoint.path)/\(gatherUUID.uuidString)/players")
        urlRequest.endpoint = endpoint
        
        var request = urlRequest.makeURLRequest()
        request.httpMethod = "GET"
        
        session.loadData(from: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(ServiceError.unexpectedResponse))
                return
            }
            
            do {
                let players = try JSONDecoder().decode([PlayerResponseModel].self, from: data)
                completion(.success(players))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
}
