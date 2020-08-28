//
//  LoginViewController.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 06/06/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import UIKit

// MARK: - LoginViewController
final class LoginViewController: UIViewController {

    @IBOutlet weak var loginView: LoginView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {
        let presenter = LoginPresenter(view: loginView)
        loginView.delegate = self
        loginView.presenter = presenter
        loginView.setupView()
    }
    
}

// MARK: - LoginViewDelegate
extension LoginViewController: LoginViewDelegate {
    func presentAlert(title: String, message: String) {
        AlertHelper.present(in: self, title: title, message: message)
    }
    
    func didLogin() {
        performSegue(withIdentifier: SegueIdentifier.playerList.rawValue, sender: nil)
    }
    
    func didRegister() {
        performSegue(withIdentifier: SegueIdentifier.playerList.rawValue, sender: nil)
    }
}
