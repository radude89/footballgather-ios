//
//  LoginServiceModels.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 02/06/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import Foundation

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
        // Postman  ZGVtby11c2VyOjAyY2NmMjcxMDU1NTRiOWE3ZmM1MTJiYTlmNDBiODYzZmY5NzRjMzU0ODc1MTJhN2VhOGIwZTY2MWY4MzFiMTI
        // Local    ZGVtby11c2VyOjA3NGY3MWUzZmFlZDY0ZmVjZThmNGQ3MmRmZDI3Y2ZmMTUzYTBlNmQ3YTI1M2Q5NDMzM2Q0OTMzN2Y2Y2NkMzY
        let loginString = String(format: "%@:%@", username, password)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        
        return base64LoginString
    }
}
