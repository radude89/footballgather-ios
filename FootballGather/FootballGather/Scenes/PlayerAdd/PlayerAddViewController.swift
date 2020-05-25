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
    @IBOutlet private weak var playerNameTextField: UITextField!
    
    private var barButtonItem: UIBarButtonItem!
    lazy var loadingView = LoadingView.initToView(view)
    
    var interactor: PlayerAddInteractorProtocol = PlayerAddInteractor()
    var router: PlayerAddRouterProtocol = PlayerAddRouter()

    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTitle("Add Player")
        setupBarButtonItem(title: "Done")
        setBarButtonState(isEnabled: false)
        setupTextField(placeholder: "Enter name of the player")
    }
    
    private func configureTitle(_ title: String) {
        self.title = title
    }
    
    private func setupBarButtonItem(title: String) {
        barButtonItem = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(done))
        navigationItem.rightBarButtonItem = barButtonItem
    }
    
    private func setBarButtonState(isEnabled: Bool) {
        barButtonItem.isEnabled = isEnabled
    }
    
    private func setupTextField(placeholder: String) {
        playerNameTextField.placeholder = placeholder
        playerNameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    // MARK: - Selectors
    @objc private func textFieldDidChange(textField: UITextField) {
        let request = PlayerAdd.TextDidChange.Request(text: textField.text)
        interactor.updateValue(request: request)
    }
    
    @objc private func done(sender: UIBarButtonItem) {
        showLoadingView()
        
        let request = PlayerAdd.Done.Request(text: playerNameTextField.text)
        interactor.endEditing(request: request)
    }
    
}

// MARK: - Configuration
extension PlayerAddViewController: PlayerAddViewConfigurable {
    func displayBarButton(viewModel: PlayerAdd.TextDidChange.ViewModel) {
        setBarButtonState(isEnabled: viewModel.barButtonIsEnabled)
    }
    
    func dismissAddView() {
        router.dismissAddView()
    }
}

// MARK: - Loadable
extension PlayerAddViewController: Loadable {}

// MARK: - Error Handler
extension PlayerAddViewController: PlayerAddViewErrorHandler {}
