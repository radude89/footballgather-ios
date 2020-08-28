//
//  PlayerAddView.swift
//  FootballGather
//
//  Created by Radu Dan on 24/02/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import UIKit

// MARK: - PlayerAddViewProtocol
protocol PlayerAddViewProtocol: AnyObject {
    func setupView()
    func showLoadingView()
    func hideLoadingView()
    func handleError(title: String, message: String)
    func handlePlayerAddedSuccessfully()
}

// MARK: - PlayerAddViewDelegate
protocol PlayerAddViewDelegate: AnyObject {
    func addRightBarButtonItem(_ barButtonItem: UIBarButtonItem)
    func presentAlert(title: String, message: String)
    func didAddPlayer()
}

// MARK: - PlayerAddView
final class PlayerAddView: UIView, Loadable {
    
    // MARK: - Properties
    @IBOutlet weak var playerNameTextField: UITextField!
    
    private lazy var doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneAction))
    lazy var loadingView = LoadingView.initToView(self)
    
    weak var delegate: PlayerAddViewDelegate?
    var presenter: PlayerAddPresenterProtocol!

    // MARK: - Setup
    private func setupNavigationItems() {
        doneButton.isEnabled = false
        delegate?.addRightBarButtonItem(doneButton)
    }
    
    private func setupPlayerNameTextField() {
        playerNameTextField.placeholder = "Enter name of the player"
        playerNameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    // MARK: - Selectors
    @objc private func doneAction(sender: UIBarButtonItem) {
        presenter.addPlayer(withName: playerNameTextField.text)
    }

    @objc func textFieldDidChange(textField: UITextField) {
        doneButton.isEnabled = presenter.doneButtonIsEnabled(forText: textField.text)
    }
    
}

// MARK: - Public methods
extension PlayerAddView: PlayerAddViewProtocol {
    func setupView() {
        setupNavigationItems()
        setupPlayerNameTextField()
    }
    
    func handleError(title: String, message: String) {
        delegate?.presentAlert(title: title, message: message)
    }
    
    func handlePlayerAddedSuccessfully() {
        delegate?.didAddPlayer()
    }
}
