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
typealias PlayerListViewProtocol = PlayerListViewable & Loadable & Emptyable & PlayerListViewConfigurable & ErrorHandler & PlayerListViewReloadable & PlayerListViewUpdatable

protocol PlayerListViewable: AnyObject {
    var presenter: PlayerListPresenterProtocol { get set }
}

protocol PlayerListViewConfigurable: AnyObject {
    func configureTitle(_ title: String)
    func setupBarButtonItem(title: String)
    func setBarButtonState(isEnabled: Bool)
    func setBarButtonTitle(_ title: String)
    func setBottomActionButtonTitle(_ title: String)
    func setBottomActionButtonState(isEnabled: Bool)
    func setupTableView()
    func setViewInteraction(_ enabled: Bool)
}

protocol PlayerListViewReloadable: AnyObject {
    func reloadData()
    func reloadRow(_ row: Int)
}

protocol PlayerListViewUpdatable: AnyObject {
    func displayDeleteConfirmationAlert(at index: Int)
    func confirmPlayerDeletion(at index: Int)
    func beginTableUpdates()
    func deleteRows(at index: Int)
    func endTableUpdates()
}

protocol PlayerTableViewCellProtocol: AnyObject {
    func setupDefaultView()
    func setupViewForSelection(isSelected: Bool)
    func setupCheckBoxImage(isSelected: Bool)
    func set(nameDescription: String)
    func set(positionDescription: String)
    func set(skillDescription: String)
}

// MARK: - Presenter
typealias PlayerListPresenterProtocol = PlayerListPresentable & PlayerListPresenterViewConfiguration & PlayerListDataSource & PlayerListPresenterServiceInteractable & PlayerListPresenterRetryable & PlayerListPresenterServiceHandler & PlayerListPresenterActionable

protocol PlayerListPresentable: AnyObject {
    var view: PlayerListViewProtocol? { get set }
    var interactor: PlayerListInteractorProtocol { get set }
    var router: PlayerListRouterProtocol { get set }
}

protocol PlayerListPresenterViewConfiguration: AnyObject {
    func viewDidLoad()
    func viewWillAppear()
}

protocol PlayerListDataSource: AnyObject {
    var numberOfRows: Int { get }
    var canEditRow: Bool { get }
    
    func cellPresenter(at index: Int) -> PlayerTableViewCellPresenterProtocol
    func player(at index: Int) -> PlayerResponseModel
    func selectRow(at index: Int)
    func requestToDeletePlayer(at index: Int)
}

protocol PlayerListPresenterServiceInteractable: AnyObject {
    func loadPlayers()
}

protocol PlayerListPresenterServiceHandler: AnyObject {
    func serviceFailedWithError(_ error: Error)
    func playerListDidLoad()
    func playerWasDeleted(at index: Int)
}

protocol PlayerListPresenterRetryable: AnyObject {
    func retry()
}

protocol PlayerListPresenterActionable: AnyObject {
    func selectPlayers()
    func confirmOrAddPlayers()
    func deletePlayer(at index: Int)
}

protocol PlayerTableViewCellPresenterProtocol: AnyObject {
    var view: PlayerTableViewCellProtocol? { get set }
    var viewState: PlayerListViewState { get set }
    var isSelected: Bool { get set }
    
    func setupView()
    func configure(with player: PlayerResponseModel)
    func toggle()
}

// MARK: - Interactor
typealias PlayerListInteractorProtocol = PlayerListInteractable & PlayerListInteractorServiceHander

protocol PlayerListInteractable: AnyObject {
    var presenter: PlayerListPresenterProtocol? { get set }
}

protocol PlayerListInteractorServiceHander: AnyObject {
    var players: [PlayerResponseModel] { get set }
    var minimumPlayersToPlay: Int { get }
    
    func loadPlayers()
    func deletePlayer(at index: Int)
    func updatePlayer(_ player: PlayerResponseModel)
    func selectedPlayers(atRows rows: Set<Int>) -> [TeamSection: [PlayerResponseModel]]
}
