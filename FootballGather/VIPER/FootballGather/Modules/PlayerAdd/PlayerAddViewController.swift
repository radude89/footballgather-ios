//
//  PlayerAddViewController.swift
//  FootballGather
//
//  Created by Radu Dan on 24/02/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import UIKit

// MARK: - PlayerAddViewController
final class PlayerAddViewController: UIViewController, PlayerAddViewable {
    
    // MARK: - Properties
    @IBOutlet weak var playerNameTextField: UITextField!
    
    private var barButtonItem: UIBarButtonItem!
    lazy var loadingView = LoadingView.initToView(view)
    
    var presenter: PlayerAddPresenterProtocol!

    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }
    
    // MARK: - Selectors
    @objc func textFieldDidChange(textField: UITextField) {
        presenter.textFieldDidChange()
    }
    
    @objc private func done(sender: UIBarButtonItem) {
        presenter.endEditing()
    }
    
}

// MARK: - Configuration
extension PlayerAddViewController: PlayerAddViewConfigurable {
    var textFieldText: String? {
        playerNameTextField.text
    }
    
    func configureTitle(_ title: String) {
        self.title = title
    }
    
    func setupBarButtonItem(title: String) {
        barButtonItem = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(done))
        navigationItem.rightBarButtonItem = barButtonItem
    }
    
    func setBarButtonState(isEnabled: Bool) {
        barButtonItem.isEnabled = isEnabled
    }
    
    func setupTextField(placeholder: String) {
        playerNameTextField.placeholder = placeholder
        playerNameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
}

// MARK: - Loadable
extension PlayerAddViewController: Loadable {}

// MARK: - Error Handler
extension PlayerAddViewController: ErrorHandler {}
