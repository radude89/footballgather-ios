//
//  LoginPresenter.swift
//  FootballGather
//
//  Created by Radu Dan on 05/02/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

protocol LoginPresenterProtocol: AnyObject {
    var rememberUsername: Bool { get }
    var username: String? { get }
    
    func setRememberUsername(_ value: Bool)
    func setUsername(_ username: String?)
    func performLogin(withUsername username: String?, andPassword password: String?)
    func performRegister(withUsername username: String?, andPassword password: String?)
}

final class LoginPresenter: LoginPresenterProtocol {
    private weak var view: LoginViewProtocol?
    private let loginService: LoginService
    private let usersService: StandardNetworkService
    private let userDefaults: FootballGatherUserDefaults
    private let keychain: FootbalGatherKeychain
    
    init(view: LoginViewProtocol? = nil,
         loginService: LoginService = LoginService(),
         usersService: StandardNetworkService = StandardNetworkService(resourcePath: "/api/users"),
         userDefaults: FootballGatherUserDefaults = .shared,
         keychain: FootbalGatherKeychain = .shared) {
        self.view = view
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
    
    func performLogin(withUsername username: String?, andPassword password: String?) {
        guard let userText = username, userText.isEmpty == false,
            let passwordText = password, passwordText.isEmpty == false else {
                view?.handleError(title: "Error", message: "Both fields are mandatory.")
                return
        }

        view?.showLoadingView()
    
        let requestModel = UserRequestModel(username: userText, password: passwordText)
        loginService.login(user: requestModel) { [weak self] result in
            DispatchQueue.main.async {
                self?.view?.hideLoadingView()
                
                switch result {
                case .failure(let error):
                    self?.view?.handleError(title: "Error", message: String(describing: error))
                    
                case .success(_):
                    self?.view?.handleLoginSuccessful()
                }
            }
        }
    }
    
    func performRegister(withUsername username: String?, andPassword password: String?) {
        guard let userText = username, userText.isEmpty == false,
            let passwordText = password, passwordText.isEmpty == false else {
                view?.handleError(title: "Error", message: "Both fields are mandatory.")
                return
        }
        
        guard let hashedPasssword = Crypto.hash(message: passwordText) else {
            fatalError("Unable to hash password")
        }

        view?.showLoadingView()
        
        let requestModel = UserRequestModel(username: userText, password: hashedPasssword)
        usersService.create(requestModel) { [weak self] result in
            DispatchQueue.main.async {
                self?.view?.hideLoadingView()
                
                switch result {
                case .failure(let error):
                    self?.view?.handleError(title: "Error", message: String(describing: error))
                    
                case .success(let resourceId):
                    print("Created user: \(resourceId)")
                    self?.view?.handleRegisterSuccessful()
                }
            }
        }
    }
    
}
