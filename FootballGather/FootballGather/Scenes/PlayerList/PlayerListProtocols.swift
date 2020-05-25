//
//  PlayerListProtocols.swift
//  FootballGather
//
//  Created by Radu Dan on 23/04/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - Router
protocol PlayerListRouterProtocol: AnyObject {
    func showDetails(for player: PlayerResponseModel, delegate: PlayerDetailDelegate)
    func showAddPlayer(delegate: PlayerAddDelegate)
    func showConfirmPlayers(with playersDictionary: [TeamSection: [PlayerResponseModel]], delegate: ConfirmPlayersDelegate)
}

// MARK: - View
typealias PlayerListViewProtocol = PlayerListViewable & Loadable & Emptyable & PlayerListViewDisplayable & PlayerListViewErrorHandler & PlayerListViewReloadable & PlayerListViewUpdatable & PlayerListViewRoutable

protocol PlayerListViewable: AnyObject {
    var interactor: PlayerListInteractorProtocol { get set }
    var router: PlayerListRouterProtocol { get set }
}

protocol PlayerListViewDisplayable: AnyObject {
    func displayFetchedPlayers(viewModel: PlayerList.FetchPlayers.ViewModel)
    func displaySelectedPlayer(viewModel: PlayerList.SelectPlayer.ViewModel)
    func setViewInteraction(_ enabled: Bool)
    func displayDeleteConfirmationAlert(at index: Int)
}

protocol PlayerListViewRoutable: AnyObject {
    func showDetailsView(player: PlayerResponseModel, delegate: PlayerDetailDelegate)
    func showAddPlayerView(delegate: PlayerAddDelegate)
    func showConfirmPlayersView(with playersDictionary: [TeamSection : [PlayerResponseModel]],
                                delegate: ConfirmPlayersDelegate)
}

protocol PlayerListViewReloadable: AnyObject {
    func reloadViewState(viewModel: PlayerList.SelectPlayers.ViewModel)
    func reloadViewState(viewModel: PlayerList.ReloadViewState.ViewModel)
}

protocol PlayerListViewUpdatable: AnyObject {
    func deletePlayer(at index: Int)
}

protocol PlayerListViewErrorHandler: ErrorHandler {
    func displayError(viewModel: PlayerList.ErrorViewModel)
}

extension PlayerListViewErrorHandler {
    func displayError(viewModel: PlayerList.ErrorViewModel) {
        handleError(title: viewModel.errorTitle, message: viewModel.errorMessage)
    }
}

// MARK: - Interactor
typealias PlayerListInteractorProtocol = PlayerListInteractable & PlayerListInteractorServiceRequester & PlayerListInteractorActionable & PlayerListInteractorTableDelegate

protocol PlayerListInteractable: AnyObject {
    var presenter: PlayerListPresenterProtocol { get set }
}

protocol PlayerListInteractorServiceRequester: AnyObject {
    func fetchPlayers(request: PlayerList.FetchPlayers.Request)
    func deletePlayer(request: PlayerList.DeletePlayer.Request)
}

protocol PlayerListInteractorActionable: AnyObject {
    func requestToDeletePlayer(request: PlayerList.DeletePlayer.Request)
    func selectPlayers(request: PlayerList.SelectPlayers.Request)
    func confirmOrAddPlayers(request: PlayerList.ConfirmOrAddPlayers.Request)
}

protocol PlayerListInteractorTableDelegate: AnyObject {
    func canEditRow(request: PlayerList.CanEdit.Request) -> Bool
    func selectRow(request: PlayerList.SelectPlayer.Request)
}

// MARK: - Presenter
typealias PlayerListPresenterProtocol = PlayerListPresentable & PlayerListPresenterServiceHandler & PlayerListPresenterActionable & PlayerListPresenterTableDelegate

protocol PlayerListPresentable: AnyObject {
    var view: PlayerListViewProtocol? { get set }
}

protocol PlayerListPresenterServiceHandler: AnyObject {
    func presentError(response: PlayerList.ErrorResponse)
    func presentFetchedPlayers(response: PlayerList.FetchPlayers.Response)
    func playerWasDeleted(response: PlayerList.DeletePlayer.Response)
    func updatePlayers(response: PlayerList.FetchPlayers.Response)
    func reloadViewState(response: PlayerList.ReloadViewState.Response)
}

protocol PlayerListPresenterActionable: AnyObject {
    func presentDeleteConfirmationAlert(response: PlayerList.DeletePlayer.Response)
    func presentViewForSelection()
    func confirmOrAddPlayers(response: PlayerList.ConfirmOrAddPlayers.Response)
}

protocol PlayerListPresenterTableDelegate: AnyObject {
    func canEditRow(response: PlayerList.CanEdit.Response) -> Bool
    func selectPlayer(response: PlayerList.SelectPlayer.Response)
}
