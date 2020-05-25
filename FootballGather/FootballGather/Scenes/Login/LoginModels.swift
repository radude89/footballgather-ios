//
//  LoginModels.swift
//  FootballGather
//
//  Created by Radu Dan on 25/05/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

enum Login {
    enum LoadCredentials {
        struct Request {}

        struct Response {
            let rememberUsername: Bool
            let username: String?
        }
        
        struct ViewModel {
            let rememberMeIsOn: Bool
            let usernameText: String?
        }
    }
    
    enum Authenticate {
        struct Request {
            let username: String?
            let password: String?
            let storeCredentials: Bool
        }
        
        struct Response {
            let error: LoginError?
        }
        
        struct ViewModel {
            let isSuccessful: Bool
            let errorTitle: String?
            let errorDescription: String?
        }
    }
}

enum LoginError: Error {
    case missingCredentials
    case loginFailed(String)
    case registerFailed(String)
}
