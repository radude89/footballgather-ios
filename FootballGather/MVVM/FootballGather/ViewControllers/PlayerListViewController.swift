//
//  PlayerListViewController.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 06/06/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import UIKit

// MARK: - PlayerListTogglable
protocol PlayerListTogglable {
    func toggleViewState()
}

// MARK: - PlayerListViewController
final class PlayerListViewController: UIViewController, Loadable {

    // MARK: - Properties
    @IBOutlet weak var playerTableView: UITableView!
    @IBOutlet weak var bottomActionView: UIView!
    @IBOutlet weak var bottomActionButton: UIButton!

    lazy var loadingView = LoadingView.initToView(self.view)
    private var barButtonItem: UIBarButtonItem!

    lazy var emptyView: EmptyView = {
        let emptyView = EmptyView.initToView(self.view, infoText: "There aren't any players for your user.")
        emptyView.delegate = self
        return emptyView
    }()

    private let viewModel = PlayerListViewModel()

    // MARK: - Setup methods
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViewModel()
        setupTitle()
        setupBarButtonItem()
        setupTableView()
        loadPlayers()
    }

    private func setupViewModel() {
        viewModel.delegate = self
    }
    
    private func setupTitle() {
        title = viewModel.title
    }

    private func setupBarButtonItem() {
        barButtonItem = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(selectPlayers))
        navigationItem.rightBarButtonItem = barButtonItem
    }

    private func setupTableView() {
        playerTableView.tableFooterView = UIView()
    }

    // MARK: - Selectors
    @objc private func selectPlayers() {
        toggleViewState()
    }

    @IBAction private func confirmOrAddPlayers(_ sender: Any) {
        performSegue(withIdentifier: viewModel.segueIdentifier, sender: nil)
    }

    // MARK: - Service methods
    private func loadPlayers() {
        view.isUserInteractionEnabled = false

        viewModel.fetchPlayers { [weak self] error in
            DispatchQueue.main.async {
                self?.view.isUserInteractionEnabled = true

                if let error = error {
                    self?.handleServiceFailures(withError: error)
                } else {
                    self?.handleLoadPlayersSuccessfulResponse()
                }
            }
        }
    }

    private func handleServiceFailures(withError error: Error) {
        AlertHelper.present(in: self, title: "Error", message: String(describing: error))
    }

    private func handleLoadPlayersSuccessfulResponse() {
        if viewModel.playersCollectionIsEmpty {
            showEmptyView()
        } else {
            hideEmptyView()
        }

        playerTableView.reloadData()
    }

    private func requestDeletePlayer(at indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        viewModel.requestDeletePlayer(at: indexPath) { [weak self] error in
            DispatchQueue.main.async {
                self?.hideLoadingView()

                if let error = error {
                    self?.handleServiceFailures(withError: error)
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }

    private func reloadRow(_ row: Int) {
        let indexPath = IndexPath(row: row, section: 0)
        playerTableView.reloadRows(at: [indexPath], with: .none)
    }

    // MARK: - Next screen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case SegueIdentifier.confirmPlayers.rawValue:
            if let confirmPlayersViewController = segue.destination as? ConfirmPlayersViewController {
                confirmPlayersViewController.viewModel = viewModel.makeConfirmPlayersViewModel()
            }

        case SegueIdentifier.playerDetails.rawValue:
            if let playerDetailsViewController = segue.destination as? PlayerDetailViewController, let player = viewModel.selectedPlayerForDetails {
                playerDetailsViewController.delegate = self
                playerDetailsViewController.viewModel = PlayerDetailViewModel(player: player)
            }

        case SegueIdentifier.addPlayer.rawValue:
            (segue.destination as? PlayerAddViewController)?.delegate = self

        default:
            break
        }
    }

}

// MARK: - PlayerDetailViewControllerDelegate
extension PlayerListViewController: PlayerDetailViewControllerDelegate {
    func didEdit(player: PlayerResponseModel) {
        guard let index = viewModel.index(of: player) else { return }

        viewModel.didEdit(player: player)
        reloadRow(index)
    }
}

