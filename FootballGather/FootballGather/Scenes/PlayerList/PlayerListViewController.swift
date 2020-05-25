//
//  PlayerListViewController.swift
//  FootballGather
//
//  Created by Radu Dan on 05/02/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import UIKit

// MARK: - PlayerListViewController
final class PlayerListViewController: UIViewController, PlayerListViewable {
    
    // MARK: - Properties
    @IBOutlet private weak var playerTableView: UITableView!
    @IBOutlet private weak var bottomActionButton: UIButton!
    
    private var barButtonItem: UIBarButtonItem!
    
    lazy var loadingView = LoadingView.initToView(view)
    
    lazy var emptyView: EmptyView = {
        let emptyView = EmptyView.initToView(view, infoText: "There aren't any players for your user.")
        emptyView.delegate = self
        return emptyView
    }()
    
    var interactor: PlayerListInteractorProtocol = PlayerListInteractor()
    var router: PlayerListRouterProtocol = PlayerListRouter()
    
    private var displayedPlayers: [PlayerList.FetchPlayers.ViewModel.DisplayedPlayer] = []
    private var isInListViewMode = true
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        fetchPlayers()
    }
    
    private func setupView() {
        configureTitle("Players")
        setupBarButtonItem(title: "Select")
        setBarButtonState(isEnabled: false)
        setupTableView()
    }
    
    private func configureTitle(_ title: String) {
        self.title = title
    }
    
    private func setupBarButtonItem(title: String) {
        barButtonItem = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(selectPlayers))
        navigationItem.rightBarButtonItem = barButtonItem
    }
    
    private func setBarButtonState(isEnabled: Bool) {
        barButtonItem.isEnabled = isEnabled
    }
    
    private func setBarButtonTitle(_ title: String) {
        barButtonItem.title = title
    }
    
    private func setupTableView() {
        playerTableView.tableFooterView = UIView()
    }
    
    private func fetchPlayers() {
        let request = PlayerList.FetchPlayers.Request()
        interactor.fetchPlayers(request: request)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    
    private func reloadData() {
        playerTableView.reloadData()
    }
    
    // MARK: - Selectors
    @objc private func selectPlayers() {
        let request = PlayerList.SelectPlayers.Request()
        interactor.selectPlayers(request: request)
    }
    
    @IBAction private func confirmOrAddPlayers(_ sender: Any) {
        let request = PlayerList.ConfirmOrAddPlayers.Request()
        interactor.confirmOrAddPlayers(request: request)
    }
    
}

// MARK: - Configuration
extension PlayerListViewController: PlayerListViewDisplayable {
    func displayFetchedPlayers(viewModel: PlayerList.FetchPlayers.ViewModel) {
        displayedPlayers = viewModel.displayedPlayers
        
        showEmptyViewIfRequired()
        setBarButtonState(isEnabled: !playersCollectionIsEmpty)
        reloadData()
    }
    
    private func showEmptyViewIfRequired() {
        if playersCollectionIsEmpty {
            showEmptyView()
        } else {
            hideEmptyView()
        }
    }
    
    private var playersCollectionIsEmpty: Bool {
        displayedPlayers.isEmpty
    }
    
    func displaySelectedPlayer(viewModel: PlayerList.SelectPlayer.ViewModel) {
        let index = viewModel.index
        displayedPlayers[index].isSelected.toggle()
        
        reloadRow(index)
        configureTitle(viewModel.title)
        setBottomActionButtonState(isEnabled: viewModel.actionButtonIsEnabled)
    }
    
    private func reloadRow(_ row: Int) {
        let indexPath = IndexPath(row: row, section: 0)
        playerTableView.reloadRows(at: [indexPath], with: .none)
    }
        
    func setViewInteraction(_ enabled: Bool) {
        view.isUserInteractionEnabled = enabled
    }
    
