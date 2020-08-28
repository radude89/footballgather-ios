//
//  PlayerListView.swift
//  FootballGather
//
//  Created by Radu Dan on 05/02/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import UIKit

// MARK: - PlayerListViewDelegate
protocol PlayerListViewDelegate: AnyObject {
    func didRequestToChangeTitle(_ title: String)
    func addRightBarButtonItem(_ barButtonItem: UIBarButtonItem)
    func confirmOrAddPlayers(withSegueIdentifier segueIdentifier: String)
    func presentAlert(title: String, message: String)
    func didRequestPlayerDetails()
    func didRequestPlayerDeletion()
}

// MARK: - PlayerListViewProtocol
protocol PlayerListViewProtocol: AnyObject {
    func setViewInteraction(_ enabled: Bool)
    func setupView()
    func loadPlayers()
    func showLoadingView()
    func hideLoadingView()
    func handleError(title: String, message: String)
    func handleLoadPlayersSuccessfulResponse()
    func handlePlayerDeletion(forRowAt indexPath: IndexPath)
    func confirmPlayerDeletion()
    func cancelPlayerDeletion()
    func didEdit(player: PlayerResponseModel)
    func toggleViewState()
}

// MARK: - PlayerListView
final class PlayerListView: UIView, Loadable {
    
    // MARK: - Properties
    @IBOutlet weak var playerTableView: UITableView!
    @IBOutlet weak var bottomActionButton: UIButton!

    private var barButtonItem: UIBarButtonItem!
    
    lazy var loadingView = LoadingView.initToView(self)

    lazy var emptyView: EmptyView = {
        let emptyView = EmptyView.initToView(self, infoText: "There aren't any players for your user.")
        emptyView.delegate = self
        return emptyView
    }()
    
    weak var delegate: PlayerListViewDelegate?
    var presenter: PlayerListPresenterProtocol = PlayerListPresenter()
    
    // MARK: - Private methods
    private func setupTitle() {
        delegate?.didRequestToChangeTitle(presenter.title)
    }

    private func setupBarButtonItem() {
        barButtonItem = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(selectPlayers))
        delegate?.addRightBarButtonItem(barButtonItem)
        barButtonItem.isEnabled = presenter.barButtonItemIsEnabled
    }

    private func setupTableView() {
        playerTableView.tableFooterView = UIView()
    }
    
    private func reloadRow(_ row: Int) {
        let indexPath = IndexPath(row: row, section: 0)
        playerTableView.reloadRows(at: [indexPath], with: .none)
    }
    
    @objc private func selectPlayers() {
        toggleViewState()
    }
    
    @IBAction private func confirmOrAddPlayers(_ sender: Any) {
        delegate?.confirmOrAddPlayers(withSegueIdentifier: presenter.segueIdentifier)
    }
    
}

// MARK: - PlayerListViewProtocol
extension PlayerListView: PlayerListViewProtocol {
    func setupView() {
        setupTitle()
        setupBarButtonItem()
        setupTableView()
        loadPlayers()
    }
    
    func loadPlayers() {
        presenter.loadPlayers()
    }
    
    func setViewInteraction(_ enabled: Bool) {
        isUserInteractionEnabled = enabled
    }
    
    func handleError(title: String, message: String) {
        delegate?.presentAlert(title: title, message: message)
    }
    
    func handleLoadPlayersSuccessfulResponse() {
        if presenter.playersCollectionIsEmpty {
            showEmptyView()
        } else {
            hideEmptyView()
        }

        barButtonItem.isEnabled = presenter.barButtonItemIsEnabled
        playerTableView.reloadData()
    }
    
    func handlePlayerDeletion(forRowAt indexPath: IndexPath) {
        playerTableView.beginUpdates()
        presenter.deleteLocallyPlayer(at: indexPath)
        playerTableView.deleteRows(at: [indexPath], with: .fade)
        playerTableView.endUpdates()

        if presenter.playersCollectionIsEmpty {
            showEmptyView()
        }
    }
    
    func confirmPlayerDeletion() {
        presenter.performPlayerDeleteRequest()
    }
    
    func cancelPlayerDeletion() {
        presenter.cancelPlayerDeletion()
    }
    
    func didEdit(player: PlayerResponseModel) {
        guard let index = presenter.index(of: player) else { return }

        presenter.didEdit(player: player)
        reloadRow(index)
    }
    
    func toggleViewState() {
        presenter.toggleViewState()
        setupTitle()
        barButtonItem.title = presenter.barButtonItemTitle
        bottomActionButton.setTitle(presenter.actionButtonTitle, for: .normal)
        bottomActionButton.isEnabled = presenter.actionButtonIsEnabled
        playerTableView.reloadData()
    }
}

// MARK: - UITableViewDelegate | UITableViewDataSource
extension PlayerListView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfRows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: PlayerTableViewCell = tableView.dequeueReusableCell(withIdentifier: "PlayerTableViewCell") as? PlayerTableViewCell else {
            return UITableViewCell()
        }

        if presenter.isInListViewMode {
            presenter.clearSelectedPlayerIfNeeded(at: indexPath)
            cell.setupDefaultView()
        } else {
            cell.setupSelectionView()
        }

        cell.nameLabel.text = presenter.playerNameDescription(at: indexPath)
        cell.positionLabel.text = presenter.playerPositionDescription(at: indexPath)
        cell.skillLabel.text = presenter.playerSkillDescription(at: indexPath)
        cell.playerIsSelected = presenter.playerIsSelected(at: indexPath)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !presenter.playersCollectionIsEmpty else { return }

        if presenter.isInListViewMode {
            presenter.selectPlayerForDisplayingDetails(at: indexPath)
            navigateToPlayerDetails(forRowAt: indexPath)
        } else {
            toggleCellSelection(at: indexPath)
            updateViewForPlayerSelection()
        }
    }

    private func navigateToPlayerDetails(forRowAt indexPath: IndexPath) {
        presenter.selectPlayer(at: indexPath)
        delegate?.didRequestPlayerDetails()
    }

    private func toggleCellSelection(at indexPath: IndexPath) {
        guard let cell = playerTableView.cellForRow(at: indexPath) as? PlayerTableViewCell else { return }

        cell.playerIsSelected.toggle()
        presenter.updateSelectedPlayers(isSelected: cell.playerIsSelected, at: indexPath)
    }

    private func updateViewForPlayerSelection() {
        delegate?.didRequestToChangeTitle(presenter.selectedPlayersTitle)
        bottomActionButton.isEnabled = presenter.playersCanPlay
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return presenter.isInListViewMode
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }

        presenter.indexPathForDeletion = indexPath
        delegate?.didRequestPlayerDeletion()
    }
}

// MARK: - EmptyViewable
extension PlayerListView: EmptyViewable {
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
        loadPlayers()
    }
}
