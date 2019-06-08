//
//  LoginViewController.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 06/06/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import UIKit

// MARK: - LoginViewController
class LoginViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var rememberMeSwitch: UISwitch!
    
    // MARK: - Variables
    lazy var loadingView = LoadingView.initToView(self.view)
    private let loginService = LoginService()
    private let usersService = StandardNetworkService(resourcePath: "/api/users")
    private let userDefaults = FootballGatherUserDefaults.shared
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rememberMeSwitch.isOn = userDefaults.rememberUsername ?? true
        
        if userDefaults.rememberUsername == true {
            usernameTextField.text = FootbalGatherKeychain.shared.username
        }
    }
    
    // MARK: - Methods
    private func handleSuccessLogin() {
        hideLoadingView()
        userDefaults.rememberUsername = rememberMeSwitch.isOn
        
        if self.rememberMeSwitch.isOn {
            FootbalGatherKeychain.shared.username = usernameTextField.text
        } else {
            FootbalGatherKeychain.shared.username = nil
        }
        
        performSegue(withIdentifier: "showMainSegueIdentifier", sender: nil)
    }
    
    // MARK: - Actions
    @IBAction func onLoginAction(_ sender: Any) {
        guard let userText = usernameTextField.text, userText.isEmpty == false,
            let passwordText = passwordTextField.text, passwordText.isEmpty == false else {
                AlertHelper.present(in: self, title: "Error", message: "Both fields are mandatory.")
                return
        }
        
        showLoadingView()
        
        let requestModel = UserRequestModel(username: userText, password: passwordText)
        loginService.login(user: requestModel) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self.hideLoadingView()
                    AlertHelper.present(in: self, title: "Error", message: String(describing: error))
                }
            case .success(_):
                DispatchQueue.main.async {
                    self.handleSuccessLogin()
                }
            }
        }
    }
    
    @IBAction func onRegisterAction(_ sender: Any) {
        guard let userText = usernameTextField.text, userText.isEmpty == false,
            let passwordText = passwordTextField.text, passwordText.isEmpty == false else {
                AlertHelper.present(in: self, title: "Error", message: "Both fields are mandatory.")
                return
        }
        
        showLoadingView()
        
        guard let hashedPasssword = Crypto.hash(message: passwordText) else {
            fatalError("Unable to hash password")
        }
        
        let requestModel = UserRequestModel(username: userText, password: hashedPasssword)
        usersService.create(requestModel) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self.hideLoadingView()
                    AlertHelper.present(in: self, title: "Error", message: String(describing: error))
                }
            case .success(let resourceId):
                print("Created user: \(resourceId)")
                DispatchQueue.main.async {
                    self.handleSuccessLogin()
                }
            }
        }
    }
    
    @IBAction func onUseOfflineAction(_ sender: Any) {
        performSegue(withIdentifier: "showMainSegueIdentifier", sender: nil)
    }
    
}

// MARK: - Loadable conformance
extension LoginViewController: Loadable {}