    func displayDeleteConfirmationAlert(at index: Int) {
        let alertController = UIAlertController(title: "Delete player",
                                                message: "Are you sure you want to delete the selected player?",
                                                preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.confirmPlayerDeletion(at: index)
        }
        alertController.addAction(confirmAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func confirmPlayerDeletion(at index: Int) {
        showLoadingView()
        
        let request = PlayerList.DeletePlayer.Request(index: index)
        interactor.deletePlayer(request: request)
    }
}

// MARK: - Reload
extension PlayerListViewController: PlayerListViewReloadable {
    func reloadViewState(viewModel: PlayerList.SelectPlayers.ViewModel) {
        configure(viewModel: viewModel)
        clearPlayerSelections()
        reloadData()
    }
    
    private func configure(viewModel: ReloadViewModel) {
        isInListViewMode = viewModel.isInListViewMode
        configureTitle(viewModel.title)
        setBarButtonTitle(viewModel.barButtonItemTitle)
        setBottomActionButtonTitle(viewModel.actionButtonTitle)
        setBottomActionButtonState(isEnabled: viewModel.actionButtonIsEnabled)
    }
    
    private func clearPlayerSelections() {
        for (index, _) in displayedPlayers.enumerated() {
            displayedPlayers[index].isSelected = false
        }
    }
    
    private func setBottomActionButtonTitle(_ title: String) {
        bottomActionButton.setTitle(title, for: .normal)
    }
    
    private func setBottomActionButtonState(isEnabled: Bool) {
        bottomActionButton.isEnabled = isEnabled
    }
    
    func reloadViewState(viewModel: PlayerList.ReloadViewState.ViewModel) {
        configure(viewModel: viewModel)
        reloadData()
    }
}

// MARK: - Update
extension PlayerListViewController: PlayerListViewUpdatable {
    func deletePlayer(at index: Int) {
        beginTableUpdates()
        displayedPlayers.remove(at: index)
        deleteRows(at: index)
        endTableUpdates()
        showEmptyViewIfRequired()
    }
    
    private func beginTableUpdates() {
        playerTableView.beginUpdates()
    }
    
    private func deleteRows(at index: Int) {
        playerTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
    }
    
    private func endTableUpdates() {
        playerTableView.endUpdates()
    }
}

// MARK: - Router
extension PlayerListViewController: PlayerListViewRoutable {
    func showDetailsView(player: PlayerResponseModel, delegate: PlayerDetailDelegate) {
        router.showDetails(for: player, delegate: delegate)
    }
    
    func showAddPlayerView(delegate: PlayerAddDelegate) {
        router.showAddPlayer(delegate: delegate)
    }
    
    func showConfirmPlayersView(with playersDictionary: [TeamSection : [PlayerResponseModel]],
                                delegate: ConfirmPlayersDelegate) {
        router.showConfirmPlayers(with: playersDictionary, delegate: delegate)
    }
}

// MARK: - EmptyViewable
extension PlayerListViewController: EmptyViewable {
    func showEmptyView() {
        playerTableView.isHidden = true
        emptyView.isHidden = false
    }
    
    func hideEmptyView() {
        playerTableView.isHidden = false
        emptyView.isHidden = true
    }
    
    func retryAction() {
        hideEmptyView()
        fetchPlayers()
    }
}

// MARK: - UITableViewDelegate | UITableViewDataSource
extension PlayerListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        displayedPlayers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: PlayerTableViewCell = tableView.dequeueReusableCell(withIdentifier: "PlayerTableViewCell") as? PlayerTableViewCell else {
            return UITableViewCell()
        }
        
        let displayedPlayer = displayedPlayers[indexPath.row]
        
        cell.set(nameDescription: displayedPlayer.name)
        cell.set(positionDescription: "Position: \(displayedPlayer.positionDescription ?? "-")")
        cell.set(skillDescription: "Skill: \(displayedPlayer.skillDescription ?? "-")")
        cell.set(isSelected: displayedPlayer.isSelected)
        cell.set(isListView: isInListViewMode)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let request = PlayerList.SelectPlayer.Request(index: indexPath.row)
        interactor.selectRow(request: request)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let request = PlayerList.CanEdit.Request()
        return interactor.canEditRow(request: request)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {
            return
        }
        
        let request = PlayerList.DeletePlayer.Request(index: indexPath.row)
        interactor.requestToDeletePlayer(request: request)
    }
}

// MARK: - Loadable
extension PlayerListViewController: Loadable {}

// MARK: - Error Handler
extension PlayerListViewController: PlayerListViewErrorHandler {}
