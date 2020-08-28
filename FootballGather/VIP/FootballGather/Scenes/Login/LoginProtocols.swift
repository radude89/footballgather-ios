//
//  LoginProtocols.swift
//  FootballGather
//
//  Created by Radu Dan on 23/04/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - Router
protocol LoginRouterProtocol: AnyObject {
    func showPlayerList()
}

// MARK: - View
typealias LoginViewProtocol = LoginViewable & LoginViewConfigurable & Loadable & ErrorHandler

protocol LoginViewable: AnyObject {
    var interactor: LoginInteractorProtocol { get set }
    var router: LoginRouterProtocol { get set }
}

protocol LoginViewConfigurable: AnyObject {
    func displayStoredCredentials(viewModel: Login.LoadCredentials.ViewModel)
    func loginCompleted(viewModel: Login.Authenticate.ViewModel)
}

// MARK: - Interactor
typealias LoginInteractorProtocol = LoginInteractable & LoginInteractorServiceRequester

protocol LoginInteractable: AnyObject {
    var presenter: LoginPresenterProtocol { get set }
}

protocol LoginInteractorServiceRequester: AnyObject {
    func loadCredentials(request: Login.LoadCredentials.Request)
    func login(request: Login.Authenticate.Request)
    func register(request: Login.Authenticate.Request)
}

// MARK: - Presenter
typealias LoginPresenterProtocol = LoginPresentable & LoginPresenterServiceHandler

protocol LoginPresentable: AnyObject {
    var view: LoginViewProtocol? { get set }
}

protocol LoginPresenterServiceHandler: AnyObject {
    func presentCredentials(response: Login.LoadCredentials.Response)
    func authenticationCompleted(response: Login.Authenticate.Response)
}
