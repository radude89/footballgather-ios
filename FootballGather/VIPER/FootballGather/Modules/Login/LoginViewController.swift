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
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var rememberMeSwitch: UISwitch!
    lazy var loadingView = LoadingView.initToView(view)
    
    var presenter: LoginPresenterProtocol = LoginPresenter()
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }
    
    // MARK: - IBActions
    @IBAction private func login(_ sender: Any) {
        presenter.performLogin()
    }

    @IBAction private func register(_ sender: Any) {
        presenter.performRegister()
    }
    
}

// MARK: - Configuration
extension LoginViewController: LoginViewConfigurable {
    var rememberMeIsOn: Bool { rememberMeSwitch.isOn }
    
    var usernameText: String? { usernameTextField.text }
    
    var passwordText: String? { passwordTextField.text }

    func setRememberMeSwitch(isOn: Bool) {
        rememberMeSwitch.isOn = isOn
    }
    
    func setUsername(_ username: String?) {
        usernameTextField.text = username
    }
}

// MARK: - Loadable
extension LoginViewController: Loadable {}

// MARK: - Error Handler
extension LoginViewController: ErrorHandler {}
