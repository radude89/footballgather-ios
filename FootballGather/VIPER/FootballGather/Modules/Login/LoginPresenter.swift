//
//  LoginPresenter.swift
//  FootballGather
//
//  Created by Radu Dan on 05/02/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

// MARK:- LoginPresenter
final class LoginPresenter: LoginPresentable {
    
    // MARK: - Properties
    weak var view: LoginViewProtocol?
    var interactor: LoginInteractorProtocol
    var router: LoginRouterProtocol
    
    // MARK: - Public API
    init(view: LoginViewProtocol? = nil,
         interactor: LoginInteractorProtocol = LoginInteractor(),
         router: LoginRouterProtocol = LoginRouter()) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
    
}

// MARK: - View Configuration
extension LoginPresenter: LoginPresenterViewConfiguration {
    func viewDidLoad() {
        let rememberUsername = interactor.rememberUsername
        
        view?.setRememberMeSwitch(isOn: rememberUsername)
        
        if rememberUsername {
            view?.setUsername(interactor.username)
        }
    }
}

// MARK: - Interactor
extension LoginPresenter: LoginPresenterServiceInteractable {
    func performLogin() {
        guard validateCredentials() else { return }
        
        view?.showLoadingView()
        
        interactor.login(username: username!, password: password!)
    }
    
    func performRegister() {
        guard validateCredentials() else { return }
        
        view?.showLoadingView()
        
        interactor.register(username: username!, password: password!)
    }
    
    private func validateCredentials() -> Bool {
        guard credentialsAreValid else {
            view?.handleError(title: "Error", message: "Both fields are mandatory.")
            return false
        }
        
        return true
    }
    
    private var credentialsAreValid: Bool {
        username?.isEmpty == false && password?.isEmpty == false
    }
    
    private var username: String? {
        view?.usernameText
    }
    
    private var password: String? {
        view?.passwordText
    }
}

// MARK: - Service Handler
extension LoginPresenter: LoginPresenterServiceHandler {
    func serviceFailedWithError(_ error: Error) {
        view?.hideLoadingView()
        view?.handleError(title: "Error", message: String(describing: error))
    }
    
    func didLogin() {
        handleAuthCompletion()
    }
    
    func didRegister() {
        handleAuthCompletion()
    }
    
    private func handleAuthCompletion() {
        storeUsernameAndRememberMe()
        view?.hideLoadingView()
        router.showPlayerList()
    }
    
    private func storeUsernameAndRememberMe() {
        let rememberMe = view?.rememberMeIsOn ?? true
        
        if rememberMe {
            interactor.setUsername(view?.usernameText)
        } else {
            interactor.setUsername(nil)
        }
    }
}
