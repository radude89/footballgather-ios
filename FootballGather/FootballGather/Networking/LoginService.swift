//
//  LoginService.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 15/04/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - Service
struct LoginService {
    private let session: NetworkSession
    private let urlRequest: URLRequestFactory
    
    init(session: NetworkSession = URLSession.shared,
         urlRequest: URLRequestFactory = StandardURLRequestFactory(endpoint: Endpoint(path: "api/users/login"))) {
        self.session = session
        self.urlRequest = urlRequest
    }
    
    func login(user: RequestUserModel, completion: @escaping (Result<Bool, Error>) -> Void) {
        var request = urlRequest.makeURLRequest()
        
        let basicAuth = BasicAuth(username: user.username, password: user.password)
        request.setValue("Basic \(basicAuth.encoded)", forHTTPHeaderField: "Authorization")
        
        session.loadData(from: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(ServiceError.expectedDataInResponse))
                return
            }
            
            guard let loginResponse = try? JSONDecoder().decode(LoginResponseModel.self, from: data) else {
                completion(.failure(ServiceError.unexpectedResponse))
                return
            }
            
            // TODO: Save token in Keychain
            
            completion(.success(true))
        }
    }
    
}

// MARK: - Response model
struct LoginResponseModel: Decodable {
    let token: String
}

// MARK: - Basic auth model
struct BasicAuth {
    let username: String
    let password: String
    
    init(username: String, password: String) {
        self.username = username
        self.password = password
    }
    
    var encoded: String {
        let loginString = String(format: "%@:%@", username, password)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        
        return base64LoginString
    }
}
