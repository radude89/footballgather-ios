//
//  PlayerAddViewController.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 10/07/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import UIKit

// MARK: - AddPlayerDelegate
protocol AddPlayerDelegate: AnyObject {
    func playerWasAdded()
}

// MARK: - PlayerAddViewController
final class PlayerAddViewController: UIViewController, Loadable {

    // MARK: - Properties
    @IBOutlet weak var playerNameTextField: UITextField!
    private lazy var doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneAction))
    lazy var loadingView = LoadingView.initToView(self.view)

    weak var delegate: AddPlayerDelegate?
    private let service = StandardNetworkService(resourcePath: "/api/players", authenticated: true)

    // MARK: - Setup
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Add Player"
        setupNavigationItems()
        setupPlayerNameTextField()
    }

    private func setupNavigationItems() {
        navigationItem.rightBarButtonItem = doneButton
        doneButton.isEnabled = false
    }

    private func setupPlayerNameTextField() {
        playerNameTextField.placeholder = "Enter name of the player"
        playerNameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }

    // MARK: - Selectors
    @objc private func doneAction(sender: UIBarButtonItem) {
        guard let playerName = playerNameTextField.text else { return }

        showLoadingView()
        
        let player = PlayerCreateModel(name: playerName)
        service.create(player) { [weak self] result in
            DispatchQueue.main.async {
                self?.hideLoadingView()
                
                if case .success(_) = result {
                    self?.handleServiceSuccess()
                } else {
                    self?.handleServiceFailure()
                }
            }
        }
    }

    private func handleServiceFailure() {
        AlertHelper.present(in: self, title: "Error update", message: "Unable to create player. Please try again.")
    }

    private func handleServiceSuccess() {
        delegate?.playerWasAdded()
        navigationController?.popViewController(animated: true)
    }

    @objc func textFieldDidChange(textField: UITextField) {
        doneButton.isEnabled = textField.text?.isEmpty == false
    }

}