// MARK: - UITableViewDelegate | UITableViewDataSource
extension PlayerListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: PlayerTableViewCell = tableView.dequeueReusableCell(withIdentifier: "PlayerTableViewCell") as? PlayerTableViewCell else {
            return UITableViewCell()
        }

        if viewModel.isInListViewMode {
            viewModel.clearSelectedPlayerIfNeeded(at: indexPath)
            cell.setupDefaultView()
        } else {
            cell.setupSelectionView()
        }

        cell.nameLabel.text = viewModel.playerNameDescription(at: indexPath)
        cell.positionLabel.text = viewModel.playerPositionDescription(at: indexPath)
        cell.skillLabel.text = viewModel.playerSkillDescription(at: indexPath)
        cell.playerIsSelected = viewModel.playerIsSelected(at: indexPath)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !viewModel.playersCollectionIsEmpty else { return }

        if viewModel.isInListViewMode {
            viewModel.selectPlayerForDisplayingDetails(at: indexPath)
            navigateToPlayerDetails(forRowAt: indexPath)
        } else {
            toggleCellSelection(at: indexPath)
            updateViewForPlayerSelection()
        }
    }

    private func navigateToPlayerDetails(forRowAt indexPath: IndexPath) {
        viewModel.selectPlayer(at: indexPath)
        performSegue(withIdentifier: SegueIdentifier.playerDetails.rawValue, sender: nil)
    }

    private func toggleCellSelection(at indexPath: IndexPath) {
        guard let cell = playerTableView.cellForRow(at: indexPath) as? PlayerTableViewCell else { return }

        cell.playerIsSelected.toggle()
        viewModel.updateSelectedPlayers(isSelected: cell.playerIsSelected, at: indexPath)
    }

    private func updateViewForPlayerSelection() {
        title = viewModel.selectedPlayersTitle
        bottomActionButton.isEnabled = viewModel.playersCanPlay
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return viewModel.isInListViewMode
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }

        let alertController = UIAlertController(title: "Delete player", message: "Are you sure you want to delete the selected player?", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.handleDeletePlayerConfirmation(forRowAt: indexPath)
        }
        alertController.addAction(confirmAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    private func handleDeletePlayerConfirmation(forRowAt indexPath: IndexPath) {
        showLoadingView()
        requestDeletePlayer(at: indexPath) { [weak self] result in
            guard result, let self = self else { return }

            self.playerTableView.beginUpdates()
            self.viewModel.deleteLocallyPlayer(at: indexPath)
            self.playerTableView.deleteRows(at: [indexPath], with: .fade)
            self.playerTableView.endUpdates()

            if self.viewModel.playersCollectionIsEmpty {
                self.showEmptyView()
            }
        }
    }
}

// MARK: - Emptyable conformance
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
        loadPlayers()
    }
}

// MARK: - AddPlayerDelegate
extension PlayerListViewController: AddPlayerDelegate {
    func playerWasAdded() {
        loadPlayers()
    }
}

// MARK: - PlayerListViewModelDelegate
extension PlayerListViewController: PlayerListViewModelDelegate {
    func viewStateDidChange() {
        title = viewModel.title
        barButtonItem.title = viewModel.barButtonItemTitle

        bottomActionButton.setTitle(viewModel.actionButtonTitle, for: .normal)
        bottomActionButton.isEnabled = viewModel.actionButtonIsEnabled

        playerTableView.reloadData()
    }
}

// MARK: - PlayerListToggable
extension PlayerListViewController: PlayerListTogglable {
    func toggleViewState() {
        viewModel.toggleViewState()
        setupTitle()
        barButtonItem.title = viewModel.barButtonItemTitle
        bottomActionButton.setTitle(viewModel.actionButtonTitle, for: .normal)
        bottomActionButton.isEnabled = viewModel.actionButtonIsEnabled
        playerTableView.reloadData()
    }
}
