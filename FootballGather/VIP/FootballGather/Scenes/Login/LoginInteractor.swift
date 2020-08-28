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
    
    var presenter: LoginPresenterProtocol
    
    private let loginService: LoginService
    private let usersService: StandardNetworkService
    private let userDefaults: FootballGatherUserDefaults
    private let keychain: FootbalGatherKeychain
    
    init(presenter: LoginPresenterProtocol = LoginPresenter(),
         loginService: LoginService = LoginService(),
         usersService: StandardNetworkService = StandardNetworkService(resourcePath: "/api/users"),
         userDefaults: FootballGatherUserDefaults = .shared,
         keychain: FootbalGatherKeychain = .shared) {
        self.presenter = presenter
        self.loginService = loginService
        self.usersService = usersService
        self.userDefaults = userDefaults
        self.keychain = keychain
    }
    
}

// MARK: - Services
extension LoginInteractor: LoginInteractorServiceRequester {
    func loadCredentials(request: Login.LoadCredentials.Request) {
        let rememberUsername = userDefaults.rememberUsername ?? true
        let username = keychain.username
        let response = Login.LoadCredentials.Response(rememberUsername: rememberUsername, username: username)
        presenter.presentCredentials(response: response)
    }
    
    func login(request: Login.Authenticate.Request) {
        guard let username = request.username, let password = request.password else {
            let response = Login.Authenticate.Response(error: .missingCredentials)
            presenter.authenticationCompleted(response: response)
            return
        }
        
        let requestModel = UserRequestModel(username: username, password: password)
        loginService.login(user: requestModel) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    let response = Login.Authenticate.Response(error: .loginFailed(error.localizedDescription))
                    self?.presenter.authenticationCompleted(response: response)
                    
                case .success(_):
                    guard let self = self else { return }
                    
                    self.updateCredentials(username: username, shouldStore: request.storeCredentials)
                    
                    let response = Login.Authenticate.Response(error: nil)
                    self.presenter.authenticationCompleted(response: response)
                }
            }
        }
    }
    
    func register(request: Login.Authenticate.Request) {
        guard let username = request.username, let password = request.password else {
            let response = Login.Authenticate.Response(error: .missingCredentials)
            presenter.authenticationCompleted(response: response)
            return
        }
        
        guard let hashedPasssword = Crypto.hash(message: password) else {
            fatalError("Unable to hash password")
        }
        
        let requestModel = UserRequestModel(username: username, password: hashedPasssword)
        usersService.create(requestModel) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    let response = Login.Authenticate.Response(error: .loginFailed(error.localizedDescription))
                    self?.presenter.authenticationCompleted(response: response)
                    
                case .success(let resourceId):
                    print("Created user: \(resourceId)")
                    guard let self = self else { return }
                    
                    self.updateCredentials(username: username, shouldStore: request.storeCredentials)
                    
                    let response = Login.Authenticate.Response(error: nil)
                    self.presenter.authenticationCompleted(response: response)
                }
            }
        }
    }
    
    private func updateCredentials(username: String, shouldStore: Bool) {
        keychain.username = shouldStore ? username : nil
        userDefaults.rememberUsername = shouldStore
    }
}
