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
    
    func getPlayers(forGatherId gatherUUID: UUID, completion: @escaping (Result<[PlayerResponseModel], Error>) -> Void) {
        var playersEndpoint = urlRequest.endpoint
        playersEndpoint.path = "\(playersEndpoint.path)/\(gatherUUID.uuidString)/players"
        urlRequest.endpoint = playersEndpoint
        
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
                let players = try JSONDecoder().decode([PlayerResponseModel].self, from: data)
                completion(.success(players))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
}
