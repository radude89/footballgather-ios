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
    
    // MARK: - Public API
    init(view: LoginViewProtocol? = nil) {
        self.view = view
    }
    
}

// MARK: - Service Handler
extension LoginPresenter: LoginPresenterServiceHandler {
    func presentCredentials(response: Login.LoadCredentials.Response) {
        let viewModel = Login.LoadCredentials.ViewModel(rememberMeIsOn: response.rememberUsername,
                                                        usernameText: response.username)
        view?.displayStoredCredentials(viewModel: viewModel)
    }
    
    func authenticationCompleted(response: Login.Authenticate.Response) {
        guard response.error == nil else {
            handleServiceError(response.error)
            return
        }
        
        let viewModel = Login.Authenticate.ViewModel(isSuccessful: true, errorTitle: nil, errorDescription: nil)
        view?.loginCompleted(viewModel: viewModel)
    }
    
    private func handleServiceError(_ error: LoginError?) {
        switch error {
        case .missingCredentials:
            let viewModel = Login.Authenticate.ViewModel(isSuccessful: false,
                                                         errorTitle: "Error",
                                                         errorDescription: "Both fields are mandatory.")
            view?.loginCompleted(viewModel: viewModel)
            
        case .loginFailed(let message), .registerFailed(let message):
            let viewModel = Login.Authenticate.ViewModel(isSuccessful: false,
                                                         errorTitle: "Error",
                                                         errorDescription: String(describing: message))
            view?.loginCompleted(viewModel: viewModel)
            
        default:
            break
        }
    }
}
