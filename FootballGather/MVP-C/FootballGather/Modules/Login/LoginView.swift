//
//  LoginView.swift
//  FootballGather
//
//  Created by Radu Dan on 05/02/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import UIKit

// MARK: - LoginViewDelegate
protocol LoginViewDelegate: AnyObject {
    func presentAlert(title: String, message: String)
    func didLogin()
    func didRegister()
}

// MARK: - LoginViewProtocol
protocol LoginViewProtocol: AnyObject {
    func setupView()
    func showLoadingView()
    func hideLoadingView()
    func handleError(title: String, message: String)
    func handleLoginSuccessful()
    func handleRegisterSuccessful()
}

// MARK: - LoginView
final class LoginView: UIView, Loadable {
    
    // MARK: - Properties
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var rememberMeSwitch: UISwitch!
    
    lazy var loadingView = LoadingView.initToView(self)
    
    weak var delegate: LoginViewDelegate?
    var presenter: LoginPresenterProtocol = LoginPresenter()
    
    private func configureRememberMe() {
        rememberMeSwitch.isOn = presenter.rememberUsername

        if presenter.rememberUsername {
            usernameTextField.text = presenter.username
        }
    }
    
    private func storeUsernameAndRememberMe() {
        presenter.setRememberUsername(rememberMeSwitch.isOn)

        if rememberMeSwitch.isOn {
            presenter.setUsername(usernameTextField.text)
        } else {
            presenter.setUsername(nil)
        }
    }
    
    @IBAction private func login(_ sender: Any) {
        presenter.performLogin(withUsername: usernameTextField.text, andPassword: passwordTextField.text)
    }

    @IBAction private func register(_ sender: Any) {
        presenter.performRegister(withUsername: usernameTextField.text, andPassword: passwordTextField.text)
    }
    
}

// MARK: - Public API
extension LoginView: LoginViewProtocol {
    func setupView() {
        configureRememberMe()
    }
    
    func handleError(title: String, message: String) {
        delegate?.presentAlert(title: title, message: message)
    }
    
    func handleLoginSuccessful() {
        storeUsernameAndRememberMe()
        delegate?.didLogin()
    }
    
    func handleRegisterSuccessful() {
        storeUsernameAndRememberMe()
        delegate?.didRegister()
    }
}
