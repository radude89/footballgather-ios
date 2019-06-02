//
//  GetNetworkService.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 02/06/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import Foundation

extension NetworkService {
    func get<Resource: Decodable>(completion: @escaping (Result<[Resource], Error>) -> Void) {
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
                let gathers = try JSONDecoder().decode([Resource].self, from: data)
                completion(.success(gathers))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
