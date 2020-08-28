//
//  PlayerAddPresenter.swift
//  FootballGather
//
//  Created by Radu Dan on 24/02/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - PlayerAddPresenter
final class PlayerAddPresenter: PlayerAddPresentable {
    
    // MARK: - Properties
    weak var view: PlayerAddViewProtocol?
    var interactor: PlayerAddInteractorProtocol
    var router: PlayerAddRouterProtocol
    weak var delegate: PlayerAddDelegate?
    
    // MARK: - Init
    init(view: PlayerAddViewProtocol? = nil,
         interactor: PlayerAddInteractorProtocol = PlayerAddInteractor(),
         router: PlayerAddRouterProtocol = PlayerAddRouter(),
         delegate: PlayerAddDelegate? = nil) {
        self.view = view
        self.interactor = interactor
        self.router = router
        self.delegate = delegate
    }
    
}

// MARK: - View Configuration
extension PlayerAddPresenter: PlayerAddPresenterViewConfiguration {
    func viewDidLoad() {
        view?.configureTitle("Add Player")
        view?.setupBarButtonItem(title: "Done")
        view?.setBarButtonState(isEnabled: false)
        view?.setupTextField(placeholder: "Enter name of the player")
    }
}

// MARK: - TextField Handler
extension PlayerAddPresenter: PlayerAddPresenterTextFieldHandler {
    func textFieldDidChange() {
        let isEnabled = view?.textFieldText?.isEmpty == false
        view?.setBarButtonState(isEnabled: isEnabled)
    }
}

// MARK: - Interactor
extension PlayerAddPresenter: PlayerAddPresenterServiceInteractable {
    func endEditing() {
        guard let playerName = view?.textFieldText else {
            return
        }
        
        view?.showLoadingView()
        interactor.addPlayer(name: playerName)
    }
}

// MARK: - Service Handler
extension PlayerAddPresenter: PlayerAddPresenterServiceHandler {
    func playerWasAdded() {
        view?.hideLoadingView()
        delegate?.didAddPlayer()
        router.dismissAddView()

    }
    
    func serviceFailedToAddPlayer() {
        view?.hideLoadingView()
        view?.handleError(title: "Error", message: "Unable to create player. Please try again.")
    }
}
