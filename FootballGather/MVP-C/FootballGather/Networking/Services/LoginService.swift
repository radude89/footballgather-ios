//
//  LoginService.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 15/04/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - Service
final class LoginService: NetworkService {
    var session: NetworkSession
    var urlRequest: URLRequestFactory
    private var appKeychain: ApplicationKeychain
    
    init(session: NetworkSession = URLSession.shared,
         urlRequest: URLRequestFactory = StandardURLRequestFactory(endpoint: StandardEndpoint("/api/users/login")),
         appKeychain: ApplicationKeychain = FootbalGatherKeychain.shared) {
        self.session = session
        self.urlRequest = urlRequest
        self.appKeychain = appKeychain
    }
    
    func login(user: UserRequestModel, completion: @escaping (Result<Bool, Error>) -> Void) {
        var request = urlRequest.makeURLRequest()
        request.httpMethod = "POST"
        
        let basicAuth = BasicAuth(username: user.username, password: Crypto.hash(message: user.password)!)
        request.setValue("Basic \(basicAuth.encoded)", forHTTPHeaderField: "Authorization")
        
        session.loadData(from: request) { [weak self] (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, data.isEmpty == false else {
                completion(.failure(ServiceError.expectedDataInResponse))
                return
            }
            
            guard let loginResponse = try? JSONDecoder().decode(LoginResponseModel.self, from: data) else {
                completion(.failure(ServiceError.unexpectedResponse))
                return
            }
            
            self?.appKeychain.token = loginResponse.token
            
            completion(.success(true))
        }
    }
    
}
