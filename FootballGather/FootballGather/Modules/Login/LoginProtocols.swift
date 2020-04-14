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
typealias LoginViewProtocol = LoginViewable & Loadable & LoginViewConfigurable & ErrorHandler

protocol LoginViewable: AnyObject {
    var presenter: LoginPresenterProtocol { get set }
}

protocol LoginViewConfigurable: AnyObject {
    var rememberMeIsOn: Bool { get }
    var usernameText: String? { get }
    var passwordText: String? { get }
    
    func setRememberMeSwitch(isOn: Bool)
    func setUsername(_ username: String?)
}

// MARK: - Presenter
typealias LoginPresenterProtocol = LoginPresentable & LoginPresenterViewConfiguration & LoginPresenterServiceInteractable & LoginPresenterServiceHandler

protocol LoginPresentable: AnyObject {
    var view: LoginViewProtocol? { get set }
    var interactor: LoginInteractorProtocol { get set }
    var router: LoginRouterProtocol { get set }
}

protocol LoginPresenterViewConfiguration: AnyObject {
    func viewDidLoad()
}

protocol LoginPresenterServiceInteractable: AnyObject {
    func performLogin()
    func performRegister()
}

protocol LoginPresenterServiceHandler: AnyObject {
    func serviceFailedWithError(_ error: Error)
    func didLogin()
    func didRegister()
}

// MARK: - Interactor
typealias LoginInteractorProtocol = LoginInteractable & LoginInteractorServiceRequester & LoginInteractorCredentialsHandler

protocol LoginInteractable: AnyObject {
    var presenter: LoginPresenterProtocol? { get set }
}

protocol LoginInteractorServiceRequester: AnyObject {
    func login(username: String, password: String)
    func register(username: String, password: String)
}

protocol LoginInteractorCredentialsHandler: AnyObject {
    var rememberUsername: Bool { get }
    var username: String? { get }
    
    func setRememberUsername(_ value: Bool)
    func setUsername(_ username: String?)
}
