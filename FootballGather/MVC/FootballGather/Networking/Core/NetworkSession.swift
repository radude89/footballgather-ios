//
//  Networking.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 13/04/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - ServiceError
enum ServiceError: Error {
    case unexpectedResponse
    case locationHeaderNotFound
    case resourceIDNotFound
    case unexpectedResourceIDType
    case expectedDataInResponse
    case invalidRequestData
}

// MARK: - Network Session
protocol NetworkSession {
    func loadData(from urlRequest: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
}

extension URLSession: NetworkSession {
    func loadData(from urlRequest: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let task  = dataTask(with: urlRequest) { (data, response, error) in
            completionHandler(data, response, error)
        }
        
        task.resume()
    }
}
