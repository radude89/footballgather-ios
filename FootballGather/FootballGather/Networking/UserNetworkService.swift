//
//  UserNetworkService.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 13/04/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - Service
struct UserNetworkService: NetworkService {
    var session: NetworkSession
    var urlRequest: URLRequestFactory
    
    init(session: NetworkSession = URLSession.shared,
         urlRequest: URLRequestFactory = StandardURLRequestFactory("/api/users")) {
        self.session = session
        self.urlRequest = urlRequest
    }
}

// MARK: - Model
struct UserRequestModel: Encodable {
    let username: String
    var password: String
}

extension UserRequestModel {
    mutating func hashPassword() {
        self.password = Crypto.hash(message: password)!
    }
}
