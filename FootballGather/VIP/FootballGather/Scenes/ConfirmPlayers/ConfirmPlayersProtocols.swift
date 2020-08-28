//
//  ConfirmPlayersProtocols.swift
//  FootballGather
//
//  Created by Radu Dan on 27/04/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - Router
protocol ConfirmPlayersRouterProtocol: AnyObject {
    func showGatherView(for gather: GatherModel, delegate: GatherDelegate)
}

// MARK: - View
typealias ConfirmPlayersViewProtocol = ConfirmPlayersViewable & ConfirmPlayersViewConfigurable & Loadable & ConfirmPlayersViewErrorHandler

protocol ConfirmPlayersViewable: AnyObject {
    var interactor: ConfirmPlayersInteractorProtocol { get set }
    var router: ConfirmPlayersRouterProtocol { get set }
}

protocol ConfirmPlayersViewConfigurable: AnyObject {
    func configureStartGatherButton(viewModel: ConfirmPlayers.Move.ViewModel)
    func showGatherView(gather: GatherModel, delegate: GatherDelegate)
}

protocol ConfirmPlayersViewErrorHandler: ErrorHandler {
    func displayError(viewModel: ConfirmPlayers.ErrorViewModel)
}

extension ConfirmPlayersViewErrorHandler {
    func displayError(viewModel: ConfirmPlayers.ErrorViewModel) {
        handleError(title: viewModel.errorTitle, message: viewModel.errorMessage)
    }
}

// MARK: - Delegate
protocol ConfirmPlayersDelegate: AnyObject {
    func didEndGather()
}

// MARK: - Interactor
typealias ConfirmPlayersInteractorProtocol = ConfirmPlayersInteractable & ConfirmPlayersInteractorActionable & ConfirmPlayersInteractorTableDelegate

protocol ConfirmPlayersInteractable: AnyObject {
    var presenter: ConfirmPlayersPresenterProtocol { get set }
    var delegate: ConfirmPlayersDelegate? { get set }
}

protocol ConfirmPlayersInteractorActionable: AnyObject {
    func startGather(request: ConfirmPlayers.StartGather.Request)
}

protocol ConfirmPlayersInteractorTableDelegate: AnyObject {
    func numberOfSections(request: ConfirmPlayers.SectionsCount.Request) -> Int
    func numberOfRowsInSection(request: ConfirmPlayers.RowsCount.Request) -> Int
    func titleForHeaderInSection(request: ConfirmPlayers.SectionTitle.Request) -> ConfirmPlayers.SectionTitle.ViewModel
    func rowDetails(request: ConfirmPlayers.RowDetails.Request) -> ConfirmPlayers.RowDetails.ViewModel?
    func move(request: ConfirmPlayers.Move.Request)
}

// MARK: - Presenter
typealias ConfirmPlayersPresenterProtocol = ConfirmPlayersPresentable & ConfirmPlayersPresenterActionable & ConfirmPlayersTableDelegate

protocol ConfirmPlayersPresentable: AnyObject {
    var view: ConfirmPlayersViewProtocol? { get set }
}

protocol ConfirmPlayersPresenterActionable: AnyObject {
    func showGatherView(response: ConfirmPlayers.StartGather.Response)
    func presentError(response: ConfirmPlayers.ErrorResponse)
}

protocol ConfirmPlayersTableDelegate: AnyObject {
    func numberOfSections(response: ConfirmPlayers.SectionsCount.Response) -> Int
    func numberOfRowsInSection(response: ConfirmPlayers.RowsCount.Response) -> Int
    func titleForHeaderInSection(response: ConfirmPlayers.SectionTitle.Response) -> ConfirmPlayers.SectionTitle.ViewModel
    func rowDetails(response: ConfirmPlayers.RowDetails.Response) -> ConfirmPlayers.RowDetails.ViewModel?
    func move(response: ConfirmPlayers.Move.Response)
}
