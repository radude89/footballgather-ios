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
    
    private let loginService = LoginService()
    private let usersService = StandardNetworkService(resourcePath: "/api/users")
    private let userDefaults = FootballGatherUserDefaults.shared
    private let keychain = FootbalGatherKeychain.shared

    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureRememberMe()
    }

    // MARK: - Private methods
    private func configureRememberMe() {
        let rememberMe = userDefaults.rememberUsername ?? true
        rememberMeSwitch.isOn = rememberMe

        if rememberMe {
            usernameTextField.text = keychain.username
        }
    }
    
    private func handleSuccessResponse() {
        storeUsernameAndRememberMe()
        performSegue(withIdentifier: SegueIdentifier.playerList.rawValue, sender: nil)
    }

    private func storeUsernameAndRememberMe() {
        setRememberUsername(rememberMeSwitch.isOn)

        if rememberMeSwitch.isOn {
            setUsername(usernameTextField.text)
        } else {
            setUsername(nil)
        }
    }
    
    private func setRememberUsername(_ value: Bool) {
        userDefaults.rememberUsername = value
    }
    
    private func setUsername(_ username: String?) {
        keychain.username = username
    }

    // MARK: - Actions
    @IBAction private func login(_ sender: Any) {
        guard let userText = usernameTextField.text, userText.isEmpty == false,
            let passwordText = passwordTextField.text, passwordText.isEmpty == false else {
                AlertHelper.present(in: self, title: "Error", message: "Both fields are mandatory.")
                return
        }

        showLoadingView()
        
        let requestModel = UserRequestModel(username: userText, password: passwordText)
        loginService.login(user: requestModel) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.hideLoadingView()
                
                switch result {
                case .failure(let error):
                    AlertHelper.present(in: self, title: "Error", message: String(describing: error))
                    
                case .success(_):
                    self.handleSuccessResponse()
                }
            }
        }
    }

    @IBAction private func register(_ sender: Any) {
        guard let userText = usernameTextField.text, userText.isEmpty == false,
            let passwordText = passwordTextField.text, passwordText.isEmpty == false else {
                AlertHelper.present(in: self, title: "Error", message: "Both fields are mandatory.")
                return
        }
        
        guard let hashedPasssword = Crypto.hash(message: passwordText) else {
            fatalError("Unable to hash password")
        }
        
        showLoadingView()
        
        let requestModel = UserRequestModel(username: userText, password: hashedPasssword)
        usersService.create(requestModel) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.hideLoadingView()
                
                switch result {
                case .failure(let error):
                    AlertHelper.present(in: self, title: "Error", message: String(describing: error))
                    
                case .success(let resourceId):
                    print("Created user: \(resourceId)")
                    self.handleSuccessResponse()
                }
            }
        }
    }

}
