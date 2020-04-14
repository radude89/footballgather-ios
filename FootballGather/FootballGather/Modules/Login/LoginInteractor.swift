//
//  LoginInteractor.swift
//  FootballGather
//
//  Created by Radu Dan on 13/04/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - LoginInteractor
final class LoginInteractor: LoginInteractable {
    
    weak var presenter: LoginPresenterProtocol?
    
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
    
}

// MARK: - Credentials handler
extension LoginInteractor: LoginInteractorCredentialsHandler {
    
    var rememberUsername: Bool { userDefaults.rememberUsername ?? true }
    
    var username: String? { keychain.username }
    
    func setRememberUsername(_ value: Bool) {
        userDefaults.rememberUsername = value
    }
    
    func setUsername(_ username: String?) {
        keychain.username = username
    }
}

// MARK: - Services
extension LoginInteractor: LoginInteractorServiceRequester {
    func login(username: String, password: String) {
        let requestModel = UserRequestModel(username: username, password: password)
        loginService.login(user: requestModel) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    self?.presenter?.serviceFailedWithError(error)
                    
                case .success(_):
                    self?.presenter?.didLogin()
                }
            }
        }
    }
    
    func register(username: String, password: String) {
        guard let hashedPasssword = Crypto.hash(message: password) else {
            fatalError("Unable to hash password")
        }
        
        let requestModel = UserRequestModel(username: username, password: hashedPasssword)
        usersService.create(requestModel) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    self?.presenter?.serviceFailedWithError(error)
                    
                case .success(let resourceId):
                    print("Created user: \(resourceId)")
                    self?.presenter?.didRegister()
                }
            }
        }
    }
}
 
