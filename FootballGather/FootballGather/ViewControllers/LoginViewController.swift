//
//  LoginViewController.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 06/06/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import UIKit

// MARK: - LoginViewController
final class LoginViewController: UIViewController, Loadable {

    // MARK: - Outlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var rememberMeSwitch: UISwitch!

    // MARK: - Variables
    lazy var loadingView = LoadingView.initToView(self.view)
    private let viewModel = LoginViewModel()

    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureRememberMe()
    }

    // MARK: - Private methods
    private func configureRememberMe() {
        rememberMeSwitch.isOn = viewModel.rememberUsername

        if viewModel.rememberUsername {
            usernameTextField.text = viewModel.username
        }
    }
    
    private func handleSuccessResponse() {
        storeUsernameAndRememberMe()
        performSegue(withIdentifier: SegueIdentifier.playerList.rawValue, sender: nil)
    }

    private func storeUsernameAndRememberMe() {
        viewModel.setRememberUsername(rememberMeSwitch.isOn)

        if rememberMeSwitch.isOn {
            viewModel.setUsername(usernameTextField.text)
        } else {
            viewModel.setUsername(nil)
        }
    }

    private func handleServiceResponse(error: Error?) {
        if let error = error {
            AlertHelper.present(in: self, title: "Error", message: String(describing: error))
        } else {
            handleSuccessResponse()
        }
    }

    // MARK: - Actions
    @IBAction private func login(_ sender: Any) {
        guard let userText = usernameTextField.text, userText.isEmpty == false,
            let passwordText = passwordTextField.text, passwordText.isEmpty == false else {
                AlertHelper.present(in: self, title: "Error", message: "Both fields are mandatory.")
                return
        }

        showLoadingView()

        viewModel.performLogin(withUsername: userText, andPassword: passwordText) { [weak self] error in
            DispatchQueue.main.async {
                self?.hideLoadingView()
                self?.handleServiceResponse(error: error)
            }
        }
    }

    @IBAction private func register(_ sender: Any) {
        guard let userText = usernameTextField.text, userText.isEmpty == false,
            let passwordText = passwordTextField.text, passwordText.isEmpty == false else {
                AlertHelper.present(in: self, title: "Error", message: "Both fields are mandatory.")
                return
        }

        showLoadingView()

        viewModel.performRegister(withUsername: userText, andPassword: passwordText) { [weak self] error in
            DispatchQueue.main.async {
                self?.hideLoadingView()
                self?.handleServiceResponse(error: error)
            }
        }
    }

}
