//
//  PlayerAddProtocols.swift
//  FootballGather
//
//  Created by Radu Dan on 24/04/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - Router
protocol PlayerAddRouterProtocol: AnyObject {
    func dismissAddView()
}

// MARK: - View
typealias PlayerAddViewProtocol = PlayerAddViewable & PlayerAddViewConfigurable & Loadable & PlayerAddViewErrorHandler

protocol PlayerAddViewable: AnyObject {
    var interactor: PlayerAddInteractorProtocol { get set }
    var router: PlayerAddRouterProtocol { get set }
}

protocol PlayerAddViewConfigurable: AnyObject {
    func displayBarButton(viewModel: PlayerAdd.TextDidChange.ViewModel)
    func dismissAddView()
}

protocol PlayerAddViewErrorHandler: ErrorHandler {
    func displayError(viewModel: PlayerAdd.ErrorViewModel)
}

extension PlayerAddViewErrorHandler {
    func displayError(viewModel: PlayerAdd.ErrorViewModel) {
        handleError(title: viewModel.errorTitle, message: viewModel.errorMessage)
    }
}

// MARK: - Delegate
protocol PlayerAddDelegate: AnyObject {
    func didAddPlayer()
}

// MARK: - Interactor
typealias PlayerAddInteractorProtocol = PlayerAddInteractable & PlayerAddInteractorActionable

protocol PlayerAddInteractable: AnyObject {
    var presenter: PlayerAddPresenterProtocol { get set }
    var delegate: PlayerAddDelegate? { get set }
}

protocol PlayerAddInteractorActionable: AnyObject {
    func endEditing(request: PlayerAdd.Done.Request)
    func updateValue(request: PlayerAdd.TextDidChange.Request)
}

// MARK: - Presenter
typealias PlayerAddPresenterProtocol = PlayerAddPresentable & PlayerAddPresenterActionable

protocol PlayerAddPresentable: AnyObject {
    var view: PlayerAddViewProtocol? { get set }
}

protocol PlayerAddPresenterActionable: AnyObject {
    func dismissAddView()
    func presentError(response: PlayerAdd.ErrorResponse)
    func updateView(response: PlayerAdd.TextDidChange.Response)
}
