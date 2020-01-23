//
//  LoginViewModel.swift
//  FootballGather
//
//  Created by Radu Dan on 21/01/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

struct LoginViewModel {
    
    private let loginService: LoginService
    private let usersService: StandardNetworkService
    private let userDefaults: FootballGatherUserDefaults
    private let keychain: FootbalGatherKeychain
    
    init(loginService: LoginService = LoginService(),
         usersService: StandardNetworkService = StandardNetworkService(resourcePath: "/api/users"),
         userDefaults: FootballGatherUserDefaults = .shared,
         keychain: FootbalGatherKeychain = .shared) {
        self.loginService = loginService
        self.usersService = usersService
        self.userDefaults = userDefaults
        self.keychain = keychain
    }
    
    var rememberUsername: Bool {
        return userDefaults.rememberUsername ?? true
    }
    
    var username: String? {
        return keychain.username
    }
    
    func setRememberUsername(_ value: Bool) {
        userDefaults.rememberUsername = value
    }
    
    func setUsername(_ username: String?) {
        keychain.username = username
    }
    
    func performLogin(withUsername username: String, andPassword password: String, completion: @escaping (Error?) -> ()) {
        let requestModel = UserRequestModel(username: username, password: password)
        loginService.login(user: requestModel) { result in
            switch result {
            case .failure(let error):
                completion(error)
                
            case .success(_):
                completion(nil)
            }
        }
    }
    
    func performRegister(withUsername username: String, andPassword password: String, completion: @escaping (Error?) -> ()) {
        guard let hashedPasssword = Crypto.hash(message: password) else {
            fatalError("Unable to hash password")
        }
        
        let requestModel = UserRequestModel(username: username, password: hashedPasssword)
        usersService.create(requestModel) { result in
            switch result {
            case .failure(let error):
                completion(error)
                
            case .success(let resourceId):
                print("Created user: \(resourceId)")
                completion(nil)
            }
        }
    }
    
}
