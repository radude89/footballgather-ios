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
    
    // MARK: - Init
    init(view: PlayerAddViewProtocol? = nil) {
        self.view = view
    }
    
}

// MARK: - Actionable
extension PlayerAddPresenter: PlayerAddPresenterActionable {
    func dismissAddView() {
        view?.hideLoadingView()
        view?.dismissAddView()
    }
    
    func presentError(response: PlayerAdd.ErrorResponse) {
        view?.hideLoadingView()
        
        let viewModel = PlayerAdd.ErrorViewModel(errorTitle: "Error",
                                                 errorMessage: "Unable to create player. Please try again.")
        view?.displayError(viewModel: viewModel)
    }
    
    func updateView(response: PlayerAdd.TextDidChange.Response) {
        let viewModel = PlayerAdd.TextDidChange.ViewModel(barButtonIsEnabled: !response.textIsEmpty)
        view?.displayBarButton(viewModel: viewModel)
    }
}
