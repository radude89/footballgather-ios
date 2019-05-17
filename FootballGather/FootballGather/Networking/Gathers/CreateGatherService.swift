//
//  CreateGatherService.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 15/05/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - Service
final class CreateGatherService {
    private let session: NetworkSession
    private let urlRequest: URLRequestFactory
    
    init(session: NetworkSession = URLSession.shared,
         urlRequest: URLRequestFactory = AuthURLRequestFactory(endpoint: StandardEndpoint(path: "/api/gathers"))) {
        self.session = session
        self.urlRequest = urlRequest
    }
    
    func createGather(_ gather: GatherCreateModel, completion: @escaping (Result<UUID, Error>) -> Void) {
        var request = urlRequest.makeURLRequest()
        request.httpMethod = "POST"
        
        if gather.score != nil || gather.winnerTeam != nil {
            request.httpBody = try? JSONEncoder().encode(gather)            
        }
        
        session.loadData(from: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
                completion(.failure(ServiceError.unexpectedResponse))
                return
            }
            
            guard let gatherIdLocation = httpResponse.allHeaderFields["Location"] as? String else {
                completion(.failure(ServiceError.locationHeaderNotFound))
                return
            }
            
            guard let gatherId = gatherIdLocation.components(separatedBy: "/").last,
                let gatherUUID = UUID(uuidString: gatherId) else {
                    completion(.failure(ServiceError.resourceIdNotFound))
                    return
            }
            
            completion(.success(gatherUUID))
        }
    }
    
}

// MARK: - Model
struct GatherCreateModel: Encodable {
    let score: String?
    let winnerTeam: String?
    
    init(score: String? = nil, winnerTeam: String? = nil) {
        self.score = score
        self.winnerTeam = winnerTeam
    }
}
