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
    var interactor: PlayerListInteractorProtocol
    var router: PlayerListRouterProtocol
    
    private var viewState: PlayerListViewState
    private var viewStateDetails: PlayerListViewStateDetails {
        PlayerListViewStateDetailsFactory.makeViewStateDetails(from: viewState)
    }
    
    private var cellPresenters: [Int: PlayerTableViewCellPresenterProtocol] = [:]
    private var selectedRows: Set<Int> = []
    
    // MARK: - Public API
    init(view: PlayerListViewProtocol? = nil,
         interactor: PlayerListInteractorProtocol = PlayerListInteractor(),
         router: PlayerListRouterProtocol = PlayerListRouter(),
         viewState: PlayerListViewState = .list) {
        self.view = view
        self.interactor = interactor
        self.router = router
        self.viewState = viewState
    }
    
}

// MARK: - View Configuration
extension PlayerListPresenter: PlayerListPresenterViewConfiguration {
    func viewDidLoad() {
        view?.configureTitle(title)
        view?.setupBarButtonItem(title: "Select")
        view?.setBarButtonState(isEnabled: !playersCollectionIsEmpty)
        view?.setupTableView()
        loadPlayers()
    }
    
    private var title: String {
        if viewState == .list {
            return "Players"
        }
        
        return "\(selectedRows.count) selected"
    }
    
    private var playersCollectionIsEmpty: Bool {
        interactor.players.isEmpty
    }
    
    func viewWillAppear() {
        view?.reloadData()
    }
}

// MARK: - Interactor
extension PlayerListPresenter: PlayerListPresenterServiceInteractable {
    func loadPlayers() {
        view?.setViewInteraction(false)
        interactor.loadPlayers()
    }
}

// MARK: - Retry
extension PlayerListPresenter: PlayerListPresenterRetryable {
    func retry() {
        view?.hideEmptyView()
        loadPlayers()
    }
}

// MARK: - Service Handler
extension PlayerListPresenter: PlayerListPresenterServiceHandler {
    func serviceFailedWithError(_ error: Error) {
        view?.setViewInteraction(true)
        view?.handleError(title: "Error", message: String(describing: error))
    }
    
    func playerListDidLoad() {
        view?.setViewInteraction(true)
        showEmptyViewIfRequired()
        view?.setBarButtonState(isEnabled: !playersCollectionIsEmpty)
        view?.reloadData()
    }
    
    private func showEmptyViewIfRequired() {
        if playersCollectionIsEmpty {
            view?.showEmptyView()
        } else {
            view?.hideEmptyView()
        }
    }
    
    func playerWasDeleted(at index: Int) {
        view?.hideLoadingView()
        view?.beginTableUpdates()
        
        interactor.players.remove(at: index)
        
        view?.deleteRows(at: index)
        view?.endTableUpdates()
        showEmptyViewIfRequired()
    }
}

// MARK: - Actions
extension PlayerListPresenter: PlayerListPresenterActionable {
    func selectPlayers() {
        viewState.toggle()
        configureView()
        clearSelection()
        view?.reloadData()
    }
    
    private func configureView() {
        view?.configureTitle(title)
        view?.setBarButtonTitle(viewStateDetails.barButtonItemTitle)
        view?.setBottomActionButtonTitle(viewStateDetails.actionButtonTitle)
        view?.setBottomActionButtonState(isEnabled: actionButtonIsEnabled)
    }
    
    private var actionButtonIsEnabled: Bool {
        if viewState == .selection {
            return playersCanPlay
        }
        
        return true
    }
    
    private var playersCanPlay: Bool {
        selectedRows.count >= interactor.minimumPlayersToPlay
    }
    
    private func clearSelection() {
        cellPresenters.values.forEach { $0.isSelected = false }
        selectedRows.removeAll()
    }
    
    func confirmOrAddPlayers() {
        if isInListViewMode {
            showAddPlayerView()
        } else {
            showConfirmPlayersView()
        }
    }
    
    private var isInListViewMode: Bool {
        viewState == .list
    }
    
    private func showAddPlayerView() {
        router.showAddPlayer(delegate: self)
    }
    
    private func showConfirmPlayersView() {
        router.showConfirmPlayers(with: interactor.selectedPlayers(atRows: selectedRows), delegate: self)
    }
    
    func deletePlayer(at index: Int) {
        view?.showLoadingView()
        interactor.deletePlayer(at: index)
    }
}

// MARK: - Data Source
extension PlayerListPresenter: PlayerListDataSource {
    var numberOfRows: Int { interactor.players.count }
    
    var canEditRow: Bool { isInListViewMode }
    
    func cellPresenter(at index: Int) -> PlayerTableViewCellPresenterProtocol {
        if let cellPresenter = cellPresenters[index] {
            cellPresenter.viewState = viewState
            return cellPresenter
        }
        
        let cellPresenter = PlayerTableViewCellPresenter(viewState: viewState)
        cellPresenters[index] = cellPresenter
        
        return cellPresenter
    }
    
    func player(at index: Int) -> PlayerResponseModel {
        interactor.players[index]
    }
    
    func selectRow(at index: Int) {
        guard playersCollectionIsEmpty == false else {
            return
        }
        
        if isInListViewMode {
            let player = interactor.players[index]
            showDetailsView(for: player)
        } else {
            toggleRow(at: index)
            updateSelectedRows(at: index)
            reloadViewAfterRowSelection(at: index)
        }
    }
    
    private func showDetailsView(for player: PlayerResponseModel) {
        router.showDetails(for: player, delegate: self)
    }
    
    private func toggleRow(at index: Int) {
        cellPresenter(at: index).toggle()
    }
    
    private func updateSelectedRows(at index: Int) {
        if cellPresenter(at: index).isSelected {
            selectedRows.insert(index)
        } else {
            selectedRows.remove(index)
        }
    }
    
    private func reloadViewAfterRowSelection(at index: Int) {
        view?.reloadRow(index)
        view?.configureTitle(title)
        view?.setBottomActionButtonState(isEnabled: actionButtonIsEnabled)
    }
    
    func requestToDeletePlayer(at index: Int) {
        view?.displayDeleteConfirmationAlert(at: index)
    }
}

// MARK: - PlayerEditDelegate
extension PlayerListPresenter: PlayerDetailDelegate {
    func didUpdate(player: PlayerResponseModel) {
        interactor.updatePlayer(player)
    }
}

// MARK: - PlayerAddDelegate
extension PlayerListPresenter: PlayerAddDelegate {
    func didAddPlayer() {
        loadPlayers()
    }
}

// MARK: - ConfirmPlayersDelegate
extension PlayerListPresenter: ConfirmPlayersDelegate {
    func didEndGather() {
        viewState = .list
        configureView()
        view?.reloadData()
    }
}
