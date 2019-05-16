//
//  GetGathersService.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 16/05/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - Service
final class GetGathersService {
    private let session: NetworkSession
    private let urlRequest: URLRequestFactory
    
    init(session: NetworkSession = URLSession.shared,
         urlRequest: URLRequestFactory = AuthURLRequestFactory(endpoint: Endpoint(path: "api/gathers"))) {
        self.session = session
        self.urlRequest = urlRequest
    }
    
    func getGathers(completion: @escaping (Result<[GatherResponseModel], Error>) -> Void) {
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
                let gathers = try JSONDecoder().decode([GatherResponseModel].self, from: data)
                completion(.success(gathers))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
}

// MARK: - Model
struct GatherResponseModel: Decodable {
    let id: UUID
    let userId: UUID
    let score: String?
    let winnerTeam: String?
}
