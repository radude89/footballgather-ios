//
//  LoginViewController.swift
//  FootballGather
//
//  Created by Radu Dan on 05/02/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import UIKit

// MARK: - LoginViewController
final class LoginViewController: UIViewController, LoginViewable {
    
    // MARK: - Properties
    @IBOutlet private weak var usernameTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var rememberMeSwitch: UISwitch!
    lazy var loadingView = LoadingView.initToView(view)
    
    var interactor: LoginInteractorProtocol = LoginInteractor()
    var router: LoginRouterProtocol = LoginRouter()
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCredentials()
    }
    
    private func loadCredentials() {
        let request = Login.LoadCredentials.Request()
        interactor.loadCredentials(request: request)
    }
    
    // MARK: - IBActions
    @IBAction private func login(_ sender: Any) {
        showLoadingView()
        let request = Login.Authenticate.Request(username: usernameTextField.text,
                                                 password: passwordTextField.text,
                                                 storeCredentials: rememberMeSwitch.isOn)
        interactor.login(request: request)
    }
    
    @IBAction private func register(_ sender: Any) {
        showLoadingView()
        let request = Login.Authenticate.Request(username: usernameTextField.text,
                                                 password: passwordTextField.text,
                                                 storeCredentials: rememberMeSwitch.isOn)
        interactor.register(request: request)
    }
    
}

// MARK: - Configuration
extension LoginViewController: LoginViewConfigurable {
    func displayStoredCredentials(viewModel: Login.LoadCredentials.ViewModel) {
        rememberMeSwitch.isOn = viewModel.rememberMeIsOn
        usernameTextField.text = viewModel.usernameText
    }
    
    func loginCompleted(viewModel: Login.Authenticate.ViewModel) {
        hideLoadingView()
        
        if viewModel.isSuccessful {
            router.showPlayerList()
        } else {
            handleError(title: viewModel.errorTitle!, message: viewModel.errorDescription!)
        }
    }
}

// MARK: - Loadable
extension LoginViewController: Loadable {}

// MARK: - Error Handler
extension LoginViewController: ErrorHandler {}
