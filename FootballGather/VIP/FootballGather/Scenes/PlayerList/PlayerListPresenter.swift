//
//  PlayerListPresenter.swift
//  FootballGather
//
//  Created by Radu Dan on 05/02/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - PlayerListPresenter
final class PlayerListPresenter: PlayerListPresentable {
    
    // MARK: - Properties
    weak var view: PlayerListViewProtocol?
    
    private var viewState: PlayerListViewState
    private var viewStateDetails: PlayerListViewStateDetails {
        PlayerListViewStateDetailsFactory.makeViewStateDetails(from: viewState)
    }
    
    private var selectedRows: Set<Int> = []
    private var minimumPlayersToPlay: Int

    // MARK: - Public API
    init(view: PlayerListViewProtocol? = nil,
         viewState: PlayerListViewState = .list,
         minimumPlayersToPlay: Int = 2) {
        self.view = view
        self.viewState = viewState
        self.minimumPlayersToPlay = minimumPlayersToPlay
    }
    
}

// MARK: - PlayerListPresenterServiceHandler
extension PlayerListPresenter: PlayerListPresenterServiceHandler {
    func presentFetchedPlayers(response: PlayerList.FetchPlayers.Response) {
        view?.setViewInteraction(true)
        updatePlayers(response: response)
    }
    
    func playerWasDeleted(response: PlayerList.DeletePlayer.Response) {
        view?.setViewInteraction(true)
        view?.hideLoadingView()
        view?.deletePlayer(at: response.index)
    }
    
    func presentError(response: PlayerList.ErrorResponse) {
        guard case let PlayerListError.serviceFailed(message) = response.error else {
            fatalError("Unable to transform service error response.")
        }
        
        view?.setViewInteraction(true)
        
        let viewModel = PlayerList.ErrorViewModel(errorTitle: "Error", errorMessage: message)
        view?.displayError(viewModel: viewModel)
    }
    
    func updatePlayers(response: PlayerList.FetchPlayers.Response) {
        minimumPlayersToPlay = response.minimumPlayersToPlay
        
        let displayedPlayers = response.players.compactMap {
            PlayerList.FetchPlayers.ViewModel.DisplayedPlayer(player: $0)
        }
        
        view?.displayFetchedPlayers(viewModel: PlayerList.FetchPlayers.ViewModel(displayedPlayers: displayedPlayers))
    }
    
    func reloadViewState(response: PlayerList.ReloadViewState.Response) {
        viewState = response.viewState
        
        let viewModel = PlayerList.ReloadViewState.ViewModel(title: title,
                                                             barButtonItemTitle: viewStateDetails.barButtonItemTitle,
                                                             actionButtonTitle: viewStateDetails.actionButtonTitle,
                                                             actionButtonIsEnabled: actionButtonIsEnabled,
                                                             isInListViewMode: isInListViewMode)
        view?.reloadViewState(viewModel: viewModel)
    }
}

// MARK: - Table Delegate
extension PlayerListPresenter: PlayerListPresenterTableDelegate {
    func canEditRow(response: PlayerList.CanEdit.Response) -> Bool {
        isInListViewMode
    }
    
    private var isInListViewMode: Bool {
        viewState == .list
    }
    
    func selectPlayer(response: PlayerList.SelectPlayer.Response) {
        if isInListViewMode {
            view?.showDetailsView(player: response.player, delegate: response.detailDelegate)
        } else {
            updateSelectedRows(at: response.index)
            
            let viewModel = PlayerList.SelectPlayer.ViewModel(index: response.index,
                                                              title: title,
                                                              actionButtonIsEnabled: actionButtonIsEnabled)
            view?.displaySelectedPlayer(viewModel: viewModel)
        }
    }
    
    private func updateSelectedRows(at index: Int) {
        if selectedRows.contains(index) {
            selectedRows.remove(index)
        } else {
            selectedRows.insert(index)
        }
    }
    
    private var title: String {
        if viewState == .list {
            return "Players"
        }
        
        return "\(selectedRows.count) selected"
    }
    
    private var actionButtonIsEnabled: Bool {
        if viewState == .selection {
            return playersCanPlay
        }
        
        return true
    }
    
    private var playersCanPlay: Bool {
        selectedRows.count >= minimumPlayersToPlay
    }
}

// MARK: - PlayerListPresenterActionable
extension PlayerListPresenter: PlayerListPresenterActionable {
    func presentDeleteConfirmationAlert(response: PlayerList.DeletePlayer.Response) {
        view?.displayDeleteConfirmationAlert(at: response.index)
    }
    
    func presentViewForSelection() {
        viewState.toggle()
        clearSelection()
        
        let viewModel = PlayerList.SelectPlayers.ViewModel(title: title,
                                                           barButtonItemTitle: viewStateDetails.barButtonItemTitle,
                                                           actionButtonTitle: viewStateDetails.actionButtonTitle,
                                                           actionButtonIsEnabled: actionButtonIsEnabled,
                                                           isInListViewMode: isInListViewMode)
        view?.reloadViewState(viewModel: viewModel)
    }
    
    private func clearSelection() {
        selectedRows.removeAll()
    }
    
    func confirmOrAddPlayers(response: PlayerList.ConfirmOrAddPlayers.Response) {
        if isInListViewMode {
            view?.showAddPlayerView(delegate: response.addDelegate)
        } else {
            view?.showConfirmPlayersView(with: filterSelectedPlayers(response: response),
                                         delegate: response.confirmDelegate)
        }
    }
    
    private func filterSelectedPlayers(response: PlayerList.ConfirmOrAddPlayers.Response) -> [TeamSection: [PlayerResponseModel]] {
        guard let allBenchPlayers = response.teamPlayersDictionary[.bench] else {
            return [:]
        }
        
        let selectedPlayers = selectedRows.map { allBenchPlayers[$0] }
        return [.bench: selectedPlayers]
    }
}
