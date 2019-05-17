//
//  CreateUserService.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 13/04/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - Service
final class CreateUserService {
    private let session: NetworkSession
    private let urlRequest: URLRequestFactory
    
    init(session: NetworkSession = URLSession.shared,
         urlRequest: URLRequestFactory = StandardURLRequestFactory(endpoint: StandardEndpoint(path: "/api/users"))) {
        self.session = session
        self.urlRequest = urlRequest
    }
    
    func createUser(_ user: UserRequestModel, completion: @escaping (Result<UUID, Error>) -> Void) {
        var request = urlRequest.makeURLRequest()
        // hashing password
        let requestUser = UserRequestModel(userModel: user)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(requestUser)
        
        session.loadData(from: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
                completion(.failure(ServiceError.unexpectedResponse))
                return
            }
            
            guard let userIdLocation = httpResponse.allHeaderFields["Location"] as? String else {
                completion(.failure(ServiceError.locationHeaderNotFound))
                return
            }
            
            guard let userId = userIdLocation.components(separatedBy: "/").last,
                let userUUID = UUID(uuidString: userId) else {
                    completion(.failure(ServiceError.resourceIdNotFound))
                    return
            }
            
            completion(.success(userUUID))
        }
    }
    
}

// MARK: - Model
struct UserRequestModel: Encodable {
    let username: String
    let password: String
}

extension UserRequestModel {
    init(userModel: UserRequestModel) {
        self.username = userModel.username
        self.password = Crypto.hash(message: userModel.password)!
    }
}
