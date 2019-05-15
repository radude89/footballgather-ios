//
//  GetPlayerService.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 15/05/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - Service
final class GetPlayerService {
    private let session: NetworkSession
    private var urlRequest: URLRequestFactory

    init(session: NetworkSession = URLSession.shared,
         urlRequest: URLRequestFactory = AuthURLRequestFactory(endpoint: Endpoint(path: "api/players"))) {
        self.session = session
        self.urlRequest = urlRequest
    }
    
    func getPlayer(withServerId serverId: Int, completion: @escaping (Result<PlayerResponseModel, Error>) -> Void) {
        let endpoint = Endpoint(path: "\(urlRequest.endpoint.path)/\(serverId)")
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
                let player = try JSONDecoder().decode(PlayerResponseModel.self, from: data)
                completion(.success(player))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
